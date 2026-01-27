Config = {}

-- ██████╗  ██████╗  ██████╗ ████████╗███████╗
-- ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝
-- ██████╔╝██║   ██║██║   ██║   ██║   ███████╗
-- ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║
-- ██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████║
-- ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
-- Multi-Character Configuration

-----------------
-- GENERAL SETTINGS
-----------------
Config.DefaultSlots = 2                    -- Base character slots for all players
Config.MaxSlots = 5                        -- Maximum possible slots (Wisteria tier = 2 base + 3 bonus)
Config.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 330.0) -- Default spawn for new characters (LSIA)
Config.CamCoords = vector4(-814.47, 176.22, 76.74, 160.0) -- Camera position for character preview

-----------------
-- PATREON/DISCORD INTEGRATION
-- Uses Discord roles to determine bonus slots
-- You'll need to configure your Discord bot to sync roles
-----------------
Config.UseDiscordRoles = true              -- Enable Discord role checking for bonus slots

-- Discord Role IDs and their bonus slots
-- Replace these with your actual Discord role IDs
Config.PatreonTiers = {
    -- +1 Extra Character Slot (3 total)
    { roleId = 'PINE_ROLE_ID', bonusSlots = 1, tierName = 'Pine' },
    { roleId = 'OAK_ROLE_ID', bonusSlots = 1, tierName = 'Oak' },
    
    -- +2 Extra Character Slots (4 total)
    { roleId = 'REDWOOD_ROLE_ID', bonusSlots = 2, tierName = 'Redwood' },
    { roleId = 'STREAMER_ROLE_ID', bonusSlots = 2, tierName = 'Streamer' },
    { roleId = 'CHERRY_BLOSSOM_ROLE_ID', bonusSlots = 2, tierName = 'Cherry Blossom' },
    
    -- +3 Extra Character Slots (5 total)
    { roleId = 'WISTERIA_ROLE_ID', bonusSlots = 3, tierName = 'Wisteria' },
}

-- Staff roles that get max slots
Config.StaffRoles = {
    -- 'ADMIN_ROLE_ID',
    -- 'MOD_ROLE_ID',
}

-----------------
-- SPAWN LOCATIONS
-- Add your custom spawn locations here
-- Format: { label = 'Display Name', coords = vector4(x, y, z, heading) }
-----------------
Config.SpawnLocations = {
    {
        id = 'last_location',
        label = 'Last Location',
        description = 'Return to where you left off',
        icon = 'location-dot',
        coords = nil, -- Will use saved location
        isLastLocation = true
    },
    {
        id = 'spawn_1',
        label = 'Airport',
        description = 'Custom spawn location 1',
        icon = 'house',
        coords = vector3(-1035.71, -2731.87, 12.86) -- Replace with your coordinates
    },
    {
        id = 'spawn_2',
        label = 'Location 2',
        description = 'Custom spawn location 2',
        icon = 'building',
        coords = vector4(0.0, 0.0, 0.0, 0.0) -- Replace with your coordinates
    },
    {
        id = 'spawn_3',
        label = 'Location 3',
        description = 'Custom spawn location 3',
        icon = 'city',
        coords = vector4(0.0, 0.0, 0.0, 0.0) -- Replace with your coordinates
    },
    {
        id = 'spawn_4',
        label = 'Location 4',
        description = 'Custom spawn location 4',
        icon = 'tree',
        coords = vector4(0.0, 0.0, 0.0, 0.0) -- Replace with your coordinates
    },
}

-----------------
-- CHARACTER CREATION SETTINGS
-----------------
Config.Nationalities = {
    -- North America
    'American',
    'Canadian',
    'Mexican',
    'Cuban',
    'Puerto Rican',
    'Dominican',
    'Jamaican',
    
    -- South America
    'Brazilian',
    'Argentinian',
    'Colombian',
    'Chilean',
    'Peruvian',
    'Venezuelan',
    
    -- Europe
    'British',
    'Irish',
    'Scottish',
    'German',
    'French',
    'Italian',
    'Spanish',
    'Portuguese',
    'Dutch',
    'Belgian',
    'Swiss',
    'Austrian',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Polish',
    'Czech',
    'Hungarian',
    'Romanian',
    'Ukrainian',
    'Russian',
    'Serbian',
    'Croatian',
    'Greek',
    
    -- Middle East
    'Turkish',
    'Saudi Arabian',
    'Iranian',
    'Iraqi',
    'Israeli',
    'Lebanese',
    'Emirati',
    'Jordanian',
    
    -- Asia
    'Japanese',
    'Chinese',
    'Korean',
    'Indian',
    'Pakistani',
    'Bangladeshi',
    'Filipino',
    'Vietnamese',
    'Thai',
    'Indonesian',
    'Malaysian',
    'Singaporean',
    'Taiwanese',
    'Mongolian',
    
    -- Africa
    'South African',
    'Nigerian',
    'Egyptian',
    'Kenyan',
    'Ghanaian',
    'Moroccan',
    'Ethiopian',
    'Tanzanian',
    
    -- Oceania
    'Australian',
    'New Zealander',
    'Fijian',
    'Samoan',
    
    -- Other
    'Other'
}

Config.MinAge = 18      -- Minimum age for characters
Config.MaxAge = 80      -- Maximum age for characters
Config.MinNameLength = 2
Config.MaxNameLength = 20

-----------------
-- DEFAULT CHARACTER APPEARANCE
-- Used for new character creation preview
-----------------
Config.DefaultMale = {
    model = `mp_m_freemode_01`,
    headBlend = {
        shapeFirst = 0,
        shapeSecond = 0,
        shapeMix = 0.5,
        skinFirst = 0,
        skinSecond = 0,
        skinMix = 0.5
    }
}

Config.DefaultFemale = {
    model = `mp_f_freemode_01`,
    headBlend = {
        shapeFirst = 0,
        shapeSecond = 0,
        shapeMix = 0.5,
        skinFirst = 0,
        skinSecond = 0,
        skinMix = 0.5
    }
}

-----------------
-- UI SETTINGS
-----------------
Config.EnableBlur = true           -- Enable background blur in menus
Config.EnableMusic = false         -- Enable ambient music (set to false if using loading screen music)
Config.TransitionSpeed = 500       -- UI transition speed in ms

-----------------
-- EVENTS (for integration with other resources)
-----------------
Config.Events = {
    onCharacterSelected = 'grimm-multicharacter:characterSelected',  -- Triggered when character is selected
    onCharacterCreated = 'grimm-multicharacter:characterCreated',    -- Triggered when new character is created
    onCharacterDeleted = 'grimm-multicharacter:characterDeleted',    -- Triggered when character is deleted
    openAppearance = 'grimm-appearance:open',                        -- Event to open appearance menu
}
