Config = {}

-- Discord Configuration
Config.BotToken = ''
Config.TicketChannelId = '1266116301961691146'
Config.GuildId = '1262947187029971049' -- Your Discord Server ID (right-click server name → Copy ID)

-- Staff Role IDs (can respond to tickets)
Config.StaffRoles = {
    '1265496911188721735', -- Moderator
    '1265497874431606866', -- Admin
    '1383272400925360240', -- Director
}

-- Embed Colors (decimal format)
Config.Colors = {
    Open = 1946297,      -- Teal (#1db489)
    Closed = 8323072,    -- Red (#7f1d00)
    Reply = 2067276,     -- Dark teal (#1f8b6c)
}

-- Messages
Config.Messages = {
    TicketCreated = 'Your ticket has been submitted! Staff will respond shortly. Use /respond to add more info.',
    TicketClosed = 'Your ticket has been closed. Thank you for contacting support!',
    NoTicket = 'You don\'t have an open ticket. Use /ticket <message> to create one.',
    AlreadyOpen = 'You already have an open ticket. Use /respond to add more info or /closeticket to close it.',
    StaffReply = '^3[TICKET] ^2Staff Response: ^7',
    Cooldown = 'Please wait before creating another ticket.',
}

-- Settings
Config.TicketCooldown = 300 -- 5 minutes between new tickets (seconds)
Config.MaxMessageLength = 1000 -- Max characters per message
Config.SaveLocation = true -- Include player location in ticket
Config.PingStaff = true -- Ping staff roles on new ticket
