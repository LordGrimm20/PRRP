/*
    GRIMM-HUD | JavaScript Application
    Project Roots RP - Custom HUD
    
    Handles NUI communication and UI updates
*/

// ═══════════════════════════════════════════════════════════════════════════
// STATE & CONFIG
// ═══════════════════════════════════════════════════════════════════════════

let config = null;
let isVisible = false;
let statusValues = {
    health: 100,
    armor: 0,
    hunger: 100,
    thirst: 100,
    stress: 0,
    oxygen: 100
};

// ═══════════════════════════════════════════════════════════════════════════
// DOM ELEMENTS
// ═══════════════════════════════════════════════════════════════════════════

const elements = {
    container: document.getElementById('hud-container'),
    statusRing: document.getElementById('status-ring'),
    statusArcs: document.getElementById('status-arcs'),
    voiceIndicator: document.getElementById('voice-indicator'),
    mediaPlayer: document.getElementById('media-player'),
    statusIcons: document.getElementById('status-icons'),
    playerId: document.getElementById('player-id'),
    infoPanel: document.getElementById('info-panel'),
    timeDisplay: document.getElementById('time-display'),
    weatherIcon: document.getElementById('weather-icon'),
    locationZone: document.getElementById('location-zone'),
    locationStreet: document.getElementById('location-street'),
    compass: document.getElementById('compass'),
    compassArrow: document.querySelector('.compass-arrow'),
    compassCardinal: document.getElementById('compass-cardinal'),
    compassDegrees: document.getElementById('compass-degrees'),
    vehicleHud: document.getElementById('vehicle-hud'),
    speedValue: document.getElementById('speed-value'),
    speedUnit: document.getElementById('speed-unit'),
    rpmBar: document.getElementById('rpm-bar'),
    fuelBar: document.getElementById('fuel-bar'),
    fuelValue: document.getElementById('fuel-value'),
    gearIndicator: document.getElementById('gear-indicator'),
    seatbeltIndicator: document.getElementById('seatbelt-indicator'),
    lightsIndicator: document.getElementById('lights-indicator'),
    engineIndicator: document.getElementById('engine-indicator'),
    statusEffects: document.getElementById('status-effects'),
    cinematicBars: document.getElementById('cinematic-bars'),
    damageFlash: document.getElementById('damage-flash'),
    mediaThumb: document.getElementById('media-thumb'),
    mediaTitleText: document.getElementById('media-title-text'),
    mediaArtist: document.getElementById('media-artist'),
    mediaProgress: document.getElementById('media-progress')
};

// ═══════════════════════════════════════════════════════════════════════════
// STATUS RING (SVG Arc Generation)
// ═══════════════════════════════════════════════════════════════════════════

const statusOrder = ['health', 'armor', 'thirst', 'hunger', 'stress', 'oxygen'];
const statusArcs = {};

function createStatusArcs() {
    elements.statusArcs.innerHTML = '';
    
    const radius = 90;
    const circumference = 2 * Math.PI * radius;
    const segmentCount = statusOrder.length;
    const gapAngle = 8; // Gap in degrees between segments
    const totalGapAngle = gapAngle * segmentCount;
    const availableAngle = 360 - totalGapAngle;
    const segmentAngle = availableAngle / segmentCount;
    
    let currentAngle = gapAngle / 2;
    
    statusOrder.forEach((status, index) => {
        const startAngle = currentAngle;
        const endAngle = currentAngle + segmentAngle;
        
        // Calculate arc length
        const arcLength = (segmentAngle / 360) * circumference;
        
        // Create arc element
        const arc = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        arc.classList.add('status-arc', status);
        arc.setAttribute('cx', '100');
        arc.setAttribute('cy', '100');
        arc.setAttribute('r', radius.toString());
        arc.setAttribute('fill', 'none');
        arc.setAttribute('stroke-dasharray', `${arcLength} ${circumference}`);
        arc.setAttribute('stroke-dashoffset', '0');
        arc.style.transformOrigin = 'center';
        arc.style.transform = `rotate(${startAngle}deg)`;
        
        // Store reference
        statusArcs[status] = {
            element: arc,
            arcLength: arcLength,
            circumference: circumference
        };
        
        elements.statusArcs.appendChild(arc);
        
        currentAngle = endAngle + gapAngle;
    });
}

function updateStatusArc(status, value) {
    if (!statusArcs[status]) return;
    
    const arc = statusArcs[status];
    const percentage = Math.max(0, Math.min(100, value)) / 100;
    const visibleLength = arc.arcLength * percentage;
    const offset = arc.arcLength - visibleLength;
    
    arc.element.setAttribute('stroke-dashoffset', offset.toString());
    
    // Add/remove warning class
    if (config && config.statusRing && config.statusRing.warnings) {
        if (value <= config.statusRing.warnings.threshold && status !== 'stress') {
            arc.element.classList.add('warning');
        } else {
            arc.element.classList.remove('warning');
        }
    }
}

function updateAllStatusArcs() {
    Object.keys(statusValues).forEach(status => {
        updateStatusArc(status, statusValues[status]);
    });
}

// ═══════════════════════════════════════════════════════════════════════════
// NUI MESSAGE HANDLER
// ═══════════════════════════════════════════════════════════════════════════

window.addEventListener('message', (event) => {
    const { action, data } = event.data;
    
    switch (action) {
        case 'init':
            initializeHud(data);
            break;
            
        case 'toggleVisibility':
            toggleVisibility(data.visible);
            break;
            
        case 'updateStatus':
            updateStatus(data);
            break;
            
        case 'updateSingleStatus':
            updateSingleStatus(data.type, data.value);
            break;
            
        case 'updateMoney':
            updateMoney(data);
            break;
            
        case 'moneyChange':
            animateMoneyChange(data);
            break;
            
        case 'updateLocation':
            updateLocation(data);
            break;
            
        case 'updateTime':
            updateTime(data);
            break;
            
        case 'updateCompass':
            updateCompass(data);
            break;
            
        case 'updateVoice':
            updateVoice(data);
            break;
            
        case 'updateMedia':
            updateMedia(data);
            break;
            
        case 'updateMediaProgress':
            updateMediaProgress(data);
            break;
            
        case 'updateVehicle':
            updateVehicle(data);
            break;
            
        case 'setVehicleState':
            setVehicleState(data.inVehicle);
            break;
            
        case 'updatePlayerId':
            updatePlayerId(data);
            break;
            
        case 'cinematicMode':
            setCinematicMode(data.enabled);
            break;
            
        case 'damageEffect':
            showDamageEffect(data.type);
            break;
            
        case 'playerDied':
            handlePlayerDeath();
            break;
            
        case 'playerRevived':
            handlePlayerRevive();
            break;
            
        case 'addStatusEffect':
            addStatusEffect(data);
            break;
            
        case 'removeStatusEffect':
            removeStatusEffect(data.id);
            break;
            
        case 'statusWarning':
            showStatusWarning(data);
            break;
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION
// ═══════════════════════════════════════════════════════════════════════════

function initializeHud(data) {
    config = data.config;
    
    // Apply colors from config
    if (config && config.colors) {
        applyColors(config.colors);
    }
    
    // Apply positions
    if (config && config.position) {
        applyPositions(config.position);
    }
    
    // Create status arcs
    createStatusArcs();
    
    // Set initial visibility
    toggleVisibility(data.visible);
    
    console.log('[GRIMM-HUD] Initialized');
}

function applyColors(colors) {
    const root = document.documentElement;
    
    if (colors.health) root.style.setProperty('--color-health', colors.health);
    if (colors.armor) root.style.setProperty('--color-armor', colors.armor);
    if (colors.hunger) root.style.setProperty('--color-hunger', colors.hunger);
    if (colors.thirst) root.style.setProperty('--color-thirst', colors.thirst);
    if (colors.stress) root.style.setProperty('--color-stress', colors.stress);
    if (colors.oxygen) root.style.setProperty('--color-oxygen', colors.oxygen);
    if (colors.primary) root.style.setProperty('--color-primary', colors.primary);
    if (colors.secondary) root.style.setProperty('--color-secondary', colors.secondary);
    
    if (colors.voice) {
        if (colors.voice.inactive) root.style.setProperty('--color-voice-inactive', colors.voice.inactive);
        if (colors.voice.normal) root.style.setProperty('--color-voice-normal', colors.voice.normal);
        if (colors.voice.shouting) root.style.setProperty('--color-voice-shouting', colors.voice.shouting);
        if (colors.voice.whispering) root.style.setProperty('--color-voice-whispering', colors.voice.whispering);
    }
}

function applyPositions(positions) {
    // Apply status ring position
    if (positions.statusRing) {
        applyElementPosition(elements.statusRing, positions.statusRing);
    }
    
    // Apply info panel position
    if (positions.infoPanel) {
        applyElementPosition(elements.infoPanel, positions.infoPanel);
    }
    
    // Apply compass position
    if (positions.compass) {
        applyElementPosition(elements.compass, positions.compass);
    }
    
    // Apply vehicle HUD position
    if (positions.vehicleHud) {
        applyElementPosition(elements.vehicleHud, positions.vehicleHud);
    }
}

function applyElementPosition(element, posConfig) {
    // Reset all positions
    element.style.top = '';
    element.style.bottom = '';
    element.style.left = '';
    element.style.right = '';
    
    const offset = {
        x: posConfig.offsetX || 20,
        y: posConfig.offsetY || 20
    };
    
    switch (posConfig.position) {
        case 'top-left':
            element.style.top = `${offset.y}px`;
            element.style.left = `${offset.x}px`;
            break;
        case 'top-right':
            element.style.top = `${offset.y}px`;
            element.style.right = `${offset.x}px`;
            break;
        case 'bottom-left':
            element.style.bottom = `${offset.y}px`;
            element.style.left = `${offset.x}px`;
            break;
        case 'bottom-right':
            element.style.bottom = `${offset.y}px`;
            element.style.right = `${offset.x}px`;
            break;
        case 'bottom-center':
            element.style.bottom = `${offset.y}px`;
            element.style.left = '50%';
            element.style.transform = 'translateX(-50%)';
            break;
        case 'custom':
            element.style.left = `${posConfig.customX}%`;
            element.style.top = `${posConfig.customY}%`;
            break;
    }
    
    // Apply scale
    if (posConfig.scale && posConfig.scale !== 1) {
        const currentTransform = element.style.transform || '';
        element.style.transform = `${currentTransform} scale(${posConfig.scale})`.trim();
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// UPDATE FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

function toggleVisibility(visible) {
    isVisible = visible;
    elements.container.classList.toggle('hidden', !visible);
}

function updateStatus(data) {
    statusValues = {
        health: data.health,
        armor: data.armor,
        hunger: data.hunger,
        thirst: data.thirst,
        stress: data.stress,
        oxygen: data.oxygen
    };
    
    updateAllStatusArcs();
    
    // Handle oxygen visibility (only show underwater)
    if (statusArcs.oxygen) {
        statusArcs.oxygen.element.style.opacity = data.isUnderwater ? '1' : '0';
    }
}

function updateSingleStatus(type, value) {
    statusValues[type] = value;
    updateStatusArc(type, value);
}

function updateMoney(data) {
    // Money display could be added to info panel if desired
}

function animateMoneyChange(data) {
    // Could add floating +/- money animation
}

function updateLocation(data) {
    if (elements.locationZone) {
        elements.locationZone.textContent = data.zone || '';
    }
    
    if (elements.locationStreet) {
        let streetText = data.street || '';
        if (data.crossing) {
            streetText += ` / ${data.crossing}`;
        }
        elements.locationStreet.textContent = streetText;
    }
}

function updateTime(data) {
    if (elements.timeDisplay) {
        elements.timeDisplay.textContent = data.time || '00:00';
    }
    
    if (elements.weatherIcon && data.weatherIcon) {
        elements.weatherIcon.className = `fas fa-${data.weatherIcon}`;
    }
}

function updateCompass(data) {
    if (elements.compassArrow) {
        elements.compassArrow.style.transform = `rotate(${data.heading}deg)`;
    }
    
    if (elements.compassCardinal) {
        elements.compassCardinal.textContent = data.cardinal;
    }
    
    if (elements.compassDegrees) {
        elements.compassDegrees.textContent = `${data.heading}°`;
    }
}

function updateVoice(data) {
    if (!elements.voiceIndicator) return;
    
    // Remove all state classes
    elements.voiceIndicator.classList.remove('talking', 'whisper', 'shout');
    
    // Add appropriate class
    if (data.talking) {
        elements.voiceIndicator.classList.add('talking');
        
        if (data.mode === 'Whisper') {
            elements.voiceIndicator.classList.add('whisper');
        } else if (data.mode === 'Shout') {
            elements.voiceIndicator.classList.add('shout');
        }
    }
    
    // Update icon
    const icon = elements.voiceIndicator.querySelector('i');
    if (icon && data.icon) {
        icon.className = `fas fa-${data.icon}`;
    }
}

function updateMedia(data) {
    if (!elements.mediaPlayer) return;
    
    if (data.playing) {
        elements.mediaPlayer.classList.remove('hidden');
        elements.statusIcons.classList.add('hidden');
        
        if (elements.mediaTitleText) {
            elements.mediaTitleText.textContent = data.title || 'Unknown';
        }
        
        if (elements.mediaArtist) {
            elements.mediaArtist.textContent = data.artist || '-';
        }
        
        if (elements.mediaThumb && data.thumbnail) {
            elements.mediaThumb.src = data.thumbnail;
        }
        
        if (elements.mediaProgress) {
            elements.mediaProgress.style.width = `${data.progress || 0}%`;
        }
    } else {
        elements.mediaPlayer.classList.add('hidden');
        elements.statusIcons.classList.remove('hidden');
    }
}

function updateMediaProgress(data) {
    if (elements.mediaProgress) {
        elements.mediaProgress.style.width = `${data.progress || 0}%`;
    }
}

function updateVehicle(data) {
    if (!data.inVehicle) {
        elements.vehicleHud.classList.add('hidden');
        return;
    }
    
    elements.vehicleHud.classList.remove('hidden');
    
    // Speed
    if (elements.speedValue) {
        elements.speedValue.textContent = data.speed || 0;
    }
    
    if (elements.speedUnit) {
        elements.speedUnit.textContent = data.speedUnit || 'KM/H';
    }
    
    // RPM
    if (elements.rpmBar) {
        elements.rpmBar.style.width = `${data.rpm || 0}%`;
    }
    
    // Fuel
    if (elements.fuelBar) {
        elements.fuelBar.style.width = `${data.fuel || 0}%`;
        elements.fuelBar.classList.toggle('low', data.fuelLow);
    }
    
    if (elements.fuelValue) {
        elements.fuelValue.textContent = `${data.fuel || 0}%`;
    }
    
    // Gear
    if (elements.gearIndicator) {
        elements.gearIndicator.textContent = data.gear || 'N';
    }
    
    // Seatbelt
    if (elements.seatbeltIndicator) {
        elements.seatbeltIndicator.classList.toggle('hidden', data.seatbelt);
    }
    
    // Lights
    if (elements.lightsIndicator) {
        elements.lightsIndicator.classList.toggle('hidden', !data.lights);
        elements.lightsIndicator.classList.toggle('high-beam', data.highBeams);
    }
    
    // Engine warning
    if (elements.engineIndicator) {
        elements.engineIndicator.classList.toggle('hidden', !data.engineDamaged);
    }
}

function setVehicleState(inVehicle) {
    if (!inVehicle) {
        elements.vehicleHud.classList.add('hidden');
    }
}

function updatePlayerId(data) {
    const valueEl = elements.playerId?.querySelector('.id-value');
    if (valueEl) {
        valueEl.textContent = data.serverId || '0';
    }
}

function setCinematicMode(enabled) {
    elements.cinematicBars.classList.toggle('active', enabled);
    elements.cinematicBars.classList.toggle('hidden', !enabled);
    
    if (enabled) {
        elements.container.classList.add('hidden');
    } else {
        elements.container.classList.remove('hidden');
    }
}

function showDamageEffect(type) {
    elements.damageFlash.className = `damage-flash ${type}`;
    
    // Force reflow for animation
    void elements.damageFlash.offsetWidth;
    
    setTimeout(() => {
        elements.damageFlash.className = 'damage-flash';
    }, 300);
}

function handlePlayerDeath() {
    elements.container.classList.add('dead');
}

function handlePlayerRevive() {
    elements.container.classList.remove('dead');
}

function addStatusEffect(data) {
    const existing = document.getElementById(`effect-${data.id}`);
    if (existing) return;
    
    const effect = document.createElement('div');
    effect.id = `effect-${data.id}`;
    effect.className = 'status-effect';
    effect.style.color = data.color || 'var(--color-primary)';
    effect.innerHTML = `<i class="fas fa-${data.icon || 'circle'}"></i>`;
    effect.title = data.tooltip || '';
    
    elements.statusEffects.appendChild(effect);
}

function removeStatusEffect(id) {
    const effect = document.getElementById(`effect-${id}`);
    if (effect) {
        effect.style.animation = 'fadeIn 0.3s ease reverse';
        setTimeout(() => effect.remove(), 300);
    }
}

function showStatusWarning(data) {
    // Could add notification or flash for low status
}

// ═══════════════════════════════════════════════════════════════════════════
// MEDIA CONTROLS
// ═══════════════════════════════════════════════════════════════════════════

document.querySelectorAll('.media-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const action = btn.dataset.action;
        fetch(`https://grimm-hud/mediaControl`, {
            method: 'POST',
            body: JSON.stringify({ action })
        });
    });
});

// ═══════════════════════════════════════════════════════════════════════════
// NUI CALLBACKS
// ═══════════════════════════════════════════════════════════════════════════

function nuiCallback(name, data = {}) {
    return fetch(`https://grimm-hud/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

// Close config menu on escape
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        nuiCallback('closeConfigMenu');
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION
// ═══════════════════════════════════════════════════════════════════════════

console.log('[GRIMM-HUD] Script loaded');
