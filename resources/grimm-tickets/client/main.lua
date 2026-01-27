local QBCore = exports['qb-core']:GetCoreObject()
local hasOpenTicket = false
local currentTicketId = nil

-- Check for open ticket on spawn
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('grimm-tickets:server:checkOpenTicket')
end)

-- Update local ticket state
RegisterNetEvent('grimm-tickets:client:setTicketState', function(isOpen, ticketId)
    hasOpenTicket = isOpen
    currentTicketId = ticketId
end)

-- Create new ticket command
RegisterCommand('ticket', function(source, args)
    if #args < 1 then
        QBCore.Functions.Notify('Usage: /ticket <message>', 'error', 5000)
        return
    end

    if hasOpenTicket then
        QBCore.Functions.Notify(Config.Messages.AlreadyOpen, 'error', 5000)
        return
    end

    local message = table.concat(args, ' ')
    
    if #message > Config.MaxMessageLength then
        QBCore.Functions.Notify('Message too long! Max ' .. Config.MaxMessageLength .. ' characters.', 'error', 5000)
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local streetName, _ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local streetLabel = GetStreetNameFromHashKey(streetName)
    local zoneName = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
    local zoneLabel = GetLabelText(zoneName)
    
    local locationData = {
        coords = {
            x = math.floor(playerCoords.x * 100) / 100,
            y = math.floor(playerCoords.y * 100) / 100,
            z = math.floor(playerCoords.z * 100) / 100
        },
        street = streetLabel or 'Unknown',
        zone = zoneLabel ~= 'NULL' and zoneLabel or zoneName
    }

    TriggerServerEvent('grimm-tickets:server:createTicket', message, locationData)
end, false)

-- Respond to open ticket
RegisterCommand('respond', function(source, args)
    if #args < 1 then
        QBCore.Functions.Notify('Usage: /respond <message>', 'error', 5000)
        return
    end

    if not hasOpenTicket then
        QBCore.Functions.Notify(Config.Messages.NoTicket, 'error', 5000)
        return
    end

    local message = table.concat(args, ' ')
    
    if #message > Config.MaxMessageLength then
        QBCore.Functions.Notify('Message too long! Max ' .. Config.MaxMessageLength .. ' characters.', 'error', 5000)
        return
    end

    TriggerServerEvent('grimm-tickets:server:playerRespond', message)
end, false)

-- Close ticket command
RegisterCommand('closeticket', function()
    if not hasOpenTicket then
        QBCore.Functions.Notify(Config.Messages.NoTicket, 'error', 5000)
        return
    end

    TriggerServerEvent('grimm-tickets:server:closeTicket')
end, false)

-- Check ticket status
RegisterCommand('ticketstatus', function()
    if hasOpenTicket then
        QBCore.Functions.Notify('You have an open ticket: #' .. currentTicketId, 'primary', 5000)
    else
        QBCore.Functions.Notify('You have no open tickets.', 'primary', 5000)
    end
end, false)

-- Receive notification
RegisterNetEvent('grimm-tickets:client:notify', function(message, type)
    QBCore.Functions.Notify(message, type or 'primary', 7000)
end)

-- Receive staff reply
RegisterNetEvent('grimm-tickets:client:staffReply', function(staffName, message)
    -- Chat notification
    TriggerEvent('chat:addMessage', {
        color = {45, 212, 191},
        multiline = true,
        args = {'[TICKET] ' .. staffName, message}
    })
    
    -- Screen notification
    QBCore.Functions.Notify('New staff reply on your ticket!', 'success', 5000)
    
    -- Play sound
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', false)
end)

-- Help text
TriggerEvent('chat:addSuggestion', '/ticket', 'Create a support ticket', {
    { name = 'message', help = 'Describe your issue' }
})

TriggerEvent('chat:addSuggestion', '/respond', 'Reply to your open ticket', {
    { name = 'message', help = 'Your response' }
})

TriggerEvent('chat:addSuggestion', '/closeticket', 'Close your open ticket')

TriggerEvent('chat:addSuggestion', '/ticketstatus', 'Check if you have an open ticket')
