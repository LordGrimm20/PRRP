// GRIMM APPEARANCE - JavaScript
let appearanceData = {};
let currentAppearance = {};
let categories = {};
let selectedCategory = null;
let outfitsCache = [];

const app = document.getElementById('app');
const categoryNav = document.getElementById('categoryNav');
const optionsContent = document.getElementById('optionsContent');
const optionsTitle = document.getElementById('optionsTitle');

// Debug logging
function debug(msg, data) {
    console.log('[grimm-appearance] ' + msg, data || '');
}

window.addEventListener('message', (event) => {
    const data = event.data;
    debug('Message received:', data.action);
    
    if (data.action === 'show') {
        appearanceData = data.data || {};
        currentAppearance = data.appearance || {};
        categories = data.categories || {};
        debug('Data loaded - categories:', Object.keys(categories));
        debug('Max drawables:', appearanceData.maxDrawables);
        app.classList.remove('hidden');
        renderCategories();
    } else if (data.action === 'hide') {
        app.classList.add('hidden');
    }
});

async function fetchNUI(eventName, data = {}) {
    debug('fetchNUI:', eventName, data);
    try {
        const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'grimm-appearance';
        const response = await fetch(`https://${resourceName}/${eventName}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await response.json();
        debug('fetchNUI response:', result);
        return result;
    } catch (error) {
        debug('fetchNUI error:', error);
        return { success: false };
    }
}

function renderCategories() {
    categoryNav.innerHTML = '';
    const groups = {
        appearance: ['inheritance', 'face', 'skin', 'hair', 'beard', 'eyebrows', 'makeup'],
        clothing: ['tops', 'arms', 'undershirt', 'pants', 'shoes', 'accessories', 'armor', 'bags', 'masks'],
        accessories: ['hats', 'glasses', 'ears', 'watches', 'bracelets'],
        outfits: ['outfits']
    };
    
    // Add outfits category to categories if not present
    if (!categories.outfits) {
        categories.outfits = { enabled: true, label: 'Outfits', icon: 'bookmark' };
    }
    
    // Add arms category if not present
    if (!categories.arms) {
        categories.arms = { enabled: true, label: 'Arms', icon: 'hand' };
    }
    
    for (const [groupName, cats] of Object.entries(groups)) {
        const label = document.createElement('div');
        label.style.cssText = 'padding:10px 15px;font-size:10px;color:#5eead4;text-transform:uppercase;letter-spacing:2px;margin-top:10px;';
        label.textContent = groupName;
        categoryNav.appendChild(label);
        
        cats.forEach(catId => {
            const cat = categories[catId];
            if (cat && cat.enabled) {
                const btn = document.createElement('button');
                btn.className = 'category-btn';
                btn.innerHTML = `<i class="fas fa-${cat.icon || 'circle'}"></i><span>${cat.label}</span>`;
                btn.onclick = () => selectCategory(catId, btn);
                categoryNav.appendChild(btn);
            }
        });
    }
}

function selectCategory(categoryId, btnElement) {
    debug('selectCategory:', categoryId);
    document.querySelectorAll('.category-btn').forEach(btn => btn.classList.remove('active'));
    btnElement.classList.add('active');
    selectedCategory = categoryId;
    optionsTitle.textContent = categories[categoryId]?.label || categoryId;
    renderCategoryOptions(categoryId);
    
    // Camera zones
    let zone = 'body';
    if (['inheritance', 'face', 'hair', 'beard', 'eyebrows', 'makeup', 'skin'].includes(categoryId)) {
        zone = 'face';
    } else if (['shoes'].includes(categoryId)) {
        zone = 'feet';
    } else if (['pants'].includes(categoryId)) {
        zone = 'legs';
    }
    fetchNUI('setCamera', { zone: zone });
}

function renderCategoryOptions(categoryId) {
    optionsContent.innerHTML = '';
    
    switch(categoryId) {
        case 'inheritance': renderInheritanceOptions(); break;
        case 'face': renderFaceOptions(); break;
        case 'skin': renderSkinOptions(); break;
        case 'hair': renderHairOptions(); break;
        case 'beard': renderOverlayOptions(1, 'Facial Hair', true); break;
        case 'eyebrows': renderOverlayOptions(2, 'Eyebrows', true); break;
        case 'makeup': renderMakeupOptions(); break;
        case 'tops': renderComponentOptions(11, 'Tops'); break;
        case 'arms': renderComponentOptions(3, 'Arms'); break;
        case 'undershirt': renderComponentOptions(8, 'Undershirt'); break;
        case 'pants': renderComponentOptions(4, 'Pants'); break;
        case 'shoes': renderComponentOptions(6, 'Shoes'); break;
        case 'accessories': renderComponentOptions(7, 'Accessories'); break;
        case 'armor': renderComponentOptions(9, 'Body Armor'); break;
        case 'bags': renderComponentOptions(5, 'Bags'); break;
        case 'masks': renderComponentOptions(1, 'Masks'); break;
        case 'hats': renderPropOptions(0, 'Hats'); break;
        case 'glasses': renderPropOptions(1, 'Glasses'); break;
        case 'ears': renderPropOptions(2, 'Earrings'); break;
        case 'watches': renderPropOptions(6, 'Watches'); break;
        case 'bracelets': renderPropOptions(7, 'Bracelets'); break;
        case 'outfits': renderOutfitsOptions(); break;
        default:
            optionsContent.innerHTML = '<div style="padding:40px;text-align:center;color:#94a3b8;">Select a category</div>';
    }
}

function renderInheritanceOptions() {
    const parents = appearanceData.parents || [];
    const parentsOpp = appearanceData.parentsOpposite || [];
    const hb = currentAppearance.headBlend || {};
    
    optionsContent.innerHTML = `
        <div class="option-group">
            <label>Father</label>
            <select id="father" onchange="updateHeadBlend()">
                ${parents.map(p => `<option value="${p.id}" ${hb.shapeFirst == p.id ? 'selected' : ''}>${p.name}</option>`).join('')}
            </select>
        </div>
        <div class="option-group">
            <label>Mother</label>
            <select id="mother" onchange="updateHeadBlend()">
                ${parentsOpp.map(p => `<option value="${p.id}" ${hb.shapeSecond == p.id ? 'selected' : ''}>${p.name}</option>`).join('')}
            </select>
        </div>
        <div class="option-group">
            <label>Resemblance</label>
            <div class="slider-container">
                <input type="range" id="shapeMix" min="0" max="100" value="${Math.round((hb.shapeMix || 0.5) * 100)}" oninput="updateHeadBlend(); this.nextElementSibling.textContent = this.value + '%'">
                <span class="slider-value">${Math.round((hb.shapeMix || 0.5) * 100)}%</span>
            </div>
        </div>
        <div class="option-group">
            <label>Skin Tone</label>
            <div class="slider-container">
                <input type="range" id="skinMix" min="0" max="100" value="${Math.round((hb.skinMix || 0.5) * 100)}" oninput="updateHeadBlend(); this.nextElementSibling.textContent = this.value + '%'">
                <span class="slider-value">${Math.round((hb.skinMix || 0.5) * 100)}%</span>
            </div>
        </div>
    `;
}

function renderFaceOptions() {
    const features = appearanceData.faceFeatures || [];
    const current = currentAppearance.faceFeatures || {};
    
    let html = '';
    features.forEach(f => {
        const val = current[f.id] || 0;
        html += `
            <div class="option-group">
                <label>${f.label}</label>
                <div class="slider-container">
                    <input type="range" min="-100" max="100" value="${Math.round(val * 100)}" oninput="updateFaceFeature(${f.id}, this.value / 100); this.nextElementSibling.textContent = this.value">
                    <span class="slider-value">${Math.round(val * 100)}</span>
                </div>
            </div>
        `;
    });
    optionsContent.innerHTML = html || '<div style="padding:20px;color:#94a3b8;">No face features available</div>';
}

function renderSkinOptions() {
    const eyeColors = appearanceData.eyeColors || [];
    const currentEye = currentAppearance.eyeColor || 0;
    
    let html = `
        <div class="option-group">
            <label>Eye Color</label>
            <select id="eyeColor" onchange="updateEyeColor()">
                ${eyeColors.map((c, i) => `<option value="${i}" ${currentEye == i ? 'selected' : ''}>${typeof c === 'object' ? (c.name || c.label || i) : c}</option>`).join('')}
            </select>
        </div>
    `;
    
    // Blemishes (overlay 0)
    html += renderOverlayHTML(0, 'Blemishes', false);
    // Ageing (overlay 3)
    html += renderOverlayHTML(3, 'Ageing', false);
    // Complexion (overlay 6)
    html += renderOverlayHTML(6, 'Complexion', false);
    // Moles/Freckles (overlay 9)
    html += renderOverlayHTML(9, 'Moles/Freckles', false);
    // Sun Damage (overlay 7)
    html += renderOverlayHTML(7, 'Sun Damage', false);
    
    optionsContent.innerHTML = html;
}

function renderHairOptions() {
    const hair = currentAppearance.hair || { style: 0, texture: 0, color: 0, highlight: 0 };
    const maxHair = appearanceData.maxDrawables?.[2]?.drawable || 50;
    const hairColors = appearanceData.hairColors || [];
    
    optionsContent.innerHTML = `
        <div class="option-group">
            <label>Hair Style (Max: ${maxHair})</label>
            <div class="stepper">
                <button onclick="stepHair(-1)">-</button>
                <span id="hairStyle">${hair.style || 0}</span>
                <button onclick="stepHair(1)">+</button>
            </div>
        </div>
        <div class="option-group">
            <label>Hair Color</label>
            <select id="hairColor" onchange="updateHair()">
                ${hairColors.map((c, i) => `<option value="${i}" ${hair.color == i ? 'selected' : ''}>${typeof c === 'object' ? c.name || c.label : c}</option>`).join('')}
            </select>
        </div>
        <div class="option-group">
            <label>Hair Highlight</label>
            <select id="hairHighlight" onchange="updateHair()">
                ${hairColors.map((c, i) => `<option value="${i}" ${hair.highlight == i ? 'selected' : ''}>${typeof c === 'object' ? c.name || c.label : c}</option>`).join('')}
            </select>
        </div>
    `;
}

function renderOverlayHTML(overlayId, label, showColor) {
    const overlay = (currentAppearance.headOverlays || {})[overlayId] || { style: 0, opacity: 1.0, color: 0 };
    const hairColors = appearanceData.hairColors || [];
    
    let html = `
        <div class="option-group">
            <label>${label} Style</label>
            <div class="stepper">
                <button onclick="stepOverlay(${overlayId}, -1)">-</button>
                <span id="overlay_${overlayId}">${overlay.style || 0}</span>
                <button onclick="stepOverlay(${overlayId}, 1)">+</button>
            </div>
        </div>
        <div class="option-group">
            <label>${label} Opacity</label>
            <div class="slider-container">
                <input type="range" min="0" max="100" value="${Math.round((overlay.opacity || 1) * 100)}" oninput="updateOverlayOpacity(${overlayId}, this.value / 100); this.nextElementSibling.textContent = this.value + '%'">
                <span class="slider-value">${Math.round((overlay.opacity || 1) * 100)}%</span>
            </div>
        </div>
    `;
    
    if (showColor) {
        html += `
            <div class="option-group">
                <label>${label} Color</label>
                <select onchange="updateOverlayColor(${overlayId}, this.value)">
                    ${hairColors.map((c, i) => `<option value="${i}" ${overlay.color == i ? 'selected' : ''}>${typeof c === 'object' ? c.name || c.label : c}</option>`).join('')}
                </select>
            </div>
        `;
    }
    
    return html;
}

function renderOverlayOptions(overlayId, label, showColor) {
    optionsContent.innerHTML = renderOverlayHTML(overlayId, label, showColor);
}

function renderMakeupOptions() {
    let html = '';
    // Makeup (overlay 4)
    html += renderOverlayHTML(4, 'Makeup', true);
    // Blush (overlay 5)
    html += renderOverlayHTML(5, 'Blush', true);
    // Lipstick (overlay 8)
    html += renderOverlayHTML(8, 'Lipstick', true);
    // Chest Hair (overlay 10)
    html += renderOverlayHTML(10, 'Chest Hair', true);
    
    optionsContent.innerHTML = html;
}

function renderComponentOptions(compId, label) {
    const comp = (currentAppearance.components || {})[compId] || { drawable: 0, texture: 0 };
    const maxDrawable = appearanceData.maxDrawables?.[compId]?.drawable || 100;
    
    optionsContent.innerHTML = `
        <div class="option-group">
            <label>${label} Style (Max: ${maxDrawable})</label>
            <div class="stepper">
                <button onclick="stepComponent(${compId}, 'drawable', -1)">-</button>
                <span id="comp_${compId}_drawable">${comp.drawable || 0}</span>
                <button onclick="stepComponent(${compId}, 'drawable', 1)">+</button>
            </div>
        </div>
        <div class="option-group">
            <label>Texture</label>
            <div class="stepper">
                <button onclick="stepComponent(${compId}, 'texture', -1)">-</button>
                <span id="comp_${compId}_texture">${comp.texture || 0}</span>
                <button onclick="stepComponent(${compId}, 'texture', 1)">+</button>
            </div>
        </div>
    `;
}

function renderPropOptions(propId, label) {
    const prop = (currentAppearance.props || {})[propId] || { drawable: -1, texture: 0 };
    const maxDrawable = appearanceData.maxProps?.[propId]?.drawable || 50;
    
    optionsContent.innerHTML = `
        <div class="option-group">
            <label>${label} Style (-1 = None, Max: ${maxDrawable})</label>
            <div class="stepper">
                <button onclick="stepProp(${propId}, 'drawable', -1)">-</button>
                <span id="prop_${propId}_drawable">${prop.drawable ?? -1}</span>
                <button onclick="stepProp(${propId}, 'drawable', 1)">+</button>
            </div>
        </div>
        <div class="option-group">
            <label>Texture</label>
            <div class="stepper">
                <button onclick="stepProp(${propId}, 'texture', -1)">-</button>
                <span id="prop_${propId}_texture">${prop.texture || 0}</span>
                <button onclick="stepProp(${propId}, 'texture', 1)">+</button>
            </div>
        </div>
        <div class="option-group">
            <button class="btn btn-secondary" onclick="removeProp(${propId})" style="width:100%;">Remove ${label}</button>
        </div>
    `;
}

// === OUTFITS ===
async function renderOutfitsOptions() {
    optionsContent.innerHTML = '<div style="padding:20px;text-align:center;color:#94a3b8;">Loading outfits...</div>';
    
    const response = await fetchNUI('getOutfits');
    outfitsCache = response?.outfits || [];
    
    let html = `
        <div class="option-group">
            <label>Save Current Outfit</label>
            <div style="display:flex;gap:10px;">
                <input type="text" id="outfitName" placeholder="Outfit name..." style="flex:1;padding:10px;background:rgba(20,50,45,0.9);border:1px solid #0d9488;border-radius:8px;color:#e2e8f0;outline:none;">
                <button class="btn btn-primary" onclick="saveOutfit()" style="padding:10px 15px;"><i class="fas fa-save"></i></button>
            </div>
        </div>
        <div class="option-group">
            <label>Saved Outfits (${outfitsCache.length})</label>
    `;
    
    if (outfitsCache.length === 0) {
        html += '<div style="padding:15px;text-align:center;color:#94a3b8;">No saved outfits</div>';
    } else {
        html += '<div class="outfits-list">';
        outfitsCache.forEach(outfit => {
            html += `
                <div class="outfit-item" style="display:flex;align-items:center;justify-content:space-between;padding:12px;background:rgba(20,50,45,0.9);border-radius:8px;margin-bottom:8px;">
                    <span style="color:#e2e8f0;">${outfit.name}</span>
                    <div style="display:flex;gap:5px;">
                        <button onclick="loadOutfit(${outfit.id})" style="padding:8px 12px;background:#2dd4bf;border:none;border-radius:4px;color:#0a1f1c;cursor:pointer;"><i class="fas fa-check"></i></button>
                        <button onclick="deleteOutfit(${outfit.id})" style="padding:8px 12px;background:#ef4444;border:none;border-radius:4px;color:white;cursor:pointer;"><i class="fas fa-trash"></i></button>
                    </div>
                </div>
            `;
        });
        html += '</div>';
    }
    
    html += '</div>';
    optionsContent.innerHTML = html;
}

async function saveOutfit() {
    const nameInput = document.getElementById('outfitName');
    const name = nameInput?.value?.trim();
    
    if (!name) {
        alert('Please enter an outfit name');
        return;
    }
    
    await fetchNUI('saveOutfit', { name: name });
    nameInput.value = '';
    renderOutfitsOptions(); // Refresh list
}

async function loadOutfit(id) {
    await fetchNUI('loadOutfit', { id: id });
}

async function deleteOutfit(id) {
    if (confirm('Are you sure you want to delete this outfit?')) {
        await fetchNUI('deleteOutfit', { id: id });
        renderOutfitsOptions(); // Refresh list
    }
}

// === UPDATE FUNCTIONS ===

function updateHeadBlend() {
    const father = parseInt(document.getElementById('father')?.value) || 0;
    const mother = parseInt(document.getElementById('mother')?.value) || 0;
    const shapeMix = (parseInt(document.getElementById('shapeMix')?.value) || 50) / 100;
    const skinMix = (parseInt(document.getElementById('skinMix')?.value) || 50) / 100;
    
    const hb = {
        shapeFirst: father,
        shapeSecond: mother,
        skinFirst: father,
        skinSecond: mother,
        shapeMix: shapeMix,
        skinMix: skinMix
    };
    
    debug('updateHeadBlend:', hb);
    currentAppearance.headBlend = hb;
    fetchNUI('updateAppearance', { category: 'headBlend', value: hb });
}

function updateFaceFeature(id, value) {
    debug('updateFaceFeature:', { id, value });
    currentAppearance.faceFeatures = currentAppearance.faceFeatures || {};
    currentAppearance.faceFeatures[id] = value;
    fetchNUI('updateAppearance', { category: 'faceFeature', id: id, value: value });
}

function updateEyeColor() {
    const color = parseInt(document.getElementById('eyeColor')?.value) || 0;
    debug('updateEyeColor:', color);
    currentAppearance.eyeColor = color;
    fetchNUI('updateAppearance', { category: 'eyeColor', value: color });
}

function stepHair(dir) {
    currentAppearance.hair = currentAppearance.hair || { style: 0, texture: 0, color: 0, highlight: 0 };
    const max = appearanceData.maxDrawables?.[2]?.drawable || 50;
    currentAppearance.hair.style = Math.max(0, Math.min(max, (currentAppearance.hair.style || 0) + dir));
    document.getElementById('hairStyle').textContent = currentAppearance.hair.style;
    debug('stepHair:', currentAppearance.hair);
    fetchNUI('updateAppearance', { category: 'hair', value: currentAppearance.hair });
}

function updateHair() {
    currentAppearance.hair = currentAppearance.hair || { style: 0, texture: 0, color: 0, highlight: 0 };
    currentAppearance.hair.color = parseInt(document.getElementById('hairColor')?.value) || 0;
    currentAppearance.hair.highlight = parseInt(document.getElementById('hairHighlight')?.value) || 0;
    debug('updateHair:', currentAppearance.hair);
    fetchNUI('updateAppearance', { category: 'hair', value: currentAppearance.hair });
}

function stepOverlay(overlayId, dir) {
    currentAppearance.headOverlays = currentAppearance.headOverlays || {};
    currentAppearance.headOverlays[overlayId] = currentAppearance.headOverlays[overlayId] || { style: 0, opacity: 1, color: 0 };
    currentAppearance.headOverlays[overlayId].style = Math.max(0, (currentAppearance.headOverlays[overlayId].style || 0) + dir);
    
    const el = document.getElementById(`overlay_${overlayId}`);
    if (el) el.textContent = currentAppearance.headOverlays[overlayId].style;
    
    debug('stepOverlay:', { overlayId, overlay: currentAppearance.headOverlays[overlayId] });
    fetchNUI('updateAppearance', { category: 'headOverlay', id: overlayId, value: currentAppearance.headOverlays[overlayId] });
}

function updateOverlayOpacity(overlayId, opacity) {
    currentAppearance.headOverlays = currentAppearance.headOverlays || {};
    currentAppearance.headOverlays[overlayId] = currentAppearance.headOverlays[overlayId] || { style: 0, opacity: 1, color: 0 };
    currentAppearance.headOverlays[overlayId].opacity = opacity;
    debug('updateOverlayOpacity:', { overlayId, opacity });
    fetchNUI('updateAppearance', { category: 'headOverlay', id: overlayId, value: currentAppearance.headOverlays[overlayId] });
}

function updateOverlayColor(overlayId, color) {
    currentAppearance.headOverlays = currentAppearance.headOverlays || {};
    currentAppearance.headOverlays[overlayId] = currentAppearance.headOverlays[overlayId] || { style: 0, opacity: 1, color: 0 };
    currentAppearance.headOverlays[overlayId].color = parseInt(color) || 0;
    debug('updateOverlayColor:', { overlayId, color });
    fetchNUI('updateAppearance', { category: 'headOverlay', id: overlayId, value: currentAppearance.headOverlays[overlayId] });
}

function stepComponent(compId, prop, dir) {
    currentAppearance.components = currentAppearance.components || {};
    currentAppearance.components[compId] = currentAppearance.components[compId] || { drawable: 0, texture: 0, palette: 0 };
    
    const maxVal = prop === 'drawable' 
        ? (appearanceData.maxDrawables?.[compId]?.drawable || 100)
        : 20;
    
    currentAppearance.components[compId][prop] = Math.max(0, Math.min(maxVal, (currentAppearance.components[compId][prop] || 0) + dir));
    
    const el = document.getElementById(`comp_${compId}_${prop}`);
    if (el) el.textContent = currentAppearance.components[compId][prop];
    
    debug('stepComponent:', { compId, prop, component: currentAppearance.components[compId] });
    fetchNUI('updateAppearance', { category: 'component', id: compId, value: currentAppearance.components[compId] });
}

function stepProp(propId, prop, dir) {
    currentAppearance.props = currentAppearance.props || {};
    currentAppearance.props[propId] = currentAppearance.props[propId] || { drawable: -1, texture: 0 };
    
    const maxVal = prop === 'drawable' ? (appearanceData.maxProps?.[propId]?.drawable || 50) : 20;
    currentAppearance.props[propId][prop] = Math.max(-1, Math.min(maxVal, (currentAppearance.props[propId][prop] ?? -1) + dir));
    
    const el = document.getElementById(`prop_${propId}_${prop}`);
    if (el) el.textContent = currentAppearance.props[propId][prop];
    
    debug('stepProp:', { propId, prop, propData: currentAppearance.props[propId] });
    fetchNUI('updateAppearance', { category: 'prop', id: propId, value: currentAppearance.props[propId] });
}

function removeProp(propId) {
    currentAppearance.props = currentAppearance.props || {};
    currentAppearance.props[propId] = { drawable: -1, texture: 0 };
    
    const el = document.getElementById(`prop_${propId}_drawable`);
    if (el) el.textContent = -1;
    
    debug('removeProp:', propId);
    fetchNUI('updateAppearance', { category: 'prop', id: propId, value: currentAppearance.props[propId] });
}

// === CAMERA & CONTROLS ===

function setCamera(zone) {
    debug('setCamera:', zone);
    fetchNUI('setCamera', { zone: zone });
}

function rotateCharacter(direction) {
    fetchNUI('rotateCharacter', { direction: direction });
}

function saveChanges() { 
    debug('saveChanges');
    fetchNUI('close', { save: true }); 
}

function cancelChanges() { 
    debug('cancelChanges');
    fetchNUI('close', { save: false }); 
}

// Keyboard
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') cancelChanges();
});

debug('app.js loaded');
