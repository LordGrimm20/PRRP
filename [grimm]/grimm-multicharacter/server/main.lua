--[[
    GRIMM-MULTICHARACTER | Server
    Lua 5.4 | QBCore Framework
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---@param src number Player source
---@return table identifiers {license, discord, steam}
local function GetIdentifiers(src)
    local identifiers = {
        license = nil,
        discord = nil,
        steam = nil
    }
    
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        local prefix, value = id:match("^(%w+):(.+)$")
        if prefix == "license" then
            identifiers.license = id
        elseif prefix == "discord" then
            identifiers.discord = value
        elseif prefix == "steam" then
            identifiers.steam = id
        end
    end
    
    return identifiers
end

---@param src number Player source
---@return number slots, string|nil tier
local function GetPlayerSlots(src)
    local slots = Config.DefaultSlots
    local tier = nil
    
    if not Config.UseDiscordRoles then
        return slots, tier
    end
    
    local identifiers = GetIdentifiers(src)
    if not identifiers.discord then
        return slots, tier
    end
    
    -- Check for Discord resource
    local discordResource = nil
    if GetResourceState('grimm-discord') == 'started' then
        discordResource = 'grimm-discord'
    elseif GetResourceState('roots-discord') == 'started' then
        discordResource = 'roots-discord'
    end
    
    if not discordResource then
        return slots, tier
    end
    
    -- Check staff roles
    for _, roleId in ipairs(Config.StaffRoles) do
        local success, hasRole = pcall(exports[discordResource].HasRole, exports[discordResource], identifiers.discord, roleId)
        if success and hasRole then
            return Config.MaxSlots, 'Staff'
        end
    end
    
    -- Check Patreon tiers
    local highestBonus = 0
    for _, tierData in ipairs(Config.PatreonTiers) do
        local success, hasRole = pcall(exports[discordResource].HasRole, exports[discordResource], identifiers.discord, tierData.roleId)
        if success and hasRole and tierData.bonusSlots > highestBonus then
            highestBonus = tierData.bonusSlots
            tier = tierData.tierName
        end
    end
    
    return slots + highestBonus, tier
end

---@return string citizenId
local function GenerateCitizenId()
    local citizenId = string.upper(QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(5))
    local result = MySQL.scalar.await('SELECT 1 FROM players WHERE citizenid = ?', { citizenId })
    
    if result then
        return GenerateCitizenId()
    end
    
    return citizenId
end

---@param str string
---@return boolean
local function IsValidName(str)
    return str and #str >= Config.MinNameLength and #str <= Config.MaxNameLength and str:match("^[A-Za-z'-]+$")
end

-- =====================================
-- CALLBACKS
-- =====================================

QBCore.Functions.CreateCallback('grimm-multicharacter:server:getCharacters', function(source, cb)
    local src = source
    local identifiers = GetIdentifiers(src)
    local license = identifiers.license
    
    if not license then
        cb({ characters = {}, maxSlots = Config.DefaultSlots, patreonTier = nil, nationalities = Config.Nationalities, spawnLocations = Config.SpawnLocations })
        return
    end
    
    local maxSlots, patreonTier = GetPlayerSlots(src)
    
    local characters = MySQL.query.await([[
        SELECT 
            citizenid,
            charinfo,
            money,
            job,
            last_updated
        FROM players 
        WHERE license = ?
        ORDER BY last_updated DESC
    ]], { license })
    
    local charList = {}
    
    if characters then
        for _, row in ipairs(characters) do
            local charinfo = json.decode(row.charinfo) or {}
            local money = json.decode(row.money) or {}
            local job = json.decode(row.job) or {}
            
            charList[#charList + 1] = {
                citizenid = row.citizenid,
                firstname = charinfo.firstname or 'Unknown',
                lastname = charinfo.lastname or 'Unknown',
                birthdate = charinfo.birthdate or '01/01/2000',
                gender = tonumber(charinfo.gender) or 0,
                nationality = charinfo.nationality or 'Unknown',
                cash = tonumber(money.cash) or 0,
                bank = tonumber(money.bank) or 0,
                job = job.label or 'Unemployed',
                lastPlayed = row.last_updated
            }
        end
    end
    
    cb({
        characters = charList,
        maxSlots = maxSlots,
        patreonTier = patreonTier,
        nationalities = Config.Nationalities,
        spawnLocations = Config.SpawnLocations
    })
end)

QBCore.Functions.CreateCallback('grimm-multicharacter:server:getCharacterData', function(source, cb, citizenid)
    local src = source
    local identifiers = GetIdentifiers(src)
    local license = identifiers.license
    
    if not license or not citizenid then
        cb(nil)
        return
    end
    
    -- Security: Verify ownership
    local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? AND license = ?', { citizenid, license })
    
    if not result or #result == 0 then
        cb(nil)
        return
    end
    
    local playerData = result[1]
    local skinResult = MySQL.query.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    local skin = skinResult and skinResult[1] and skinResult[1].skin and json.decode(skinResult[1].skin) or nil
    
    cb({
        citizenid = playerData.citizenid,
        charinfo = json.decode(playerData.charinfo),
        money = json.decode(playerData.money),
        job = json.decode(playerData.job),
        gang = json.decode(playerData.gang),
        position = json.decode(playerData.position),
        metadata = json.decode(playerData.metadata),
        skin = skin
    })
end)

QBCore.Functions.CreateCallback('grimm-multicharacter:server:createCharacter', function(source, cb, charData)
    local src = source
    local identifiers = GetIdentifiers(src)
    local license = identifiers.license
    
    if not license then
        cb({ success = false, message = 'No license found' })
        return
    end
    
    -- Security: Validate input
    if not charData or type(charData) ~= 'table' then
        cb({ success = false, message = 'Invalid data' })
        return
    end
    
    local firstName = charData.firstName and tostring(charData.firstName):gsub('%s+', '') or ''
    local lastName = charData.lastName and tostring(charData.lastName):gsub('%s+', '') or ''
    
    if not IsValidName(firstName) then
        cb({ success = false, message = 'Invalid first name' })
        return
    end
    
    if not IsValidName(lastName) then
        cb({ success = false, message = 'Invalid last name' })
        return
    end
    
    -- Check slot limit
    local maxSlots = GetPlayerSlots(src)
    local countResult = MySQL.scalar.await('SELECT COUNT(*) FROM players WHERE license = ?', { license })
    
    if countResult and countResult >= maxSlots then
        cb({ success = false, message = 'Max characters reached' })
        return
    end
    
    local citizenid = GenerateCitizenId()
    local gender = charData.gender == 'female' and 1 or 0
    
    local charinfo = {
        firstname = firstName:sub(1, 1):upper() .. firstName:sub(2):lower(),
        lastname = lastName:sub(1, 1):upper() .. lastName:sub(2):lower(),
        birthdate = charData.dob or '01/01/2000',
        gender = gender,
        nationality = charData.nationality or 'Unknown',
        phone = QBCore.Shared.RandomInt(10),
        account = 'US0' .. QBCore.Shared.RandomInt(9)
    }
    
    local money = { cash = 500, bank = 5000, crypto = 0 }
    local job = { name = 'unemployed', label = 'Unemployed', payment = 0, onduty = false, isboss = false, grade = { name = 'Freelancer', level = 0 } }
    local gang = { name = 'none', label = 'No Gang', isboss = false, grade = { name = 'None', level = 0 } }
    local position = { x = Config.DefaultSpawn.x, y = Config.DefaultSpawn.y, z = Config.DefaultSpawn.z, w = Config.DefaultSpawn.w }
    
    local metadata = {
        hunger = 100,
        thirst = 100,
        stress = 0,
        armor = 0,
        ishandcuffed = false,
        tracker = false,
        injail = 0,
        jailitems = {},
        status = {},
        phone = {},
        rep = {},
        inside = { house = nil, apartment = { apartmentType = nil, apartmentId = nil } },
        bloodtype = QBCore.Config.Player.Bloodtypes[math.random(#QBCore.Config.Player.Bloodtypes)],
        fingerprint = QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(1) .. QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(4),
        walletid = 'QB-' .. QBCore.Shared.RandomInt(5) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(2),
        criminalrecord = { hasRecord = false, date = nil },
        licences = { driver = true, business = false, weapon = false },
        jobrep = { tow = 0, trucker = 0, taxi = 0, hotdog = 0 },
        callsign = 'NO-CALLSIGN',
        isdead = false
    }
    
    local playerName = GetPlayerName(src)
    
    MySQL.insert.await([[
        INSERT INTO players (citizenid, license, name, charinfo, money, job, gang, position, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid,
        license,
        playerName,
        json.encode(charinfo),
        json.encode(money),
        json.encode(job),
        json.encode(gang),
        json.encode(position),
        json.encode(metadata)
    })
    
    TriggerEvent(Config.Events.onCharacterCreated, src, citizenid)
    
    cb({ success = true, citizenid = citizenid })
end)

QBCore.Functions.CreateCallback('grimm-multicharacter:server:deleteCharacter', function(source, cb, citizenid)
    local src = source
    local identifiers = GetIdentifiers(src)
    local license = identifiers.license
    
    if not license or not citizenid then
        cb({ success = false })
        return
    end
    
    -- Security: Verify ownership
    local result = MySQL.scalar.await('SELECT 1 FROM players WHERE citizenid = ? AND license = ?', { citizenid, license })
    
    if not result then
        cb({ success = false })
        return
    end
    
    MySQL.query.await('DELETE FROM players WHERE citizenid = ?', { citizenid })
    MySQL.query.await('DELETE FROM playerskins WHERE citizenid = ?', { citizenid })
    MySQL.query.await('DELETE FROM player_outfits WHERE citizenid = ?', { citizenid })
    
    TriggerEvent(Config.Events.onCharacterDeleted, src, citizenid)
    
    cb({ success = true })
end)

QBCore.Functions.CreateCallback('grimm-multicharacter:server:loadCharacter', function(source, cb, citizenid, spawnId)
    local src = source
    local identifiers = GetIdentifiers(src)
    local license = identifiers.license
    
    if not license or not citizenid then
        cb({ success = false, isNew = false })
        return
    end
    
    -- Security: Verify ownership
    local result = MySQL.scalar.await('SELECT 1 FROM players WHERE citizenid = ? AND license = ?', { citizenid, license })
    
    if not result then
        cb({ success = false, isNew = false })
        return
    end
    
    -- Check if new character (no skin record exists)
    local skinResult = MySQL.scalar.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    local isNew = false

    if not skinResult then
        -- No skin record at all = new character
        isNew = true
    elseif skinResult == '{}' or skinResult == '' or skinResult == 'null' or skinResult == '[]' then
        -- Empty skin record = created but never customized
        isNew = true
    end

    -- Load character
    local success = QBCore.Player.Login(src, citizenid)

    if success then
        MySQL.update('UPDATE players SET last_updated = NOW() WHERE citizenid = ?', { citizenid })
        
        -- Spawn location is handled client-side
        cb({ success = true, isNew = isNew, spawnId = spawnId })
    else
        cb({ success = false, isNew = false })
    end
end)

-- =====================================
-- COMMANDS
-- =====================================

QBCore.Commands.Add('logout', 'Return to character selection', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        TriggerClientEvent('grimm-multicharacter:client:open', src)
    end
end, 'user')

-- =====================================
-- RESOURCE START
-- =====================================

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    print('^2[grimm-multicharacter] ^7Server started')
    print('^2[grimm-multicharacter] ^7Slots: ' .. Config.DefaultSlots .. ' (max: ' .. Config.MaxSlots .. ')')
end)
