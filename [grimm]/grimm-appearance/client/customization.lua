-- =====================================
-- CUSTOMIZATION HELPER FUNCTIONS
-- =====================================

-- Get number of hair styles
function GetHairStyleCount(ped)
    return GetNumberOfPedDrawableVariations(ped, 2)
end

-- Get number of hair textures for a style
function GetHairTextureCount(ped, styleId)
    return GetNumberOfPedTextureVariations(ped, 2, styleId)
end

-- Get head overlay count
function GetHeadOverlayCount(overlayId)
    return GetNumHeadOverlayValues(overlayId)
end

-- Get hair color count
function GetHairColorCount()
    return GetNumHairColors()
end

-- Get makeup color count
function GetMakeupColorCount()
    return GetNumMakeupColors()
end

-- Native functions for hair color (not available in all versions)
function GetPedHairColor(ped)
    -- This native might not exist, return default
    return 0
end

function GetPedHairHighlightColor(ped)
    -- This native might not exist, return default
    return 0
end

-- Check if ped has head blend data set
function HasPedHeadBlendFinished(ped)
    return HasPedHeadBlendFinished(ped)
end

-- Get face feature value (native exists)
-- GetPedFaceFeature is available

-- Set face feature value
-- SetPedFaceFeature is available

-- Get head overlay value (need to track manually or use natives)
function GetCurrentHeadOverlay(ped, overlayId)
    -- Need to track this ourselves as there's no reliable getter
    return { style = 0, opacity = 1.0, color = 0, secondColor = 0 }
end

-- Apply full ped appearance from saved data
function ApplyFullAppearance(ped, data)
    if not data then return end
    
    -- Set model if different
    if data.model then
        local model = type(data.model) == 'string' and GetHashKey(data.model) or data.model
        if GetEntityModel(ped) ~= model then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
            ped = PlayerPedId()
        end
    end
    
    -- Set head blend (parents)
    if data.headBlend then
        SetPedHeadBlendData(ped,
            data.headBlend.shapeFirst or 0,
            data.headBlend.shapeSecond or 0,
            0,
            data.headBlend.skinFirst or 0,
            data.headBlend.skinSecond or 0,
            0,
            data.headBlend.shapeMix or 0.5,
            data.headBlend.skinMix or 0.5,
            0.0,
            false
        )
    end
    
    -- Set face features
    if data.faceFeatures then
        for i = 0, 19 do
            local value = data.faceFeatures[tostring(i)] or data.faceFeatures[i] or 0.0
            SetPedFaceFeature(ped, i, value + 0.0)
        end
    end
    
    -- Set head overlays
    if data.headOverlays then
        for i = 0, 12 do
            local overlay = data.headOverlays[tostring(i)] or data.headOverlays[i]
            if overlay then
                SetPedHeadOverlay(ped, i, overlay.style or 255, overlay.opacity or 1.0)
                if overlay.color ~= nil then
                    local colorType = overlay.colorType or 1
                    if i == 1 or i == 2 or i == 10 then -- Beard, eyebrows, chest hair
                        colorType = 1
                    elseif i == 4 or i == 5 or i == 8 then -- Makeup, blush, lipstick
                        colorType = 2
                    end
                    SetPedHeadOverlayColor(ped, i, colorType, overlay.color or 0, overlay.secondColor or 0)
                end
            else
                SetPedHeadOverlay(ped, i, 255, 1.0) -- None
            end
        end
    end
    
    -- Set hair
    if data.hair then
        SetPedComponentVariation(ped, 2, data.hair.style or 0, data.hair.texture or 0, 0)
        SetPedHairColor(ped, data.hair.color or 0, data.hair.highlight or 0)
    end
    
    -- Set eye color
    if data.eyeColor ~= nil then
        SetPedEyeColor(ped, data.eyeColor)
    end
    
    -- Set components (clothing)
    if data.components then
        for i = 0, 11 do
            local comp = data.components[tostring(i)] or data.components[i]
            if comp then
                SetPedComponentVariation(ped, i, comp.drawable or 0, comp.texture or 0, comp.palette or 0)
            end
        end
    end
    
    -- Set props
    if data.props then
        local propIds = { 0, 1, 2, 6, 7 }
        for _, propId in pairs(propIds) do
            local prop = data.props[tostring(propId)] or data.props[propId]
            if prop then
                if prop.drawable == -1 then
                    ClearPedProp(ped, propId)
                else
                    SetPedPropIndex(ped, propId, prop.drawable or 0, prop.texture or 0, true)
                end
            else
                ClearPedProp(ped, propId)
            end
        end
    end
    
    -- Set tattoos
    if data.tattoos then
        ClearPedDecorations(ped)
        for _, tattoo in pairs(data.tattoos) do
            if tattoo.collection and tattoo.overlay then
                AddPedDecorationFromHashes(ped, GetHashKey(tattoo.collection), GetHashKey(tattoo.overlay))
            end
        end
    end
end

-- Get current component data
function GetPedComponents(ped)
    local components = {}
    for i = 0, 11 do
        components[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
            palette = GetPedPaletteVariation(ped, i)
        }
    end
    return components
end

-- Get current prop data
function GetPedProps(ped)
    local props = {}
    local propIds = { 0, 1, 2, 6, 7 }
    for _, propId in pairs(propIds) do
        props[propId] = {
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId)
        }
    end
    return props
end

-- Refresh ped
function RefreshPedAppearance(ped)
    -- Force refresh by resetting something innocuous
    local currentModel = GetEntityModel(ped)
    if currentModel then
        -- Ped should automatically refresh when values change
    end
end
