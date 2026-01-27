-- Server Utility Functions
QBCore = exports['qb-core']:GetCoreObject()

-- Format time function
function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Check if player is online
function IsPlayerOnline(citizenid)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    return Player ~= nil
end

-- Get player name by citizenid
function GetPlayerNameByCID(citizenid)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player then
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    end
    return 'Unknown'
end

-- Validate reason length
function ValidateReason(reason, minLength)
    if not reason or reason == '' then
        return false, 'Reason cannot be empty'
    end
    if #reason < minLength then
        return false, 'Reason must be at least ' .. minLength .. ' characters'
    end
    return true, reason
end

-- Format money
function FormatMoney(amount)
    return '$' .. string.format("%,d", amount):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Get all online players with details
function GetOnlinePlayersDetails()
    local players = {}
    local QBPlayers = QBCore.Functions.GetQBPlayers()
    
    for id, player in pairs(QBPlayers) do
        table.insert(players, {
            id = id,
            name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
            citizenid = player.PlayerData.citizenid,
            job = player.PlayerData.job.name,
            jobGrade = player.PlayerData.job.grade.level,
            gang = player.PlayerData.gang.name,
            gangGrade = player.PlayerData.gang.grade.level,
            cash = player.PlayerData.money.cash,
            bank = player.PlayerData.money.bank,
            phone = player.PlayerData.charinfo.phone
        })
    end
    
    return players
end

-- Ban duration presets
BanDurations = {
    ['1hour'] = 3600,
    ['6hours'] = 21600,
    ['12hours'] = 43200,
    ['1day'] = 86400,
    ['3days'] = 259200,
    ['1week'] = 604800,
    ['2weeks'] = 1209600,
    ['1month'] = 2592000,
    ['3months'] = 7776000,
    ['6months'] = 15552000,
    ['1year'] = 31536000,
    ['permanent'] = 2147483647
}

-- Get ban duration in seconds
function GetBanDuration(preset)
    return BanDurations[preset] or BanDurations['1day']
end

-- Check if string is valid vector4
function IsValidVector4(str)
    local pattern = "vector4%(%-?%d+%.?%d*, %-?%d+%.?%d*, %-?%d+%.?%d*, %-?%d+%.?%d*%)"
    return string.match(str, pattern) ~= nil
end

-- Sanitize input
function SanitizeInput(input)
    if not input then return '' end
    -- Remove potentially dangerous characters
    input = string.gsub(input, "[<>\"']", "")
    return input
end

-- Check permission with fallback
function HasPermissionSafe(src, permission)
    if not src or src == 0 then return false end
    if not permission then return false end
    
    local hasPerm = QBCore.Functions.HasPermission(src, Config.Permissions[permission])
    local hasAce = IsPlayerAceAllowed(src, 'command')
    
    return hasPerm or hasAce
end

-- Rate limiting
local RateLimits = {}

function CheckRateLimit(src, action, maxCalls, timeWindow)
    if not RateLimits[src] then
        RateLimits[src] = {}
    end
    
    if not RateLimits[src][action] then
        RateLimits[src][action] = {
            calls = 0,
            reset = os.time() + timeWindow
        }
    end
    
    local limit = RateLimits[src][action]
    
    if os.time() > limit.reset then
        limit.calls = 0
        limit.reset = os.time() + timeWindow
    end
    
    limit.calls = limit.calls + 1
    
    if limit.calls > maxCalls then
        return false, 'Rate limit exceeded. Please wait.'
    end
    
    return true
end

-- Clean up rate limits periodically
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        local currentTime = os.time()
        for src, actions in pairs(RateLimits) do
            for action, limit in pairs(actions) do
                if currentTime > limit.reset then
                    RateLimits[src][action] = nil
                end
            end
        end
    end
end)
