

local QBCore = exports['qb-core']:GetCoreObject()

-- State
local isOpen = false
local cam = nil
local charPed = nil
local currentCharacter = nil

-- =====================================
-- CAMERA FUNCTIONS
-- =====================================

local function SetupCamera()
    local coords = Config.CamCoords
    
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamRot(cam, -5.0, 0.0, coords.w, 2)
    SetCamFov(cam, 40.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, false)
end

local function DestroyCamera()
    if not cam then return end
    
    RenderScriptCams(false, true, 500, true, false)
    DestroyCam(cam, false)
    cam = nil
end

-- =====================================
-- PED FUNCTIONS
-- =====================================

---@param model number|string
---@return number ped
local function CreatePreviewPed(model)
    if charPed and DoesEntityExist(charPed) then
        DeleteEntity(charPed)
        charPed = nil
    end
    
    local modelHash = type(model) == 'string' and joaat(model) or model
    
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(modelHash) then
        return 0
    end
    
    local coords = Config.CamCoords
    local spawnCoords = vector3(coords.x, coords.y + 2.0, coords.z - 1.0)
    
    charPed = CreatePed(2, modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, coords.w + 180.0, false, true)
    
    FreezeEntityPosition(charPed, true)
    SetEntityInvincible(charPed, true)
    SetBlockingOfNonTemporaryEvents(charPed, true)
    SetModelAsNoLongerNeeded(modelHash)
    
    return charPed
end

local function DestroyPreviewPed()
    if charPed and DoesEntityExist(charPed) then
        DeleteEntity(charPed)
        charPed = nil
    end
end

---@param ped number
---@param skin table
local function ApplySkinToPed(ped, skin)
    if not ped or not DoesEntityExist(ped) or not skin then 
        print('[grimm-multicharacter] ApplySkinToPed failed - invalid ped or skin')
        return 
    end
    
    print('[grimm-multicharacter] Applying skin to ped...')
    
    -- IMPORTANT: Must set head blend first before other appearance data
    if skin.headBlend then
        local hb = skin.headBlend
        SetPedHeadBlendData(ped, 
            tonumber(hb.shapeFirst) or 0, 
            tonumber(hb.shapeSecond) or 0, 
            0, 
            tonumber(hb.skinFirst) or 0, 
            tonumber(hb.skinSecond) or 0, 
            0, 
            tonumber(hb.shapeMix) or 0.5, 
            tonumber(hb.skinMix) or 0.5, 
            0.0, 
            false
        )
    else
        -- Set default head blend if none exists
        SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)
    end
    
    -- Face features
    if skin.faceFeatures then
        for i, v in pairs(skin.faceFeatures) do
            SetPedFaceFeature(ped, tonumber(i), tonumber(v) + 0.0)
        end
    end
    
    -- Head overlays (blemishes, facial hair, eyebrows, etc.)
    if skin.headOverlays then
        for i, overlay in pairs(skin.headOverlays) do
            local idx = tonumber(i)
            local style = tonumber(overlay.style) or 255
            local opacity = tonumber(overlay.opacity) or 1.0
            
            SetPedHeadOverlay(ped, idx, style, opacity + 0.0)
            
            if overlay.color ~= nil then
                local colorType = 1
                -- Makeup types use color type 2
                if idx == 4 or idx == 5 or idx == 8 then
                    colorType = 2
                end
                SetPedHeadOverlayColor(ped, idx, colorType, tonumber(overlay.color) or 0, tonumber(overlay.secondColor) or 0)
            end
        end
    end
    
    -- Hair (component 2)
    if skin.hair then
        SetPedComponentVariation(ped, 2, tonumber(skin.hair.style) or 0, tonumber(skin.hair.texture) or 0, 0)
        SetPedHairColor(ped, tonumber(skin.hair.color) or 0, tonumber(skin.hair.highlight) or 0)
    end
    
    -- Eye color
    if skin.eyeColor ~= nil then
        SetPedEyeColor(ped, tonumber(skin.eyeColor) or 0)
    end
    
    -- Components (clothing) - skip index 2 as it's hair
    if skin.components then
        for i, comp in pairs(skin.components) do
            local idx = tonumber(i)
            if idx ~= 2 then -- Don't override hair
                SetPedComponentVariation(ped, idx, tonumber(comp.drawable) or 0, tonumber(comp.texture) or 0, tonumber(comp.palette) or 0)
            end
        end
    end
    
    -- Props (hats, glasses, etc.)
    if skin.props then
        for i, prop in pairs(skin.props) do
            local idx = tonumber(i)
            local drawable = tonumber(prop.drawable)
            if drawable == nil or drawable == -1 then
                ClearPedProp(ped, idx)
            else
                SetPedPropIndex(ped, idx, drawable, tonumber(prop.texture) or 0, true)
            end
        end
    end
    
    print('[grimm-multicharacter] Skin applied successfully')
end

-- =====================================
-- UI FUNCTIONS
-- =====================================

local function OpenUI()
    if isOpen then return end
    isOpen = true
    
    -- Setup scene
    DoScreenFadeOut(500)
    Wait(500)
    
    SetupCamera()
    
    -- Hide HUD
    DisplayRadar(false)
    
    -- Freeze player
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)
    
    DoScreenFadeIn(500)
    
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'show' })
end

local function CloseUI()
    if not isOpen then return end
    isOpen = false
    
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    
    DestroyCamera()
    DestroyPreviewPed()
    
    -- Restore player
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true, false)
    DisplayRadar(true)
end

-- =====================================
-- NUI CALLBACKS
-- =====================================

RegisterNUICallback('getCharacters', function(_, cb)
    QBCore.Functions.TriggerCallback('grimm-multicharacter:server:getCharacters', function(data)
        cb(data)
    end)
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    if not data.citizenid then
        cb({ success = false })
        return
    end
    
    currentCharacter = data.citizenid
    
    QBCore.Functions.TriggerCallback('grimm-multicharacter:server:getCharacterData', function(charData)
        if charData then
            local model = charData.skin and charData.skin.model
            if not model then
                model = (charData.charinfo and charData.charinfo.gender == 1) and `mp_f_freemode_01` or `mp_m_freemode_01`
            end
            
            local ped = CreatePreviewPed(model)
            if ped and charData.skin then
                ApplySkinToPed(ped, charData.skin)
            end
        end
        
        cb({ success = true })
    end, data.citizenid)
end)

RegisterNUICallback('previewGender', function(data, cb)
    local model = data.gender == 'female' and `mp_f_freemode_01` or `mp_m_freemode_01`
    CreatePreviewPed(model)
    cb({ success = true })
end)

RegisterNUICallback('createCharacter', function(data, cb)
    QBCore.Functions.TriggerCallback('grimm-multicharacter:server:createCharacter', function(result)
        if result.success then
            currentCharacter = result.citizenid
        end
        cb(result)
    end, data)
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    if not data.citizenid then
        cb({ success = false })
        return
    end
    
    QBCore.Functions.TriggerCallback('grimm-multicharacter:server:deleteCharacter', function(result)
        if result.success then
            DestroyPreviewPed()
            currentCharacter = nil
        end
        cb(result)
    end, data.citizenid)
end)

RegisterNUICallback('spawnCharacter', function(data, cb)
    if not data.citizenid then
        cb({ success = false })
        return
    end
    
    QBCore.Functions.TriggerCallback('grimm-multicharacter:server:loadCharacter', function(result)
        if result.success then
            CloseUI()
            
            DoScreenFadeOut(500)
            Wait(500)
            
            -- Shutdown loading screen
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
            
            -- Handle spawn location
            local spawnCoords = nil
            if data.spawnId and data.spawnId ~= 'last_location' then
                for _, loc in ipairs(Config.SpawnLocations) do
                    if loc.id == data.spawnId and loc.coords then
                        spawnCoords = loc.coords
                        break
                    end
                end
            end
            
            -- Get spawn position
            local spawnX, spawnY, spawnZ, spawnH
            if spawnCoords then
                spawnX, spawnY, spawnZ = spawnCoords.x, spawnCoords.y, spawnCoords.z
                spawnH = spawnCoords.w or 0.0
            else
                spawnX, spawnY, spawnZ = Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z
                spawnH = Config.DefaultSpawn.w or 0.0
            end
            
            if result.isNew then
                -- New character - set model and spawn
                QBCore.Functions.TriggerCallback('grimm-multicharacter:server:getCharacterData', function(charData)
                    local model = `mp_m_freemode_01`
                    if charData and charData.charinfo and charData.charinfo.gender == 1 then
                        model = `mp_f_freemode_01`
                    end
                    
                    RequestModel(model)
                    while not HasModelLoaded(model) do Wait(10) end
                    
                    SetPlayerModel(PlayerId(), model)
                    SetModelAsNoLongerNeeded(model)
                    
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, spawnX, spawnY, spawnZ, false, false, false, false)
                    SetEntityHeading(ped, spawnH)
                    FreezeEntityPosition(ped, false)
                    SetEntityVisible(ped, true, false)
                    
                    -- Set default appearance
                    SetPedDefaultComponentVariation(ped)
                    SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)
                    
                    Wait(500)
                    DoScreenFadeIn(500)
                    
                    -- Open appearance menu for new character
                    Wait(500)
                    TriggerEvent(Config.Events.openAppearance, true)
                end, data.citizenid)
            else
                -- Existing character - load saved skin and spawn
                QBCore.Functions.TriggerCallback('grimm-multicharacter:server:getCharacterData', function(charData)
                    local ped = PlayerPedId()
                    
                    -- Apply skin if exists
                    if charData and charData.skin then
                        local model = charData.skin.model or `mp_m_freemode_01`
                        
                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(10) end
                        
                        SetPlayerModel(PlayerId(), model)
                        SetModelAsNoLongerNeeded(model)
                        
                        ped = PlayerPedId()
                        Wait(200)
                        ApplySkinToPed(ped, charData.skin)
                        Wait(100)
                    end
                    
                    -- Set position
                    SetEntityCoords(ped, spawnX, spawnY, spawnZ, false, false, false, false)
                    SetEntityHeading(ped, spawnH)
                    FreezeEntityPosition(ped, false)
                    SetEntityVisible(ped, true, false)
                    
                    DoScreenFadeIn(500)
                    
                    -- Wait for QBCore to fully load player data before triggering the event
                    CreateThread(function()
                        local timeout = 0
                        while not QBCore.Functions.GetPlayerData().citizenid and timeout < 100 do
                            Wait(100)
                            timeout = timeout + 1
                        end
                        Wait(500)
                        TriggerEvent('QBCore:Client:OnPlayerLoaded')
                    end)
                end, data.citizenid)
            end
        end
        
        cb(result)
    end, data.citizenid, data.spawnId)
end)

RegisterNUICallback('rotateCharacter', function(data, cb)
    if charPed and DoesEntityExist(charPed) then
        local heading = GetEntityHeading(charPed)
        local rotation = data.direction == 'left' and 15.0 or -15.0
        SetEntityHeading(charPed, heading + rotation)
    end
    cb({ success = true })
end)

-- =====================================
-- EVENTS
-- =====================================

RegisterNetEvent('grimm-multicharacter:client:open', function()
    OpenUI()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    -- Player logged out
end)

-- =====================================
-- INITIAL SPAWN HANDLER
-- =====================================

AddEventHandler('playerSpawned', function()
    -- This prevents the default spawn
end)

CreateThread(function()
    -- Wait for player to be ready
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end
    
    -- Shutdown any loading screens
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    
    -- Disable auto-spawn
    exports.spawnmanager:setAutoSpawn(false)
    
    -- Open character selection
    Wait(500)
    OpenUI()
end)

-- =====================================
-- EXPORTS
-- =====================================

exports('OpenCharacterSelection', OpenUI)
exports('CloseCharacterSelection', CloseUI)