-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local frozen = {}
local godmode = {}
local cachedPlayers = {}

-- Helper Functions
local function GetQBPlayers()
    local playerReturn = {}
    local players = QBCore.Functions.GetQBPlayers()
    
    for id, player in pairs(players) do
        local playerPed = GetPlayerPed(id)
        local name = (player.PlayerData.charinfo.firstname or '') .. ' ' .. (player.PlayerData.charinfo.lastname or '')
        playerReturn[#playerReturn + 1] = {
            name = name .. ' | (' .. (player.PlayerData.name or '') .. ')',
            id = id,
            coords = GetEntityCoords(playerPed),
            cid = name,
            citizenid = player.PlayerData.citizenid,
            sources = playerPed,
            sourceplayer = id,
            job = player.PlayerData.job.name,
            gang = player.PlayerData.gang.name,
            money = {
                cash = player.PlayerData.money.cash,
                bank = player.PlayerData.money.bank
            }
        }
    end
    cachedPlayers = playerReturn
    return playerReturn
end

local function HasPermission(src, permission)
    return QBCore.Functions.HasPermission(src, Config.Permissions[permission]) or IsPlayerAceAllowed(src, 'command')
end

local function BanPlayer(src, reason)
    reason = reason or 'Exploiting admin functions'
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        QBCore.Functions.GetIdentifier(src, 'license'),
        QBCore.Functions.GetIdentifier(src, 'discord'),
        QBCore.Functions.GetIdentifier(src, 'ip'),
        reason,
        2147483647,
        'qb-adminmenu [Anti-Exploit]'
    })
    
    SendLog('admin_action', 'Player Banned', 'red', string.format('%s was banned by qb-adminmenu for %s', GetPlayerName(src), reason), true)
    DropPlayer(src, 'You were permanently banned by the server for: ' .. reason)
end

-- Callbacks
QBCore.Functions.CreateCallback('qb-admin:server:getplayers', function(_, cb)
    cb(GetQBPlayers())
end)

QBCore.Functions.CreateCallback('qb-admin:isAdmin', function(src, cb)
    cb(QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command'))
end)

QBCore.Functions.CreateCallback('qb-admin:server:getrank', function(source, cb)
    if QBCore.Functions.HasPermission(source, 'god') or IsPlayerAceAllowed(source, 'command') then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-admin:server:getServerInfo', function(_, cb)
    local serverInfo = {
        players = #GetPlayers(),
        maxPlayers = GetConvarInt('sv_maxclients', 48),
        uptime = os.time() - GlobalState.ServerStartTime or 0,
        version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
    }
    cb(serverInfo)
end)

QBCore.Functions.CreateCallback('qb-admin:server:getBannedPlayers', function(_, cb)
    MySQL.query('SELECT * FROM bans ORDER BY expire DESC LIMIT 100', {}, function(result)
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback('test:getdealers', function(_, cb)
    if GetResourceState('qb-drugs') == 'started' then
        cb(exports['qb-drugs']:GetDealers())
    else
        cb({})
    end
end)

-- Events
RegisterNetEvent('qb-admin:server:GetPlayersForBlips', function()
    local src = source
    if not HasPermission(src, 'spectate') then return end
    TriggerClientEvent('qb-admin:client:Show', src, GetQBPlayers())
end)

RegisterNetEvent('qb-admin:server:kill', function(player)
    local src = source
    if not HasPermission(src, 'kill') then
        BanPlayer(src, 'Attempting to use kill without permission')
        return
    end
    
    TriggerClientEvent('hospital:client:KillPlayer', player.id)
    SendLog('kill', 'Player Killed', 'red', string.format('%s killed %s', GetPlayerName(src), GetPlayerName(player.id)))
end)

RegisterNetEvent('qb-admin:server:revive', function(player)
    local src = source
    if not HasPermission(src, 'revive') then
        BanPlayer(src, 'Attempting to use revive without permission')
        return
    end
    
    TriggerClientEvent('hospital:client:Revive', player.id)
    TriggerClientEvent('hud:client:UpdateNeeds', player.id, 100, 100)
    SendLog('revive', 'Player Revived', 'green', string.format('%s revived %s', GetPlayerName(src), GetPlayerName(player.id)))
end)

RegisterNetEvent('qb-admin:server:reviveall', function()
    local src = source
    if not HasPermission(src, 'revive') then
        BanPlayer(src, 'Attempting to use reviveall without permission')
        return
    end
    
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        TriggerClientEvent('hospital:client:Revive', playerId)
        TriggerClientEvent('hud:client:UpdateNeeds', playerId, 100, 100)
    end
    
    SendLog('revive', 'Mass Revive', 'green', string.format('%s revived all players', GetPlayerName(src)))
    TriggerClientEvent('QBCore:Notify', src, 'All players have been revived', 'success')
end)

RegisterNetEvent('qb-admin:server:kick', function(player, reason)
    local src = source
    if not HasPermission(src, 'kick') then
        BanPlayer(src, 'Attempting to use kick without permission')
        return
    end
    
    if #reason < Config.Kick.MinReason then
        TriggerClientEvent('QBCore:Notify', src, 'Reason must be at least ' .. Config.Kick.MinReason .. ' characters', 'error')
        return
    end
    
    SendLog('kick', 'Player Kicked', 'orange', string.format('%s was kicked by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason))
    DropPlayer(player.id, Lang:t('info.kicked_server') .. ':\n' .. reason .. '\n\n' .. Lang:t('info.check_discord') .. QBCore.Config.Server.Discord)
end)

RegisterNetEvent('qb-admin:server:ban', function(player, time, reason)
    local src = source
    if not HasPermission(src, 'ban') then
        BanPlayer(src, 'Attempting to use ban without permission')
        return
    end
    
    if #reason < Config.Ban.MinReason then
        TriggerClientEvent('QBCore:Notify', src, 'Reason must be at least ' .. Config.Ban.MinReason .. ' characters', 'error')
        return
    end
    
    time = tonumber(time)
    local banTime = tonumber(os.time() + time)
    if banTime > 2147483647 then
        banTime = 2147483647
    end
    
    local timeTable = os.date('*t', banTime)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(player.id),
        QBCore.Functions.GetIdentifier(player.id, 'license'),
        QBCore.Functions.GetIdentifier(player.id, 'discord'),
        QBCore.Functions.GetIdentifier(player.id, 'ip'),
        reason,
        banTime,
        GetPlayerName(src)
    })
    
    if Config.Ban.ShowBanMessage then
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class='chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = { GetPlayerName(player.id), reason }
        })
    end
    
    SendLog('ban', 'Player Banned', 'red', string.format('%s was banned by %s for %s (Duration: %s seconds)', GetPlayerName(player.id), GetPlayerName(src), reason, time))
    
    if banTime >= 2147483647 then
        DropPlayer(player.id, Lang:t('info.banned') .. '\n' .. reason .. Lang:t('info.ban_perm') .. QBCore.Config.Server.Discord)
    else
        DropPlayer(player.id, Lang:t('info.banned') .. '\n' .. reason .. Lang:t('info.ban_expires') .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Check our Discord for more information: ' .. QBCore.Config.Server.Discord)
    end
end)

RegisterNetEvent('qb-admin:server:banOffline', function(citizenid, time, reason)
    local src = source
    if not Config.EnableBanOffline then
        TriggerClientEvent('QBCore:Notify', src, 'Offline banning is disabled', 'error')
        return
    end
    
    if not HasPermission(src, 'ban_offline') then
        BanPlayer(src, 'Attempting to use offline ban without permission')
        return
    end
    
    MySQL.query('SELECT * FROM players WHERE citizenid = ? LIMIT 1', {citizenid}, function(result)
        if result[1] then
            time = tonumber(time)
            local banTime = tonumber(os.time() + time)
            if banTime > 2147483647 then
                banTime = 2147483647
            end
            
            local playerData = json.decode(result[1].charinfo) or {}
            local playerName = (playerData.firstname or 'Unknown') .. ' ' .. (playerData.lastname or 'Unknown')
            
            MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                playerName,
                result[1].license,
                result[1].discord or 'unknown',
                result[1].ip or 'unknown',
                reason,
                banTime,
                GetPlayerName(src)
            })
            
            SendLog('ban', 'Offline Player Banned', 'red', string.format('%s (CID: %s) was banned offline by %s for %s', playerName, citizenid, GetPlayerName(src), reason))
            TriggerClientEvent('QBCore:Notify', src, 'Player banned successfully', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Player not found with that Citizen ID', 'error')
        end
    end)
end)

RegisterNetEvent('qb-admin:server:unban', function(banId)
    local src = source
    if not HasPermission(src, 'unban') then
        BanPlayer(src, 'Attempting to use unban without permission')
        return
    end
    
    MySQL.query('DELETE FROM bans WHERE id = ?', {banId}, function(affectedRows)
        if affectedRows > 0 then
            SendLog('ban', 'Player Unbanned', 'green', string.format('Ban ID %s was removed by %s', banId, GetPlayerName(src)))
            TriggerClientEvent('QBCore:Notify', src, 'Player unbanned successfully', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Ban ID not found', 'error')
        end
    end)
end)

RegisterNetEvent('qb-admin:server:spectate', function(player)
    local src = source
    if not HasPermission(src, 'spectate') then
        BanPlayer(src, 'Attempting to use spectate without permission')
        return
    end
    
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)
    TriggerClientEvent('qb-admin:client:spectate', src, player.id, coords)
    SendLog('spectate', 'Player Spectating', 'blue', string.format('%s is spectating %s', GetPlayerName(src), GetPlayerName(player.id)))
end)

RegisterNetEvent('qb-admin:server:freeze', function(player)
    local src = source
    if not HasPermission(src, 'freeze') then
        BanPlayer(src, 'Attempting to use freeze without permission')
        return
    end
    
    local target = GetPlayerPed(player.id)
    local playerId = player.id
    
    if not frozen[playerId] then
        frozen[playerId] = true
        FreezeEntityPosition(target, true)
        TriggerClientEvent('QBCore:Notify', playerId, 'You have been frozen by an admin', 'error')
        TriggerClientEvent('QBCore:Notify', src, 'Player frozen', 'success')
        SendLog('freeze', 'Player Frozen', 'purple', string.format('%s froze %s', GetPlayerName(src), GetPlayerName(playerId)))
    else
        frozen[playerId] = false
        FreezeEntityPosition(target, false)
        TriggerClientEvent('QBCore:Notify', playerId, 'You have been unfrozen', 'success')
        TriggerClientEvent('QBCore:Notify', src, 'Player unfrozen', 'success')
        SendLog('freeze', 'Player Unfrozen', 'purple', string.format('%s unfroze %s', GetPlayerName(src), GetPlayerName(playerId)))
    end
end)

RegisterNetEvent('qb-admin:server:freezeall', function()
    local src = source
    if not HasPermission(src, 'freeze') then
        BanPlayer(src, 'Attempting to use freezeall without permission')
        return
    end
    
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        playerId = tonumber(playerId)
        if playerId ~= src then
            local target = GetPlayerPed(playerId)
            if not frozen[playerId] then
                frozen[playerId] = true
                FreezeEntityPosition(target, true)
                TriggerClientEvent('QBCore:Notify', playerId, 'You have been frozen by an admin', 'error')
            end
        end
    end
    
    SendLog('freeze', 'Mass Freeze', 'purple', string.format('%s froze all players', GetPlayerName(src)))
    TriggerClientEvent('QBCore:Notify', src, 'All players have been frozen', 'success')
end)

RegisterNetEvent('qb-admin:server:unfreezeall', function()
    local src = source
    if not HasPermission(src, 'freeze') then
        BanPlayer(src, 'Attempting to use unfreezeall without permission')
        return
    end
    
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        playerId = tonumber(playerId)
        local target = GetPlayerPed(playerId)
        if frozen[playerId] then
            frozen[playerId] = false
            FreezeEntityPosition(target, false)
            TriggerClientEvent('QBCore:Notify', playerId, 'You have been unfrozen', 'success')
        end
    end
    
    SendLog('freeze', 'Mass Unfreeze', 'purple', string.format('%s unfroze all players', GetPlayerName(src)))
    TriggerClientEvent('QBCore:Notify', src, 'All players have been unfrozen', 'success')
end)

RegisterNetEvent('qb-admin:server:bringplayer', function(player)
    local src = source
    if not HasPermission(src, 'bring') then
        BanPlayer(src, 'Attempting to use bring without permission')
        return
    end
    
    local coords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('qb-admin:client:teleportPlayer', player.id, coords)
    SendLog('teleport', 'Player Brought', 'cyan', string.format('%s brought %s to their location', GetPlayerName(src), GetPlayerName(player.id)))
end)

RegisterNetEvent('qb-admin:server:bringall', function()
    local src = source
    if not HasPermission(src, 'bring') then
        BanPlayer(src, 'Attempting to use bringall without permission')
        return
    end
    
    local coords = GetEntityCoords(GetPlayerPed(src))
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        playerId = tonumber(playerId)
        if playerId ~= src then
            TriggerClientEvent('qb-admin:client:teleportPlayer', playerId, coords)
        end
    end
    
    SendLog('teleport', 'Mass Bring', 'cyan', string.format('%s brought all players to their location', GetPlayerName(src)))
    TriggerClientEvent('QBCore:Notify', src, 'All players have been brought to you', 'success')
end)

RegisterNetEvent('qb-admin:server:sendAnnounce', function(message)
    local src = source
    if not HasPermission(src, 'announce') then
        BanPlayer(src, 'Attempting to use announce without permission')
        return
    end
    
    TriggerClientEvent('chat:addMessage', -1, {
        template = "<div class='chat-message server'><strong>📢 SERVER ANNOUNCEMENT:</strong> {0}</div>",
        args = { message }
    })
    
    TriggerClientEvent('QBCore:Notify', -1, message, 'primary', 10000)
    SendLog('announce', 'Server Announcement', 'lightblue', string.format('%s sent announcement: %s', GetPlayerName(src), message))
end)

RegisterNetEvent('qb-admin:server:givemoney', function(player, moneyType, amount)
    local src = source
    if not HasPermission(src, 'givemoney') then
        BanPlayer(src, 'Attempting to use givemoney without permission')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(player.id)
    if Player then
        Player.Functions.AddMoney(moneyType, amount, 'admin-menu')
        TriggerClientEvent('QBCore:Notify', player.id, 'You received $' .. amount .. ' ' .. moneyType, 'success')
        TriggerClientEvent('QBCore:Notify', src, 'Money given successfully', 'success')
        SendLog('money', 'Money Given', 'gold', string.format('%s gave %s $%s %s', GetPlayerName(src), GetPlayerName(player.id), amount, moneyType))
    end
end)

RegisterNetEvent('qb-admin:server:removemoney', function(player, moneyType, amount)
    local src = source
    if not HasPermission(src, 'removemoney') then
        BanPlayer(src, 'Attempting to use removemoney without permission')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(player.id)
    if Player then
        Player.Functions.RemoveMoney(moneyType, amount, 'admin-menu')
        TriggerClientEvent('QBCore:Notify', player.id, 'You lost $' .. amount .. ' ' .. moneyType, 'error')
        TriggerClientEvent('QBCore:Notify', src, 'Money removed successfully', 'success')
        SendLog('money', 'Money Removed', 'gold', string.format('%s removed $%s %s from %s', GetPlayerName(src), amount, moneyType, GetPlayerName(player.id)))
    end
end)

RegisterNetEvent('qb-admin:server:setjob', function(player, job, grade)
    local src = source
    if not HasPermission(src, 'setjob') then
        BanPlayer(src, 'Attempting to use setjob without permission')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(player.id)
    if Player then
        Player.Functions.SetJob(job, grade)
        TriggerClientEvent('QBCore:Notify', player.id, 'Your job has been set to ' .. job .. ' - Grade ' .. grade, 'success')
        TriggerClientEvent('QBCore:Notify', src, 'Job set successfully', 'success')
        SendLog('job', 'Job Set', 'darkgreen', string.format('%s set %s job to %s (Grade: %s)', GetPlayerName(src), GetPlayerName(player.id), job, grade))
    end
end)

RegisterNetEvent('qb-admin:server:setgang', function(player, gang, grade)
    local src = source
    if not HasPermission(src, 'setgang') then
        BanPlayer(src, 'Attempting to use setgang without permission')
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(player.id)
    if Player then
        Player.Functions.SetGang(gang, grade)
        TriggerClientEvent('QBCore:Notify', player.id, 'Your gang has been set to ' .. gang .. ' - Grade ' .. grade, 'success')
        TriggerClientEvent('QBCore:Notify', src, 'Gang set successfully', 'success')
        SendLog('gang', 'Gang Set', 'darkred', string.format('%s set %s gang to %s (Grade: %s)', GetPlayerName(src), GetPlayerName(player.id), gang, grade))
    end
end)

RegisterNetEvent('qb-admin:server:screenshot', function(player)
    local src = source
    if not Config.EnableScreenshots then
        TriggerClientEvent('QBCore:Notify', src, 'Screenshots are disabled', 'error')
        return
    end
    
    if not HasPermission(src, 'screenshot') then
        BanPlayer(src, 'Attempting to use screenshot without permission')
        return
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'Taking screenshot...', 'primary')
    exports['screenshot-basic']:requestClientScreenshot(player.id, {}, function(url)
        SendLog('admin_action', 'Screenshot Taken', 'lightred', string.format('%s took a screenshot of %s\nScreenshot: %s', GetPlayerName(src), GetPlayerName(player.id), url))
        TriggerClientEvent('QBCore:Notify', src, 'Screenshot taken and logged', 'success')
    end)
end)

-- Initialize
CreateThread(function()
    GlobalState.ServerStartTime = os.time()
end)
