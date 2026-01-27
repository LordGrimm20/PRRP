// GRIMM MULTICHARACTER - JavaScript
let characters = [];
let maxSlots = 2;
let patreonTier = null;
let nationalities = [];
let spawnLocations = [];
let selectedCharacter = null;
let selectedSpawn = null;
let selectedGender = null;

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    initParticles();
    initGenderSelection();
    initFormSubmit();
});

function initParticles() {
    const container = document.getElementById('particles');
    if (!container) return;
    for (let i = 0; i < 30; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.left = Math.random() * 100 + '%';
        particle.style.animationDelay = Math.random() * 8 + 's';
        particle.style.animationDuration = (5 + Math.random() * 5) + 's';
        container.appendChild(particle);
    }
}

function initGenderSelection() {
    document.querySelectorAll('.gender-option').forEach(option => {
        option.addEventListener('click', () => {
            document.querySelectorAll('.gender-option').forEach(opt => opt.classList.remove('selected'));
            option.classList.add('selected');
            selectedGender = option.dataset.gender;
            fetchNUI('previewGender', { gender: selectedGender });
        });
    });
}

function initFormSubmit() {
    const form = document.getElementById('creationForm');
    if (!form) return;
    
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        if (!selectedGender) {
            showNotification('Please select a gender', 'error');
            return;
        }
        
        const formData = new FormData(form);
        const data = {
            firstName: formData.get('firstName'),
            lastName: formData.get('lastName'),
            dob: formData.get('dob'),
            nationality: formData.get('nationality'),
            gender: selectedGender
        };
        
        showLoading('Creating character...');
        const response = await fetchNUI('createCharacter', data);
        hideLoading();
        
        if (response && response.success) {
            showNotification('Character created!', 'success');
            selectedCharacter = response.citizenid;
            showPage('spawnSelection');
        } else {
            showNotification(response?.message || 'Failed to create character', 'error');
        }
    });
}

// NUI Communication
async function fetchNUI(eventName, data) {
    try {
        const resp = await fetch(`https://grimm-multicharacter/${eventName}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data || {})
        });
        return await resp.json();
    } catch (err) {
        console.error('fetchNUI error:', eventName, err);
        return null;
    }
}

// Listen for messages from Lua
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'show') {
        document.getElementById('app').classList.remove('hidden');
        showPage('characterSelection');
        loadCharacters();
    } else if (data.action === 'hide') {
        document.getElementById('app').classList.add('hidden');
    }
});

// UI Functions
function showPage(pageId) {
    document.querySelectorAll('.page').forEach(page => page.classList.remove('active'));
    const page = document.getElementById(pageId);
    if (page) page.classList.add('active');
}

function showLoading(text) {
    const overlay = document.getElementById('loadingOverlay');
    const loadingText = document.getElementById('loadingText');
    if (loadingText) loadingText.textContent = text || 'Loading...';
    if (overlay) overlay.classList.remove('hidden');
}

function hideLoading() {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) overlay.classList.add('hidden');
}

function showNotification(message, type) {
    const container = document.getElementById('notifications');
    if (!container) return;
    
    const notification = document.createElement('div');
    notification.className = `notification ${type || 'success'}`;
    notification.innerHTML = `<i class="fas fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i><span>${message}</span>`;
    container.appendChild(notification);
    
    setTimeout(() => notification.remove(), 3000);
}

// Character Functions
async function loadCharacters() {
    showLoading('Loading characters...');
    
    const response = await fetchNUI('getCharacters', {});
    
    hideLoading();
    
    if (response) {
        characters = response.characters || [];
        maxSlots = response.maxSlots || 2;
        patreonTier = response.patreonTier || null;
        nationalities = response.nationalities || [];
        spawnLocations = response.spawnLocations || [];
        
        console.log('Loaded:', characters.length, 'characters,', nationalities.length, 'nationalities');
        
        renderCharacters();
        renderSpawnLocations();
        populateNationalities();
        updateSlotInfo();
    } else {
        console.error('Failed to load characters');
    }
}

function renderCharacters() {
    const grid = document.getElementById('characterGrid');
    if (!grid) return;
    grid.innerHTML = '';
    
    // Existing characters
    characters.forEach((char) => {
        const card = document.createElement('div');
        card.className = 'character-card';
        card.dataset.citizenid = char.citizenid;
        
        const genderClass = char.gender == 0 ? 'male' : 'female';
        const genderIcon = char.gender == 0 ? 'mars' : 'venus';
        
        card.innerHTML = `
            <div class="card-content">
                <div class="avatar ${genderClass}"><i class="fas fa-${genderIcon}"></i></div>
                <h3 class="char-name">${char.firstname} ${char.lastname}</h3>
                <p class="char-info">${char.job || 'Unemployed'}</p>
            </div>
        `;
        
        card.addEventListener('click', () => selectCharacter(char, card));
        grid.appendChild(card);
    });
    
    // Empty slots
    for (let i = characters.length; i < maxSlots; i++) {
        const card = document.createElement('div');
        card.className = 'character-card empty';
        card.innerHTML = `
            <div class="card-content">
                <div class="add-icon"><i class="fas fa-plus"></i></div>
                <span>Create Character</span>
            </div>
        `;
        card.addEventListener('click', openCharacterCreation);
        grid.appendChild(card);
    }
    
    updateActionButtons();
}

async function selectCharacter(char, cardElement) {
    document.querySelectorAll('.character-card').forEach(c => c.classList.remove('selected'));
    cardElement.classList.add('selected');
    selectedCharacter = char.citizenid;
    
    // Update preview info
    const previewInfo = document.getElementById('previewInfo');
    if (previewInfo) {
        document.getElementById('previewName').textContent = `${char.firstname} ${char.lastname}`;
        document.getElementById('previewDob').textContent = char.birthdate || 'Unknown';
        document.getElementById('previewNationality').textContent = char.nationality || 'Unknown';
        document.getElementById('previewJob').textContent = char.job || 'Unemployed';
        document.getElementById('previewCash').textContent = formatMoney(char.cash);
        document.getElementById('previewBank').textContent = formatMoney(char.bank);
        previewInfo.classList.remove('hidden');
    }
    
    await fetchNUI('selectCharacter', { citizenid: char.citizenid });
    updateActionButtons();
}

function openCharacterCreation() {
    if (characters.length >= maxSlots) {
        showNotification('Maximum characters reached', 'error');
        return;
    }
    
    const form = document.getElementById('creationForm');
    if (form) form.reset();
    document.querySelectorAll('.gender-option').forEach(opt => opt.classList.remove('selected'));
    selectedGender = null;
    
    populateNationalities();
    showPage('characterCreation');
}

function cancelCreation() {
    showPage('characterSelection');
}

function openSpawnSelection() {
    if (!selectedCharacter) {
        showNotification('Select a character first', 'error');
        return;
    }
    selectedSpawn = 'last_location';
    renderSpawnLocations();
    showPage('spawnSelection');
}

function backToSelection() {
    showPage('characterSelection');
}

// Spawn Functions
function renderSpawnLocations() {
    const grid = document.getElementById('spawnGrid');
    if (!grid) return;
    grid.innerHTML = '';
    
    spawnLocations.forEach(loc => {
        const card = document.createElement('div');
        card.className = 'spawn-card' + (selectedSpawn === loc.id ? ' selected' : '');
        card.innerHTML = `
            <div class="spawn-icon"><i class="fas fa-${loc.icon || 'location-dot'}"></i></div>
            <h3 class="spawn-name">${loc.label}</h3>
            <p class="spawn-desc">${loc.description || ''}</p>
        `;
        card.addEventListener('click', () => {
            document.querySelectorAll('.spawn-card').forEach(c => c.classList.remove('selected'));
            card.classList.add('selected');
            selectedSpawn = loc.id;
        });
        grid.appendChild(card);
    });
}

async function spawnCharacter() {
    if (!selectedCharacter || !selectedSpawn) {
        showNotification('Select a spawn location', 'error');
        return;
    }
    
    showLoading('Spawning...');
    await fetchNUI('spawnCharacter', { citizenid: selectedCharacter, spawnId: selectedSpawn });
}

// Delete Functions
function confirmDelete() {
    if (!selectedCharacter) {
        showNotification('Select a character first', 'error');
        return;
    }
    
    const char = characters.find(c => c.citizenid === selectedCharacter);
    if (char) {
        document.getElementById('deleteCharName').textContent = `${char.firstname} ${char.lastname}`;
    }
    document.getElementById('deleteModal').classList.remove('hidden');
}

function closeDeleteModal() {
    document.getElementById('deleteModal').classList.add('hidden');
}

async function deleteCharacter() {
    if (!selectedCharacter) return;
    
    closeDeleteModal();
    showLoading('Deleting...');
    
    const response = await fetchNUI('deleteCharacter', { citizenid: selectedCharacter });
    hideLoading();
    
    if (response && response.success) {
        showNotification('Character deleted', 'success');
        selectedCharacter = null;
        document.getElementById('previewInfo')?.classList.add('hidden');
        loadCharacters();
    } else {
        showNotification('Failed to delete', 'error');
    }
}

// Utility Functions
function rotateCharacter(direction) {
    fetchNUI('rotateCharacter', { direction: direction });
}

function populateNationalities() {
    const select = document.getElementById('nationality');
    if (!select) return;
    
    select.innerHTML = '<option value="">Select nationality...</option>';
    
    if (nationalities && nationalities.length > 0) {
        nationalities.forEach(nat => {
            const option = document.createElement('option');
            option.value = nat;
            option.textContent = nat;
            select.appendChild(option);
        });
        console.log('Populated', nationalities.length, 'nationalities');
    }
}

function updateSlotInfo() {
    const usedEl = document.getElementById('usedSlots');
    const maxEl = document.getElementById('maxSlots');
    const badge = document.getElementById('patreonBadge');
    
    if (usedEl) usedEl.textContent = characters.length;
    if (maxEl) maxEl.textContent = maxSlots;
    
    if (badge) {
        if (patreonTier) {
            badge.textContent = patreonTier;
            badge.classList.remove('hidden');
        } else {
            badge.classList.add('hidden');
        }
    }
}

function updateActionButtons() {
    const deleteBtn = document.getElementById('deleteBtn');
    const playBtn = document.getElementById('playBtn');
    
    if (deleteBtn) deleteBtn.disabled = !selectedCharacter;
    if (playBtn) playBtn.disabled = !selectedCharacter;
}

function formatMoney(amount) {
    return (parseInt(amount) || 0).toLocaleString('en-US');
}

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const modal = document.getElementById('deleteModal');
        if (modal && !modal.classList.contains('hidden')) {
            closeDeleteModal();
            return;
        }
        
        const activePage = document.querySelector('.page.active');
        if (activePage && (activePage.id === 'characterCreation' || activePage.id === 'spawnSelection')) {
            showPage('characterSelection');
        }
    }
});
