Config = {}

-- ██████╗  ██████╗  ██████╗ ████████╗███████╗
-- ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝
-- ██████╔╝██║   ██║██║   ██║   ██║   ███████╗
-- ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║
-- ██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████║
-- ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
-- Appearance Configuration

-----------------
-- GENERAL SETTINGS
-----------------
Config.UseTarget = false                    -- Use qb-target for clothing stores
Config.EnableClothingStores = true          -- Enable clothing store locations
Config.EnableBarberShops = true             -- Enable barber shop locations
Config.EnableTattooShops = true             -- Enable tattoo shop locations

-----------------
-- PRICING
-----------------
Config.Prices = {
    clothing = 100,          -- Price per clothing item
    haircut = 50,            -- Price for haircut
    makeup = 25,             -- Price for makeup
    tattoo = 200,            -- Price per tattoo
    surgery = 5000,          -- Price for face surgery (changing facial features)
}

-----------------
-- CAMERA SETTINGS
-----------------
Config.CameraOffsets = {
    face = { y = 1.0, z = 0.65, lookZ = 0.65 },     -- Close up on face
    body = { y = 2.2, z = 0.2, lookZ = 0.0 },       -- Full body view  
    legs = { y = 1.8, z = -0.3, lookZ = -0.4 },     -- Lower body
    feet = { y = 1.2, z = -0.6, lookZ = -0.8 },     -- Feet view
}

-----------------
-- OUTFITS
-----------------
Config.MaxOutfits = 15                      -- Maximum saved outfits per character
Config.AllowOutfitSharing = false           -- Allow sharing outfits with other players

-----------------
-- CATEGORIES
-----------------
Config.Categories = {
    -- Outfits (for outfit management)
    outfits = {
    enabled = true,
    label = 'Outfits',
    icon = 'bookmark'
},
    -- Inheritance / Parents
    inheritance = {
        enabled = true,
        label = 'Heritage',
        icon = 'dna'
    },
    -- Face Features
    face = {
        enabled = true,
        label = 'Face Features',
        icon = 'face-smile'
    },
    -- Skin / Appearance
    skin = {
        enabled = true,
        label = 'Skin & Aging',
        icon = 'droplet'
    },
    -- Hair
    hair = {
        enabled = true,
        label = 'Hair',
        icon = 'scissors'
    },
    -- Facial Hair (Beard)
    beard = {
        enabled = true,
        label = 'Facial Hair',
        icon = 'face-smile-wink'
    },
    -- Eyebrows
    eyebrows = {
        enabled = true,
        label = 'Eyebrows',
        icon = 'eye'
    },
    -- Makeup
    makeup = {
        enabled = true,
        label = 'Makeup',
        icon = 'palette'
    },
    -- Clothing - Upper Body
    tops = {
        enabled = true,
        label = 'Tops',
        icon = 'shirt'
    },
    arms = {
    enabled = true,
    label = 'Arms',
    icon = 'hand'
    },
    -- Clothing - Lower Body
    pants = {
        enabled = true,
        label = 'Pants',
        icon = 'socks'
    },
    -- Shoes
    shoes = {
        enabled = true,
        label = 'Shoes',
        icon = 'shoe-prints'
    },
    -- Accessories
    accessories = {
        enabled = true,
        label = 'Accessories',
        icon = 'glasses'
    },
    -- Undershirt
    undershirt = {
        enabled = true,
        label = 'Undershirt',
        icon = 'vest'
    },
    -- Body Armor / Vest
    armor = {
        enabled = true,
        label = 'Body Armor',
        icon = 'shield'
    },
    -- Bags / Backpacks
    bags = {
        enabled = true,
        label = 'Bags',
        icon = 'bag-shopping'
    },
    -- Hats / Headwear
    hats = {
        enabled = true,
        label = 'Hats',
        icon = 'hat-cowboy'
    },
    -- Glasses / Eyewear
    glasses = {
        enabled = true,
        label = 'Glasses',
        icon = 'glasses'
    },
    -- Earrings / Ear Accessories
    ears = {
        enabled = true,
        label = 'Earrings',
        icon = 'circle-dot'
    },
    -- Watches
    watches = {
        enabled = true,
        label = 'Watches',
        icon = 'clock'
    },
    -- Bracelets
    bracelets = {
        enabled = true,
        label = 'Bracelets',
        icon = 'circle'
    },
    -- Masks
    masks = {
        enabled = true,
        label = 'Masks',
        icon = 'mask'
    },
    -- Tattoos
    tattoos = {
        enabled = true,
        label = 'Tattoos',
        icon = 'pen-nib'
    }
}

-----------------
-- STORE LOCATIONS
-----------------
Config.ClothingStores = {
    { coords = vector3(72.25, -1399.1, 29.38), heading = 270.0, label = "Suburban" },
    { coords = vector3(-703.78, -152.26, 37.42), heading = 120.0, label = "Ponsonbys" },
    { coords = vector3(-167.87, -299.0, 39.73), heading = 250.0, label = "Suburban" },
    { coords = vector3(428.69, -800.41, 29.49), heading = 180.0, label = "Suburban" },
    { coords = vector3(-829.41, -1073.71, 11.33), heading = 300.0, label = "Ponsonbys" },
    { coords = vector3(-1447.8, -242.46, 49.82), heading = 35.0, label = "Suburban" },
    { coords = vector3(11.63, 6514.23, 31.88), heading = 136.0, label = "Suburban" },
    { coords = vector3(123.65, -219.44, 54.56), heading = 70.0, label = "Ponsonbys" },
    { coords = vector3(1696.29, 4829.31, 42.06), heading = 190.0, label = "Suburban" },
    { coords = vector3(618.09, 2759.63, 42.09), heading = 190.0, label = "Suburban" },
    { coords = vector3(1190.55, 2713.44, 38.22), heading = 270.0, label = "Suburban" },
    { coords = vector3(-1193.43, -772.26, 17.32), heading = 215.0, label = "Ponsonbys" },
    { coords = vector3(-3172.49, 1048.13, 20.86), heading = 340.0, label = "Suburban" },
}

Config.BarberShops = {
    { coords = vector3(-814.31, -183.82, 37.57), heading = 110.0, label = "Barber" },
    { coords = vector3(136.87, -1708.36, 29.29), heading = 140.0, label = "Barber" },
    { coords = vector3(-1282.6, -1116.75, 6.99), heading = 70.0, label = "Barber" },
    { coords = vector3(1931.51, 3729.74, 32.84), heading = 210.0, label = "Barber" },
    { coords = vector3(1212.84, -472.92, 66.21), heading = 70.0, label = "Barber" },
    { coords = vector3(-32.9, -152.3, 57.08), heading = 340.0, label = "Barber" },
    { coords = vector3(-278.08, 6228.51, 31.7), heading = 45.0, label = "Barber" },
}

Config.TattooShops = {
    { coords = vector3(1322.64, -1651.97, 52.28), heading = 35.0, label = "Tattoo" },
    { coords = vector3(-1153.67, -1425.68, 4.95), heading = 35.0, label = "Tattoo" },
    { coords = vector3(322.14, 180.36, 103.59), heading = 250.0, label = "Tattoo" },
    { coords = vector3(-3169.92, 1075.43, 20.83), heading = 340.0, label = "Tattoo" },
    { coords = vector3(1864.93, 3747.91, 33.03), heading = 20.0, label = "Tattoo" },
    { coords = vector3(-293.62, 6200.12, 31.49), heading = 225.0, label = "Tattoo" },
}

-----------------
-- BLIP SETTINGS
-----------------
Config.Blips = {
    clothing = {
        enabled = true,
        sprite = 73,
        color = 47,
        scale = 0.7,
        label = "Clothing Store"
    },
    barber = {
        enabled = true,
        sprite = 71,
        color = 0,
        scale = 0.7,
        label = "Barber Shop"
    },
    tattoo = {
        enabled = true,
        sprite = 75,
        color = 1,
        scale = 0.7,
        label = "Tattoo Parlor"
    }
}

-----------------
-- KEYBINDS
-----------------
Config.OpenKey = 'F1'                       -- Key to open appearance menu (when at valid location)
Config.RotateLeftKey = 'LEFT'               -- Key to rotate character left
Config.RotateRightKey = 'RIGHT'             -- Key to rotate character right

-----------------
-- EVENTS
-----------------
Config.Events = {
    onSave = 'grimm-appearance:saved',
    onCancel = 'grimm-appearance:cancelled',
}
