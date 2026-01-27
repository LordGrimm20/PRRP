-- Server Permission Helper Functions
QBCore = exports['qb-core']:GetCoreObject()

-- Get player's rank/permission level
function GetPlayerRank(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil end
    return Player.PlayerData.permission or 'user'
end

-- Check if player has required permission level
function HasPermissionLevel(src, requiredRank)
    local playerRank = GetPlayerRank(src)
    if not playerRank then return false end
    
    local playerLevel = Config.PermissionHierarchy[playerRank] or 0
    local requiredLevel = Config.PermissionHierarchy[requiredRank] or 0
    
    return playerLevel >= requiredLevel
end

-- Check if player can use a specific feature
function CanUseFeature(src, feature)
    local requiredRank = Config.FeaturePermissions[feature]
    if not requiredRank then return true end -- No permission set = everyone can use
    
    return HasPermissionLevel(src, requiredRank)
end

-- Check if player can see a category
function CanSeeCategory(src, category)
    local requiredRank = Config.CategoryPermissions[category]
    if not requiredRank then return true end
    
    return HasPermissionLevel(src, requiredRank)
end

-- Get player's permission data (for sending to client)
function GetPlayerPermissions(src)
    local playerRank = GetPlayerRank(src)
    
    return {
        rank = playerRank,
        level = Config.PermissionHierarchy[playerRank] or 0,
        displayName = Config.StaffRanks[playerRank] or playerRank,
        categories = {},
        features = {}
    }
end

-- Log admin action with permission info
function LogAdminAction(src, action, target, data)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local rank = GetPlayerRank(src)
    local targetName = target and GetPlayerName(target) or 'N/A'
    
    local logMessage = string.format(
        '**Admin:** %s (%s)\n**Action:** %s\n**Target:** %s\n**Data:** %s',
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        rank,
        action,
        targetName,
        data or 'None'
    )
    
    SendLog('admin_action', 'Admin Action', 'lightred', logMessage)
end

print('^2[qb-adminmenu]^7 Permission system loaded ^2✓^7')
