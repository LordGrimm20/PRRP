Config = {}

--[[
    ██████╗ ██████╗ ██╗███╗   ███╗███╗   ███╗      ██╗  ██╗██╗   ██╗██████╗ 
    ██╔════╝ ██╔══██╗██║████╗ ████║████╗ ████║      ██║  ██║██║   ██║██╔══██╗
    ██║  ███╗██████╔╝██║██╔████╔██║██╔████╔██║█████╗███████║██║   ██║██║  ██║
    ██║   ██║██╔══██╗██║██║╚██╔╝██║██║╚██╔╝██║╚════╝██╔══██║██║   ██║██║  ██║
    ╚██████╔╝██║  ██║██║██║ ╚═╝ ██║██║ ╚═╝ ██║      ██║  ██║╚██████╔╝██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝     ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    Project Roots RP - Custom HUD Configuration
    Version: 1.0.0
]]

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           GENERAL SETTINGS                              │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Framework = 'qb-core' -- 'qb-core' or 'esx'

Config.RefreshRate = 250 -- How often to update HUD (ms) - lower = smoother but more resource usage

Config.HideInVehicle = false -- Hide status ring when in vehicle (show vehicle HUD instead)
Config.HideOnFoot = false -- Hide vehicle HUD elements when on foot

Config.DefaultVisible = true -- Is HUD visible by default on spawn

Config.ToggleKey = 'F7' -- Key to toggle HUD visibility (set to false to disable)

Config.UseKMH = true -- true = KM/H, false = MPH for speedometer

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                          POSITION & LAYOUT                              │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Position = {
    -- Main status ring position
    statusRing = {
        position = 'bottom-left', -- 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'custom'
        customX = 0, -- Only used if position = 'custom' (percentage from left)
        customY = 0, -- Only used if position = 'custom' (percentage from top)
        scale = 1.0, -- Scale multiplier (0.5 = half size, 2.0 = double size)
        offsetX = 20, -- Pixels offset from edge (X)
        offsetY = 20, -- Pixels offset from edge (Y)
    },

    -- Info panel (time, location, weather)
    infoPanel = {
        position = 'top-right', -- 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'custom'
        customX = 0,
        customY = 0,
        scale = 1.0,
        offsetX = 20,
        offsetY = 20,
    },

    -- Compass
    compass = {
        position = 'bottom-right', -- 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'bottom-center', 'custom'
        customX = 0,
        customY = 0,
        scale = 1.0,
        offsetX = 20,
        offsetY = 20,
    },

    -- Media player
    mediaPlayer = {
        position = 'center', -- Position within status ring: 'center', 'below', 'above'
        scale = 1.0,
    },

    -- Vehicle HUD (speedometer, fuel, etc)
    vehicleHud = {
        position = 'bottom-right',
        customX = 0,
        customY = 0,
        scale = 1.0,
        offsetX = 20,
        offsetY = 150,
    },
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                              COLORS                                     │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Colors = {
    -- Status ring colors
    health = '#ff3b3b',      -- Red
    armor = '#3b8fff',       -- Blue
    hunger = '#f1c40f',      -- Yellow
    thirst = '#2ecc71',      -- Green
    stress = '#ffffff',      -- White
    oxygen = '#00bcd4',      -- Cyan (for underwater)

    -- Voice indicator
    voice = {
        inactive = '#4a4a4a',    -- Grey when not talking
        normal = '#9b59b6',      -- Purple for normal voice
        shouting = '#e74c3c',    -- Red when shouting
        whispering = '#3498db',  -- Blue when whispering
    },

    -- UI accents (your teal theme)
    primary = '#00d9ff',     -- Teal accent
    secondary = '#0a0a0a',   -- Dark background
    text = '#ffffff',        -- White text
    textMuted = '#888888',   -- Muted text

    -- Vehicle HUD
    speed = '#00d9ff',       -- Teal
    fuel = '#f39c12',        -- Orange
    engine = '#e74c3c',      -- Red for damage
    nitro = '#9b59b6',       -- Purple

    -- Ring background (unfilled portion)
    ringBackground = 'rgba(0, 0, 0, 0.3)',
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                          STATUS RING SETTINGS                           │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.StatusRing = {
    -- Ring dimensions
    size = 200,              -- Diameter in pixels
    thickness = 8,           -- Thickness of the ring stroke
    gap = 4,                 -- Gap between ring segments

    -- Which stats to show (order matters - clockwise from top)
    stats = {
        { id = 'health',  enabled = true,  icon = 'heart',        showPercent = false },
        { id = 'armor',   enabled = true,  icon = 'shield',       showPercent = false },
        { id = 'hunger',  enabled = true,  icon = 'utensils',     showPercent = false },
        { id = 'thirst',  enabled = true,  icon = 'droplet',      showPercent = false },
        { id = 'stress',  enabled = true,  icon = 'brain',        showPercent = false },
        { id = 'oxygen',  enabled = true,  icon = 'wind',         showPercent = false, autoHide = true }, -- Only shows underwater
    },

    -- Animation settings
    animation = {
        enabled = true,
        duration = 300,      -- Transition duration in ms
        easing = 'ease-out', -- CSS easing function
    },

    -- Low value warnings
    warnings = {
        enabled = true,
        threshold = 25,      -- Percentage to trigger warning
        pulse = true,        -- Pulse animation when low
        pulseSpeed = 1000,   -- Pulse animation speed (ms)
    },

    -- Show icons inside ring
    showIcons = true,
    iconSize = 16,           -- Icon size in pixels
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                          INFO PANEL SETTINGS                            │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.InfoPanel = {
    -- Time display
    time = {
        enabled = true,
        use24Hour = false,   -- true = 24h format, false = 12h format
        showSeconds = false,
        showWeatherIcon = true,
    },

    -- Location display
    location = {
        enabled = true,
        showStreet = true,       -- Show street name
        showCrossing = true,     -- Show crossing street
        showZone = true,         -- Show area/zone name
        showPostal = false,      -- Show postal code (requires postal resource)
        postalResource = 'nearest-postal', -- Postal resource name
    },

    -- Player ID (for RP servers)
    playerId = {
        enabled = true,
        prefix = 'ID: ',
        showCitizenId = false,   -- Show citizenid instead of server id
    },

    -- Online players count
    onlinePlayers = {
        enabled = false,
        icon = 'users',
    },
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           COMPASS SETTINGS                              │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Compass = {
    enabled = true,
    style = 'minimal',       -- 'minimal', 'full', 'bar'
    size = 60,               -- Size in pixels
    showDegrees = true,      -- Show heading in degrees
    showCardinal = true,     -- Show N, S, E, W
    smoothing = 0.15,        -- Rotation smoothing (0-1, lower = smoother)
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         VOICE INDICATOR                                 │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Voice = {
    enabled = true,
    position = 'ring',       -- 'ring' (inside status ring), 'standalone' (separate element)

    -- Voice ranges (must match pma-voice config)
    ranges = {
        { range = 2.0,  label = 'Whisper', icon = 'volume-off' },
        { range = 4.0,  label = 'Normal',  icon = 'volume-low' },
        { range = 8.0,  label = 'Shout',   icon = 'volume-high' },
    },

    -- Show voice range indicator
    showRange = true,
    showLabel = false,       -- Show "Whisper", "Normal", "Shout" text

    -- Talking indicator
    talkingAnimation = true, -- Pulse/glow when talking
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         MEDIA PLAYER                                    │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.MediaPlayer = {
    enabled = true,
    resource = 'rtx_carradio', -- Radio resource name

    -- Display settings
    showAlbumArt = true,
    showTrackName = true,
    showArtist = true,
    showProgress = true,
    showControls = true,     -- Play/pause, skip buttons

    -- Auto-hide when no media playing
    autoHide = true,
    hideDelay = 3000,        -- Delay before hiding (ms)

    -- Marquee for long text
    marquee = {
        enabled = true,
        speed = 50,          -- Pixels per second
        delay = 2000,        -- Delay before starting scroll
    },
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         VEHICLE HUD                                     │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.VehicleHud = {
    enabled = true,

    -- Speedometer
    speedometer = {
        enabled = true,
        style = 'digital',   -- 'digital', 'analog', 'minimal'
        maxSpeed = 300,      -- Max speed for analog gauge
    },

    -- Fuel gauge
    fuel = {
        enabled = true,
        resource = 'LegacyFuel', -- Fuel resource: 'LegacyFuel', 'cdn-fuel', 'ps-fuel', 'ox_fuel', or 'native'
        lowWarning = 20,     -- Percentage to show warning
    },

    -- RPM gauge
    rpm = {
        enabled = true,
        style = 'bar',       -- 'bar', 'gauge'
    },

    -- Gear indicator
    gear = {
        enabled = true,
    },

    -- Seatbelt indicator
    seatbelt = {
        enabled = true,
        resource = 'qb-seatbelt', -- Seatbelt resource name (or false to disable)
        warningIcon = 'car-crash',
    },

    -- Engine health
    engine = {
        enabled = true,
        showPercent = false,
        damageWarning = 50,  -- Percentage to show warning
    },

    -- Lights indicator
    lights = {
        enabled = true,
        showHighBeam = true,
    },

    -- Nitro/NOS (if applicable)
    nitro = {
        enabled = false,
        resource = false,    -- Nitro resource name
    },
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         PHONE INTEGRATION                               │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Phone = {
    enabled = true,
    resource = 'gksphonev2', -- Phone resource name

    -- Notification indicator
    notifications = {
        enabled = true,
        showCount = true,    -- Show number of notifications
        position = 'top-right',
    },
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         MINIMAP SETTINGS                                │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Minimap = {
    -- Minimap customization (applies GTA native settings)
    enabled = true,
    shape = 'square',        -- 'square', 'circle' (circle requires custom mask)
    zoom = 1000,             -- Zoom level
    
    -- When to show minimap
    showOnFoot = true,
    showInVehicle = true,
    showInCombat = true,

    -- Border/styling applied via CSS
    borderColor = '#00d9ff',
    borderWidth = 2,
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         CINEMATIC MODE                                  │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.CinematicMode = {
    enabled = true,
    key = 'F8',              -- Key to toggle cinematic mode
    hideAll = true,          -- Hide all HUD elements
    blackBars = true,        -- Show cinematic black bars
    barHeight = 80,          -- Height of black bars in pixels
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         ADMIN/DEBUG                                     │
-- └─────────────────────────────────────────────────────────────────────────┘

Config.Debug = false         -- Enable debug prints

Config.AdminMenu = {
    enabled = true,
    command = 'hudconfig',   -- Command to open HUD configuration menu
    acePermission = 'command.hudconfig', -- ACE permission required (false for everyone)
}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         EXPORTS & EVENTS                                │
-- └─────────────────────────────────────────────────────────────────────────┘

--[[
    AVAILABLE EXPORTS:
    
    exports['grimm-hud']:ToggleHud(visible)        -- Toggle HUD visibility
    exports['grimm-hud']:UpdateStatus(type, value) -- Update a status value
    exports['grimm-hud']:ShowNotification(data)    -- Show a notification
    exports['grimm-hud']:SetCinematicMode(enabled) -- Toggle cinematic mode
    exports['grimm-hud']:RefreshConfig()           -- Reload config

    AVAILABLE EVENTS:
    
    TriggerClientEvent('grimm-hud:client:toggle', source, visible)
    TriggerClientEvent('grimm-hud:client:updateStatus', source, type, value)
    TriggerClientEvent('grimm-hud:client:notify', source, data)
]]
