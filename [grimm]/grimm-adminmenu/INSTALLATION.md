# Installation Guide for QB-AdminMenu Enhanced

## 📋 Pre-Installation Checklist

Before installing, ensure you have:
- [x] QBCore Framework installed and working
- [x] oxmysql resource installed
- [x] menuv resource installed
- [x] Backup of current qb-adminmenu (if applicable)
- [x] FTP/File access to your server
- [x] Admin/God permissions on server
- [x] (Optional) screenshot-basic for screenshot feature
- [x] (Optional) qb-drugs for dealer list feature

## 🔧 Step-by-Step Installation

### Step 1: Backup Current Admin Menu
```bash
# Navigate to your resources folder
cd /path/to/your/server/resources/[qb]

# Rename current admin menu
mv qb-adminmenu qb-adminmenu-backup-$(date +%Y%m%d)
```

**Or manually:**
1. Go to your `resources/[qb]` folder
2. Find `qb-adminmenu`
3. Rename it to `qb-adminmenu-backup`

### Step 2: Extract Enhanced Version
1. Extract the `qb-adminmenu-improved` folder
2. Rename it to `qb-adminmenu`
3. Place it in `resources/[qb]/`

Your structure should look like:
```
resources/
└── [qb]/
    └── qb-adminmenu/
        ├── client/
        ├── server/
        ├── config/
        ├── html/
        ├── entityhashes/
        ├── locales/
        ├── fxmanifest.lua
        └── README.md
```

### Step 3: Configure Discord Webhooks (Optional but Recommended)

1. Create Discord webhooks for logging
2. Edit `config/config.lua`
3. Add your webhook URLs:

```lua
Config.Logs = {
    ['ban'] = { webhook = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE', color = 16711680 },
    ['kick'] = { webhook = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE', color = 16744192 },
    ['warn'] = { webhook = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE', color = 16776960 },
    -- Add more as needed
}
```

### Step 4: Configure Permissions

Edit `config/config.lua` to match your permission structure:

```lua
Config.Permissions = {
    ['kill'] = 'admin',         -- Required rank to kill players
    ['ban'] = 'admin',          -- Required rank to ban
    ['noclip'] = 'admin',       -- Required rank for noclip
    ['kickall'] = 'god',        -- Required rank to kick all
    -- Adjust as needed for your server
}
```

### Step 5: Customize Features

In `config/config.lua`, enable/disable features:

```lua
Config.EnableScreenshots = true      -- Requires screenshot-basic
Config.EnableAdvancedLogs = true     -- Discord webhook logging
Config.EnableAntiCheat = true        -- Anti-exploit protection
Config.EnablePlayerReports = true    -- /report system
Config.EnableBanOffline = true       -- Ban offline players
Config.EnableDrugDealers = true      -- Requires qb-drugs
```

### Step 6: Add Custom Teleport Locations

Edit `config/config.lua` to add your custom locations:

```lua
Config.TeleportLocations = {
    ['LSPD'] = vector4(428.9, -984.5, 30.7, 180.0),
    ['Hospital'] = vector4(298.5, -584.5, 43.2, 70.0),
    ['Your Custom Location'] = vector4(x, y, z, heading),
    -- Add as many as you want
}
```

### Step 7: Set Up Announcement Presets

Customize common announcements in `config/config.lua`:

```lua
Config.AnnouncementPresets = {
    ['Restart'] = 'Server restart in %s minutes!',
    ['Event'] = 'Server event starting soon at City Hall!',
    ['Maintenance'] = 'Server maintenance in progress. Thank you for your patience.',
    ['Your Custom'] = 'Your custom message here',
}
```

### Step 8: Restart Your Server

1. Stop your server
2. Clear cache (recommended):
   ```bash
   # Linux
   rm -rf cache/*
   
   # Windows
   # Delete contents of cache folder
   ```
3. Start your server
4. Check console for any errors

### Step 9: Verify Installation

1. Join your server
2. Type `/admin` - Menu should open
3. Test basic functions:
   - Toggle noclip
   - Toggle blips
   - Open player management
   - Check server info

### Step 10: Test New Features

Try these new commands:
- `/reviveall` - Revive all players
- `/announce Test message` - Send announcement
- `/freezeall` - Freeze all players
- `/unfreezeall` - Unfreeze all players

## 🔍 Troubleshooting

### Menu Doesn't Open
**Problem**: Nothing happens when typing `/admin`

**Solutions**:
1. Check you have admin permissions:
   ```sql
   -- Check your permissions in database
   SELECT * FROM players WHERE citizenid = 'YOUR_CID';
   ```
2. Verify menuv is installed and started
3. Check server console for errors
4. Try `/noclip` to test if resource is loaded

### Commands Don't Work
**Problem**: Commands return "You don't have permission"

**Solutions**:
1. Check `Config.Permissions` matches your rank
2. Verify you have the correct permission group
3. Check ACE permissions in server.cfg
4. Restart the resource: `restart qb-adminmenu`

### Discord Webhooks Not Working
**Problem**: No logs appearing in Discord

**Solutions**:
1. Verify webhook URLs are correct
2. Check webhook hasn't been deleted in Discord
3. Ensure `Config.EnableAdvancedLogs = true`
4. Test webhook manually with a tool like Postman
5. Check firewall isn't blocking Discord requests

### Screenshot Feature Not Working
**Problem**: Screenshot command does nothing

**Solutions**:
1. Install screenshot-basic:
   ```lua
   -- In server.cfg
   ensure screenshot-basic
   ```
2. Ensure `Config.EnableScreenshots = true`
3. Check screenshot-basic is properly configured
4. Verify Discord webhook for screenshots is set

### Players Can't See Blips
**Problem**: Player blips don't show for admins

**Solutions**:
1. Toggle blips off and on again (`/blips` twice)
2. Check `Config.Blips.UpdateInterval` isn't too high
3. Verify permissions are correct
4. Check for conflicting resources

## 📊 Performance Optimization

### For Large Servers (50+ players)

1. **Increase Update Interval**:
   ```lua
   Config.Blips = {
       UpdateInterval = 2000, -- Increase from 1000 to 2000ms
   }
   ```

2. **Disable Unused Features**:
   ```lua
   Config.EnableDrugDealers = false  -- If not using qb-drugs
   Config.EnableScreenshots = false  -- If not using screenshots
   ```

3. **Limit Webhook Logging**:
   ```lua
   -- Only log critical actions
   Config.Logs = {
       ['ban'] = { webhook = 'YOUR_WEBHOOK', color = 16711680 },
       ['kick'] = { webhook = 'YOUR_WEBHOOK', color = 16744192 },
       -- Comment out less important logs
   }
   ```

## 🔒 Security Recommendations

1. **Set Minimum Reason Lengths**:
   ```lua
   Config.Ban.MinReason = 10  -- Increase from 5
   Config.Kick.MinReason = 10
   ```

2. **Enable Anti-Cheat**:
   ```lua
   Config.EnableAntiCheat = true
   ```

3. **Review Logs Regularly**:
   - Check Discord logs daily
   - Monitor unusual admin activity
   - Review ban reasons for validity

4. **Limit God Permissions**:
   - Only give 'god' rank to owners
   - Use 'admin' for regular staff
   - Create custom permission levels if needed

## 📱 Discord Integration Setup

### Creating Webhooks

1. Go to your Discord server
2. Navigate to Server Settings → Integrations
3. Click "Webhooks" → "New Webhook"
4. Name it (e.g., "Admin Logs - Bans")
5. Select the channel for logs
6. Copy the webhook URL
7. Paste in config.lua

### Recommended Channel Structure

Create separate channels for different log types:
```
#admin-logs
  └── #admin-bans
  └── #admin-kicks
  └── #admin-warns
  └── #admin-actions
  └── #admin-money
  └── #admin-jobs
```

## 🎯 Best Practices

1. **Train Your Staff**:
   - Show them the new features
   - Explain logging system
   - Set clear guidelines for use

2. **Regular Backups**:
   - Backup config.lua regularly
   - Keep ban database backed up
   - Document any custom changes

3. **Monitor Resource Usage**:
   - Check server performance
   - Monitor memory usage
   - Watch for errors in console

4. **Keep Updated**:
   - Check for updates regularly
   - Review changelog for new features
   - Test updates in development first

## 🆘 Getting Help

If you're still having issues:

1. **Check the README.md** for detailed documentation
2. **Review ENHANCEMENTS.md** for feature explanations
3. **Check console logs** for specific error messages
4. **Verify all dependencies** are installed
5. **Test in a clean environment** to isolate issues

## ✅ Post-Installation Checklist

After installation, verify:
- [ ] Admin menu opens with `/admin`
- [ ] NoClip works with `/noclip`
- [ ] Player blips toggle correctly
- [ ] Ban/kick/warn functions work
- [ ] New mass actions function (reviveall, etc.)
- [ ] Money management works
- [ ] Job/Gang setting works
- [ ] Discord webhooks are logging
- [ ] Screenshot feature works (if enabled)
- [ ] Quick teleports work
- [ ] Announcements send correctly
- [ ] All permissions are correct
- [ ] No console errors appear

## 🎉 You're Done!

Your enhanced QB-AdminMenu is now installed and ready to use!

Enjoy the new features and improved functionality. Remember to review the README.md and ENHANCEMENTS.md files for complete feature documentation.

---

**Need more help?** Check the troubleshooting section or review the configuration examples in the config file.
