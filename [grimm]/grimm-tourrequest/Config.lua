DebugEnabled = true
DrivingTask = 169
HasPlayerCompletedIntro = false

Config = {
    -- TRIGGER SETTINGS
    TriggerMethod = "auto", -- Options: "command", "keybind", "phone", "auto", "cityhall"
    
    -- If using keybind method
    KeybindKey = 'F7', -- Key to press to request tour
    KeybindLabel = 'Request City Tour',
    
    -- If using auto method
    AutoTriggerDelay = 10000, -- Wait 10 seconds after player loads before auto-starting tour
    AutoShowNotification = true, -- Show notification before auto-starting
    AutoNotificationDelay = 5000, -- Show notification 5 seconds before auto-start
    AutoAllowCancel = true, -- Allow players to cancel the auto-tour before it starts
    AutoWaitForCustomization = true, -- Wait until character customization is complete
    AutoCheckInterval = 2000, -- Check every 2 seconds if customization is done
    
    -- If using cityhall method
    CityHallPed = {
        Model = 'a_f_y_business_01',
        Coordinates = vector4(-545.38, -204.29, 37.65, 210.0),
        Label = 'Request City Tour',
    },
    
    -- Notification settings
    ShowWelcomeNotification = true,
    WelcomeNotificationDelay = 3000, -- 3 seconds after spawn
    
    -- Tour Vehicle Settings
    SecondsToWaitAtEachDestination = 4,
    DistanceFromDestinations = 2.5,
    VehicleSpawnDistance = 40.0, -- Increased for better road finding (was 25)
    VehicleStopDistance = 8.0, -- How close the taxi stops to player (meters)
    ShowVehicleBlip = true, -- Show blip on map until player enters
    AllowMultipleTours = true, -- Allow multiple players to do tour simultaneously
    
    TaxiDriver = {
        Model = 'a_m_y_stlat_01', -- Regular taxi driver ped
        Instance = nil,
        Invincible = true,
        FreezePosition = false,
        DrivingStyle = 786603, -- Smoother driving for taxi
    },
    
    LamarPedDriver = {
        Model = 'cs_lamardavis',
        Instance = nil,
        Invincible = true,
        FreezePosition = false,
        DrivingStyle = 524863,
    },
    
    TaxiVehicle = {
        Model = 'taxi', -- Default GTA taxi
        Instance = nil,
        Heading = 0.0, -- Will be calculated based on player position
    },
    
    LamarVehicle = {
        Model = 'baller',
        Instance = nil,
        Heading = 0.0, -- Will be calculated based on player position
    },
    
    -- Taxi Driver Messages
    Messages = {
        Calling = "Tour taxi dispatched! Look for the yellow marker on your map.",
        Arriving = "Welcome aboard! Sit back and enjoy the tour.",
        AlreadyCompleted = "You've already completed the city tour!",
        AlreadyActive = "Your tour taxi is already on the way!",
        AutoStarting = "Your free city tour will begin shortly. Type /canceltour to skip.",
        AutoStarted = "Welcome to the city! Your tour taxi has been dispatched.",
    },
    
    SightSeeingLocations = {
        [1] = {
            Name = 'City Hall',
            Coordinates = vector3(-506.26, -271.08, 35.5),
            Message = 'This is City Hall. Come here for jobs and shit.',
            VehicleSpeed = 50.0,
        },
        [2] = {
            Name = 'Pillbox Hospital',
            Coordinates = vector3(261.77, -566.79, 43.14),
            Message = 'You\'ll be coming here when you get shot.',
            VehicleSpeed = 50.0,
        },
        [3] = {
            Name = 'Gruppe Sechs',
            Coordinates = vector3(-175.86, -832.55, 30.64),
            Message = 'Gruppe Sechs...what more can I say',
            VehicleSpeed = 50.0,
        },
        [4] = {
            Name = 'PDM',
            Coordinates = vector3(-81.78, -1080.88, 26.67),
            Message = 'And this concludes our tour. Go redeem a car, on the house. Welcome to the city!',
            VehicleSpeed = 50.0,
        },
    },
}