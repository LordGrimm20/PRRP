-- QB-AdminMenu Enhanced - Client
-- Variables
QBCore = exports['qb-core']:GetCoreObject()

-- Initialize Config if not loaded
if not Config then
    Config = {}
    print('^3[qb-adminmenu] Warning: Config not loaded, using defaults^7')
end

-- Set default config values if not present
Config.MenuLocation = Config.MenuLocation or 'topright'
Config.VehicleSpawn = Config.VehicleSpawn or {
    SpawnInVehicle = true,
    SpawnMaxed = false,
    ReplaceVehicle = true
}

-- Wait for QBCore to be ready
CreateThread(function()
    while not QBCore do
        Wait(100)
        QBCore = exports['qb-core']:GetCoreObject()
    end
    print('[qb-adminmenu] QBCore loaded successfully')
end)

-- Check if MenuV is loaded
CreateThread(function()
    Wait(1000)
    if MenuV then
        print('[qb-adminmenu] MenuV loaded successfully')
    else
        print('^1[qb-adminmenu] ERROR: MenuV is not loaded! Make sure menuv resource is started.^7')
    end
end)

local banlength = nil
local developermode = false
local showCoords = false
local vehicleDevMode = false
local banreason = 'Unknown'
local kickreason = 'Unknown'
local menuLocation = Config.MenuLocation or 'topright'

-- Main Menus
local menu1 = MenuV:CreateMenu(false, Lang:t('menu.admin_menu'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test1')
local menu2 = MenuV:CreateMenu(false, Lang:t('menu.admin_options'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test2')
local menu3 = MenuV:CreateMenu(false, Lang:t('menu.manage_server'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test3')
local menu4 = MenuV:CreateMenu(false, Lang:t('menu.online_players'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test4')
local menu5 = MenuV:CreateMenu(false, Lang:t('menu.vehicle_options'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test5')
local menu6 = MenuV:CreateMenu(false, Lang:t('menu.dealer_list'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test6')
local menu7 = MenuV:CreateMenu(false, Lang:t('menu.developer_options'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test7')

-- Sub Menus
local menu8 = MenuV:CreateMenu(false, Lang:t('menu.weather_conditions'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test8')
local menu9 = MenuV:CreateMenu(false, Lang:t('menu.ban'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test9')
local menu10 = MenuV:CreateMenu(false, Lang:t('menu.kick'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test10')
local menu11 = MenuV:CreateMenu(false, Lang:t('menu.permissions'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test11')
local menu12 = MenuV:CreateMenu(false, Lang:t('menu.vehicle_categories'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test12')
local menu13 = MenuV:CreateMenu(false, Lang:t('menu.vehicle_models'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test13')
local menu14 = MenuV:CreateMenu(false, Lang:t('menu.entity_view_options'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test14')
local menu15 = MenuV:CreateMenu(false, Lang:t('menu.spawn_weapons'), menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test15')

-- NEW Enhanced Sub Menus
local menu16 = MenuV:CreateMenu(false, 'Quick Teleport', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test16')
local menu17 = MenuV:CreateMenu(false, 'Ban Management', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test17')
local menu18 = MenuV:CreateMenu(false, 'Server Info', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test18')
local menu19 = MenuV:CreateMenu(false, 'Mass Actions', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test19')

-- Helper Functions
local function LocalInput(text, number, windows)
    AddTextEntry('FMMC_MPM_NA', text)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", windows or "", "", "", "", number or 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return result
    end
end

local function LocalInputInt(text, number, windows)
    AddTextEntry('FMMC_MPM_NA', text)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", windows or "", "", "", "", number or 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return tonumber(result)
    end
end

-- Register Admin Menu Open
RegisterNetEvent('qb-admin:client:openMenu', function()
    print('[qb-adminmenu] Menu open triggered') -- Debug
    QBCore.Functions.TriggerCallback('qb-admin:isAdmin', function(isAdmin)
        print('[qb-adminmenu] IsAdmin callback received:', isAdmin) -- Debug
        if not isAdmin then 
            QBCore.Functions.Notify('You do not have permission to use the admin menu', 'error')
            return 
        end
        print('[qb-adminmenu] Opening menu...') -- Debug
        MenuV:OpenMenu(menu1)
    end)
end)

-- Also register command directly as backup
RegisterCommand('admin', function()
    print('[qb-adminmenu] Admin command executed') -- Debug
    TriggerEvent('qb-admin:client:openMenu')
end, false)

--[[
    MAIN MENU BUTTONS
--]]
-- Admin Options
menu1:AddButton({
    icon = '😃',
    label = Lang:t('menu.admin_options'),
    value = menu2,
    description = Lang:t('desc.admin_options_desc')
})

-- Player Management
local player_management = menu1:AddButton({
    icon = '🙍‍♂️',
    label = Lang:t('menu.player_management'),
    value = menu4,
    description = Lang:t('desc.player_management_desc')
})

-- Server Management
menu1:AddButton({
    icon = '🎮',
    label = Lang:t('menu.server_management'),
    value = menu3,
    description = Lang:t('desc.server_management_desc')
})

-- Vehicle Spawner
menu1:AddButton({
    icon = '🚗',
    label = Lang:t('menu.vehicles'),
    value = menu5,
    description = Lang:t('desc.vehicles_desc')
})

-- Dealer List
if Config.EnableDrugDealers then
    local menu1_dealer_list = menu1:AddButton({
        icon = '💊',
        label = Lang:t('menu.dealer_list'),
        value = menu6,
        description = Lang:t('desc.dealer_desc')
    })
end

-- Developer Options
menu1:AddButton({
    icon = '🔧',
    label = Lang:t('menu.developer_options'),
    value = menu7,
    description = Lang:t('desc.developer_desc')
})

--[[
    ADMIN OPTIONS MENU (menu2)
--]]
local menu2_admin_noclip = menu2:AddCheckbox({
    icon = '🎥',
    label = Lang:t('menu.noclip'),
    value = nil,
    description = Lang:t('desc.noclip_desc')
})

local menu2_admin_revive = menu2:AddButton({
    icon = '🏥',
    label = Lang:t('menu.revive'),
    value = 'revive',
    description = Lang:t('desc.revive_desc')
})

local menu2_admin_invisible = menu2:AddCheckbox({
    icon = '👻',
    label = Lang:t('menu.invisible'),
    value = nil,
    description = Lang:t('desc.invisible_desc')
})

local menu2_admin_god_mode = menu2:AddCheckbox({
    icon = '⚡',
    label = Lang:t('menu.god'),
    value = nil,
    description = Lang:t('desc.god_desc')
})

local menu2_admin_display_names = menu2:AddCheckbox({
    icon = '📋',
    label = Lang:t('menu.names'),
    value = nil,
    description = Lang:t('desc.names_desc')
})

local menu2_admin_display_blips = menu2:AddCheckbox({
    icon = '📍',
    label = Lang:t('menu.blips'),
    value = nil,
    description = Lang:t('desc.blips_desc')
})

-- Give Weapons
menu2:AddButton({
    icon = '🎁',
    label = Lang:t('menu.spawn_weapons'),
    value = menu15,
    description = Lang:t('desc.spawn_weapons_desc')
})

-- NEW: Revive All Players
menu2:AddButton({
    icon = '💊',
    label = 'Revive All Players',
    value = 'reviveall',
    description = 'Revive all players on the server'
})

--[[
    SERVER MANAGEMENT MENU (menu3)
--]]
local menu3_server_weather = menu3:AddButton({
    icon = '🌡️',
    label = Lang:t('menu.weather_options'),
    value = menu8,
    description = Lang:t('desc.weather_desc')
})

local menu3_server_time = menu3:AddSlider({
    icon = '⏲️',
    label = Lang:t('menu.server_time'),
    value = GetClockHours(),
    values = {
        {label = '00', value = '00', description = Lang:t('menu.time')},
        {label = '01', value = '01', description = Lang:t('menu.time')},
        {label = '02', value = '02', description = Lang:t('menu.time')},
        {label = '03', value = '03', description = Lang:t('menu.time')},
        {label = '04', value = '04', description = Lang:t('menu.time')},
        {label = '05', value = '05', description = Lang:t('menu.time')},
        {label = '06', value = '06', description = Lang:t('menu.time')},
        {label = '07', value = '07', description = Lang:t('menu.time')},
        {label = '08', value = '08', description = Lang:t('menu.time')},
        {label = '09', value = '09', description = Lang:t('menu.time')},
        {label = '10', value = '10', description = Lang:t('menu.time')},
        {label = '11', value = '11', description = Lang:t('menu.time')},
        {label = '12', value = '12', description = Lang:t('menu.time')},
        {label = '13', value = '13', description = Lang:t('menu.time')},
        {label = '14', value = '14', description = Lang:t('menu.time')},
        {label = '15', value = '15', description = Lang:t('menu.time')},
        {label = '16', value = '16', description = Lang:t('menu.time')},
        {label = '17', value = '17', description = Lang:t('menu.time')},
        {label = '18', value = '18', description = Lang:t('menu.time')},
        {label = '19', value = '19', description = Lang:t('menu.time')},
        {label = '20', value = '20', description = Lang:t('menu.time')},
        {label = '21', value = '21', description = Lang:t('menu.time')},
        {label = '22', value = '22', description = Lang:t('menu.time')},
        {label = '23', value = '23', description = Lang:t('menu.time')}
    }
})

-- NEW: Server Announcement
menu3:AddButton({
    icon = '📢',
    label = 'Send Announcement',
    value = 'announcement',
    description = 'Send a server-wide announcement'
})

-- NEW: Mass Actions Menu
menu3:AddButton({
    icon = '⚡',
    label = 'Mass Actions',
    value = menu19,
    description = 'Perform actions on all players'
})

-- NEW: Quick Teleport Locations
menu3:AddButton({
    icon = '📍',
    label = 'Quick Teleport',
    value = menu16,
    description = 'Teleport to pre-configured locations'
})

-- NEW: Ban Management
menu3:AddButton({
    icon = '🚫',
    label = 'Ban Management',
    value = menu17,
    description = 'View and manage server bans'
})

-- NEW: Server Information
menu3:AddButton({
    icon = 'ℹ️',
    label = 'Server Info',
    value = menu18,
    description = 'View server information and statistics'
})

--[[
    VEHICLE OPTIONS MENU (menu5)
--]]
local menu5_vehicles_spawn = menu5:AddButton({
    icon = '🚗',
    label = Lang:t('menu.spawn_vehicle'),
    value = menu12,
    description = Lang:t('desc.spawn_vehicle_desc')
})

local menu5_vehicles_fix = menu5:AddButton({
    icon = '🔧',
    label = Lang:t('menu.fix_vehicle'),
    value = 'fix',
    description = Lang:t('desc.fix_vehicle_desc')
})

local menu5_vehicles_buy = menu5:AddButton({
    icon = '💲',
    label = Lang:t('menu.buy'),
    value = 'buy',
    description = Lang:t('desc.buy_desc')
})

local menu5_vehicles_remove = menu5:AddButton({
    icon = '🗑️',
    label = Lang:t('menu.remove_vehicle'),
    value = 'remove',
    description = Lang:t('desc.remove_vehicle_desc')
})

local menu5_vehicles_max_upgrades = menu5:AddButton({
    icon = '⚡️',
    label = Lang:t('menu.max_mods'),
    value = 'maxmods',
    description = Lang:t('desc.max_mod_desc')
})

--[[
    DEVELOPER OPTIONS MENU (menu7)
--]]
local menu7_dev_copy_vec3 = menu7:AddButton({
    icon = '📋',
    label = Lang:t('menu.copy_vector3'),
    value = 'coords',
    description = Lang:t('desc.vector3_desc')
})

local menu7_dev_copy_vec4 = menu7:AddButton({
    icon = '📋',
    label = Lang:t('menu.copy_vector4'),
    value = 'coords',
    description = Lang:t('desc.vector4_desc')
})

local menu7_dev_copy_heading = menu7:AddButton({
    icon = '📋',
    label = Lang:t('menu.copy_heading'),
    value = 'heading',
    description = Lang:t('desc.coords_desc')
})

local menu7_dev_toggle_coords = menu7:AddCheckbox({
    icon = '🗺️',
    label = Lang:t('menu.display_coords'),
    value = nil,
    description = Lang:t('desc.coords_desc')
})

local menu7_dev_vehicle_mode = menu7:AddCheckbox({
    icon = '🚗',
    label = Lang:t('menu.vehicle_dev_mode'),
    value = nil,
    description = Lang:t('desc.veh_dev_mode_desc')
})

local menu7_dev_noclip = menu7:AddCheckbox({
    icon = '🎥',
    label = Lang:t('menu.noclip'),
    value = nil,
    description = Lang:t('desc.noclip_desc')
})

menu7:AddButton({
    icon = '👁️',
    label = Lang:t('menu.entity_view_option'),
    value = menu14,
    description = Lang:t('desc.entity_view_desc')
})

--[[
    NEW ENHANCED MENUS
--]]

-- QUICK TELEPORT MENU (menu16)
local function BuildQuickTeleportMenu()
    menu16:ClearItems()
    for name, coords in pairs(Config.TeleportLocations) do
        menu16:AddButton({
            icon = '📍',
            label = name,
            value = coords,
            description = 'Teleport to ' .. name,
            select = function(btn)
                local tpCoords = btn.Value
                DoScreenFadeOut(500)
                Wait(500)
                SetEntityCoords(PlayerPedId(), tpCoords.x, tpCoords.y, tpCoords.z, false, false, false, false)
                SetEntityHeading(PlayerPedId(), tpCoords.w)
                Wait(500)
                DoScreenFadeIn(500)
                QBCore.Functions.Notify('Teleported to ' .. name, 'success')
            end
        })
    end
end

-- BAN MANAGEMENT MENU (menu17)
local function BuildBanManagementMenu()
    menu17:ClearItems()
    
    -- Option to ban offline player
    if Config.EnableBanOffline then
        menu17:AddButton({
            icon = '🚫',
            label = 'Ban Offline Player',
            value = 'banoffline',
            description = 'Ban a player by Citizen ID',
            select = function()
                local citizenid = LocalInput('Enter Citizen ID', 20)
                if citizenid and citizenid ~= '' then
                    local reason = LocalInput('Ban Reason', 100, 'Violation of server rules')
                    if reason and reason ~= '' then
                        local duration = LocalInputInt('Ban Duration (seconds)', 11)
                        if duration and duration > 0 then
                            TriggerServerEvent('qb-admin:server:banOffline', citizenid, duration, reason)
                            QBCore.Functions.Notify('Ban request sent', 'success')
                        end
                    end
                end
            end
        })
    end
    
    -- View all bans
    menu17:AddButton({
        icon = '📋',
        label = 'View All Bans',
        value = 'viewbans',
        description = 'View list of banned players',
        select = function()
            QBCore.Functions.TriggerCallback('qb-admin:server:getBannedPlayers', function(bans)
                local BanList = MenuV:CreateMenu(false, 'Banned Players', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv')
                BanList:ClearItems()
                MenuV:OpenMenu(BanList)
                
                for _, ban in ipairs(bans) do
                    local expireDate = os.date('%Y-%m-%d %H:%M', ban.expire)
                    BanList:AddButton({
                        icon = '🚫',
                        label = ban.name,
                        description = 'Reason: ' .. ban.reason .. ' | Expires: ' .. expireDate,
                        select = function()
                            local UnbanMenu = MenuV:CreateMenu(false, 'Unban Options', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv')
                            UnbanMenu:ClearItems()
                            MenuV:OpenMenu(UnbanMenu)
                            
                            UnbanMenu:AddButton({
                                icon = '✅',
                                label = 'Unban Player',
                                description = 'Remove this ban',
                                select = function()
                                    TriggerServerEvent('qb-admin:server:unban', ban.id)
                                    QBCore.Functions.Notify('Player unbanned', 'success')
                                    UnbanMenu:Close()
                                    BanList:Close()
                                end
                            })
                            
                            UnbanMenu:AddButton({
                                icon = '❌',
                                label = 'Cancel',
                                description = 'Go back',
                                select = function()
                                    UnbanMenu:Close()
                                end
                            })
                        end
                    })
                end
            end)
        end
    })
end

-- SERVER INFO MENU (menu18)
local function BuildServerInfoMenu()
    menu18:ClearItems()
    
    QBCore.Functions.TriggerCallback('qb-admin:server:getServerInfo', function(info)
        menu18:AddButton({
            icon = '👥',
            label = 'Players Online',
            description = info.players .. ' / ' .. info.maxPlayers
        })
        
        menu18:AddButton({
            icon = '⏱️',
            label = 'Server Uptime',
            description = math.floor(info.uptime / 3600) .. ' hours'
        })
        
        menu18:AddButton({
            icon = 'ℹ️',
            label = 'Admin Menu Version',
            description = 'v' .. info.version
        })
        
        menu18:AddButton({
            icon = '🔄',
            label = 'Refresh',
            description = 'Refresh server information',
            select = function()
                BuildServerInfoMenu()
            end
        })
    end)
end

-- MASS ACTIONS MENU (menu19)
menu19:AddButton({
    icon = '💊',
    label = 'Revive All Players',
    description = 'Revive everyone on the server',
    select = function()
        TriggerServerEvent('qb-admin:server:reviveall')
    end
})

menu19:AddButton({
    icon = '🥶',
    label = 'Freeze All Players',
    description = 'Freeze all players',
    select = function()
        TriggerServerEvent('qb-admin:server:freezeall')
    end
})

menu19:AddButton({
    icon = '🔥',
    label = 'Unfreeze All Players',
    description = 'Unfreeze all players',
    select = function()
        TriggerServerEvent('qb-admin:server:unfreezeall')
    end
})

menu19:AddButton({
    icon = '➡️',
    label = 'Bring All Players',
    description = 'Teleport all players to you',
    select = function()
        TriggerServerEvent('qb-admin:server:bringall')
    end
})

--[[
    PLAYER MANAGEMENT FUNCTIONS
--]]

local function OpenKickMenu(player)
    kickplayer = player
    menu10:ClearItems()
    MenuV:OpenMenu(menu10)
    
    menu10:AddButton({
        icon = '📝',
        label = Lang:t('info.reason'),
        value = 'reason',
        description = Lang:t('info.reason'),
        select = function(_)
            kickreason = LocalInput('Reason...', 100, 'Unknown')
        end
    })
    
    menu10:AddButton({
        icon = '',
        label = Lang:t('info.confirm'),
        value = 'kick',
        description = Lang:t('desc.confirm_kick'),
        select = function(_)
            if kickreason ~= 'Unknown' then
                TriggerServerEvent('qb-admin:server:kick', kickplayer, kickreason)
                kickreason = 'Unknown'
            else
                QBCore.Functions.Notify(Lang:t('error.no_valid_reason'), 'error')
            end
        end
    })
end

local function OpenBanMenu(player)
    banplayer = player
    menu9:ClearItems()
    MenuV:OpenMenu(menu9)
    
    menu9:AddButton({
        icon = '📝',
        label = Lang:t('info.reason'),
        value = 'reason',
        description = Lang:t('info.reason'),
        select = function(_)
            banreason = LocalInput('Reason...', 100, 'Unknown')
        end
    })
    
    menu9:AddSlider({
        icon = '⏲️',
        label = Lang:t('info.length'),
        value = '3600',
        values = {
            {label = Lang:t('time.onehour'), value = '3600', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.sixhour'), value = '21600', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.twelvehour'), value = '43200', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.oneday'), value = '86400', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.threeday'), value = '259200', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.oneweek'), value = '604800', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.onemonth'), value = '2678400', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.threemonth'), value = '8035200', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.sixmonth'), value = '16070400', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.oneyear'), value = '32140800', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.permanent'), value = '99999999999', description = Lang:t('time.ban_length')},
            {label = Lang:t('time.self'), value = 'self', description = Lang:t('time.ban_length')}
        },
        select = function(_, newValue, _)
            if newValue == 'self' then
                banlength = LocalInputInt('Ban Length (seconds)', 11)
            else
                banlength = newValue
            end
        end
    })
    
    menu9:AddButton({
        icon = '',
        label = Lang:t('info.confirm'),
        value = 'ban',
        description = Lang:t('desc.confirm_ban'),
        select = function(_)
            if banreason ~= 'Unknown' and banlength ~= nil then
                TriggerServerEvent('qb-admin:server:ban', banplayer, banlength, banreason)
                banreason = 'Unknown'
                banlength = nil
            else
                QBCore.Functions.Notify(Lang:t('error.invalid_reason_length_ban'), 'error')
            end
        end
    })
end

local function OpenPermsMenu(player)
    permsplayer = player
    menu11:ClearItems()
    MenuV:OpenMenu(menu11)
    
    local elements = {
        {icon = '🔨', label = 'God', value = 'god', description = 'Give god permissions'},
        {icon = '👮', label = 'Admin', value = 'admin', description = 'Give admin permissions'},
        {icon = '🎫', label = 'Mod', value = 'mod', description = 'Give mod permissions'}
    }
    
    for _, v in ipairs(elements) do
        menu11:AddButton({
            icon = v.icon,
            label = v.label,
            value = v.value,
            description = v.description,
            select = function(btn)
                TriggerServerEvent('QBCore:Server:SetPermissions', permsplayer.id, btn.Value)
            end
        })
    end
end

local function OpenPlayerMenus(player)
    local Players = MenuV:CreateMenu(false, player.cid .. ' Options', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv')
    Players:ClearItems()
    MenuV:OpenMenu(Players)
    
    local elements = {
        {icon = '💀', label = Lang:t('menu.kill'), value = 'kill', description = Lang:t('menu.kill') .. ' ' .. player.cid},
        {icon = '🏥', label = Lang:t('menu.revive'), value = 'revive', description = Lang:t('menu.revive') .. ' ' .. player.cid},
        {icon = '🥶', label = Lang:t('menu.freeze'), value = 'freeze', description = Lang:t('menu.freeze') .. ' ' .. player.cid},
        {icon = '👀', label = Lang:t('menu.spectate'), value = 'spectate', description = Lang:t('menu.spectate') .. ' ' .. player.cid},
        {icon = '➡️', label = Lang:t('info.go_to'), value = 'goto', description = Lang:t('info.go_to') .. ' ' .. player.cid},
        {icon = '⬅️', label = Lang:t('menu.bring'), value = 'bring', description = Lang:t('menu.bring') .. ' ' .. player.cid},
        {icon = '🚗', label = Lang:t('menu.sit_in_vehicle'), value = 'intovehicle', description = 'Get into ' .. player.cid .. ' vehicle'},
        {icon = '🎒', label = Lang:t('menu.open_inv'), value = 'inventory', description = Lang:t('info.open') .. ' ' .. player.cid .. ' inventory'},
        {icon = '👕', label = Lang:t('menu.give_clothing_menu'), value = 'cloth', description = 'Give clothing menu to ' .. player.cid},
        {icon = '💰', label = 'Give Money', value = 'givemoney', description = 'Give money to ' .. player.cid},
        {icon = '💸', label = 'Remove Money', value = 'removemoney', description = 'Remove money from ' .. player.cid},
        {icon = '💼', label = 'Set Job', value = 'setjob', description = 'Set job for ' .. player.cid},
        {icon = '👥', label = 'Set Gang', value = 'setgang', description = 'Set gang for ' .. player.cid},
    }
    
    if Config.EnableScreenshots then
        table.insert(elements, {icon = '📷', label = 'Screenshot', value = 'screenshot', description = 'Take screenshot of ' .. player.cid})
    end
    
    table.insert(elements, {icon = '🥾', label = Lang:t('menu.kick'), value = 'kick', description = Lang:t('menu.kick') .. ' ' .. player.cid})
    table.insert(elements, {icon = '🚫', label = Lang:t('menu.ban'), value = 'ban', description = Lang:t('menu.ban') .. ' ' .. player.cid})
    table.insert(elements, {icon = '🎟️', label = Lang:t('menu.permissions'), value = 'perms', description = 'Give permissions to ' .. player.cid})
    
    for _, v in ipairs(elements) do
        Players:AddButton({
            icon = v.icon,
            label = v.label,
            value = v.value,
            description = v.description,
            select = function(btn)
                local values = btn.Value
                
                if values == 'givemoney' then
                    local MoneyMenu = MenuV:CreateMenu(false, 'Give Money', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv')
                    MoneyMenu:ClearItems()
                    MenuV:OpenMenu(MoneyMenu)
                    
                    MoneyMenu:AddButton({
                        icon = '💵',
                        label = 'Give Cash',
                        description = 'Give cash money',
                        select = function()
                            local amount = LocalInputInt('Amount', 10)
                            if amount and amount > 0 then
                                TriggerServerEvent('qb-admin:server:givemoney', player, 'cash', amount)
                                MoneyMenu:Close()
                            end
                        end
                    })
                    
                    MoneyMenu:AddButton({
                        icon = '🏦',
                        label = 'Give Bank Money',
                        description = 'Give bank money',
                        select = function()
                            local amount = LocalInputInt('Amount', 10)
                            if amount and amount > 0 then
                                TriggerServerEvent('qb-admin:server:givemoney', player, 'bank', amount)
                                MoneyMenu:Close()
                            end
                        end
                    })
                    
                elseif values == 'removemoney' then
                    local MoneyMenu = MenuV:CreateMenu(false, 'Remove Money', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv')
                    MoneyMenu:ClearItems()
                    MenuV:OpenMenu(MoneyMenu)
                    
                    MoneyMenu:AddButton({
                        icon = '💵',
                        label = 'Remove Cash',
                        description = 'Remove cash money',
                        select = function()
                            local amount = LocalInputInt('Amount', 10)
                            if amount and amount > 0 then
                                TriggerServerEvent('qb-admin:server:removemoney', player, 'cash', amount)
                                MoneyMenu:Close()
                            end
                        end
                    })
                    
                    MoneyMenu:AddButton({
                        icon = '🏦',
                        label = 'Remove Bank Money',
                        description = 'Remove bank money',
                        select = function()
                            local amount = LocalInputInt('Amount', 10)
                            if amount and amount > 0 then
                                TriggerServerEvent('qb-admin:server:removemoney', player, 'bank', amount)
                                MoneyMenu:Close()
                            end
                        end
                    })
                    
                elseif values == 'setjob' then
                    local job = LocalInput('Job Name (e.g., police)', 20)
                    if job and job ~= '' then
                        local grade = LocalInputInt('Job Grade (0-10)', 2)
                        if grade and grade >= 0 then
                            TriggerServerEvent('qb-admin:server:setjob', player, job, grade)
                        end
                    end
                    
                elseif values == 'setgang' then
                    local gang = LocalInput('Gang Name (e.g., ballas)', 20)
                    if gang and gang ~= '' then
                        local grade = LocalInputInt('Gang Grade (0-10)', 2)
                        if grade and grade >= 0 then
                            TriggerServerEvent('qb-admin:server:setgang', player, gang, grade)
                        end
                    end
                    
                elseif values == 'screenshot' then
                    TriggerServerEvent('qb-admin:server:screenshot', player)
                    QBCore.Functions.Notify('Taking screenshot...', 'primary')
                    
                elseif values == 'ban' then
                    OpenBanMenu(player)
                elseif values == 'kick' then
                    OpenKickMenu(player)
                elseif values == 'perms' then
                    OpenPermsMenu(player)
                else
                    TriggerServerEvent('qb-admin:server:' .. values, player)
                end
            end
        })
    end
end

-- Load player management list
player_management:On('select', function(_)
    menu4:ClearItems()
    QBCore.Functions.TriggerCallback('qb-admin:server:getplayers', function(players)
        for _, v in pairs(players) do
            menu4:AddButton({
                label = 'ID: ' .. v['id'] .. ' | ' .. v['name'],
                value = v,
                description = 'Job: ' .. (v.job or 'None') .. ' | Cash: $' .. (v.money and v.money.cash or 0),
                select = function(btn)
                    OpenPlayerMenus(btn.Value)
                end
            })
        end
    end)
end)

--[[
    WEATHER OPTIONS
--]]
menu3_server_weather:On('select', function()
    menu8:ClearItems()
    local weathers = Config.WeatherTypes or {
        'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 'FOGGY', 'OVERCAST',
        'CLOUDS', 'CLEARING', 'RAIN', 'THUNDER', 'SNOW', 'BLIZZARD',
        'SNOWLIGHT', 'XMAS', 'HALLOWEEN'
    }
    
    for _, weather in ipairs(weathers) do
        menu8:AddButton({
            icon = '🌤️',
            label = weather,
            value = weather,
            description = 'Set weather to ' .. weather,
            select = function(btn)
                TriggerServerEvent('qb-weathersync:server:setWeather', btn.Value)
                QBCore.Functions.Notify('Weather set to ' .. btn.Value, 'success')
            end
        })
    end
end)

-- Time slider handler
menu3_server_time:On('select', function(_, newValue, _)
    TriggerServerEvent('qb-weathersync:server:setTime', tonumber(newValue), 0)
end)

--[[
    VEHICLE OPTIONS HANDLERS
--]]
menu5_vehicles_fix:On('select', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        QBCore.Functions.Notify(Lang:t('success.vehicle_repaired'), 'success')
    else
        QBCore.Functions.Notify(Lang:t('error.not_in_veh'), 'error')
    end
end)

menu5_vehicles_buy:On('select', function()
    TriggerEvent('qb-admin:client:SaveCar')
end)

menu5_vehicles_remove:On('select', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        QBCore.Functions.DeleteVehicle(veh)
        QBCore.Functions.Notify(Lang:t('success.vehicle_delete'), 'success')
    else
        QBCore.Functions.Notify(Lang:t('error.not_in_veh'), 'error')
    end
end)

menu5_vehicles_max_upgrades:On('select', function()
    TriggerEvent('qb-admin:client:maxmodVehicle')
end)

-- Vehicle spawner (categories and models)
menu5_vehicles_spawn:On('select', function()
    menu12:ClearItems()
    
    -- Get all vehicles and organize by category
    local categories = {}
    for model, vehicle in pairs(QBCore.Shared.Vehicles) do
        local category = vehicle.category or 'other'
        if not categories[category] then
            categories[category] = {}
        end
        table.insert(categories[category], {
            name = vehicle.name,
            model = model,
            brand = vehicle.brand
        })
    end
    
    -- Create category buttons
    for category, vehicles in pairs(categories) do
        menu12:AddButton({
            icon = '🚗',
            label = string.upper(category),
            value = {category = category, vehicles = vehicles},
            description = 'Spawn ' .. category .. ' vehicles',
            select = function(btn)
                menu13:ClearItems()
                MenuV:OpenMenu(menu13)
                
                -- Sort vehicles alphabetically
                table.sort(btn.Value.vehicles, function(a, b)
                    return a.name < b.name
                end)
                
                for _, vehicle in pairs(btn.Value.vehicles) do
                    menu13:AddButton({
                        icon = '🚗',
                        label = vehicle.name,
                        value = vehicle.model,
                        description = 'Spawn ' .. vehicle.name,
                        select = function(vehBtn)
                            TriggerEvent('qb-admin:client:spawnVehicle', vehBtn.Value)
                            QBCore.Functions.Notify('Spawning ' .. vehicle.name .. '...', 'success')
                        end
                    })
                end
            end
        })
    end
end)

--[[
    WEAPON SPAWNER
--]]
menu15:ClearItems()
for weapon, data in pairs(QBCore.Shared.Weapons) do
    menu15:AddButton({
        icon = '🔫',
        label = data.label,
        value = weapon,
        description = 'Spawn ' .. data.label,
        select = function(btn)
            TriggerServerEvent('QBCore:Server:AddItem', btn.Value, 1)
            TriggerServerEvent('QBCore:Server:AddItem', 'pistol_ammo', 50)
            QBCore.Functions.Notify('Weapon spawned', 'success')
        end
    })
end

--[[
    ADMIN OPTIONS HANDLERS
--]]
menu2_admin_noclip:On('change', function(item, newValue, oldValue)
    TriggerEvent('qb-admin:client:ToggleNoClip')
end)

menu2_admin_revive:On('select', function()
    TriggerEvent('hospital:client:Revive')
    TriggerEvent('hud:client:UpdateNeeds', 100, 100)
    QBCore.Functions.Notify(Lang:t('success.revived'), 'success')
end)

menu2_admin_invisible:On('change', function(item, _, value)
    local ped = PlayerPedId()
    if value then
        SetEntityVisible(ped, false, false)
        SetEntityAlpha(ped, 0, false)
        QBCore.Functions.Notify(Lang:t('success.invis_enabled'), 'success')
    else
        SetEntityVisible(ped, true, false)
        ResetEntityAlpha(ped)
        QBCore.Functions.Notify(Lang:t('success.invis_disabled'), 'success')
    end
end)

menu2_admin_god_mode:On('change', function(item, _, value)
    local ped = PlayerPedId()
    if value then
        SetEntityInvincible(ped, true)
        QBCore.Functions.Notify(Lang:t('success.god_enabled'), 'success')
    else
        SetEntityInvincible(ped, false)
        QBCore.Functions.Notify(Lang:t('success.god_disabled'), 'success')
    end
end)

menu2_admin_display_names:On('change', function()
    TriggerEvent('qb-admin:client:toggleNames')
end)

menu2_admin_display_blips:On('change', function()
    TriggerEvent('qb-admin:client:toggleBlips')
end)

--[[
    DEVELOPER OPTIONS HANDLERS
--]]
menu7_dev_copy_vec3:On('select', function()
    CopyToClipboard('coords3')
end)

menu7_dev_copy_vec4:On('select', function()
    CopyToClipboard('coords4')
end)

menu7_dev_copy_heading:On('select', function()
    CopyToClipboard('heading')
end)

menu7_dev_toggle_coords:On('change', function()
    ToggleShowCoordinates()
end)

menu7_dev_vehicle_mode:On('change', function()
    ToggleVehicleDeveloperMode()
end)

menu7_dev_noclip:On('change', function(item, newValue, oldValue)
    TriggerEvent('qb-admin:client:ToggleNoClip')
end)

--[[
    NEW MENU HANDLERS
--]]
-- Build menus when opened
menu16:On('open', function()
    BuildQuickTeleportMenu()
end)

menu17:On('open', function()
    BuildBanManagementMenu()
end)

menu18:On('open', function()
    BuildServerInfoMenu()
end)

-- Server announcement handler
menu3:On('select', function(item)
    if item.Value == 'announcement' then
        local message = LocalInput('Announcement Message', 200)
        if message and message ~= '' then
            TriggerServerEvent('qb-admin:server:sendAnnounce', message)
            QBCore.Functions.Notify('Announcement sent', 'success')
        end
    end
end)

--[[
    UTILITY FUNCTIONS
--]]
local function CopyToClipboard(dataType)
    local ped = PlayerPedId()
    if dataType == 'coords2' then
        local coords = GetEntityCoords(ped)
        local x = QBCore.Shared.Round(coords.x, 2)
        local y = QBCore.Shared.Round(coords.y, 2)
        SendNUIMessage({
            string = string.format('vector2(%s, %s)', x, y)
        })
        QBCore.Functions.Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'coords3' then
        local coords = GetEntityCoords(ped)
        local x = QBCore.Shared.Round(coords.x, 2)
        local y = QBCore.Shared.Round(coords.y, 2)
        local z = QBCore.Shared.Round(coords.z, 2)
        SendNUIMessage({
            string = string.format('vector3(%s, %s, %s)', x, y, z)
        })
        QBCore.Functions.Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'coords4' then
        local coords = GetEntityCoords(ped)
        local x = QBCore.Shared.Round(coords.x, 2)
        local y = QBCore.Shared.Round(coords.y, 2)
        local z = QBCore.Shared.Round(coords.z, 2)
        local heading = GetEntityHeading(ped)
        local h = QBCore.Shared.Round(heading, 2)
        SendNUIMessage({
            string = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
        })
        QBCore.Functions.Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'heading' then
        local heading = GetEntityHeading(ped)
        local h = QBCore.Shared.Round(heading, 2)
        SendNUIMessage({
            string = h
        })
        QBCore.Functions.Notify(Lang:t('success.heading_copied'), 'success')
    end
end

RegisterNetEvent('qb-admin:client:copyToClipboard', function(dataType)
    CopyToClipboard(dataType)
end)

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    BeginTextCommandDisplayText('STRING')
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentSubstringPlayerName(content)
    EndTextCommandDisplayText(x, y)
end

function ToggleShowCoordinates()
    local x = 0.4
    local y = 0.025
    showCoords = not showCoords
    CreateThread(function()
        while showCoords do
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            local c = {}
            c.x = QBCore.Shared.Round(coords.x, 2)
            c.y = QBCore.Shared.Round(coords.y, 2)
            c.z = QBCore.Shared.Round(coords.z, 2)
            heading = QBCore.Shared.Round(heading, 2)
            Wait(0)
            Draw2DText(string.format('~w~Coordinates: ~b~vector4(~w~%s~b~, ~w~%s~b~, ~w~%s~b~, ~w~%s~b~)', c.x, c.y, c.z, heading), 4, {66, 182, 245}, 0.4, x, y)
        end
    end)
end

function ToggleVehicleDeveloperMode()
    vehicleDevMode = not vehicleDevMode
    CreateThread(function()
        while vehicleDevMode do
            local ped = PlayerPedId()
            Wait(0)
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local netID = VehToNet(vehicle)
                local hash = GetEntityModel(vehicle)
                local modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
                local eHealth = GetVehicleEngineHealth(vehicle)
                local bHealth = GetVehicleBodyHealth(vehicle)
                
                Draw2DText('~w~Vehicle Dev Mode:', 4, {66, 182, 245}, 0.4, 0.4, 0.888)
                Draw2DText(string.format('Entity ID: ~b~%s~s~ | Net ID: ~b~%s~s~', vehicle, netID), 4, {255, 255, 255}, 0.4, 0.4, 0.913)
                Draw2DText(string.format('Model: ~b~%s~s~ | Hash: ~b~%s~s~', modelName, hash), 4, {255, 255, 255}, 0.4, 0.4, 0.938)
                Draw2DText(string.format('Engine: ~b~%s~s~ | Body: ~b~%s~s~', QBCore.Shared.Round(eHealth, 2), QBCore.Shared.Round(bHealth, 2)), 4, {255, 255, 255}, 0.4, 0.4, 0.963)
            end
        end
    end)
end

RegisterNetEvent('qb-admin:client:ToggleCoords', function()
    ToggleShowCoordinates()
end)

RegisterNetEvent('qb-admin:client:teleportPlayer', function(coords)
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    Wait(500)
    DoScreenFadeIn(500)
    QBCore.Functions.Notify('Teleported', 'success')
end)

RegisterNetEvent('qb-admin:client:spawnVehicle', function(model)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Delete current vehicle if player is in one and ReplaceVehicle is enabled
    -- Default to true if Config not loaded yet
    local shouldReplace = true
    if Config and Config.VehicleSpawn then
        shouldReplace = Config.VehicleSpawn.ReplaceVehicle
    end
    
    if shouldReplace and IsPedInAnyVehicle(ped, false) then
        local currentVehicle = GetVehiclePedIsIn(ped, false)
        if currentVehicle ~= 0 then
            QBCore.Functions.Notify('Replacing current vehicle...', 'primary', 2000)
            TaskLeaveVehicle(ped, currentVehicle, 0)
            Wait(500) -- Wait for player to exit
            QBCore.Functions.DeleteVehicle(currentVehicle)
            Wait(200) -- Short delay before spawning new one
        end
    end
    
    -- Convert model to hash if it's a string
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    -- Check if model is valid
    if not IsModelInCdimage(hash) then
        QBCore.Functions.Notify('Invalid vehicle model: ' .. tostring(model), 'error')
        return
    end
    
    if not IsModelAVehicle(hash) then
        QBCore.Functions.Notify('Model is not a vehicle', 'error')
        return
    end
    
    -- Request the model
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 5000 then
            QBCore.Functions.Notify('Failed to load vehicle model', 'error')
            return
        end
    end
    
    -- Find a clear spawn location
    local forward = GetEntityForwardVector(ped)
    local spawnCoords = vector3(
        coords.x + forward.x * 5.0,
        coords.y + forward.y * 5.0,
        coords.z
    )
    
    -- Create the vehicle
    local vehicle = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
    
    -- Wait for vehicle to be created
    timeout = 0
    while not DoesEntityExist(vehicle) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 2000 then
            QBCore.Functions.Notify('Failed to spawn vehicle', 'error')
            SetModelAsNoLongerNeeded(hash)
            return
        end
    end
    
    -- Set vehicle properties
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetPedIntoVehicle(ped, vehicle, -1)
    
    -- Set vehicle as owned
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', plate, NetworkGetNetworkIdFromEntity(vehicle))
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
    
    -- Max it out if configured (with nil check)
    local shouldMax = false
    if Config and Config.VehicleSpawn and Config.VehicleSpawn.SpawnMaxed then
        shouldMax = Config.VehicleSpawn.SpawnMaxed
    end
    
    if shouldMax then
        Wait(100)
        TriggerEvent('qb-admin:client:maxmodVehicle')
    end
    
    -- Clean up
    SetModelAsNoLongerNeeded(hash)
    
    QBCore.Functions.Notify('Vehicle spawned successfully', 'success')
end)

RegisterNetEvent('qb-admin:client:deleteVehicle', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        QBCore.Functions.DeleteVehicle(vehicle)
        QBCore.Functions.Notify('Vehicle deleted', 'success')
    else
        QBCore.Functions.Notify('Not in a vehicle', 'error')
    end
end)

RegisterNetEvent('qb-admin:client:fixVehicle', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
        QBCore.Functions.Notify('Vehicle fixed', 'success')
    else
        QBCore.Functions.Notify('Not in a vehicle', 'error')
    end
end)

-- Dealer List (if enabled)
if Config.EnableDrugDealers then
    menu1_dealer_list:On('Select', function(_)
        menu6:ClearItems()
        QBCore.Functions.TriggerCallback('test:getdealers', function(dealers)
            for _, v in pairs(dealers) do
                menu6:AddButton({
                    label = v['name'],
                    value = v,
                    description = 'Dealer: ' .. v['name'],
                    select = function(btn)
                        local dealer = btn.Value
                        local DealerMenu = MenuV:CreateMenu(false, 'Dealer: ' .. dealer['name'], menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv')
                        DealerMenu:ClearItems()
                        MenuV:OpenMenu(DealerMenu)
                        
                        DealerMenu:AddButton({
                            icon = '➡️',
                            label = 'Go To ' .. dealer['name'],
                            description = 'Teleport to this dealer',
                            select = function()
                                TriggerServerEvent('QBCore:CallCommand', 'dealergoto', {dealer['name']})
                            end
                        })
                        
                        DealerMenu:AddButton({
                            icon = '☠',
                            label = 'Remove ' .. dealer['name'],
                            description = 'Delete this dealer',
                            select = function()
                                TriggerServerEvent('QBCore:CallCommand', 'deletedealer', {dealer['name']})
                                DealerMenu:Close()
                                menu6:Close()
                            end
                        })
                    end
                })
            end
        end)
    end)
end

print('^2[qb-adminmenu]^7 Enhanced Client Loaded Successfully! ^2✓^7')

print('^2[qb-adminmenu]^7 Enhanced Client Loaded Successfully! ^2✓^7')
print('^3[qb-adminmenu]^7 Use /admin to open the menu')
print('^3[qb-adminmenu]^7 Use /noclip to toggle noclip')
