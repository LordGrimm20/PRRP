--[[
    GRIMM-APPEARANCE | Client
    Lua 5.4 | QBCore Framework
]]

local QBCore = exports['qb-core']:GetCoreObject()
local isOpen = false
local isFirstTime = false
local currentCamera = nil
local originalAppearance = nil
local currentAppearance = nil

-- Debug function
local function Debug(msg)
    print('[grimm-appearance] ' .. tostring(msg))
end

-- =====================================
-- EVENTS
-- =====================================

RegisterNetEvent('grimm-appearance:open', function(firstTime)
    Debug('Event grimm-appearance:open received, firstTime=' .. tostring(firstTime))
    if isOpen then return end
    OpenAppearanceMenu(firstTime or false, 'full')
end)

RegisterNetEvent('grimm-appearance:client:openClothing', function()
    Debug('Event openClothing received')
    OpenAppearanceMenu(false, 'clothing')
end)

RegisterNetEvent('grimm-appearance:client:openBarber', function()
    Debug('Event openBarber received')
    OpenAppearanceMenu(false, 'barber')
end)

-- =====================================
-- MAIN FUNCTIONS
-- =====================================

function OpenAppearanceMenu(firstTime, menuType)
    Debug('OpenAppearanceMenu called')
    isOpen = true
    isFirstTime = firstTime or false
    
    local ped = PlayerPedId()
    originalAppearance = GetCurrentAppearance(ped)
    currentAppearance = DeepCopy(originalAppearance)
    
    SetupCamera('body')
    FreezeEntityPosition(ped, true)
    
    local data = GetAppearanceData(ped)
    Debug('Sending NUI show message')
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        menuType = menuType or 'full',
        isFirstTime = isFirstTime,
        appearance = currentAppearance,
        data = data,
        categories = Config.Categories
    })
end

function CloseAppearanceMenu(save)
    Debug('CloseAppearanceMenu called, save=' .. tostring(save))
    if not isOpen then return end
    isOpen = false
    
    local ped = PlayerPedId()
    
    if save then
        TriggerServerEvent('grimm-appearance:server:saveAppearance', currentAppearance)
        QBCore.Functions.Notify('Appearance saved!', 'success')
    else
        ApplyAppearance(ped, originalAppearance)
        QBCore.Functions.Notify('Changes cancelled', 'error')
    end
    
    DestroyCamera()
    FreezeEntityPosition(ped, false)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    
    originalAppearance = nil
    currentAppearance = nil
end

-- =====================================
-- APPEARANCE DATA
-- =====================================

function GetAppearanceData(ped)
    local model = GetEntityModel(ped)
    local isMale = model == `mp_m_freemode_01`
    local gender = isMale and 'male' or 'female'
    
    Debug('GetAppearanceData - gender=' .. gender)
    
    return {
        gender = gender,
        parents = isMale and AppearanceData.Parents.male or AppearanceData.Parents.female,
        parentsOpposite = isMale and AppearanceData.Parents.female or AppearanceData.Parents.male,
        faceFeatures = AppearanceData.FaceFeatures,
        headOverlays = AppearanceData.HeadOverlays,
        hairColors = AppearanceData.HairColors,
        eyeColors = AppearanceData.EyeColors,
        maxDrawables = GetMaxDrawables(ped),
        maxProps = GetMaxProps(ped)
    }
end

function GetMaxDrawables(ped)
    local maxDrawables = {}
    for i = 0, 11 do
        local maxD = GetNumberOfPedDrawableVariations(ped, i) - 1
        maxDrawables[i] = { drawable = maxD, texture = {} }
        for j = 0, math.min(maxD, 50) do
            maxDrawables[i].texture[j] = GetNumberOfPedTextureVariations(ped, i, j) - 1
        end
    end
    return maxDrawables
end

function GetMaxProps(ped)
    local maxProps = {}
    for _, propId in ipairs({0, 1, 2, 6, 7}) do
        local maxD = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
        maxProps[propId] = { drawable = maxD, texture = {} }
        for j = 0, math.min(maxD, 25) do
            maxProps[propId].texture[j] = GetNumberOfPedPropTextureVariations(ped, propId, j) - 1
        end
    end
    return maxProps
end

-- =====================================
-- CAMERA FUNCTIONS
-- =====================================

function SetupCamera(zone)
    Debug('SetupCamera zone=' .. tostring(zone))
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local offset = Config.CameraOffsets[zone] or Config.CameraOffsets.body
    
    local angle = math.rad(heading)
    local camX = coords.x + (offset.y * math.sin(angle))
    local camY = coords.y + (offset.y * math.cos(angle))
    local camZ = coords.z + offset.z
    local lookZ = offset.lookZ or 0.0
    
    if currentCamera then
        SetCamCoord(currentCamera, camX, camY, camZ)
        PointCamAtCoord(currentCamera, coords.x, coords.y, coords.z + lookZ)
    else
        currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(currentCamera, camX, camY, camZ)
        PointCamAtCoord(currentCamera, coords.x, coords.y, coords.z + lookZ)
        SetCamFov(currentCamera, 45.0)
        SetCamActive(currentCamera, true)
        RenderScriptCams(true, true, 500, true, false)
    end
end

function DestroyCamera()
    if currentCamera then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(currentCamera, false)
        currentCamera = nil
    end
end

-- =====================================
-- HAIR COLOR HELPER
-- This function properly applies hair and color together
-- =====================================
local function ApplyHairWithColor(ped)
    if currentAppearance and currentAppearance.hair then
        local style = tonumber(currentAppearance.hair.style) or 0
        local texture = tonumber(currentAppearance.hair.texture) or 0
        local color = tonumber(currentAppearance.hair.color) or 0
        local highlight = tonumber(currentAppearance.hair.highlight) or 0
        
        -- Use palette 2 like working scripts do
        SetPedComponentVariation(ped, 2, style, texture, 2)
        SetPedHairColor(ped, color, highlight)
    end
end

-- =====================================
-- NUI CALLBACKS
-- =====================================

RegisterNUICallback('close', function(data, cb)
    Debug('NUI close callback received')
    CloseAppearanceMenu(data.save or false)
    cb({ success = true })
end)

RegisterNUICallback('updateAppearance', function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    
    Debug('NUI updateAppearance: category=' .. tostring(cat) .. ', id=' .. tostring(data.id))
    
    if cat == 'headBlend' then
        local val = data.value
        local shapeFirst = tonumber(val.shapeFirst) or 0
        local shapeSecond = tonumber(val.shapeSecond) or 0
        local skinFirst = tonumber(val.skinFirst) or 0
        local skinSecond = tonumber(val.skinSecond) or 0
        local shapeMix = tonumber(val.shapeMix) or 0.5
        local skinMix = tonumber(val.skinMix) or 0.5
        
        Debug('headBlend: ' .. shapeFirst .. ',' .. shapeSecond .. ' mix=' .. shapeMix)
        
        currentAppearance.headBlend = val
        SetPedHeadBlendData(ped, shapeFirst, shapeSecond, 0, skinFirst, skinSecond, 0, shapeMix, skinMix, 0.0, false)
        
    elseif cat == 'faceFeature' then
        local id = tonumber(data.id) or 0
        local value = tonumber(data.value) or 0.0
        
        Debug('faceFeature: id=' .. id .. ' value=' .. value)
        
        currentAppearance.faceFeatures = currentAppearance.faceFeatures or {}
        currentAppearance.faceFeatures[id] = value
        SetPedFaceFeature(ped, id, value + 0.0)
        
    elseif cat == 'headOverlay' then
        local id = tonumber(data.id) or 0
        local val = data.value
        local style = tonumber(val.style) or 0
        local opacity = tonumber(val.opacity) or 1.0
        local color = tonumber(val.color) or 0
        
        Debug('headOverlay: id=' .. id .. ' style=' .. style .. ' opacity=' .. opacity)
        
        currentAppearance.headOverlays = currentAppearance.headOverlays or {}
        currentAppearance.headOverlays[id] = val
        
        SetPedHeadOverlay(ped, id, style, opacity + 0.0)
        
        -- Use correct color type based on overlay ID
        local colorType = 1
        if id == 4 or id == 5 or id == 8 then -- Makeup, blush, lipstick
            colorType = 2
        end
        SetPedHeadOverlayColor(ped, id, colorType, color, 0)
        
    elseif cat == 'hair' then
        local val = data.value
        local style = tonumber(val.style) or 0
        local texture = tonumber(val.texture) or 0
        local color = tonumber(val.color) or 0
        local highlight = tonumber(val.highlight) or 0
        
        Debug('hair: style=' .. style .. ' color=' .. color .. ' highlight=' .. highlight)
        
        currentAppearance.hair = val
        
        -- IMPORTANT: Use palette 2 and apply hair color immediately after
        SetPedComponentVariation(ped, 2, style, texture, 2)
        SetPedHairColor(ped, color, highlight)
        
    elseif cat == 'eyeColor' then
        local color = tonumber(data.value) or 0
        
        Debug('eyeColor: ' .. color)
        
        currentAppearance.eyeColor = color
        SetPedEyeColor(ped, color)
        
    elseif cat == 'component' then
        local id = tonumber(data.id) or 0
        local val = data.value
        local drawable = tonumber(val.drawable) or 0
        local texture = tonumber(val.texture) or 0
        local palette = tonumber(val.palette) or 2
        
        Debug('component: id=' .. id .. ' drawable=' .. drawable .. ' texture=' .. texture)
        
        currentAppearance.components = currentAppearance.components or {}
        currentAppearance.components[id] = val
        
        -- Apply the component with palette 2
        SetPedComponentVariation(ped, id, drawable, texture, palette)
        
        -- CRITICAL FIX: Re-apply hair with color after ANY component change
        -- This prevents the GTA V bug where changing clothes resets hair color
        ApplyHairWithColor(ped)
        
    elseif cat == 'prop' then
        local id = tonumber(data.id) or 0
        local val = data.value
        local drawable = tonumber(val.drawable)
        local texture = tonumber(val.texture) or 0
        
        Debug('prop: id=' .. id .. ' drawable=' .. tostring(drawable))
        
        currentAppearance.props = currentAppearance.props or {}
        currentAppearance.props[id] = val
        
        if drawable == nil or drawable == -1 then
            ClearPedProp(ped, id)
        else
            SetPedPropIndex(ped, id, drawable, texture, true)
        end
        
        -- Re-apply hair color after prop change too
        ApplyHairWithColor(ped)
    else
        Debug('Unknown category: ' .. tostring(cat))
    end
    
    cb({ success = true })
end)

RegisterNUICallback('setCamera', function(data, cb)
    Debug('NUI setCamera: zone=' .. tostring(data.zone))
    SetupCamera(data.zone or 'body')
    cb({ success = true })
end)

RegisterNUICallback('rotateCharacter', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    local rotation = data.direction == 'left' and 15.0 or -15.0
    SetEntityHeading(ped, heading + rotation)
    cb({ success = true })
end)

-- =====================================
-- OUTFIT CALLBACKS
-- =====================================

RegisterNUICallback('getOutfits', function(_, cb)
    QBCore.Functions.TriggerCallback('grimm-appearance:server:getOutfits', function(outfits)
        cb({ success = true, outfits = outfits or {} })
    end)
end)

RegisterNUICallback('saveOutfit', function(data, cb)
    if not data.name or data.name == '' then
        cb({ success = false, message = 'Please enter an outfit name' })
        return
    end
    
    -- Save only clothing-related data for outfits
    local outfitData = {
        components = currentAppearance.components,
        props = currentAppearance.props,
        hair = currentAppearance.hair
    }
    
    TriggerServerEvent('grimm-appearance:server:saveOutfit', data.name, outfitData)
    QBCore.Functions.Notify('Outfit saved: ' .. data.name, 'success')
    cb({ success = true })
end)

RegisterNUICallback('loadOutfit', function(data, cb)
    if not data.id then
        cb({ success = false })
        return
    end
    
    QBCore.Functions.TriggerCallback('grimm-appearance:server:getOutfit', function(outfit)
        if outfit then
            local ped = PlayerPedId()
            
            -- Apply outfit components
            if outfit.components then
                for id, comp in pairs(outfit.components) do
                    local idx = tonumber(id)
                    if idx ~= 2 then -- Skip hair component, handle separately
                        SetPedComponentVariation(ped, idx, tonumber(comp.drawable) or 0, tonumber(comp.texture) or 0, 2)
                    end
                end
                currentAppearance.components = outfit.components
            end
            
            -- Apply outfit props
            if outfit.props then
                for id, prop in pairs(outfit.props) do
                    local propId = tonumber(id)
                    local drawable = tonumber(prop.drawable)
                    if drawable == nil or drawable == -1 then
                        ClearPedProp(ped, propId)
                    else
                        SetPedPropIndex(ped, propId, drawable, tonumber(prop.texture) or 0, true)
                    end
                end
                currentAppearance.props = outfit.props
            end
            
            -- Apply hair from outfit
            if outfit.hair then
                currentAppearance.hair = outfit.hair
            end
            
            -- Apply hair with color last (critical for hair color to stick)
            ApplyHairWithColor(ped)
            
            QBCore.Functions.Notify('Outfit loaded!', 'success')
        else
            QBCore.Functions.Notify('Failed to load outfit', 'error')
        end
        cb({ success = outfit ~= nil })
    end, data.id)
end)

RegisterNUICallback('deleteOutfit', function(data, cb)
    if not data.id then
        cb({ success = false })
        return
    end
    
    TriggerServerEvent('grimm-appearance:server:deleteOutfit', data.id)
    QBCore.Functions.Notify('Outfit deleted', 'success')
    cb({ success = true })
end)

-- =====================================
-- APPEARANCE FUNCTIONS
-- =====================================

function GetCurrentAppearance(ped)
    local appearance = {
        model = GetEntityModel(ped),
        headBlend = { shapeFirst = 0, shapeSecond = 0, skinFirst = 0, skinSecond = 0, shapeMix = 0.5, skinMix = 0.5 },
        faceFeatures = {},
        headOverlays = {},
        hair = {},
        eyeColor = GetPedEyeColor(ped),
        components = {},
        props = {}
    }
    
    for i = 0, 19 do
        appearance.faceFeatures[i] = GetPedFaceFeature(ped, i)
    end
    
    for i = 0, 11 do
        appearance.components[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
            palette = GetPedPaletteVariation(ped, i)
        }
    end
    
    for _, propId in ipairs({0, 1, 2, 6, 7}) do
        appearance.props[propId] = {
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId)
        }
    end
    
    appearance.hair = {
        style = GetPedDrawableVariation(ped, 2),
        texture = GetPedTextureVariation(ped, 2),
        color = 0,
        highlight = 0
    }
    
    return appearance
end

function ApplyAppearance(ped, appearance)
    if not appearance then return end
    
    Debug('ApplyAppearance called')
    
    -- 1. Head blend first
    if appearance.headBlend then
        local hb = appearance.headBlend
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
    end
    
    -- 2. Face features
    if appearance.faceFeatures then
        for id, value in pairs(appearance.faceFeatures) do
            SetPedFaceFeature(ped, tonumber(id), tonumber(value) + 0.0)
        end
    end
    
    -- 3. Head overlays
    if appearance.headOverlays then
        for id, overlay in pairs(appearance.headOverlays) do
            local idx = tonumber(id)
            SetPedHeadOverlay(ped, idx, tonumber(overlay.style) or 0, tonumber(overlay.opacity) or 1.0)
            local colorType = 1
            if idx == 4 or idx == 5 or idx == 8 then
                colorType = 2
            end
            SetPedHeadOverlayColor(ped, idx, colorType, tonumber(overlay.color) or 0, 0)
        end
    end
    
    -- 4. Eye color
    if appearance.eyeColor then
        SetPedEyeColor(ped, tonumber(appearance.eyeColor))
    end
    
    -- 5. Components (clothing) - SKIP hair (component 2), apply it last
    if appearance.components then
        for id, comp in pairs(appearance.components) do
            local idx = tonumber(id)
            if idx ~= 2 then -- Skip hair, we'll apply it with color at the end
                SetPedComponentVariation(ped, idx, tonumber(comp.drawable) or 0, tonumber(comp.texture) or 0, 2)
            end
        end
    end
    
    -- 6. Props
    if appearance.props then
        for id, prop in pairs(appearance.props) do
            local propId = tonumber(id)
            local drawable = tonumber(prop.drawable)
            if drawable == nil or drawable == -1 then
                ClearPedProp(ped, propId)
            else
                SetPedPropIndex(ped, propId, drawable, tonumber(prop.texture) or 0, true)
            end
        end
    end
    
    -- 7. LAST: Apply hair style AND color together
    -- This must be done LAST to prevent other components from resetting it
    if appearance.hair then
        local style = tonumber(appearance.hair.style) or 0
        local texture = tonumber(appearance.hair.texture) or 0
        local color = tonumber(appearance.hair.color) or 0
        local highlight = tonumber(appearance.hair.highlight) or 0
        
        SetPedComponentVariation(ped, 2, style, texture, 2)
        SetPedHairColor(ped, color, highlight)
    end
end

function DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in next, orig, nil do
            copy[DeepCopy(k)] = DeepCopy(v)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- =====================================
-- STORE LOCATIONS
-- =====================================

CreateThread(function()
    Wait(1000)
    Debug('Creating blips...')
    
    if Config.Blips and Config.Blips.clothing and Config.Blips.clothing.enabled and Config.ClothingStores then
        for _, store in pairs(Config.ClothingStores) do
            local blip = AddBlipForCoord(store.coords.x, store.coords.y, store.coords.z)
            SetBlipSprite(blip, Config.Blips.clothing.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blips.clothing.scale)
            SetBlipColour(blip, Config.Blips.clothing.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Blips.clothing.label)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    if Config.Blips and Config.Blips.barber and Config.Blips.barber.enabled and Config.BarberShops then
        for _, shop in pairs(Config.BarberShops) do
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, Config.Blips.barber.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blips.barber.scale)
            SetBlipColour(blip, Config.Blips.barber.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Blips.barber.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        if Config.EnableClothingStores and Config.ClothingStores then
            for _, store in pairs(Config.ClothingStores) do
                local dist = #(coords - store.coords)
                if dist < 2.0 then
                    sleep = 0
                    DrawText3D(store.coords.x, store.coords.y, store.coords.z + 1.0, '[E] Clothing Store')
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('grimm-appearance:client:openClothing')
                    end
                end
            end
        end
        
        if Config.EnableBarberShops and Config.BarberShops then
            for _, shop in pairs(Config.BarberShops) do
                local dist = #(coords - shop.coords)
                if dist < 2.0 then
                    sleep = 0
                    DrawText3D(shop.coords.x, shop.coords.y, shop.coords.z + 1.0, '[E] Barber Shop')
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('grimm-appearance:client:openBarber')
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 100)
    ClearDrawOrigin()
end

-- =====================================
-- EXPORTS
-- =====================================

exports('OpenAppearanceMenu', OpenAppearanceMenu)
exports('ApplyAppearance', ApplyAppearance)
exports('GetCurrentAppearance', function(ped) return GetCurrentAppearance(ped or PlayerPedId()) end)

Debug('grimm-appearance client loaded')
