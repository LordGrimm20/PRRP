local QBCore = exports['qb-core']:GetCoreObject()
local playerTickets = {} -- [source] = ticketId
local ticketPlayers = {} -- [ticketId] = source
local cooldowns = {} -- [visit identifier] = timestamp

-- Generate unique ticket ID
local function generateTicketId()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local id = ''
    for i = 1, 6 do
        local rand = math.random(1, #chars)
        id = id .. chars:sub(rand, rand)
    end
    return id
end

-- Get player identifier
local function getIdentifier(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return nil
end

-- Check for open ticket on player load
RegisterNetEvent('grimm-tickets:server:checkOpenTicket', function()
    local source = source
    local citizenId = getIdentifier(source)
    
    if not citizenId then return end
    
    local result = MySQL.query.await('SELECT ticket_id FROM grimm_tickets WHERE citizen_id = ? AND status = ?', {
        citizenId, 'open'
    })
    
    if result and result[1] then
        local ticketId = result[1].ticket_id
        playerTickets[source] = ticketId
        ticketPlayers[ticketId] = source
        TriggerClientEvent('grimm-tickets:client:setTicketState', source, true, ticketId)
    else
        TriggerClientEvent('grimm-tickets:client:setTicketState', source, false, nil)
    end
end)

-- Create new ticket
RegisterNetEvent('grimm-tickets:server:createTicket', function(message, locationData)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    local citizenId = Player.PlayerData.citizenid
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local steamName = GetPlayerName(source)
    
    -- Check cooldown
    if cooldowns[citizenId] and (os.time() - cooldowns[citizenId]) < Config.TicketCooldown then
        local remaining = Config.TicketCooldown - (os.time() - cooldowns[citizenId])
        TriggerClientEvent('grimm-tickets:client:notify', source, 'Please wait ' .. remaining .. ' seconds before creating another ticket.', 'error')
        return
    end
    
    -- Check for existing open ticket
    local existing = MySQL.query.await('SELECT ticket_id FROM grimm_tickets WHERE citizen_id = ? AND status = ?', {
        citizenId, 'open'
    })
    
    if existing and existing[1] then
        TriggerClientEvent('grimm-tickets:client:notify', source, Config.Messages.AlreadyOpen, 'error')
        return
    end
    
    -- Generate ticket ID
    local ticketId = generateTicketId()
    
    -- Create ticket in database
    MySQL.insert.await('INSERT INTO grimm_tickets (ticket_id, citizen_id, player_name) VALUES (?, ?, ?)', {
        ticketId, citizenId, playerName
    })
    
    -- Save initial message
    MySQL.insert.await('INSERT INTO grimm_ticket_messages (ticket_id, sender_type, sender_name, message) VALUES (?, ?, ?, ?)', {
        ticketId, 'player', playerName, message
    })
    
    -- Update tracking
    playerTickets[source] = ticketId
    ticketPlayers[ticketId] = source
    cooldowns[citizenId] = os.time()
    
    -- Player data for Discord
    local playerData = {
        source = source,
        ticketId = ticketId,
        steamName = steamName,
        characterName = playerName,
        citizenId = citizenId,
        message = message,
        location = locationData,
        ping = GetPlayerPing(source)
    }
    
    -- Send to Discord
    TriggerEvent('grimm-tickets:discord:createTicket', playerData)
    
    -- Notify player
    TriggerClientEvent('grimm-tickets:client:setTicketState', source, true, ticketId)
    TriggerClientEvent('grimm-tickets:client:notify', source, Config.Messages.TicketCreated, 'success')
    
    print('^2[grimm-tickets]^7 New ticket #' .. ticketId .. ' created by ' .. playerName)
end)

-- Player responds to ticket
RegisterNetEvent('grimm-tickets:server:playerRespond', function(message)
    local source = source
    local ticketId = playerTickets[source]
    
    if not ticketId then
        TriggerClientEvent('grimm-tickets:client:notify', source, Config.Messages.NoTicket, 'error')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    
    -- Save message
    MySQL.insert.await('INSERT INTO grimm_ticket_messages (ticket_id, sender_type, sender_name, message) VALUES (?, ?, ?, ?)', {
        ticketId, 'player', playerName, message
    })
    
    -- Send to Discord thread
    TriggerEvent('grimm-tickets:discord:playerReply', ticketId, playerName, message)
    
    TriggerClientEvent('grimm-tickets:client:notify', source, 'Response sent to ticket #' .. ticketId, 'success')
end)

-- Close ticket (by player)
RegisterNetEvent('grimm-tickets:server:closeTicket', function()
    local source = source
    local ticketId = playerTickets[source]
    
    if not ticketId then
        TriggerClientEvent('grimm-tickets:client:notify', source, Config.Messages.NoTicket, 'error')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(source)
    local closedBy = Player and (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname) or 'Unknown'
    
    -- Update database
    MySQL.update.await('UPDATE grimm_tickets SET status = ?, closed_at = NOW(), closed_by = ? WHERE ticket_id = ?', {
        'closed', closedBy .. ' (Player)', ticketId
    })
    
    -- Update Discord
    TriggerEvent('grimm-tickets:discord:closeTicket', ticketId, closedBy .. ' (Player)')
    
    -- Clear tracking
    playerTickets[source] = nil
    ticketPlayers[ticketId] = nil
    
    -- Notify player
    TriggerClientEvent('grimm-tickets:client:setTicketState', source, false, nil)
    TriggerClientEvent('grimm-tickets:client:notify', source, Config.Messages.TicketClosed, 'success')
    
    print('^3[grimm-tickets]^7 Ticket #' .. ticketId .. ' closed by player')
end)

-- Staff reply from Discord (called by discord.lua)
RegisterNetEvent('grimm-tickets:server:staffReply', function(ticketId, staffName, message)
    local source = ticketPlayers[ticketId]
    
    -- Save to database
    MySQL.insert.await('INSERT INTO grimm_ticket_messages (ticket_id, sender_type, sender_name, message) VALUES (?, ?, ?, ?)', {
        ticketId, 'staff', staffName, message
    })
    
    -- Send to player if online
    if source then
        TriggerClientEvent('grimm-tickets:client:staffReply', source, staffName, message)
    end
    
    print('^5[grimm-tickets]^7 Staff ' .. staffName .. ' replied to ticket #' .. ticketId)
end)

-- Close ticket from Discord (called by discord.lua)
RegisterNetEvent('grimm-tickets:server:closeTicketFromDiscord', function(ticketId, staffName)
    local source = ticketPlayers[ticketId]
    
    -- Update database
    MySQL.update.await('UPDATE grimm_tickets SET status = ?, closed_at = NOW(), closed_by = ? WHERE ticket_id = ?', {
        'closed', staffName .. ' (Staff)', ticketId
    })
    
    -- Notify player if online
    if source then
        playerTickets[source] = nil
        TriggerClientEvent('grimm-tickets:client:setTicketState', source, false, nil)
        TriggerClientEvent('grimm-tickets:client:notify', source, 'Your ticket has been closed by ' .. staffName, 'primary')
    end
    
    ticketPlayers[ticketId] = nil
    
    print('^3[grimm-tickets]^7 Ticket #' .. ticketId .. ' closed by staff: ' .. staffName)
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    local ticketId = playerTickets[source]
    
    if ticketId then
        ticketPlayers[ticketId] = nil
        playerTickets[source] = nil
    end
end)

-- Handle player reconnect - reassociate ticket
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local source = Player.PlayerData.source
    local citizenId = Player.PlayerData.citizenid
    
    local result = MySQL.query.await('SELECT ticket_id FROM grimm_tickets WHERE citizen_id = ? AND status = ?', {
        citizenId, 'open'
    })
    
    if result and result[1] then
        local ticketId = result[1].ticket_id
        playerTickets[source] = ticketId
        ticketPlayers[ticketId] = source
    end
end)

-- Export for other resources
exports('hasOpenTicket', function(source)
    return playerTickets[source] ~= nil
end)

exports('getTicketId', function(source)
    return playerTickets[source]
end)
