-- =====================================
-- APPEARANCE DATA TABLES
-- =====================================

AppearanceData = {}

-- Parent / Heritage Data
AppearanceData.Parents = {
    male = {
        { id = 0, name = "Benjamin" },
        { id = 1, name = "Daniel" },
        { id = 2, name = "Joshua" },
        { id = 3, name = "Noah" },
        { id = 4, name = "Andrew" },
        { id = 5, name = "Juan" },
        { id = 6, name = "Alex" },
        { id = 7, name = "Isaac" },
        { id = 8, name = "Evan" },
        { id = 9, name = "Ethan" },
        { id = 10, name = "Vincent" },
        { id = 11, name = "Angel" },
        { id = 12, name = "Diego" },
        { id = 13, name = "Adrian" },
        { id = 14, name = "Gabriel" },
        { id = 15, name = "Michael" },
        { id = 16, name = "Santiago" },
        { id = 17, name = "Kevin" },
        { id = 18, name = "Louis" },
        { id = 19, name = "Samuel" },
        { id = 20, name = "Anthony" },
        { id = 42, name = "Claude" },
        { id = 43, name = "Niko" },
        { id = 44, name = "John" }
    },
    female = {
        { id = 21, name = "Hannah" },
        { id = 22, name = "Audrey" },
        { id = 23, name = "Jasmine" },
        { id = 24, name = "Giselle" },
        { id = 25, name = "Amelia" },
        { id = 26, name = "Isabella" },
        { id = 27, name = "Zoe" },
        { id = 28, name = "Ava" },
        { id = 29, name = "Camila" },
        { id = 30, name = "Violet" },
        { id = 31, name = "Sophia" },
        { id = 32, name = "Evelyn" },
        { id = 33, name = "Nicole" },
        { id = 34, name = "Ashley" },
        { id = 35, name = "Grace" },
        { id = 36, name = "Brianna" },
        { id = 37, name = "Natalie" },
        { id = 38, name = "Olivia" },
        { id = 39, name = "Elizabeth" },
        { id = 40, name = "Charlotte" },
        { id = 41, name = "Emma" },
        { id = 45, name = "Misty" }
    }
}

-- Face Feature Labels
AppearanceData.FaceFeatures = {
    { id = 0, label = "Nose Width" },
    { id = 1, label = "Nose Peak Height" },
    { id = 2, label = "Nose Peak Length" },
    { id = 3, label = "Nose Bone Height" },
    { id = 4, label = "Nose Peak Lowering" },
    { id = 5, label = "Nose Bone Twist" },
    { id = 6, label = "Eyebrow Height" },
    { id = 7, label = "Eyebrow Depth" },
    { id = 8, label = "Cheekbone Height" },
    { id = 9, label = "Cheekbone Width" },
    { id = 10, label = "Cheek Width" },
    { id = 11, label = "Eye Opening" },
    { id = 12, label = "Lip Thickness" },
    { id = 13, label = "Jaw Bone Width" },
    { id = 14, label = "Jaw Bone Length" },
    { id = 15, label = "Chin Bone Height" },
    { id = 16, label = "Chin Bone Length" },
    { id = 17, label = "Chin Bone Width" },
    { id = 18, label = "Chin Hole" },
    { id = 19, label = "Neck Thickness" }
}

-- Head Overlay Labels
AppearanceData.HeadOverlays = {
    { id = 0, label = "Blemishes", hasColor = false },
    { id = 1, label = "Facial Hair", hasColor = true },
    { id = 2, label = "Eyebrows", hasColor = true },
    { id = 3, label = "Ageing", hasColor = false },
    { id = 4, label = "Makeup", hasColor = true },
    { id = 5, label = "Blush", hasColor = true },
    { id = 6, label = "Complexion", hasColor = false },
    { id = 7, label = "Sun Damage", hasColor = false },
    { id = 8, label = "Lipstick", hasColor = true },
    { id = 9, label = "Moles/Freckles", hasColor = false },
    { id = 10, label = "Chest Hair", hasColor = true },
    { id = 11, label = "Body Blemishes", hasColor = false },
    { id = 12, label = "Add Body Blemishes", hasColor = false }
}

-- Hair Colors
AppearanceData.HairColors = {
    { id = 0, label = "Black" },
    { id = 1, label = "Dark Brown" },
    { id = 2, label = "Brown" },
    { id = 3, label = "Light Brown" },
    { id = 4, label = "Dirty Blonde" },
    { id = 5, label = "Blonde" },
    { id = 6, label = "Platinum Blonde" },
    { id = 7, label = "Light Blonde" },
    { id = 8, label = "Golden Blonde" },
    { id = 9, label = "Honey" },
    { id = 10, label = "Auburn" },
    { id = 11, label = "Red" },
    { id = 12, label = "Dark Red" },
    { id = 13, label = "Fire Red" },
    { id = 14, label = "Pink" },
    { id = 15, label = "Hot Pink" },
    { id = 16, label = "Magenta" },
    { id = 17, label = "Purple" },
    { id = 18, label = "Deep Purple" },
    { id = 19, label = "Ultra Violet" },
    { id = 20, label = "Blue" },
    { id = 21, label = "Electric Blue" },
    { id = 22, label = "Aqua" },
    { id = 23, label = "Teal" },
    { id = 24, label = "Green" },
    { id = 25, label = "Dark Green" },
    { id = 26, label = "Yellow" },
    { id = 27, label = "Orange" },
    { id = 28, label = "White" },
    { id = 29, label = "Silver" },
    { id = 30, label = "Grey" },
    { id = 31, label = "Dark Grey" }
}

-- Clothing Component IDs
AppearanceData.Components = {
    { id = 0, label = "Face", category = "face" },
    { id = 1, label = "Mask", category = "masks" },
    { id = 2, label = "Hair", category = "hair" },
    { id = 3, label = "Torso", category = "torso" },
    { id = 4, label = "Legs", category = "pants" },
    { id = 5, label = "Bags", category = "bags" },
    { id = 6, label = "Shoes", category = "shoes" },
    { id = 7, label = "Accessories", category = "accessories" },
    { id = 8, label = "Undershirt", category = "undershirt" },
    { id = 9, label = "Body Armor", category = "armor" },
    { id = 10, label = "Decals", category = "decals" },
    { id = 11, label = "Tops", category = "tops" }
}

-- Prop IDs
AppearanceData.Props = {
    { id = 0, label = "Hats", category = "hats" },
    { id = 1, label = "Glasses", category = "glasses" },
    { id = 2, label = "Ears", category = "ears" },
    { id = 6, label = "Watches", category = "watches" },
    { id = 7, label = "Bracelets", category = "bracelets" }
}

-- Tattoo Zones
AppearanceData.TattooZones = {
    { zone = "ZONE_HEAD", label = "Head" },
    { zone = "ZONE_TORSO", label = "Torso" },
    { zone = "ZONE_LEFT_ARM", label = "Left Arm" },
    { zone = "ZONE_RIGHT_ARM", label = "Right Arm" },
    { zone = "ZONE_LEFT_LEG", label = "Left Leg" },
    { zone = "ZONE_RIGHT_LEG", label = "Right Leg" }
}

-- Tattoo Collections (simplified, add more as needed)
AppearanceData.Tattoos = {
    male = {
        ZONE_TORSO = {
            { collection = "mpairraces_overlays", name = "MP_Airraces_Tattoo_000_M", label = "Turbulence" },
            { collection = "mpairraces_overlays", name = "MP_Airraces_Tattoo_001_M", label = "Pilot Skull" },
            { collection = "mpairraces_overlays", name = "MP_Airraces_Tattoo_002_M", label = "Winged Skull" },
            -- Add more tattoos here
        },
        ZONE_HEAD = {
            { collection = "mpheist3_overlays", name = "mpHeist3_Tat_000_M", label = "Bullseye" },
            -- Add more tattoos here
        },
        ZONE_LEFT_ARM = {
            { collection = "mpbeach_overlays", name = "MP_Bea_M_LArm_000", label = "Bottle Blonde" },
            -- Add more tattoos here
        },
        ZONE_RIGHT_ARM = {
            { collection = "mpbeach_overlays", name = "MP_Bea_M_RArm_000", label = "Tribal Tiki Tower" },
            -- Add more tattoos here
        },
        ZONE_LEFT_LEG = {
            { collection = "mpbeach_overlays", name = "MP_Bea_M_LLeg_000", label = "Mermaid" },
            -- Add more tattoos here
        },
        ZONE_RIGHT_LEG = {
            { collection = "mpbiker_overlays", name = "MP_MP_Biker_Tat_000_M", label = "Dragon" },
            -- Add more tattoos here
        }
    },
    female = {
        ZONE_TORSO = {
            { collection = "mpairraces_overlays", name = "MP_Airraces_Tattoo_000_F", label = "Turbulence" },
            { collection = "mpairraces_overlays", name = "MP_Airraces_Tattoo_001_F", label = "Pilot Skull" },
            { collection = "mpairraces_overlays", name = "MP_Airraces_Tattoo_002_F", label = "Winged Skull" },
            -- Add more tattoos here
        },
        ZONE_HEAD = {
            { collection = "mpheist3_overlays", name = "mpHeist3_Tat_000_F", label = "Bullseye" },
            -- Add more tattoos here
        },
        ZONE_LEFT_ARM = {
            { collection = "mpbeach_overlays", name = "MP_Bea_F_LArm_000", label = "Bottle Blonde" },
            -- Add more tattoos here
        },
        ZONE_RIGHT_ARM = {
            { collection = "mpbeach_overlays", name = "MP_Bea_F_RArm_000", label = "Tribal Tiki Tower" },
            -- Add more tattoos here
        },
        ZONE_LEFT_LEG = {
            { collection = "mpbeach_overlays", name = "MP_Bea_F_LLeg_000", label = "Mermaid" },
            -- Add more tattoos here
        },
        ZONE_RIGHT_LEG = {
            { collection = "mpbiker_overlays", name = "MP_MP_Biker_Tat_000_F", label = "Dragon" },
            -- Add more tattoos here
        }
    }
}

-- Eye Colors
AppearanceData.EyeColors = {
    { id = 0, label = "Green" },
    { id = 1, label = "Emerald" },
    { id = 2, label = "Light Blue" },
    { id = 3, label = "Ocean Blue" },
    { id = 4, label = "Light Brown" },
    { id = 5, label = "Dark Brown" },
    { id = 6, label = "Hazel" },
    { id = 7, label = "Dark Gray" },
    { id = 8, label = "Light Gray" },
    { id = 9, label = "Pink" },
    { id = 10, label = "Yellow" },
    { id = 11, label = "Purple" },
    { id = 12, label = "Blackout" },
    { id = 13, label = "Shades of Gray" },
    { id = 14, label = "Tequila Sunrise" },
    { id = 15, label = "Atomic" },
    { id = 16, label = "Warp" },
    { id = 17, label = "ECola" },
    { id = 18, label = "Space Ranger" },
    { id = 19, label = "Ying Yang" },
    { id = 20, label = "Bullseye" },
    { id = 21, label = "Lizard" },
    { id = 22, label = "Dragon" },
    { id = 23, label = "Extra Terrestrial" },
    { id = 24, label = "Goat" },
    { id = 25, label = "Smiley" },
    { id = 26, label = "Possessed" },
    { id = 27, label = "Demon" },
    { id = 28, label = "Infected" },
    { id = 29, label = "Alien" },
    { id = 30, label = "Undead" },
    { id = 31, label = "Zombie" }
}
