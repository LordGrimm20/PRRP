-- ██████╗  ██████╗  ██████╗ ████████╗███████╗
-- ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝
-- ██████╔╝██║   ██║██║   ██║   ██║   ███████╗
-- ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║
-- ██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████║
-- ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
-- Appearance Server

local QBCore = exports['qb-core']:GetCoreObject()

-- =====================================
-- DATABASE SETUP
-- =====================================

MySQL.ready(function()
    -- Create playerskins table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `playerskins` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `citizenid` VARCHAR(50) NOT NULL,
            `skin` LONGTEXT,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY `citizenid` (`citizenid`)
        )
    ]])
    
    -- Create player_outfits table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `player_outfits` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `citizenid` VARCHAR(50) NOT NULL,
            `name` VARCHAR(100) NOT NULL,
            `outfit` LONGTEXT,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX `citizenid_idx` (`citizenid`)
        )
    ]])
    
    print('^2[grimm-appearance] Database tables verified^0')
end)

-- =====================================
-- EVENTS
-- =====================================

RegisterNetEvent('grimm-appearance:server:saveAppearance', function(appearance)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local skinData = json.encode(appearance)
    
    MySQL.query([[
        INSERT INTO playerskins (citizenid, skin) 
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE skin = VALUES(skin)
    ]], { citizenid, skinData })
    
    print('^2[grimm-appearance] Saved appearance for ' .. citizenid .. '^0')
end)

RegisterNetEvent('grimm-appearance:server:saveOutfit', function(outfitName, outfitData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM player_outfits WHERE citizenid = ?', { citizenid })
    
    if count >= Config.MaxOutfits then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.max_outfits'), 'error')
        return
    end
    
    MySQL.insert('INSERT INTO player_outfits (citizenid, outfitname, skin) VALUES (?, ?, ?)', {
        citizenid,
        outfitName,
        json.encode(outfitData)
    })
    
    TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.outfit_saved', { outfitName }), 'success')
end)

RegisterNetEvent('grimm-appearance:server:deleteOutfit', function(outfitId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    MySQL.query('DELETE FROM player_outfits WHERE id = ? AND citizenid = ?', { outfitId, citizenid })
    TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.outfit_deleted'), 'success')
end)

-- =====================================
-- CALLBACKS
-- =====================================

QBCore.Functions.CreateCallback('grimm-appearance:server:getSkin', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then cb(nil) return end
    
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    
    if result and #result > 0 and result[1].skin then
        cb(json.decode(result[1].skin))
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback('grimm-appearance:server:getOutfits', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then cb({}) return end
    
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT id, outfitname as name FROM player_outfits WHERE citizenid = ? ORDER BY id DESC', { citizenid })
    
    cb(result or {})
end)

QBCore.Functions.CreateCallback('grimm-appearance:server:getOutfit', function(source, cb, outfitId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then cb(nil) return end
    
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT skin as outfit FROM player_outfits WHERE id = ?', { outfitId, citizenid })
    
    if result and #result > 0 and result[1].outfit then
        cb(json.decode(result[1].outfit))
    else
        cb(nil)
    end
end)

-- =====================================
-- COMMANDS
-- =====================================

QBCore.Commands.Add('appearance', 'Open appearance menu (Admin)', {}, false, function(source)
    TriggerClientEvent('grimm-appearance:open', source, false)
end, 'admin')

QBCore.Commands.Add('clothes', 'Open clothing menu', {}, false, function(source)
    TriggerClientEvent('grimm-appearance:client:openClothing', source)
end, 'user')

-- =====================================
-- EXPORTS
-- =====================================

exports('GetPlayerSkin', function(citizenid)
    local result = MySQL.query.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    if result and #result > 0 and result[1].skin then
        return json.decode(result[1].skin)
    end
    return nil
end)

exports('SavePlayerSkin', function(citizenid, skinData)
    MySQL.query([[
        INSERT INTO playerskins (citizenid, skin) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE skin = VALUES(skin)
    ]], { citizenid, json.encode(skinData) })
end)

print('^2[grimm-appearance] Resource started successfully^0')
