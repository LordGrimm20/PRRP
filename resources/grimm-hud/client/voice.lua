--[[
    GRIMM-HUD | Voice Module
    pma-voice integration for voice/mic indicator
]]

-- State
local isTalking = false
local currentVoiceRange = 2 -- Index in Config.Voice.ranges
local voiceRanges = Config.Voice.ranges

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           PMA-VOICE INTEGRATION                         │
-- └─────────────────────────────────────────────────────────────────────────┘

---Get current voice mode label
---@return string
local function GetVoiceModeLabel()
    if voiceRanges[currentVoiceRange] then
        return voiceRanges[currentVoiceRange].label
    end
    return 'Normal'
end

---Get current voice mode icon
---@return string
local function GetVoiceModeIcon()
    if voiceRanges[currentVoiceRange] then
        return voiceRanges[currentVoiceRange].icon
    end
    return 'volume-low'
end

---Get current voice range value
---@return number
local function GetVoiceRangeValue()
    if voiceRanges[currentVoiceRange] then
        return voiceRanges[currentVoiceRange].range
    end
    return 4.0
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           UPDATE VOICE STATE                            │
-- └─────────────────────────────────────────────────────────────────────────┘

---Send voice update to NUI
local function UpdateVoiceUI()
    if not Config.Voice.enabled then return end
    
    local mode = GetVoiceModeLabel()
    local color = Config.Colors.voice.normal
    
    if mode == 'Whisper' then
        color = Config.Colors.voice.whispering
    elseif mode == 'Shout' then
        color = Config.Colors.voice.shouting
    end
    
    if not isTalking then
        color = Config.Colors.voice.inactive
    end
    
    SendNUIMessage({
        action = 'updateVoice',
        data = {
            talking = isTalking,
            mode = mode,
            icon = GetVoiceModeIcon(),
            range = GetVoiceRangeValue(),
            rangeIndex = currentVoiceRange,
            maxRanges = #voiceRanges,
            color = color,
        }
    })
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           PMA-VOICE EVENTS                              │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Listen for voice range changes (pma-voice)
AddStateBagChangeHandler('proximity', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    if value then
        -- Find matching range index
        for i, range in ipairs(voiceRanges) do
            if range.range == value then
                currentVoiceRange = i
                break
            end
        end
        UpdateVoiceUI()
    end
end)

-- Talking state listener
CreateThread(function()
    if not Config.Voice.enabled then return end
    
    while true do
        Wait(100)
        
        -- Check if player is talking (pma-voice uses NetworkIsPlayerTalking)
        local talking = NetworkIsPlayerTalking(PlayerId())
        
        if talking ~= isTalking then
            isTalking = talking
            UpdateVoiceUI()
        end
    end
end)

-- Alternative: Listen for pma-voice events directly
RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
    currentVoiceRange = mode
    UpdateVoiceUI()
end)

-- Some pma-voice versions use this event
RegisterNetEvent('pma-voice:radioActive', function(isActive)
    SendNUIMessage({
        action = 'updateRadio',
        data = {
            active = isActive,
        }
    })
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           KEYBIND FOR VOICE RANGE                       │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Note: pma-voice usually handles its own keybinds
-- This is just for display purposes

-- Initial update
CreateThread(function()
    Wait(2000) -- Wait for pma-voice to initialize
    
    if Config.Voice.enabled then
        -- Try to get initial voice range from pma-voice
        local success, result = pcall(function()
            return exports['pma-voice']:getVoiceRange()
        end)
        
        if success and result then
            for i, range in ipairs(voiceRanges) do
                if range.range == result then
                    currentVoiceRange = i
                    break
                end
            end
        end
        
        UpdateVoiceUI()
    end
end)

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                           EXPORTS                                       │
-- └─────────────────────────────────────────────────────────────────────────┘

exports('IsTalking', function() return isTalking end)
exports('GetVoiceRange', function() return GetVoiceRangeValue() end)
exports('GetVoiceMode', function() return GetVoiceModeLabel() end)
