--[[
    GRIMM-HUD | Location Module
    Street names, compass heading, time, and weather display
]]

-- State
local currentStreet = ''
local currentCrossing = ''
local currentZone = ''
local currentHeading = 0
local currentPostal = ''

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           STREET NAMES                                  │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get street names at coordinates
---@param coords vector3
---@return string street, string crossing
local function GetStreetNames(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash) or ''
    local crossing = GetStreetNameFromHashKey(crossingHash) or ''
    return street, crossing
end

---Get zone name at coordinates
---@param coords vector3
---@return string
local function GetZoneName(coords)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    return GetLabelText(zone) or zone
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           POSTAL CODES                                  │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get nearest postal code (requires postal resource)
---@return string
local function GetNearestPostal()
    if not Config.InfoPanel.location.showPostal then
        return ''
    end
    
    local postalResource = Config.InfoPanel.location.postalResource
    if not postalResource or GetResourceState(postalResource) ~= 'started' then
        return ''
    end
    
    -- Try to get postal from resource export
    local success, result = pcall(function()
        return exports[postalResource]:getPostal()
    end)
    
    if success and result then
        return tostring(result)
    end
    
    return ''
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           COMPASS                                       │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get cardinal direction from heading
---@param heading number
---@return string
local function GetCardinalDirection(heading)
    local directions = { 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N' }
    local index = math.floor((heading + 22.5) / 45) + 1
    return directions[index] or 'N'
end

---Smooth heading transition
---@param current number
---@param target number
---@param smoothing number
---@return number
local function SmoothHeading(current, target, smoothing)
    local diff = target - current
    
    -- Handle wraparound
    if diff > 180 then
        diff = diff - 360
    elseif diff < -180 then
        diff = diff + 360
    end
    
    return current + (diff * smoothing)
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           TIME & WEATHER                                │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get formatted game time
---@return string
local function GetGameTime()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    
    if Config.InfoPanel.time.use24Hour then
        if Config.InfoPanel.time.showSeconds then
            local second = GetClockSeconds()
            return string.format('%02d:%02d:%02d', hour, minute, second)
        end
        return string.format('%02d:%02d', hour, minute)
    else
        local period = 'AM'
        if hour >= 12 then
            period = 'PM'
            if hour > 12 then hour = hour - 12 end
        end
        if hour == 0 then hour = 12 end
        
        if Config.InfoPanel.time.showSeconds then
            local second = GetClockSeconds()
            return string.format('%d:%02d:%02d %s', hour, minute, second, period)
        end
        return string.format('%d:%02d %s', hour, minute, period)
    end
end

---Get weather icon based on current weather
---@return string icon name
local function GetWeatherIcon()
    local weather = GetPrevWeatherTypeHashName()
    
    local weatherIcons = {
        [`CLEAR`] = 'sun',
        [`EXTRASUNNY`] = 'sun',
        [`CLOUDS`] = 'cloud',
        [`OVERCAST`] = 'cloud',
        [`RAIN`] = 'cloud-rain',
        [`THUNDER`] = 'cloud-bolt',
        [`CLEARING`] = 'cloud-sun',
        [`NEUTRAL`] = 'cloud-sun',
        [`SNOW`] = 'snowflake',
        [`BLIZZARD`] = 'snowflake',
        [`SNOWLIGHT`] = 'snowflake',
        [`XMAS`] = 'snowflake',
        [`HALLOWEEN`] = 'moon',
        [`FOGGY`] = 'smog',
        [`SMOG`] = 'smog',
    }
    
    return weatherIcons[weather] or 'cloud'
end

---Check if it's night time
---@return boolean
local function IsNightTime()
    local hour = GetClockHours()
    return hour >= 20 or hour < 6
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           UPDATE LOOP                                   │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Location update thread (slower refresh for performance)
CreateThread(function()
    while true do
        Wait(500)
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Update street names
        if Config.InfoPanel.location.enabled then
            local street, crossing = GetStreetNames(coords)
            local zone = GetZoneName(coords)
            local postal = GetNearestPostal()
            
            if street ~= currentStreet or crossing ~= currentCrossing or zone ~= currentZone or postal ~= currentPostal then
                currentStreet = street
                currentCrossing = crossing
                currentZone = zone
                currentPostal = postal
                
                SendNUIMessage({
                    action = 'updateLocation',
                    data = {
                        street = currentStreet,
                        crossing = currentCrossing,
                        zone = currentZone,
                        postal = currentPostal,
                    }
                })
            end
        end
        
        -- Update time and weather
        if Config.InfoPanel.time.enabled then
            SendNUIMessage({
                action = 'updateTime',
                data = {
                    time = GetGameTime(),
                    weatherIcon = GetWeatherIcon(),
                    isNight = IsNightTime(),
                }
            })
        end
    end
end)

-- Compass update thread (faster for smooth rotation)
CreateThread(function()
    if not Config.Compass.enabled then return end
    
    local smoothedHeading = 0
    
    while true do
        Wait(50)
        
        local ped = PlayerPedId()
        local heading = GetEntityHeading(ped)
        
        -- Normalize heading (0-360)
        heading = (360 - heading) % 360
        
        -- Smooth the heading
        smoothedHeading = SmoothHeading(smoothedHeading, heading, Config.Compass.smoothing)
        
        -- Normalize smoothed heading
        if smoothedHeading < 0 then smoothedHeading = smoothedHeading + 360 end
        if smoothedHeading >= 360 then smoothedHeading = smoothedHeading - 360 end
        
        SendNUIMessage({
            action = 'updateCompass',
            data = {
                heading = math.floor(smoothedHeading),
                cardinal = GetCardinalDirection(smoothedHeading),
            }
        })
    end
end)

-- Player ID update
CreateThread(function()
    if not Config.InfoPanel.playerId.enabled then return end
    
    Wait(2000) -- Wait for player to load
    
    local playerId = GetPlayerServerId(PlayerId())
    local citizenId = ''
    
    if Config.InfoPanel.playerId.showCitizenId then
        local QBCore = exports['qb-core']:GetCoreObject()
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.citizenid then
            citizenId = playerData.citizenid
        end
    end
    
    SendNUIMessage({
        action = 'updatePlayerId',
        data = {
            serverId = playerId,
            citizenId = citizenId,
        }
    })
end)

-- Online players update (optional)
if Config.InfoPanel.onlinePlayers and Config.InfoPanel.onlinePlayers.enabled then
    CreateThread(function()
        while true do
            Wait(10000) -- Update every 10 seconds
            
            local players = GetActivePlayers()
            
            SendNUIMessage({
                action = 'updateOnlinePlayers',
                data = {
                    count = #players,
                }
            })
        end
    end)
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           EXPORTS                                       │
-- └─────────────────────────────────────────────────────────────────────────┘

exports('GetCurrentStreet', function() return currentStreet end)
exports('GetCurrentZone', function() return currentZone end)
exports('GetCurrentHeading', function() return currentHeading end)
exports('GetCurrentPostal', function() return currentPostal end)
