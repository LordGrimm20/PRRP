local QBCore = exports['qb-core']:GetCoreObject()

-- Variables (Per-Player)
local CurrentDestination = 0
local TourActive = false
local TourRequested = false
local CityHallPed = nil
local VehicleBlip = nil
local MyTourVehicle = nil
local MyTourDriver = nil
local AutoTourCancelled = false
local CustomizationComplete = false
local AutoTourStarted = false

-- Utility Functions
local function GetDistance(coords1, coords2)
    if not coords1 or not coords2 then return 999999 end
    return #(coords1 - coords2)
end

local function SpawnVehicle(model, coords, heading)
    local modelHash = GetHashKey(model)
    
    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        return nil
    end
    
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then
        return nil
    end
    
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetModelAsNoLongerNeeded(modelHash)
    
    if not DoesEntityExist(vehicle) then
        return nil
    end
    
    return vehicle
end

local function SpawnPed(model, coords)
    local modelHash = GetHashKey(model)
    
    if not IsModelInCdimage(modelHash) then
        return nil
    end

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then
        return nil
    end

    local ped = CreatePed(6, modelHash, coords, false, true)
    
    if not DoesEntityExist(ped) then
        return nil
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, false)
    SetModelAsNoLongerNeeded(modelHash)
    
    return ped
end

local function GetSafeSpawnLocation(playerCoords, distance)
    local found = false
    local spawnCoords = nil
    local spawnHeading = 0
    local attempts = 0
    local maxAttempts = 10
    
    while not found and attempts < maxAttempts do
        attempts = attempts + 1
        
        local angle = math.random() * 2 * math.pi
        local x = playerCoords.x + (math.cos(angle) * distance)
        local y = playerCoords.y + (math.sin(angle) * distance)
        local z = playerCoords.z
        
        local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z + 100, 0)
        if foundGround then
            z = groundZ
        end
        
        local roadFound, roadCoords, roadHeading = GetClosestVehicleNodeWithHeading(x, y, z, 1, 3.0, 0)
        
        if roadFound then
            local roadDistance = #(playerCoords - roadCoords)
            if roadDistance >= (distance * 0.7) and roadDistance <= (distance * 1.5) then
                local isDriveable = IsPointOnRoad(roadCoords.x, roadCoords.y, roadCoords.z, 0)
                
                if isDriveable or attempts >= 5 then
                    spawnCoords = roadCoords
                    spawnHeading = roadHeading
                    found = true
                    
                    if DebugEnabled then
                        print('[Grimm] Found valid road spawn after ' .. attempts .. ' attempts')
                        print('[Grimm] Road distance from player: ' .. roadDistance)
                    end
                end
            end
        end
    end
    
    if not found then
        if DebugEnabled then
            print('[Grimm] No valid road found, using fallback position')
        end
        
        local angle = math.random() * 2 * math.pi
        local x = playerCoords.x + (math.cos(angle) * distance)
        local y = playerCoords.y + (math.sin(angle) * distance)
        local z = playerCoords.z
        
        local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z + 100, 0)
        if foundGround then
            z = groundZ
        end
        
        spawnCoords = vector3(x, y, z)
        spawnHeading = math.random(0, 360)
    end
    
    return spawnCoords, spawnHeading
end

local function IsPlayerInCustomization()
    if GetResourceState('illenium-appearance') == 'started' then
        local success, result = pcall(function()
            return exports['illenium-appearance']:isPlayerInShop()
        end)
        if success and result then
            return true
        end
    end
    
    if GetResourceState('qb-clothing') == 'started' then
        local success, result = pcall(function()
            return exports['qb-clothing']:InClothingShop()
        end)
        if success and result then
            return true
        end
    end
    
    if GetResourceState('fivem-appearance') == 'started' then
        local success, result = pcall(function()
            return exports['fivem-appearance']:isPedFreecamActive()
        end)
        if success and result then
            return true
        end
    end
    
    if IsNuiFocused() then
        return true
    end
    
    if GetFollowPedCamViewMode() == 4 then
        return true
    end
    
    return false
end

local function WaitForCustomizationComplete()
    if not Config.AutoWaitForCustomization then
        return true
    end
    
    local maxWaitTime = 300000
    local waitedTime = 0
    
    while waitedTime < maxWaitTime do
        if not IsPlayerInCustomization() then
            if DebugEnabled then
                print('[Grimm] Player customization complete, proceeding with auto-tour')
            end
            return true
        end
        
        if DebugEnabled and waitedTime % 10000 == 0 then
            print('[Grimm] Waiting for player customization to complete...')
        end
        
        Wait(Config.AutoCheckInterval)
        waitedTime = waitedTime + Config.AutoCheckInterval
        
        if AutoTourCancelled then
            if DebugEnabled then
                print('[Grimm] Tour cancelled during customization wait')
            end
            return false
        end
    end
    
    if DebugEnabled then
        print('[Grimm] Customization wait timeout, proceeding with auto-tour')
    end
    return true
end

local function StartTour()
    if DebugEnabled then
        print('[Grimm] StartTour called')
        print('[Grimm] HasPlayerCompletedIntro: ' .. tostring(HasPlayerCompletedIntro))
        print('[Grimm] TourActive: ' .. tostring(TourActive))
        print('[Grimm] TourRequested: ' .. tostring(TourRequested))
    end
    
    if HasPlayerCompletedIntro then
        TriggerEvent('QBCore:Notify', Config.Messages.AlreadyCompleted, 'error')
        return
    end
    
    if TourActive or TourRequested then
        TriggerEvent('QBCore:Notify', Config.Messages.AlreadyActive, 'error')
        return
    end
    
    TourRequested = true
    
    TriggerEvent('QBCore:Notify', Config.Messages.Calling, 'success')
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if DebugEnabled then
        print('[Grimm] Player coords: ' .. tostring(playerCoords))
    end
    
    local spawnCoords, spawnHeading = GetSafeSpawnLocation(playerCoords, Config.VehicleSpawnDistance)
    
    if DebugEnabled then
        print('[Grimm] Spawning tour vehicle at: ' .. tostring(spawnCoords))
        print('[Grimm] Spawn heading: ' .. spawnHeading)
    end
    
    MyTourVehicle = SpawnVehicle(Config.TaxiVehicle.Model, spawnCoords, spawnHeading)
    
    if not MyTourVehicle then
        TriggerEvent('QBCore:Notify', 'Failed to spawn tour vehicle', 'error')
        TourRequested = false
        if DebugEnabled then
            print('[Grimm] ERROR: Vehicle spawn failed')
        end
        return
    end
    
    if DebugEnabled then
        print('[Grimm] Vehicle spawned successfully: ' .. tostring(MyTourVehicle))
    end
    
    SetEntityAsMissionEntity(MyTourVehicle, true, true)
    SetEntityInvincible(MyTourVehicle, true)
    SetVehicleEngineOn(MyTourVehicle, true, true, false)
    SetVehicleDirtLevel(MyTourVehicle, 0.0)
    SetVehicleColours(MyTourVehicle, 6, 6)
    SetVehicleNumberPlateText(MyTourVehicle, "TOUR" .. math.random(100, 999))
    SetVehicleDoorsLocked(MyTourVehicle, 0)
    
    MyTourDriver = SpawnPed(Config.TaxiDriver.Model, spawnCoords)
    
    if not MyTourDriver then
        TriggerEvent('QBCore:Notify', 'Failed to spawn driver', 'error')
        DeleteVehicle(MyTourVehicle)
        MyTourVehicle = nil
        TourRequested = false
        if DebugEnabled then
            print('[Grimm] ERROR: Driver ped spawn failed')
        end
        return
    end
    
    if DebugEnabled then
        print('[Grimm] Driver ped spawned successfully: ' .. tostring(MyTourDriver))
    end
    
    TaskWarpPedIntoVehicle(MyTourDriver, MyTourVehicle, -1)
    
    Wait(500)
    
    if DebugEnabled then
        print('[Grimm] Starting drive task to player location')
        print('[Grimm] Target coords: ' .. tostring(playerCoords))
    end
    
    TaskVehicleDriveToCoord(MyTourDriver, 
        MyTourVehicle,
        playerCoords.x,
        playerCoords.y,
        playerCoords.z,
        20.0,
        1.0,
        GetEntityModel(MyTourVehicle),
        Config.TaxiDriver.DrivingStyle,
        Config.VehicleStopDistance,
        true)
    
    SetPedKeepTask(MyTourDriver, true)
    
    if DebugEnabled then
        print('[Grimm] Drive task started, taxi will stop ' .. Config.VehicleStopDistance .. 'm from player')
    end
    
    if Config.ShowVehicleBlip then
        VehicleBlip = AddBlipForEntity(MyTourVehicle)
        SetBlipSprite(VehicleBlip, 225)
        SetBlipColour(VehicleBlip, 5)
        SetBlipScale(VehicleBlip, 0.8)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Your Tour Taxi")
        EndTextCommandSetBlipName(VehicleBlip)
        
        if DebugEnabled then
            print('[Grimm] Vehicle blip created')
        end
    end
    
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(MyTourVehicle, {
            options = {
                {
                    type = "client",
                    event = "GrimmTour:Client:EnterVehicle",
                    icon = "fa-solid fa-car-side",
                    label = "Get in tour taxi",
                },
            },
            distance = 3.0,
        })
        
        if DebugEnabled then
            print('[Grimm] qb-target added to vehicle')
        end
    else
        if DebugEnabled then
            print('[Grimm] WARNING: qb-target not started, cannot add target')
        end
    end
end

local function StartDriveTask(destinationNumber)
    if not MyTourDriver or not DoesEntityExist(MyTourDriver) then
        return false
    end
    
    if not MyTourVehicle or not DoesEntityExist(MyTourVehicle) then
        return false
    end
    
    if not Config.SightSeeingLocations[destinationNumber] then
        return false
    end
    
    TaskVehicleDriveToCoord(MyTourDriver, 
        MyTourVehicle,
        Config.SightSeeingLocations[destinationNumber].Coordinates.x,
        Config.SightSeeingLocations[destinationNumber].Coordinates.y,
        Config.SightSeeingLocations[destinationNumber].Coordinates.z,
        Config.SightSeeingLocations[destinationNumber].VehicleSpeed,
        Config.DistanceFromDestinations - 0.2,
        GetEntityModel(MyTourVehicle),
        Config.TaxiDriver.DrivingStyle,
        Config.DistanceFromDestinations,
        true)
        
    SetPedKeepTask(MyTourDriver, true)

    local destinationName = Config.SightSeeingLocations[CurrentDestination].Name
    if destinationName and destinationName ~= '' then
        TriggerEvent('QBCore:Notify', 'Next stop: ' .. destinationName, 'primary')
    end
    
    return true
end

local function CleanupTour()
    CurrentDestination = 0
    TourActive = false
    TourRequested = false

    if VehicleBlip and DoesBlipExist(VehicleBlip) then
        RemoveBlip(VehicleBlip)
        VehicleBlip = nil
    end

    if MyTourDriver and DoesEntityExist(MyTourDriver) then
        DeletePed(MyTourDriver)
        MyTourDriver = nil
    end

    if MyTourVehicle and DoesEntityExist(MyTourVehicle) then
        DeleteVehicle(MyTourVehicle)
        MyTourVehicle = nil
    end
    
    AutoTourStarted = false
end

local function SetupCityHallPed()
    if CityHallPed and DoesEntityExist(CityHallPed) then
        return
    end
    
    CityHallPed = SpawnPed(Config.CityHallPed.Model, Config.CityHallPed.Coordinates)
    
    if not CityHallPed then
        return
    end
    
    FreezeEntityPosition(CityHallPed, true)
    SetEntityInvincible(CityHallPed, true)
    SetBlockingOfNonTemporaryEvents(CityHallPed, true)
    
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(CityHallPed, {
            options = {
                {
                    type = "client",
                    event = "GrimmTour:Client:RequestTour",
                    icon = "fa-solid fa-map",
                    label = Config.CityHallPed.Label,
                },
            },
            distance = 2.0,
        })
    end
end

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if DebugEnabled then
        print('[Grimm] QBCore:Client:OnPlayerLoaded event fired')
    end
    
    Wait(1000)
    TriggerServerEvent('GrimmTour:Server:CheckCompletion')
    
    if Config.ShowWelcomeNotification then
        Wait(Config.WelcomeNotificationDelay)
        
        if DebugEnabled then
            print('[Grimm] HasPlayerCompletedIntro: ' .. tostring(HasPlayerCompletedIntro))
            print('[Grimm] TriggerMethod: ' .. Config.TriggerMethod)
        end
        
        if not HasPlayerCompletedIntro then
            if Config.TriggerMethod == "command" then
                TriggerEvent('QBCore:Notify', 'New to the city? Type /calltour to get a free city tour!', 'primary', 8000)
            elseif Config.TriggerMethod == "keybind" then
                TriggerEvent('QBCore:Notify', 'New to the city? Press ' .. Config.KeybindKey .. ' to request a city tour!', 'primary', 8000)
            elseif Config.TriggerMethod == "cityhall" then
                TriggerEvent('QBCore:Notify', 'New to the city? Visit City Hall to request a free city tour!', 'primary', 8000)
            elseif Config.TriggerMethod == "auto" then
                if DebugEnabled then
                    print('[Grimm] Auto mode detected, starting customization wait thread')
                end
                
                if not AutoTourStarted then
                    AutoTourStarted = true
                    
                    CreateThread(function()
                        if DebugEnabled then
                            print('[Grimm] Customization wait thread started')
                        end
                        
                        local customizationDone = WaitForCustomizationComplete()
                        
                        if DebugEnabled then
                            print('[Grimm] Customization done: ' .. tostring(customizationDone))
                            print('[Grimm] AutoTourCancelled: ' .. tostring(AutoTourCancelled))
                        end
                        
                        if not customizationDone or AutoTourCancelled or HasPlayerCompletedIntro then
                            if DebugEnabled then
                                print('[Grimm] Aborting auto-tour')
                            end
                            return
                        end
                        
                        if Config.AutoShowNotification and Config.AutoAllowCancel then
                            if DebugEnabled then
                                print('[Grimm] Showing auto-start notification')
                            end
                            TriggerEvent('QBCore:Notify', Config.Messages.AutoStarting, 'primary', 8000)
                            Wait(Config.AutoNotificationDelay)
                        end
                        
                        if not HasPlayerCompletedIntro and not AutoTourCancelled then
                            Wait(Config.AutoTriggerDelay - Config.AutoNotificationDelay)
                            
                            if DebugEnabled then
                                print('[Grimm] Starting auto-tour now')
                            end
                            
                            TriggerEvent('QBCore:Notify', Config.Messages.AutoStarted, 'success')
                            TriggerEvent('GrimmTour:Client:RequestTour')
                        end
                    end)
                else
                    if DebugEnabled then
                        print('[Grimm] Auto-tour already started, skipping duplicate')
                    end
                end
            end
        else
            if DebugEnabled then
                print('[Grimm] Player has already completed intro, not showing notification')
            end
        end
    end
    
    if Config.TriggerMethod == "cityhall" then
        SetupCityHallPed()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end

    Wait(1000)
    
    if QBCore.Functions.GetPlayerData() and next(QBCore.Functions.GetPlayerData()) then
        TriggerServerEvent('GrimmTour:Server:CheckCompletion')
        
        if Config.TriggerMethod == "cityhall" then
            SetupCityHallPed()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then
        return  
    end
    
    CleanupTour()
    
    if CityHallPed and DoesEntityExist(CityHallPed) then
        DeletePed(CityHallPed)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    CleanupTour()
end)

RegisterNetEvent('GrimmTour:Client:SetCompleted', function(completed)
    HasPlayerCompletedIntro = completed
end)

RegisterNetEvent('GrimmTour:Client:RequestTour', function()
    StartTour()
end)

RegisterNetEvent('GrimmTour:Client:EnterVehicle', function()
    if not MyTourVehicle or not DoesEntityExist(MyTourVehicle) then
        TriggerEvent('QBCore:Notify', 'Vehicle is not available', 'error')
        return
    end
    
    if TourActive then
        TriggerEvent('QBCore:Notify', 'Tour already started', 'error')
        return
    end
    
    local seatToUse = 1
    if IsVehicleSeatFree(MyTourVehicle, 1) then
        seatToUse = 1
    elseif IsVehicleSeatFree(MyTourVehicle, 2) then
        seatToUse = 2
    else
        TriggerEvent('QBCore:Notify', 'No rear seats available', 'error')
        return
    end
    
    local doorIndex = seatToUse == 1 and 2 or 3
    SetVehicleDoorOpen(MyTourVehicle, doorIndex, false, false)
    
    Wait(500)
    
    TaskWarpPedIntoVehicle(PlayerPedId(), MyTourVehicle, seatToUse)
    
    Wait(500)
    
    if IsPedInVehicle(PlayerPedId(), MyTourVehicle, false) then
        SetVehicleDoorShut(MyTourVehicle, doorIndex, false)
        Wait(300)
        
        if VehicleBlip and DoesBlipExist(VehicleBlip) then
            RemoveBlip(VehicleBlip)
            VehicleBlip = nil
        end
        
        TourActive = true
        TourRequested = false
        SetVehicleDoorsLocked(MyTourVehicle, 4)
        CurrentDestination = 1
        
        TriggerEvent('QBCore:Notify', Config.Messages.Arriving, 'success')
        
        StartDriveTask(CurrentDestination)
    else
        SetVehicleDoorShut(MyTourVehicle, doorIndex, false)
        TriggerEvent('QBCore:Notify', 'Failed to enter vehicle', 'error')
    end
end)

RegisterNetEvent('GrimmTour:Client:TourConcluded', function()
    if MyTourVehicle and DoesEntityExist(MyTourVehicle) then
        SetVehicleDoorsLocked(MyTourVehicle, 1)
        
        if IsPedInVehicle(PlayerPedId(), MyTourVehicle, false) then
            TaskLeaveVehicle(PlayerPedId(), MyTourVehicle, 4160)
        end
    end
    
    TriggerServerEvent('GrimmTour:Server:CompleteTour')
    
    Wait(5000)
    CleanupTour()
end)

-- Commands
RegisterCommand('canceltour', function()
    if Config.TriggerMethod == "auto" and not TourActive and not TourRequested then
        AutoTourCancelled = true
        TriggerEvent('QBCore:Notify', 'City tour cancelled. Type /calltour anytime to start one.', 'error')
    elseif TourActive or TourRequested then
        CleanupTour()
        TriggerEvent('QBCore:Notify', 'Tour cancelled', 'error')
    else
        TriggerEvent('QBCore:Notify', 'No active tour to cancel', 'error')
    end
end)

RegisterCommand('calltour', function()
    if Config.TriggerMethod == "auto" or Config.TriggerMethod == "command" then
        AutoTourCancelled = false
        TriggerEvent('GrimmTour:Client:RequestTour')
    end
end, false)

if Config.TriggerMethod == "keybind" then
    RegisterCommand('requesttour', function()
        if not HasPlayerCompletedIntro then
            TriggerEvent('GrimmTour:Client:RequestTour')
        end
    end, false)
    
    RegisterKeyMapping('requesttour', Config.KeybindLabel, 'keyboard', Config.KeybindKey)
end

RegisterCommand('grimmtourcheck', function()
    print('=== GRIMM TOUR DEBUG INFO ===')
    print('HasPlayerCompletedIntro: ' .. tostring(HasPlayerCompletedIntro))
    print('TourActive: ' .. tostring(TourActive))
    print('TourRequested: ' .. tostring(TourRequested))
    print('AutoTourCancelled: ' .. tostring(AutoTourCancelled))
    print('AutoTourStarted: ' .. tostring(AutoTourStarted))
    print('CurrentDestination: ' .. tostring(CurrentDestination))
    print('Vehicle Exists: ' .. tostring(MyTourVehicle and DoesEntityExist(MyTourVehicle)))
    print('Driver Exists: ' .. tostring(MyTourDriver and DoesEntityExist(MyTourDriver)))
    print('Trigger Method: ' .. Config.TriggerMethod)
    print('In Customization: ' .. tostring(IsPlayerInCustomization()))
    print('======================')
    TriggerEvent('QBCore:Notify', 'Check F8 console for debug info', 'primary')
end)

RegisterCommand('grimmforcestart', function()
    print('[Grimm] Force starting tour via command')
    AutoTourCancelled = false
    TriggerEvent('GrimmTour:Client:RequestTour')
end)

-- Threads
Citizen.CreateThread(function()
    while true do
        if TourActive and CurrentDestination > 0 then
            if MyTourVehicle and DoesEntityExist(MyTourVehicle) and
               MyTourDriver and DoesEntityExist(MyTourDriver) then
                
                local currentVehicleCoords = GetEntityCoords(MyTourVehicle)
                local distanceToCurrentDestination = GetDistance(currentVehicleCoords, Config.SightSeeingLocations[CurrentDestination].Coordinates)

                if distanceToCurrentDestination <= (Config.DistanceFromDestinations + 10) and not GetIsTaskActive(MyTourDriver, DrivingTask) then
                    TriggerEvent('QBCore:Notify', Config.SightSeeingLocations[CurrentDestination].Message, 'primary')

                    Wait(Config.SecondsToWaitAtEachDestination * 1000)

                    CurrentDestination = CurrentDestination + 1

                    if not Config.SightSeeingLocations[CurrentDestination] then 
                        TriggerEvent('GrimmTour:Client:TourConcluded')
                        break
                    end

                    StartDriveTask(CurrentDestination)
                end
            else
                TourActive = false
                CleanupTour()
                break
            end
        end
        
        Wait(100)
    end
end)
