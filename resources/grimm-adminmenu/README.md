# QB-AdminMenu Enhanced v2.0.0

An enhanced and feature-rich admin menu for QBCore Framework with improved functionality, better code organization, and numerous new features.

## 🎯 New Features & Improvements

### ✨ Major Additions

1. **Mass Admin Actions**
   - Revive All Players (`/reviveall`)
   - Freeze All Players (`/freezeall`)
   - Unfreeze All Players (`/unfreezeall`)
   - Bring All Players (`/bringall`)

2. **Advanced Player Management**
   - Give/Remove Money (Cash/Bank)
   - Set Player Job with Grade Selection
   - Set Player Gang with Grade Selection
   - Offline Player Banning (by Citizen ID)
   - Enhanced Ban System with customizable durations
   - Player Screenshot Capture (requires screenshot-basic)

3. **Server Management**
   - Server Announcements (`/announce`)
   - Quick Teleport Locations (Configurable)
   - Announcement Presets
   - Server Info Display (Uptime, Players, Version)
   - Ban List Viewer with Unban Function

4. **Enhanced Security**
   - Anti-Exploit Protection
   - Permission-based Action Logging
   - Auto-ban on Unauthorized Admin Action Attempts
   - Detailed Action Logging

5. **Improved Developer Tools**
   - Better Entity View Options
   - Vehicle Developer Mode
   - Enhanced Coordinate Display
   - Entity Information Copy

6. **Configuration System**
   - Centralized Config File
   - Customizable Permissions per Action
   - Feature Toggles
   - Discord Webhook Integration
   - Custom Teleport Locations
   - Announcement Presets

### 🔧 Code Improvements

- **Better Organization**: Separated files for server, client, commands, logs, and utilities
- **Optimized Performance**: Reduced resource usage and improved efficiency
- **Error Handling**: Better error checking and validation
- **Clean Code**: Improved readability and maintainability
- **Modular Design**: Easy to add/remove features

## 📋 Requirements

- QBCore Framework
- oxmysql
- menuv
- screenshot-basic (optional, for screenshot feature)
- qb-drugs (optional, for dealer list)

## 📥 Installation

1. **Backup your current qb-adminmenu**
   ```bash
   # Rename your current folder
   mv qb-adminmenu qb-adminmenu-backup
   ```

2. **Extract the enhanced version**
   - Place `qb-adminmenu-improved` folder in your resources directory
   - Rename to `qb-adminmenu`

3. **Configure the resource**
   - Edit `config/config.lua` to customize settings
   - Set up Discord webhooks in config for logging
   - Adjust permissions as needed

4. **Database Setup**
   - The script uses existing QBCore database tables
   - No additional database changes required

5. **Start the resource**
   ```lua
   ensure qb-adminmenu
   ```

## ⚙️ Configuration

### Permission Levels
Edit `config/config.lua` to adjust permission requirements:

```lua
Config.Permissions = {
    ['kill'] = 'admin',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'god',
    -- Add more permissions here
}
```

### Discord Webhooks
Set up logging webhooks in `config/config.lua`:

```lua
Config.Logs = {
    ['ban'] = { webhook = 'YOUR_WEBHOOK_HERE', color = 16711680 },
    ['kick'] = { webhook = 'YOUR_WEBHOOK_HERE', color = 16744192 },
    -- Configure webhooks for different actions
}
```

### Quick Teleport Locations
Add custom locations in `config/config.lua`:

```lua
Config.TeleportLocations = {
    ['LSPD'] = vector4(428.9, -984.5, 30.7, 180.0),
    ['Your Location'] = vector4(x, y, z, heading),
}
```

## 🎮 Commands

### Basic Commands
- `/admin` - Open Admin Menu
- `/noclip` - Toggle NoClip
- `/blips` - Toggle Player Blips
- `/names` - Toggle Player Names
- `/coords` - Toggle Coordinate Display

### Player Management
- `/reviveall` - Revive all players
- `/freezeall` - Freeze all players
- `/unfreezeall` - Unfreeze all players
- `/bringall` - Bring all players to you

### Communication
- `/announce [message]` - Send server announcement
- `/report [message]` - Send report to admins
- `/reportr [id] [message]` - Reply to player report
- `/reporttoggle` - Toggle receiving reports

### Warning System
- `/warn [id] [reason]` - Warn a player
- `/checkwarns [id] [warning#]` - Check player warnings
- `/delwarn [id] [warning#]` - Delete a warning

### Developer Tools
- `/vector2` - Copy vector2 to clipboard
- `/vector3` - Copy vector3 to clipboard
- `/vector4` - Copy vector4 to clipboard
- `/heading` - Copy heading to clipboard

### Vehicle Commands
- `/car [model]` - Spawn vehicle
- `/dv` - Delete vehicle
- `/fix` - Fix current vehicle
- `/maxupgrades` - Max out vehicle performance
- `/savecar` - Save vehicle to garage

### Player Modification
- `/setmodel [model] [id]` - Change ped model
- `/setspeed [fast/normal]` - Set foot speed

### Server Management (God Only)
- `/kickall [reason]` - Kick all players

## 🎨 Menu Features

### Admin Options Menu
- NoClip Toggle
- Self Revive
- Invisibility
- God Mode
- Display Player Names
- Display Player Blips
- Weapon Spawner

### Player Management Menu
- Spectate Player
- Freeze/Unfreeze Player
- Revive Player
- Kill Player
- Teleport to Player
- Bring Player
- Give/Remove Money
- Set Job/Gang
- Kick Player
- Ban Player
- View Player Info
- Take Screenshot

### Server Management Menu
- Weather Control
- Time Control
- Server Announcements
- Quick Teleport Locations
- Ban List Viewer
- Server Info Display

### Vehicle Options Menu
- Spawn by Category
- Quick Vehicle Spawn
- Vehicle Modifications

### Developer Options Menu
- Entity View Options
- Coordinate Tools
- Vehicle Dev Mode
- Entity Inspector

## 📊 Features Comparison

| Feature | Old Version | Enhanced Version |
|---------|-------------|------------------|
| Mass Actions | ❌ | ✅ |
| Money Management | ❌ | ✅ |
| Job/Gang Management | ❌ | ✅ |
| Offline Banning | ❌ | ✅ |
| Screenshot Capture | ❌ | ✅ |
| Discord Logging | Limited | ✅ Advanced |
| Config File | ❌ | ✅ |
| Quick Teleports | ❌ | ✅ |
| Announcements | ❌ | ✅ |
| Anti-Exploit | Basic | ✅ Enhanced |
| Code Organization | Single Files | ✅ Modular |

## 🔒 Security Features

1. **Permission Validation**: Every action validates permissions server-side
2. **Anti-Exploit**: Automatic ban on unauthorized action attempts
3. **Action Logging**: All admin actions are logged
4. **Rate Limiting**: Prevents spam of admin commands
5. **Input Validation**: Sanitizes all user inputs

## 🐛 Troubleshooting

### Menu not opening
- Ensure you have admin permissions
- Check console for errors
- Verify menuv is installed

### Commands not working
- Check your permission level
- Ensure resource is started
- Check server console for errors

### Webhooks not sending
- Verify webhook URLs in config
- Check webhook permissions in Discord
- Ensure server has internet access

## 📝 Changelog

### Version 2.0.0
- Complete code restructure
- Added mass admin actions
- Added money/job/gang management
- Added offline banning
- Added screenshot feature
- Added centralized config
- Added Discord webhook logging
- Added quick teleport locations
- Added server announcements
- Enhanced security
- Improved performance
- Better error handling

## 🤝 Support

For issues, suggestions, or contributions:
1. Check existing issues
2. Create detailed bug reports
3. Test in a development environment first

## 📜 License

This is an enhanced version of qb-adminmenu for QBCore Framework.
Use, modify, and distribute as needed for your FiveM server.

## 🙏 Credits

- Original qb-adminmenu by Kakarot
- Enhanced by the Community
- QBCore Framework Team

---

**Note**: This is a significantly enhanced version. Always backup your current version before updating!
