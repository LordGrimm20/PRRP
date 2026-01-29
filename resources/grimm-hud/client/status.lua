--[[
    GRIMM-HUD | Status Module
    Additional status handling, effects, and warnings
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- State
local lastHealth = 100
local lastArmor = 0
local isDead = false

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           DAMAGE EFFECTS                                │
-- └─────────────────────────────────────────────────────────────────────────┘

---Send damage flash effect to NUI
---@param type string 'health' or 'armor'
---@param amount number Damage amount
local function SendDamageEffect(type, amount)
    SendNUIMessage({
        action = 'damageEffect',
        data = {
            type = type,
            amount = amount,
        }
    })
end

-- Monitor for damage
CreateThread(function()
    while true do
        Wait(100)
        
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped) - 100
        local armor = GetPedArmour(ped)
        
        -- Check for health damage
        if health < lastHealth and lastHealth > 0 then
            local damage = lastHealth - health
            if damage > 0 then
                SendDamageEffect('health', damage)
            end
        end
        
        -- Check for armor damage
        if armor < lastArmor and lastArmor > 0 then
            local damage = lastArmor - armor
            if damage > 0 then
                SendDamageEffect('armor', damage)
            end
        end
        
        -- Check for death
        local currentlyDead = IsEntityDead(ped)
        if currentlyDead and not isDead then
            isDead = true
            SendNUIMessage({
                action = 'playerDied',
                data = {}
            })
        elseif not currentlyDead and isDead then
            isDead = false
            SendNUIMessage({
                action = 'playerRevived',
                data = {}
            })
        end
        
        lastHealth = health
        lastArmor = armor
    end
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           STRESS SYSTEM                                 │
-- └─────────────────────────────────────────────────────────────────────────┘

-- If you want to handle stress effects (screen blur, etc.)
local stressEffectActive = false

local function UpdateStressEffects(stressLevel)
    if not Config.StatusRing.warnings.enabled then return end
    
    -- High stress visual effect
    if stressLevel >= 75 and not stressEffectActive then
        stressEffectActive = true
        -- Could add screen effects here
    elseif stressLevel < 75 and stressEffectActive then
        stressEffectActive = false
        -- Remove screen effects
    end
end

-- Listen for stress updates
RegisterNetEvent('hud:client:UpdateStress', function(stress)
    UpdateStressEffects(stress)
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           HUNGER/THIRST EFFECTS                         │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Monitor hunger/thirst for low warnings
CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.metadata then
            local hunger = playerData.metadata.hunger or 100
            local thirst = playerData.metadata.thirst or 100
            
            -- Send warning if low
            if hunger <= Config.StatusRing.warnings.threshold then
                SendNUIMessage({
                    action = 'statusWarning',
                    data = { type = 'hunger', value = hunger }
                })
            end
            
            if thirst <= Config.StatusRing.warnings.threshold then
                SendNUIMessage({
                    action = 'statusWarning',
                    data = { type = 'thirst', value = thirst }
                })
            end
        end
    end
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           BUFF/DEBUFF INDICATORS                        │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Track active buffs/debuffs
local activeEffects = {}

---Add a status effect indicator
---@param id string Unique effect ID
---@param data table Effect data (icon, color, duration, tooltip)
local function AddStatusEffect(id, data)
    activeEffects[id] = data
    SendNUIMessage({
        action = 'addStatusEffect',
        data = {
            id = id,
            icon = data.icon,
            color = data.color,
            tooltip = data.tooltip,
        }
    })
    
    -- Auto-remove after duration
    if data.duration then
        SetTimeout(data.duration, function()
            RemoveStatusEffect(id)
        end)
    end
end

---Remove a status effect indicator
---@param id string Effect ID to remove
local function RemoveStatusEffect(id)
    activeEffects[id] = nil
    SendNUIMessage({
        action = 'removeStatusEffect',
        data = { id = id }
    })
end

-- Export functions
exports('AddStatusEffect', AddStatusEffect)
exports('RemoveStatusEffect', RemoveStatusEffect)
exports('GetActiveEffects', function() return activeEffects end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           ADMIN COMMANDS                                │
-- └─────────────────────────────────────────────────────────────────────────┘

if Config.AdminMenu and Config.AdminMenu.enabled then
    RegisterCommand(Config.AdminMenu.command or 'hudconfig', function()
        -- Open HUD configuration menu
        SendNUIMessage({
            action = 'openConfigMenu',
            data = {
                config = Config,
            }
        })
        SetNuiFocus(true, true)
    end, false)
end

-- NUI callback for closing config menu
RegisterNUICallback('closeConfigMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- NUI callback for saving config changes
RegisterNUICallback('saveConfig', function(data, cb)
    -- This would need server-side persistence for permanent changes
    -- For now, just update the local config
    if data.colors then
        for k, v in pairs(data.colors) do
            Config.Colors[k] = v
        end
    end
    
    if data.position then
        for k, v in pairs(data.position) do
            Config.Position[k] = v
        end
    end
    
    -- Refresh HUD with new settings
    exports['grimm-hud']:RefreshConfig()
    
    cb('ok')
end)
