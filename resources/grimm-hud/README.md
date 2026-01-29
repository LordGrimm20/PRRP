# 🎮 GRIMM-HUD

**Custom HUD for Project Roots RP**

A fully customizable, modern HUD system for QBCore FiveM servers featuring a circular status ring design inspired by NoPixel 4.0.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Framework](https://img.shields.io/badge/framework-QBCore-green)
![Lua](https://img.shields.io/badge/lua-5.4-purple)

---

## ✨ Features

### Status Ring
- 🔴 **Health** - Red indicator
- 🔵 **Armor** - Blue indicator  
- 💜 **Voice** - Purple (pma-voice integration)
- 🟢 **Thirst** - Green indicator
- 🟡 **Hunger** - Yellow indicator
- ⚪ **Stress** - White indicator
- 🔵 **Oxygen** - Cyan (auto-shows underwater)

### Info Panel
- ⏰ Real-time game clock (12h/24h formats)
- 🌤️ Dynamic weather icons
- 📍 Street name & zone display
- 🆔 Player ID display

### Compass
- 🧭 Smooth rotating compass
- Cardinal directions (N, S, E, W)
- Degree display

### Vehicle HUD
- 📊 Digital speedometer (KM/H or MPH)
- ⛽ Fuel gauge with low warning
- 🔧 RPM bar
- ⚙️ Gear indicator
- 💺 Seatbelt warning
- 💡 Lights indicator
- 🔥 Engine damage warning

### Media Player
- 🎵 rtx_carradio integration
- Album art display
- Track info with marquee
- Playback controls

### Additional Features
- 🎬 Cinematic mode with letterbox bars
- 💥 Damage flash effects
- ⚡ Status effect indicators (buffs/debuffs)
- 📱 Phone notification support (gksphonev2)

---

## 📦 Installation

1. Download and extract to your `resources` folder
2. Rename to `grimm-hud`
3. Add to your `server.cfg`:
   ```cfg
   ensure grimm-hud
   ```
4. Configure `config.lua` to your preferences
5. Restart your server

### Dependencies
- `qb-core`
- `pma-voice`
- `rtx_carradio` (optional, for media player)
- `gksphonev2` (optional, for phone notifications)

---

## ⚙️ Configuration

All settings are in `config.lua`. Here are the main sections:

### Colors
```lua
Config.Colors = {
    health = '#ff3b3b',      -- Red
    armor = '#3b8fff',       -- Blue
    hunger = '#f1c40f',      -- Yellow
    thirst = '#2ecc71',      -- Green
    stress = '#ffffff',      -- White
    oxygen = '#00bcd4',      -- Cyan
    
    voice = {
        inactive = '#4a4a4a',
        normal = '#9b59b6',      -- Purple
        shouting = '#e74c3c',
        whispering = '#3498db',
    },
    
    primary = '#00d9ff',     -- Teal accent
}
```

### Positioning
Each HUD element can be positioned independently:
```lua
Config.Position = {
    statusRing = {
        position = 'bottom-left', -- 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'custom'
        customX = 0,              -- Only for 'custom' position
        customY = 0,
        scale = 1.0,              -- Size multiplier
        offsetX = 20,             -- Pixels from edge
        offsetY = 20,
    },
    -- Similar for: infoPanel, compass, vehicleHud
}
```

### Keybindings
```lua
Config.ToggleKey = 'F7'                    -- Toggle HUD visibility
Config.CinematicMode.key = 'F8'            -- Toggle cinematic mode
```

### Fuel Resource
```lua
Config.VehicleHud.fuel.resource = 'LegacyFuel'  -- Options: 'LegacyFuel', 'cdn-fuel', 'ps-fuel', 'ox_fuel', 'native'
```

---

## 🔧 Exports

### Client-side Exports

```lua
-- Toggle HUD visibility
exports['grimm-hud']:ToggleHud(true/false)

-- Check if HUD is visible
local visible = exports['grimm-hud']:IsHudVisible()

-- Update a specific status
exports['grimm-hud']:UpdateStatus('health', 75)
exports['grimm-hud']:UpdateStatus('stress', 50)

-- Set cinematic mode
exports['grimm-hud']:SetCinematicMode(true/false)

-- Add status effect indicator
exports['grimm-hud']:AddStatusEffect('caffeine', {
    icon = 'coffee',
    color = '#8B4513',
    tooltip = 'Caffeine Boost',
    duration = 60000  -- Auto-remove after 60 seconds (optional)
})

-- Remove status effect
exports['grimm-hud']:RemoveStatusEffect('caffeine')

-- Refresh config (after changes)
exports['grimm-hud']:RefreshConfig()

-- Seatbelt state
exports['grimm-hud']:SetSeatbeltState(true/false)
```

---

## 📡 Events

### Client Events

```lua
-- Toggle HUD
TriggerClientEvent('grimm-hud:client:toggle', source, true/false)

-- Update status
TriggerClientEvent('grimm-hud:client:updateStatus', source, 'hunger', 50)

-- Show notification (if implemented)
TriggerClientEvent('grimm-hud:client:notify', source, {
    title = 'Alert',
    message = 'Something happened!',
    type = 'info'
})
```

---

## 🎨 CSS Customization

For advanced styling, edit `html/css/style.css`. All colors use CSS variables:

```css
:root {
    /* Easily change the entire color scheme */
    --color-health: #ff3b3b;
    --color-armor: #3b8fff;
    --color-primary: #00d9ff;
    
    /* Fonts */
    --font-primary: 'Rajdhani', sans-serif;
    --font-display: 'Orbitron', sans-serif;
    
    /* Ring settings */
    --ring-size: 200px;
    --ring-thickness: 8px;
}
```

---

## 🔌 Integration Examples

### With qb-ambulancejob (stress)
```lua
-- In your stress script
TriggerClientEvent('hud:client:UpdateStress', source, newStressLevel)
```

### With custom drug effects
```lua
-- Add drug effect indicator
exports['grimm-hud']:AddStatusEffect('high', {
    icon = 'cannabis',
    color = '#2ecc71',
    tooltip = 'High',
    duration = 300000  -- 5 minutes
})
```

### With racing scripts
```lua
-- Show nitro indicator
exports['grimm-hud']:AddStatusEffect('nitro', {
    icon = 'bolt',
    color = '#9b59b6',
    tooltip = 'Nitro Active'
})
```

---

## ❓ FAQ

**Q: HUD not showing?**
- Make sure player is fully loaded
- Check F8 console for errors
- Verify `ensure grimm-hud` is in server.cfg after qb-core

**Q: Media player not working?**
- Ensure `rtx_carradio` is started
- Check that exports match your radio resource

**Q: Fuel not displaying correctly?**
- Update `Config.VehicleHud.fuel.resource` to match your fuel script

**Q: Voice indicator not working?**
- Ensure `pma-voice` is installed and running
- Check voice ranges in config match pma-voice config

---

## 📝 Changelog

### v1.0.0
- Initial release
- Circular status ring
- Vehicle HUD
- Media player integration
- pma-voice support
- Cinematic mode
- Full customization support

---

## 🤝 Credits

- **Development**: PRRP Development Team
- **Design Inspiration**: NoPixel 4.0
- **Framework**: QBCore

---

## 📄 License

This resource is provided for use on Project Roots RP. 
Redistribution or resale is not permitted without permission.

---

**Made with ❤️ for Project Roots RP**
