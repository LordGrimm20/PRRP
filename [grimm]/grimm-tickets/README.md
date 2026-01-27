# grimm-tickets

Two-way ticket system for Project Roots - In-game tickets with Discord integration.

## Features

- `/ticket <message>` - Create a support ticket
- `/respond <message>` - Reply to your open ticket  
- `/closeticket` - Close your ticket
- `/ticketstatus` - Check if you have an open ticket
- Discord thread created for each ticket
- Staff can reply in Discord thread → Player sees it in-game
- Player replies go to Discord thread
- `!close` in Discord to close ticket
- Ticket history saved to database

## Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Copy `grimm-tickets` to your resources folder

2. Import the SQL schema:
   ```sql
   -- Run the contents of sql/schema.sql in your database
   ```

3. Configure `config.lua`:
   - Add your Discord Bot Token
   - Add your Ticket Channel ID
   - Add your Guild (Server) ID
   - Add Staff Role IDs

4. Add to your `server.cfg`:
   ```
   ensure grimm-tickets
   ```

5. Discord Bot Setup:
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Select your bot → Bot → Enable "Message Content Intent"
   - OAuth2 → URL Generator → Select `bot` scope
   - Select permissions: `Send Messages`, `Create Public Threads`, `Send Messages in Threads`, `Manage Threads`, `Read Message History`
   - Use generated URL to invite bot to your server

## Configuration

```lua
Config.BotToken = 'your-bot-token'
Config.TicketChannelId = 'channel-id'
Config.GuildId = 'server-id'

Config.StaffRoles = {
    'moderator-role-id',
    'admin-role-id',
}

Config.TicketCooldown = 300 -- 5 minutes between tickets
Config.MaxMessageLength = 1000
Config.SaveLocation = true
Config.PingStaff = true
```

## Commands

| Command | Description |
|---------|-------------|
| `/ticket <message>` | Create a new support ticket |
| `/respond <message>` | Reply to your open ticket |
| `/closeticket` | Close your open ticket |
| `/ticketstatus` | Check your ticket status |

## Discord Commands

| Command | Description |
|---------|-------------|
| `!close` | Close the ticket (staff only) |
| *(any message)* | Reply to player in-game (staff only) |

## Support

For issues, contact LordGrimm20 on Discord.
