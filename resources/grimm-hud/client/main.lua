--[[
    GRIMM-HUD | Main Client
    Core HUD logic, NUI communication, and state management
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- State variables
local isHudVisible = Config.DefaultVisible
local isLoggedIn = false
local isCinematicMode = false
local playerData = {}

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           NUI COMMUNICATION                             │
-- └─────────────────────────────────────────────────────────────────────────┘

---Send message to NUI
---@param action string Action name
---@param data table Data to send
local function SendNUI(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---Initialize HUD with config
local function InitializeHud()
    SendNUI('init', {
        config = {
            colors = Config.Colors,
            position = Config.Position,
            statusRing = Config.StatusRing,
            infoPanel = Config.InfoPanel,
            compass = Config.Compass,
            voice = Config.Voice,
            mediaPlayer = Config.MediaPlayer,
            vehicleHud = Config.VehicleHud,
            minimap = Config.Minimap,
        },
        visible = isHudVisible,
    })
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           VISIBILITY CONTROL                            │
-- └─────────────────────────────────────────────────────────────────────────┘

---Toggle HUD visibility
---@param visible boolean|nil Toggle or set specific state
local function ToggleHud(visible)
    if visible == nil then
        isHudVisible = not isHudVisible
    else
        isHudVisible = visible
    end
    
    SendNUI('toggleVisibility', { visible = isHudVisible })
    
    if Config.Debug then
        print('^3[GRIMM-HUD]^7 HUD visibility:', isHudVisible)
    end
end

---Set cinematic mode
---@param enabled boolean
local function SetCinematicMode(enabled)
    isCinematicMode = enabled
    SendNUI('cinematicMode', { enabled = enabled })
    
    if enabled then
        DisplayRadar(false)
    else
        DisplayRadar(true)
    end
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           PLAYER DATA                                   │
-- └─────────────────────────────────────────────────────────────────────────┘

---Update player data cache
local function UpdatePlayerData()
    local pd = QBCore.Functions.GetPlayerData()
    if pd then
        playerData = pd
    end
end

---Get player metadata value
---@param key string Metadata key
---@return number
local function GetMetadata(key)
    if playerData and playerData.metadata then
        return playerData.metadata[key] or 0
    end
    return 0
end

---Get player money
---@param type string 'cash' or 'bank'
---@return number
local function GetMoney(type)
    if playerData and playerData.money then
        return playerData.money[type] or 0
    end
    return 0
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           MAIN UPDATE LOOP                              │
-- └─────────────────────────────────────────────────────────────────────────┘

CreateThread(function()
    -- Wait for player to be logged in
    while not isLoggedIn do
        Wait(500)
    end

    -- Initialize HUD
    InitializeHud()
    Wait(500)

    -- Main update loop
    while true do
        if isHudVisible and isLoggedIn and not isCinematicMode then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local armor = GetPedArmour(ped)

            -- Calculate health percentage (accounting for 100 base health)
            local healthPercent = math.floor(((health - 100) / (maxHealth - 100)) * 100)
            if healthPercent < 0 then healthPercent = 0 end
            if healthPercent > 100 then healthPercent = 100 end

            -- Check if underwater for oxygen
            local isUnderwater = IsEntityInWater(ped) and IsPedSwimmingUnderWater(ped)
            local oxygen = 100
            if isUnderwater then
                oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
                if oxygen > 100 then oxygen = 100 end
            end

            -- Send status update
            SendNUI('updateStatus', {
                health = healthPercent,
                armor = armor,
                hunger = math.floor(GetMetadata('hunger') or 100),
                thirst = math.floor(GetMetadata('thirst') or 100),
                stress = math.floor(GetMetadata('stress') or 0),
                oxygen = math.floor(oxygen),
                isUnderwater = isUnderwater,
                isDead = IsEntityDead(ped),
            })

            -- Send money update
            SendNUI('updateMoney', {
                cash = GetMoney('cash'),
                bank = GetMoney('bank'),
            })

            -- Check if in vehicle
            local inVehicle = IsPedInAnyVehicle(ped, false)
            SendNUI('setVehicleState', { inVehicle = inVehicle })
        end

        Wait(Config.RefreshRate)
    end
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           EVENTS                                        │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Player loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    UpdatePlayerData()
    
    Wait(1000)
    InitializeHud()
    ToggleHud(true)
end)

-- Player unloaded
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    ToggleHud(false)
end)

-- Player data updated
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    playerData = data
end)

-- Money changed
RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    -- Flash animation for money change
    SendNUI('moneyChange', {
        type = type,
        amount = amount,
        isMinus = isMinus,
    })
end)

-- Stress update (from other resources)
RegisterNetEvent('hud:client:UpdateStress', function(stress)
    SendNUI('updateSingleStatus', {
        type = 'stress',
        value = stress,
    })
end)

-- External toggle event
RegisterNetEvent('grimm-hud:client:toggle', function(visible)
    ToggleHud(visible)
end)

-- External status update event
RegisterNetEvent('grimm-hud:client:updateStatus', function(type, value)
    SendNUI('updateSingleStatus', {
        type = type,
        value = value,
    })
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           KEY BINDINGS                                  │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Toggle HUD visibility
if Config.ToggleKey then
    RegisterKeyMapping('togglehud', 'Toggle HUD', 'keyboard', Config.ToggleKey)
    RegisterCommand('togglehud', function()
        ToggleHud()
    end, false)
end

-- Cinematic mode
if Config.CinematicMode.enabled and Config.CinematicMode.key then
    RegisterKeyMapping('cinematicmode', 'Cinematic Mode', 'keyboard', Config.CinematicMode.key)
    RegisterCommand('cinematicmode', function()
        SetCinematicMode(not isCinematicMode)
    end, false)
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           EXPORTS                                       │
-- └─────────────────────────────────────────────────────────────────────────┘

exports('ToggleHud', ToggleHud)
exports('SetCinematicMode', SetCinematicMode)
exports('IsHudVisible', function() return isHudVisible end)
exports('IsCinematicMode', function() return isCinematicMode end)

exports('UpdateStatus', function(type, value)
    SendNUI('updateSingleStatus', {
        type = type,
        value = value,
    })
end)

exports('ShowNotification', function(data)
    SendNUI('notification', data)
end)

exports('RefreshConfig', function()
    InitializeHud()
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           RESOURCE EVENTS                               │
-- └─────────────────────────────────────────────────────────────────────────┘

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000)
        local pd = QBCore.Functions.GetPlayerData()
        if pd and pd.citizenid then
            isLoggedIn = true
            playerData = pd
            InitializeHud()
            ToggleHud(true)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Cleanup
        DisplayRadar(true)
    end
end)

-- Debug command
if Config.Debug then
    RegisterCommand('huddebug', function()
        print('^3[GRIMM-HUD DEBUG]^7')
        print('Logged in:', isLoggedIn)
        print('HUD visible:', isHudVisible)
        print('Cinematic:', isCinematicMode)
        print('Player data:', json.encode(playerData))
    end, false)
end
