-- Enhanced Commands System
local QBCore = exports['qb-core']:GetCoreObject()

-- Helper function for player count
local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Noclip Command
QBCore.Commands.Add('noclip', 'Toggle NoClip (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:ToggleNoClip', source)
end, 'admin')

-- Admin Menu Command
QBCore.Commands.Add('admin', 'Open Admin Menu (Admin Only)', {}, false, function(source, _)
    local src = source
    print('[qb-adminmenu] Admin command triggered by player:', src) -- Debug
    
    if QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        print('[qb-adminmenu] Permission check passed, opening menu') -- Debug
        TriggerClientEvent('qb-admin:client:openMenu', src)
    else
        print('[qb-adminmenu] Permission check failed') -- Debug
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error')
    end
end, 'admin')

-- Blips Toggle
QBCore.Commands.Add('blips', 'Toggle Player Blips (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:toggleBlips', source)
end, 'admin')

-- Names Toggle
QBCore.Commands.Add('names', 'Toggle Player Names (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:toggleNames', source)
end, 'admin')

-- Revive All Command
QBCore.Commands.Add('reviveall', 'Revive All Players (Admin Only)', {}, false, function(source, _)
    TriggerEvent('qb-admin:server:reviveall')
end, 'admin')

-- Freeze All Command
QBCore.Commands.Add('freezeall', 'Freeze All Players (Admin Only)', {}, false, function(source, _)
    TriggerEvent('qb-admin:server:freezeall')
end, 'admin')

-- Unfreeze All Command
QBCore.Commands.Add('unfreezeall', 'Unfreeze All Players (Admin Only)', {}, false, function(source, _)
    TriggerEvent('qb-admin:server:unfreezeall')
end, 'admin')

-- Bring All Command
QBCore.Commands.Add('bringall', 'Bring All Players (Admin Only)', {}, false, function(source, _)
    TriggerEvent('qb-admin:server:bringall')
end, 'admin')

-- Announce Command
QBCore.Commands.Add('announce', 'Send Server Announcement (Admin Only)', {{name = 'message', help = 'Announcement message'}}, true, function(source, args)
    local message = table.concat(args, ' ')
    TriggerEvent('qb-admin:server:sendAnnounce', message)
end, 'admin')

-- Coordinates Commands
QBCore.Commands.Add('coords', 'Toggle Coordinates Display (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:ToggleCoords', source)
end, 'admin')

QBCore.Commands.Add('vector2', 'Copy vector2 to clipboard (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'coords2')
end, 'admin')

QBCore.Commands.Add('vector3', 'Copy vector3 to clipboard (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'coords3')
end, 'admin')

QBCore.Commands.Add('vector4', 'Copy vector4 to clipboard (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'coords4')
end, 'admin')

QBCore.Commands.Add('heading', 'Copy heading to clipboard (Admin Only)', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'heading')
end, 'admin')

-- Warning System
QBCore.Commands.Add('warn', 'Warn a player', {{name = 'ID', help = 'Player'}, {name = 'Reason', help = 'Mention a reason'}}, true, function(source, args)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = QBCore.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local warnId = 'WARN-' .. math.random(1111, 9999)
    
    if targetPlayer ~= nil then
        TriggerClientEvent('chat:addMessage', targetPlayer.PlayerData.source, {
            args = {'SYSTEM', 'You have been warned by ' .. GetPlayerName(source) .. ', Reason: ' .. msg},
            color = {255, 0, 0}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {'SYSTEM', 'You warned ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' for: ' .. msg},
            color = {255, 0, 0}
        })
        MySQL.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)', {
            senderPlayer.PlayerData.license,
            targetPlayer.PlayerData.license,
            msg,
            warnId
        })
        SendLog('warn', 'Player Warned', 'yellow', string.format('%s warned %s\nReason: %s\nWarn ID: %s', GetPlayerName(source), GetPlayerName(targetPlayer.PlayerData.source), msg, warnId))
    else
        TriggerClientEvent('QBCore:Notify', source, 'Player not online', 'error')
    end
end, 'admin')

QBCore.Commands.Add('checkwarns', 'Check player warnings', {{name = 'id', help = 'Player'}, {name = 'Warning', help = 'Number of warning (1, 2, 3, etc.)'}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        if not targetPlayer then
            TriggerClientEvent('QBCore:Notify', source, 'Player not online', 'error')
            return
        end
        local result = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', {targetPlayer.PlayerData.license})
        TriggerClientEvent('chat:addMessage', source, {
            args = {'SYSTEM', targetPlayer.PlayerData.name .. ' has ' .. tablelength(result) .. ' warnings!'}
        })
    else
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        if not targetPlayer then
            TriggerClientEvent('QBCore:Notify', source, 'Player not online', 'error')
            return
        end
        local warnings = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', {targetPlayer.PlayerData.license})
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local senderLicense = warnings[selectedWarning].senderIdentifier
            MySQL.query('SELECT * FROM players WHERE license = ? LIMIT 1', {senderLicense}, function(senderData)
                if senderData[1] then
                    local senderName = json.decode(senderData[1].charinfo).firstname .. ' ' .. json.decode(senderData[1].charinfo).lastname
                    TriggerClientEvent('chat:addMessage', source, {
                        args = {'SYSTEM', targetPlayer.PlayerData.name .. ' was warned by ' .. senderName .. ', Reason: ' .. warnings[selectedWarning].reason}
                    })
                end
            end)
        end
    end
end, 'admin')

QBCore.Commands.Add('delwarn', 'Delete player warning', {{name = 'id', help = 'Player'}, {name = 'Warning', help = 'Number of warning (1, 2, 3, etc.)'}}, true, function(source, args)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Player not online', 'error')
        return
    end
    local warnings = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', {targetPlayer.PlayerData.license})
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'SYSTEM', 'You deleted warning (' .. selectedWarning .. '), Reason: ' .. warnings[selectedWarning].reason}
        })
        MySQL.query('DELETE FROM player_warns WHERE warnId = ?', {warnings[selectedWarning].warnId})
        SendLog('warn', 'Warning Deleted', 'yellow', string.format('%s deleted warning %s from %s', GetPlayerName(source), selectedWarning, targetPlayer.PlayerData.name))
    end
end, 'admin')

-- Report System
QBCore.Commands.Add('report', 'Send a report to admins', {{name = 'message', help = 'Report message'}}, true, function(source, args)
    if not Config.EnablePlayerReports then
        TriggerClientEvent('QBCore:Notify', source, 'Reports are disabled', 'error')
        return
    end
    
    local msg = table.concat(args, ' ')
    local src = source
    TriggerClientEvent('qb-admin:client:SendReport', -1, GetPlayerName(src), src, msg)
end)

QBCore.Commands.Add('reportr', 'Reply to a report', {{name = 'id', help = 'Player'}, {name = 'message', help = 'Message to respond with'}}, true, function(source, args)
    local src = source
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    
    if msg == '' then return end
    if not OtherPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player is not online', 'error')
        return
    end
    if not QBCore.Functions.HasPermission(src, 'admin') then return end
    
    TriggerClientEvent('chat:addMessage', playerId, {
        color = {255, 0, 0},
        multiline = true,
        args = {'Admin Response', msg}
    })
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 0, 0},
        multiline = true,
        args = {'Report Response (' .. playerId .. ')', msg}
    })
    TriggerClientEvent('QBCore:Notify', src, 'Reply Sent', 'success')
    SendLog('admin_action', 'Report Reply', 'lightred', string.format('%s replied to %s report\nMessage: %s', GetPlayerName(src), OtherPlayer.PlayerData.name, msg))
end, 'admin')

QBCore.Commands.Add('reporttoggle', 'Toggle receiving reports', {}, false, function(source, _)
    QBCore.Functions.ToggleOptin(source)
    if QBCore.Functions.IsOptin(source) then
        TriggerClientEvent('QBCore:Notify', source, 'You will now receive reports', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'You will no longer receive reports', 'error')
    end
end, 'admin')

-- Model & Speed Commands
QBCore.Commands.Add('setmodel', 'Change ped model', {{name = 'model', help = 'Name of the model'}, {name = 'id', help = 'Player ID (empty for yourself)'}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    
    if model ~= nil and model ~= '' then
        if target == nil then
            TriggerClientEvent('qb-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = QBCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('qb-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('QBCore:Notify', source, 'Player not online', 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to set model', 'error')
    end
end, 'admin')

QBCore.Commands.Add('setspeed', 'Set player foot speed', {{name = 'type', help = 'fast or normal'}}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('qb-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to set speed', 'error')
    end
end, 'admin')

-- Vehicle Commands
QBCore.Commands.Add('car', 'Spawn a vehicle', {{name = 'model', help = 'Vehicle model name'}}, true, function(source, args)
    local model = args[1]
    if model then
        TriggerClientEvent('qb-admin:client:spawnVehicle', source, model)
    else
        TriggerClientEvent('QBCore:Notify', source, 'You must specify a vehicle model', 'error')
    end
end, 'admin')

QBCore.Commands.Add('dv', 'Delete vehicle', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:deleteVehicle', source)
end, 'admin')

QBCore.Commands.Add('fix', 'Fix vehicle', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:fixVehicle', source)
end, 'admin')

QBCore.Commands.Add('maxupgrades', 'Max out vehicle performance', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:maxmodVehicle', source)
end, 'admin')

QBCore.Commands.Add('savecar', 'Save vehicle to garage', {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:SaveCar', source)
end, 'admin')

-- Kick All Command
QBCore.Commands.Add('kickall', 'Kick all players', {}, false, function(source, args)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        if QBCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
            if reason and reason ~= '' then
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    if tonumber(playerId) ~= src then
                        DropPlayer(playerId, reason)
                    end
                end
                SendLog('admin_action', 'Kick All', 'red', string.format('%s kicked all players\nReason: %s', GetPlayerName(src), reason))
            else
                TriggerClientEvent('QBCore:Notify', src, 'No reason specified', 'error')
            end
        end
    else
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            DropPlayer(playerId, 'Server Restart\n\nCheck Discord: ' .. QBCore.Config.Server.Discord)
        end
    end
end, 'god')

-- Ammo Command
QBCore.Commands.Add('setammo', 'Set ammo amount', {{name = 'amount', help = 'Amount of bullets'}}, false, function(source, args)
    local src = source
    local ped = GetPlayerPed(src)
    local amount = tonumber(args[1])
    local weapon = GetSelectedPedWeapon(ped)
    
    if weapon and amount then
        SetPedAmmo(ped, weapon, amount)
        TriggerClientEvent('QBCore:Notify', src, 'Set ammo to ' .. amount, 'success')
    end
end, 'admin')

-- NUI Focus Command
QBCore.Commands.Add('givenuifocus', 'Give NUI focus', {{name = 'id', help = 'Player id'}, {name = 'focus', help = 'Focus on/off'}, {name = 'mouse', help = 'Mouse on/off'}}, true, function(_, args)
    local playerid = tonumber(args[1])
    local focus = args[2] == 'true'
    local mouse = args[3] == 'true'
    TriggerClientEvent('qb-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, 'admin')
