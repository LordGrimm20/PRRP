--[[
    GRIMM-HUD | Media & Vehicle Module
    rtx_carradio integration and vehicle HUD (speedometer, fuel, etc)
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- State
local currentVehicle = 0
local isInVehicle = false
local currentMedia = nil
local seatbeltOn = false

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           MEDIA PLAYER (rtx_carradio)                   │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get current playing media from rtx_carradio
---@return table|nil
local function GetCurrentMedia()
    if not Config.MediaPlayer.enabled then return nil end
    
    local resource = Config.MediaPlayer.resource
    if GetResourceState(resource) ~= 'started' then
        return nil
    end
    
    -- Try to get current track info from rtx_carradio
    local success, result = pcall(function()
        -- rtx_carradio exports (adjust based on actual exports)
        local isPlaying = exports[resource]:IsPlaying()
        if not isPlaying then return nil end
        
        return {
            title = exports[resource]:GetCurrentTitle() or 'Unknown',
            artist = exports[resource]:GetCurrentArtist() or 'Unknown',
            thumbnail = exports[resource]:GetCurrentThumbnail() or '',
            duration = exports[resource]:GetDuration() or 0,
            currentTime = exports[resource]:GetCurrentTime() or 0,
            isPlaying = true,
        }
    end)
    
    if success and result then
        return result
    end
    
    return nil
end

-- Media update thread
CreateThread(function()
    if not Config.MediaPlayer.enabled then return end
    
    while true do
        Wait(1000) -- Update every second
        
        local media = GetCurrentMedia()
        
        if media then
            -- Media is playing
            if currentMedia == nil or currentMedia.title ~= media.title then
                -- New track started
                SendNUIMessage({
                    action = 'updateMedia',
                    data = {
                        playing = true,
                        title = media.title,
                        artist = media.artist,
                        thumbnail = media.thumbnail,
                        duration = media.duration,
                        currentTime = media.currentTime,
                        progress = media.duration > 0 and (media.currentTime / media.duration * 100) or 0,
                    }
                })
            else
                -- Same track, just update progress
                SendNUIMessage({
                    action = 'updateMediaProgress',
                    data = {
                        currentTime = media.currentTime,
                        progress = media.duration > 0 and (media.currentTime / media.duration * 100) or 0,
                    }
                })
            end
            currentMedia = media
        else
            -- No media playing
            if currentMedia ~= nil then
                SendNUIMessage({
                    action = 'updateMedia',
                    data = {
                        playing = false,
                    }
                })
                currentMedia = nil
            end
        end
    end
end)

-- Listen for rtx_carradio events (if available)
RegisterNetEvent('rtx_carradio:trackChanged', function(trackData)
    if trackData then
        SendNUIMessage({
            action = 'updateMedia',
            data = {
                playing = true,
                title = trackData.title or 'Unknown',
                artist = trackData.artist or 'Unknown',
                thumbnail = trackData.thumbnail or '',
            }
        })
    end
end)

RegisterNetEvent('rtx_carradio:stopped', function()
    SendNUIMessage({
        action = 'updateMedia',
        data = { playing = false }
    })
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           VEHICLE HUD                                   │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get fuel level from configured resource
---@param vehicle number Vehicle entity
---@return number
local function GetFuelLevel(vehicle)
    if not Config.VehicleHud.fuel.enabled then return 100 end
    
    local fuelResource = Config.VehicleHud.fuel.resource
    
    if fuelResource == 'native' or not fuelResource then
        return GetVehicleFuelLevel(vehicle)
    end
    
    if GetResourceState(fuelResource) ~= 'started' then
        return GetVehicleFuelLevel(vehicle)
    end
    
    -- Try different fuel resource exports
    local success, result = pcall(function()
        if fuelResource == 'LegacyFuel' then
            return exports['LegacyFuel']:GetFuel(vehicle)
        elseif fuelResource == 'cdn-fuel' then
            return exports['cdn-fuel']:GetFuel(vehicle)
        elseif fuelResource == 'ps-fuel' then
            return exports['ps-fuel']:GetFuel(vehicle)
        elseif fuelResource == 'ox_fuel' then
            return exports['ox_fuel']:GetFuel(vehicle)
        else
            return exports[fuelResource]:GetFuel(vehicle)
        end
    end)
    
    if success and result then
        return result
    end
    
    return GetVehicleFuelLevel(vehicle)
end

---Get engine health as percentage
---@param vehicle number
---@return number
local function GetEngineHealth(vehicle)
    local health = GetVehicleEngineHealth(vehicle)
    return math.floor((health / 1000) * 100)
end

---Get vehicle speed
---@param vehicle number
---@return number
local function GetVehicleSpeedFormatted(vehicle)
    local speed = GetEntitySpeed(vehicle)
    
    if Config.UseKMH then
        return math.floor(speed * 3.6) -- Convert m/s to km/h
    else
        return math.floor(speed * 2.236936) -- Convert m/s to mph
    end
end

---Check if lights are on
---@param vehicle number
---@return boolean, boolean (lights on, high beams)
local function GetLightsState(vehicle)
    local lightsOn, highBeamsOn = GetVehicleLightsState(vehicle)
    return lightsOn == 1, highBeamsOn == 1
end

-- Vehicle HUD update thread
CreateThread(function()
    if not Config.VehicleHud.enabled then return end
    
    while true do
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)
        
        if inVehicle then
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle ~= currentVehicle then
                currentVehicle = vehicle
                isInVehicle = true
            end
            
            -- Get vehicle data
            local speed = GetVehicleSpeedFormatted(vehicle)
            local rpm = GetVehicleCurrentRpm(vehicle)
            local gear = GetVehicleCurrentGear(vehicle)
            local fuel = GetFuelLevel(vehicle)
            local engineHealth = GetEngineHealth(vehicle)
            local lightsOn, highBeams = GetLightsState(vehicle)
            
            -- Handle reverse gear display
            if gear == 0 then
                gear = 'R'
            elseif speed < 1 and rpm < 0.2 then
                gear = 'N'
            end
            
            SendNUIMessage({
                action = 'updateVehicle',
                data = {
                    inVehicle = true,
                    speed = speed,
                    speedUnit = Config.UseKMH and 'KM/H' or 'MPH',
                    rpm = math.floor(rpm * 100),
                    gear = gear,
                    fuel = math.floor(fuel),
                    fuelLow = fuel <= Config.VehicleHud.fuel.lowWarning,
                    engine = engineHealth,
                    engineDamaged = engineHealth <= Config.VehicleHud.engine.damageWarning,
                    lights = lightsOn,
                    highBeams = highBeams,
                    seatbelt = seatbeltOn,
                }
            })
            
            Wait(50) -- Fast update for smooth speedometer
        else
            if isInVehicle then
                isInVehicle = false
                currentVehicle = 0
                
                SendNUIMessage({
                    action = 'updateVehicle',
                    data = { inVehicle = false }
                })
            end
            
            Wait(500) -- Slower when not in vehicle
        end
    end
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           SEATBELT INTEGRATION                          │
-- └─────────────────────────────────────────────────────────────────────────┘

if Config.VehicleHud.seatbelt.enabled and Config.VehicleHud.seatbelt.resource then
    -- Listen for seatbelt events
    RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
        seatbeltOn = not seatbeltOn
    end)
    
    RegisterNetEvent('qb-seatbelt:client:ToggleSeatbelt', function()
        seatbeltOn = not seatbeltOn
    end)
    
    -- Alternative event names
    RegisterNetEvent('seatbelt:toggled', function(state)
        seatbeltOn = state
    end)
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           NUI CALLBACKS                                 │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Media controls
RegisterNUICallback('mediaControl', function(data, cb)
    local resource = Config.MediaPlayer.resource
    if GetResourceState(resource) ~= 'started' then
        cb('error')
        return
    end
    
    local action = data.action
    
    pcall(function()
        if action == 'play' then
            exports[resource]:Play()
        elseif action == 'pause' then
            exports[resource]:Pause()
        elseif action == 'skip' then
            exports[resource]:Skip()
        elseif action == 'previous' then
            exports[resource]:Previous()
        elseif action == 'volumeUp' then
            exports[resource]:VolumeUp()
        elseif action == 'volumeDown' then
            exports[resource]:VolumeDown()
        end
    end)
    
    cb('ok')
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           EXPORTS                                       │
-- └─────────────────────────────────────────────────────────────────────────┘

exports('IsInVehicle', function() return isInVehicle end)
exports('GetCurrentVehicle', function() return currentVehicle end)
exports('GetSeatbeltState', function() return seatbeltOn end)
exports('SetSeatbeltState', function(state) seatbeltOn = state end)
