-- Client Utility Functions for QB-AdminMenu Enhanced
QBCore = exports['qb-core']:GetCoreObject()

-- Teleport with fade effect
function TeleportToCoords(coords, heading)
    local ped = PlayerPedId()
    
    if Config.Teleport.FadeScreen then
        DoScreenFadeOut(Config.Teleport.FadeDuration)
        Wait(Config.Teleport.FadeDuration)
    end
    
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    
    if heading then
        SetEntityHeading(ped, heading)
    end
    
    if Config.Teleport.FadeScreen then
        Wait(Config.Teleport.FadeDuration)
        DoScreenFadeIn(Config.Teleport.FadeDuration)
    end
end

-- Safe entity check
function IsEntityValid(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
end

-- Get closest player
function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    
    for _, value in ipairs(players) do
        local target = GetPlayerPed(value)
        if target ~= ply then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = #(targetCoords - plyCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Draw 3D text
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Show notification with custom type
function ShowNotification(message, type, duration)
    if type == 'success' then
        QBCore.Functions.Notify(message, 'success', duration or 5000)
    elseif type == 'error' then
        QBCore.Functions.Notify(message, 'error', duration or 5000)
    elseif type == 'info' then
        QBCore.Functions.Notify(message, 'primary', duration or 5000)
    else
        QBCore.Functions.Notify(message, type or 'primary', duration or 5000)
    end
end

-- Format number with commas
function FormatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Get vehicle class name
function GetVehicleClassName(vehicle)
    local class = GetVehicleClass(vehicle)
    local classes = {
        [0] = "Compacts",
        [1] = "Sedans",
        [2] = "SUVs",
        [3] = "Coupes",
        [4] = "Muscle",
        [5] = "Sports Classics",
        [6] = "Sports",
        [7] = "Super",
        [8] = "Motorcycles",
        [9] = "Off-road",
        [10] = "Industrial",
        [11] = "Utility",
        [12] = "Vans",
        [13] = "Cycles",
        [14] = "Boats",
        [15] = "Helicopters",
        [16] = "Planes",
        [17] = "Service",
        [18] = "Emergency",
        [19] = "Military",
        [20] = "Commercial",
        [21] = "Trains"
    }
    return classes[class] or "Unknown"
end

-- Round number to decimals
function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Check if player has weapon
function HasWeapon(weaponHash)
    local ped = PlayerPedId()
    return HasPedGotWeapon(ped, weaponHash, false)
end

-- Get current vehicle
function GetCurrentVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

-- Request model with timeout
function RequestModelWithTimeout(model, timeout)
    timeout = timeout or 5000
    local modelHash = type(model) == "string" and GetHashKey(model) or model
    
    if not IsModelInCdimage(modelHash) then
        return false
    end
    
    RequestModel(modelHash)
    local startTime = GetGameTimer()
    
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() - startTime > timeout then
            return false
        end
        Wait(0)
    end
    
    return true
end

-- Get street name at coords
function GetStreetNameAtCoords(coords)
    local streetName1, streetName2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1 = GetStreetNameFromHashKey(streetName1)
    local street2 = GetStreetNameFromHashKey(streetName2)
    
    if street2 and street2 ~= "" then
        return street1 .. " | " .. street2
    else
        return street1
    end
end

-- Check if coords are in water
function IsCoordsInWater(coords)
    local result, height = GetWaterHeight(coords.x, coords.y, coords.z)
    return result and coords.z < height
end

-- Get zone name at coords
function GetZoneNameAtCoords(coords)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local zones = {
        ['AIRP'] = 'Los Santos International Airport',
        ['ALAMO'] = 'Alamo Sea',
        ['ALTA'] = 'Alta',
        ['ARMYB'] = 'Fort Zancudo',
        ['BANHAMC'] = 'Banham Canyon',
        ['BANNING'] = 'Banning',
        ['BEACH'] = 'Vespucci Beach',
        ['BHAMCA'] = 'Banham Canyon',
        ['BRADP'] = 'Braddock Pass',
        ['BRADT'] = 'Braddock Tunnel',
        ['BURTON'] = 'Burton',
        ['CALAFB'] = 'Calafia Bridge',
        ['CANNY'] = 'Raton Canyon',
        ['CCREAK'] = 'Cassidy Creek',
        ['CHAMH'] = 'Chamberlain Hills',
        ['CHIL'] = 'Vinewood Hills',
        ['CHU'] = 'Chumash',
        ['CMSW'] = 'Chiliad Mountain State Wilderness',
        ['CYPRE'] = 'Cypress Flats',
        ['DAVIS'] = 'Davis',
        ['DELBE'] = 'Del Perro Beach',
        ['DELPE'] = 'Del Perro',
        ['DELSOL'] = 'La Puerta',
        ['DESRT'] = 'Grand Senora Desert',
        ['DOWNT'] = 'Downtown',
        ['DTVINE'] = 'Downtown Vinewood',
        ['EAST_V'] = 'East Vinewood',
        ['EBURO'] = 'El Burro Heights',
        ['ELGORL'] = 'El Gordo Lighthouse',
        ['ELYSIAN'] = 'Elysian Island',
        ['GALFISH'] = 'Galilee',
        ['GOLF'] = 'GWC and Golfing Society',
        ['GRAPES'] = 'Grapeseed',
        ['GREATC'] = 'Great Chaparral',
        ['HARMO'] = 'Harmony',
        ['HAWICK'] = 'Hawick',
        ['HORS'] = 'Vinewood Racetrack',
        ['HUMLAB'] = 'Humane Labs and Research',
        ['JAIL'] = 'Bolingbroke Penitentiary',
        ['KOREAT'] = 'Little Seoul',
        ['LACT'] = 'Land Act Reservoir',
        ['LAGO'] = 'Lago Zancudo',
        ['LDAM'] = 'Land Act Dam',
        ['LEGSQU'] = 'Legion Square',
        ['LMESA'] = 'La Mesa',
        ['LOSPUER'] = 'La Puerta',
        ['MIRR'] = 'Mirror Park',
        ['MORN'] = 'Morningwood',
        ['MOVIE'] = 'Richards Majestic',
        ['MTCHIL'] = 'Mount Chiliad',
        ['MTGORDO'] = 'Mount Gordo',
        ['MTJOSE'] = 'Mount Josiah',
        ['MURRI'] = 'Murrieta Heights',
        ['NCHU'] = 'North Chumash',
        ['NOOSE'] = 'N.O.O.S.E',
        ['OCEANA'] = 'Pacific Ocean',
        ['PALCOV'] = 'Paleto Cove',
        ['PALETO'] = 'Paleto Bay',
        ['PALFOR'] = 'Paleto Forest',
        ['PALHIGH'] = 'Palomino Highlands',
        ['PALMPOW'] = 'Palmer-Taylor Power Station',
        ['PBLUFF'] = 'Pacific Bluffs',
        ['PBOX'] = 'Pillbox Hill',
        ['PROCOB'] = 'Procopio Beach',
        ['RANCHO'] = 'Rancho',
        ['RGLEN'] = 'Richman Glen',
        ['RICHM'] = 'Richman',
        ['ROCKF'] = 'Rockford Hills',
        ['RTRAK'] = 'Redwood Lights Track',
        ['SANAND'] = 'San Andreas',
        ['SANCHIA'] = 'San Chianski Mountain Range',
        ['SANDY'] = 'Sandy Shores',
        ['SKID'] = 'Mission Row',
        ['SLAB'] = 'Stab City',
        ['STAD'] = 'Maze Bank Arena',
        ['STRAW'] = 'Strawberry',
        ['TATAMO'] = 'Tataviam Mountains',
        ['TERMINA'] = 'Terminal',
        ['TEXTI'] = 'Textile City',
        ['TONGVAH'] = 'Tongva Hills',
        ['TONGVAV'] = 'Tongva Valley',
        ['VCANA'] = 'Vespucci Canals',
        ['VESP'] = 'Vespucci',
        ['VINE'] = 'Vinewood',
        ['WINDF'] = 'Ron Alternates Wind Farm',
        ['WVINE'] = 'West Vinewood',
        ['ZANCUDO'] = 'Zancudo River',
        ['ZP_ORT'] = 'Port of South Los Santos',
        ['ZQ_UAR'] = 'Davis Quartz'
    }
    return zones[zone] or zone
end

print('^2[qb-adminmenu]^7 Client Utils Loaded ^2✓^7')
