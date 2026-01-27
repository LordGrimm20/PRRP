Config = Config or {}

-- =============================================
-- UI CUSTOMIZATION SETTINGS
-- =============================================

-- Menu Appearance
Config.UI = {
    -- Menu position: 'topright', 'topleft', 'bottomright', 'bottomleft'
    Position = 'topright',
    
    -- Menu size: 'default', 'large', 'small'
    Size = 'default',
    
    -- Theme: 'dark', 'light', 'blue', 'red', 'green', 'purple'
    Theme = 'dark',
    
    -- Show icons in menu
    ShowIcons = true,
    
    -- Show descriptions
    ShowDescriptions = true,
    
    -- Menu width (in pixels)
    Width = 220,
    
    -- Menu animation: 'slide', 'fade', 'none'
    Animation = 'slide',
}

-- Menu Organization (Show/Hide entire categories)
Config.MenuCategories = {
    AdminOptions = true,        -- Personal admin tools
    PlayerManagement = true,    -- Player control options
    ServerManagement = true,    -- Weather, time, announcements
    VehicleOptions = true,      -- Vehicle spawning and management
    DeveloperOptions = true,    -- Dev tools, coords, entity view
    DealerList = true,         -- Drug dealer management (requires qb-drugs)
}

-- Quick Actions (Show in main menu for fast access)
Config.QuickActions = {
    NoClip = true,             -- Add noclip toggle to main menu
    Revive = true,             -- Add self-revive to main menu
    GodMode = false,           -- Add god mode toggle to main menu
    DeleteVehicle = true,      -- Add delete vehicle to main menu
    Teleport = false,          -- Add quick teleport to main menu
}

-- =============================================
-- PERMISSION SYSTEM
-- =============================================

--[[
    Permission Levels (Hierarchical):
    - god: Full access to everything
    - admin: Most admin functions
    - mod: Moderate access, player management
    - support: Basic support functions only
    
    Higher ranks inherit lower rank permissions
]]

-- Define which ranks can see which menu categories
Config.CategoryPermissions = {
    ['AdminOptions'] = 'support',        -- support and above
    ['PlayerManagement'] = 'mod',        -- mod and above
    ['ServerManagement'] = 'admin',      -- admin and above
    ['VehicleOptions'] = 'mod',          -- mod and above
    ['DeveloperOptions'] = 'admin',      -- admin and above
    ['DealerList'] = 'admin',            -- admin and above
}

-- Individual Feature Permissions (Granular Control)
Config.FeaturePermissions = {
    -- Admin Options
    ['noclip'] = 'support',
    ['revive_self'] = 'support',
    ['revive_all'] = 'admin',
    ['invisible'] = 'mod',
    ['godmode'] = 'mod',
    ['display_blips'] = 'support',
    ['display_names'] = 'support',
    ['spawn_weapons'] = 'admin',
    
    -- Player Management
    ['view_players'] = 'support',
    ['spectate'] = 'mod',
    ['teleport_to_player'] = 'mod',
    ['bring_player'] = 'mod',
    ['freeze_player'] = 'mod',
    ['freeze_all'] = 'admin',
    ['kick'] = 'mod',
    ['ban'] = 'admin',
    ['ban_offline'] = 'god',
    ['unban'] = 'god',
    ['warn'] = 'mod',
    ['kill'] = 'admin',
    ['revive_player'] = 'support',
    ['inventory'] = 'mod',
    ['clothing'] = 'mod',
    ['give_money'] = 'admin',
    ['remove_money'] = 'admin',
    ['set_job'] = 'admin',
    ['set_gang'] = 'admin',
    ['screenshot'] = 'mod',
    ['permissions'] = 'god',
    
    -- Server Management
    ['weather'] = 'admin',
    ['time'] = 'admin',
    ['announcement'] = 'admin',
    ['mass_actions'] = 'admin',
    ['quick_teleport'] = 'admin',
    ['ban_management'] = 'admin',
    ['server_info'] = 'support',
    ['kickall'] = 'god',
    
    -- Vehicle Options
    ['spawn_vehicle'] = 'mod',
    ['delete_vehicle'] = 'mod',
    ['fix_vehicle'] = 'mod',
    ['max_upgrades'] = 'admin',
    ['save_vehicle'] = 'admin',
    
    -- Developer Options
    ['coords'] = 'admin',
    ['copy_coords'] = 'admin',
    ['vehicle_dev_mode'] = 'admin',
    ['entity_view'] = 'admin',
}

-- Permission Hierarchy (Higher includes all lower)
Config.PermissionHierarchy = {
    ['god'] = 4,
    ['admin'] = 3,
    ['mod'] = 2,
    ['support'] = 1,
}

-- =============================================
-- MENU CUSTOMIZATION PER PERMISSION LEVEL
-- =============================================

-- Customize what each rank sees in player management
Config.PlayerManagementOptions = {
    ['support'] = {
        'spectate',
        'goto',
        'revive',
        'inventory',
    },
    ['mod'] = {
        'spectate',
        'goto',
        'bring',
        'freeze',
        'revive',
        'inventory',
        'clothing',
        'kick',
        'warn',
        'screenshot',
    },
    ['admin'] = {
        'kill',
        'revive',
        'freeze',
        'spectate',
        'goto',
        'bring',
        'intovehicle',
        'inventory',
        'clothing',
        'give_money',
        'remove_money',
        'set_job',
        'set_gang',
        'kick',
        'ban',
        'warn',
        'screenshot',
    },
    ['god'] = {
        'kill',
        'revive',
        'freeze',
        'spectate',
        'goto',
        'bring',
        'intovehicle',
        'inventory',
        'clothing',
        'give_money',
        'remove_money',
        'set_job',
        'set_gang',
        'kick',
        'ban',
        'screenshot',
        'permissions',
    },
}

-- =============================================
-- EXISTING SETTINGS
-- =============================================

Config.MenuLocation = Config.UI.Position or 'topright'

Config.Permissions = {
    ['kill'] = 'admin',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'god',
    ['kick'] = 'admin',
    ['revive'] = 'admin',
    ['freeze'] = 'admin',
    ['goto'] = 'admin',
    ['spectate'] = 'admin',
    ['intovehicle'] = 'admin',
    ['bring'] = 'admin',
    ['inventory'] = 'admin',
    ['clothing'] = 'admin',
    ['announce'] = 'admin',
    ['screenshot'] = 'admin',
    ['ban_offline'] = 'god',
    ['unban'] = 'god',
    ['givemoney'] = 'admin',
    ['removemoney'] = 'admin',
    ['setjob'] = 'admin',
    ['setgang'] = 'admin',
    ['drunk'] = 'admin',
    ['armor'] = 'admin',
    ['hunger'] = 'admin',
    ['thirst'] = 'admin',
    ['stress'] = 'admin',
}

-- Feature Toggles
Config.EnableScreenshots = true
Config.EnableAdvancedLogs = true
Config.EnableAntiCheat = true
Config.EnablePlayerReports = true
Config.EnableBanOffline = true
Config.EnableDrugDealers = true

-- NoClip Settings
Config.NoClip = {
    Speed = 1.0,
    MaxSpeed = 16.0,
    PedFirstPerson = true,
    VehFirstPerson = false,
    ESCEnable = false,
}

-- Spectate Settings
Config.Spectate = {
    ShowPlayerInfo = true,
    ShowHUD = true,
}

-- Vehicle Spawn Settings
Config.VehicleSpawn = {
    SpawnInVehicle = true,
    SpawnMaxed = false,
    ReplaceVehicle = true,
}

-- Teleport Settings
Config.Teleport = {
    FadeScreen = true,
    FadeDuration = 500,
}

-- Ban Settings
Config.Ban = {
    MinReason = 5,
    DefaultTime = 86400,
    ShowBanMessage = true,
}

-- Kick Settings
Config.Kick = {
    MinReason = 5,
}

-- Freeze Settings
Config.Freeze = {
    ShowNotification = true,
}

-- Player Blips
Config.Blips = {
    UpdateInterval = 1000,
    ShowOffDuty = true,
}

-- Developer Mode
Config.Developer = {
    EnableCoordsCopy = true,
    EnableVehicleDevMode = true,
    EnableEntityView = true,
}

-- Logs Configuration
Config.Logs = {
    ['ban'] = { webhook = '', color = 16711680 },
    ['kick'] = { webhook = '', color = 16744192 },
    ['warn'] = { webhook = '', color = 16776960 },
    ['revive'] = { webhook = '', color = 65280 },
    ['kill'] = { webhook = '', color = 16711680 },
    ['spectate'] = { webhook = '', color = 3447003 },
    ['freeze'] = { webhook = '', color = 10181046 },
    ['teleport'] = { webhook = '', color = 3066993 },
    ['announce'] = { webhook = '', color = 15105570 },
    ['money'] = { webhook = '', color = 15844367 },
    ['job'] = { webhook = '', color = 5763719 },
    ['gang'] = { webhook = '', color = 10038562 },
    ['vehicle'] = { webhook = '', color = 9807270 },
    ['weapon'] = { webhook = '', color = 8359053 },
    ['admin_action'] = { webhook = '', color = 15158332 },
}

-- Quick Teleport Locations
Config.TeleportLocations = {
    ['LSPD'] = vector4(428.9, -984.5, 30.7, 180.0),
    ['Pillbox Hospital'] = vector4(298.5, -584.5, 43.2, 70.0),
    ['Legion Square'] = vector4(195.2, -933.9, 30.7, 140.0),
    ['Paleto Bay'] = vector4(-248.5, 6331.8, 32.4, 220.0),
    ['Sandy Shores'] = vector4(1852.5, 3686.9, 34.2, 210.0),
    ['Prison'] = vector4(1679.0, 2513.7, 45.5, 0.0),
    ['Airport'] = vector4(-1037.8, -2738.9, 13.7, 330.0),
    ['Docks'] = vector4(1212.0, -3008.6, 5.9, 270.0),
    ['Casino'] = vector4(924.0, 47.5, 81.0, 60.0),
    ['Fort Zancudo'] = vector4(-2360.0, 3249.0, 32.8, 240.0),
    ['Mount Chiliad'] = vector4(501.8, 5604.5, 797.9, 180.0),
}

-- Announcement Presets
Config.AnnouncementPresets = {
    ['Restart'] = 'Server restart in %s minutes!',
    ['Event'] = 'Server event starting soon!',
    ['Maintenance'] = 'Server maintenance in progress.',
    ['Update'] = 'New update deployed!',
}

-- Blocked Ped Models
Config.BlockedPeds = {
    'mp_m_freemode_01',
    'mp_f_freemode_01',
    'tony',
    'g_m_m_chigoon_02_m',
    'u_m_m_jesus_01',
    'a_m_y_stbla_m',
    'ig_terry_m',
    'a_m_m_ktown_m',
    'a_m_y_skater_m',
    'u_m_y_coop',
    'ig_car3guy1_m',
}

-- Weather Options
Config.WeatherTypes = {
    'EXTRASUNNY',
    'CLEAR',
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'THUNDER',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'XMAS',
    'HALLOWEEN',
}

-- Staff Ranks Display Names
Config.StaffRanks = {
    ['god'] = '👑 Owner',
    ['admin'] = '⚡ Administrator',
    ['mod'] = '🛡️ Moderator',
    ['support'] = '💬 Support',
}

-- =============================================
-- UI ICONS (Customizable per feature)
-- =============================================

Config.Icons = {
    -- Categories
    admin_options = '⚙️',
    player_management = '👥',
    server_management = '🖥️',
    vehicle_options = '🚗',
    developer_options = '🔧',
    dealer_list = '💊',
    
    -- Actions
    noclip = '✈️',
    revive = '💊',
    godmode = '🛡️',
    invisible = '👻',
    spectate = '👁️',
    freeze = '🧊',
    teleport = '📍',
    kill = '💀',
    kick = '🚪',
    ban = '🔨',
    warn = '⚠️',
    money = '💰',
    vehicle = '🚙',
    weather = '🌤️',
    time = '⏰',
    announcement = '📢',
}

-- =============================================
-- HELPER FUNCTIONS
-- =============================================

-- Check if player has permission for a feature
function Config.HasPermission(playerRank, requiredRank)
    local playerLevel = Config.PermissionHierarchy[playerRank] or 0
    local requiredLevel = Config.PermissionHierarchy[requiredRank] or 0
    return playerLevel >= requiredLevel
end

-- Get player's permission level
function Config.GetPermissionLevel(rank)
    return Config.PermissionHierarchy[rank] or 0
end

-- Check if category should be visible for rank
function Config.CanSeeCategory(rank, category)
    local requiredRank = Config.CategoryPermissions[category]
    if not requiredRank then return true end
    return Config.HasPermission(rank, requiredRank)
end

-- Check if feature should be available for rank
function Config.CanUseFeature(rank, feature)
    local requiredRank = Config.FeaturePermissions[feature]
    if not requiredRank then return true end
    return Config.HasPermission(rank, requiredRank)
end

return Config
