-- [AI-FIRST SETUP]: Give PROMPT.md to your AI assistant to configure this file automatically.
-- For advanced technical settings, see shared/internal_config.lua
Config = Config or {}

-- Framework Detection: 'auto', 'qbcore', 'qbox', 'esx', 'standalone'
Config.Framework = 'auto'

-- SQL Driver: 'auto', 'oxmysql', 'ghmattimysql', 'mysql-async'
Config.SQL = 'auto'

-- Interaction Handler: 'auto', 'drawtext', 'ox_target', 'qb_target', 'qb_textui', 'esx_textui'
Config.InteractionHandler = 'auto'

-- Inventory System: 'auto', 'ox_inventory', 'qb_inventory', 'esx_inventory', 'qs_inventory'
Config.Inventory = 'auto'

-- Notify System: 'auto', 'qb-core', 'esx', 'native'
Config.Notify = 'auto'

-- Target System: 'auto', 'ox_target', 'qb-target', nil (disables target-based interaction)
Config.Target = 'auto'

-- Progress Bar: 'auto', 'progressbar', 'wait'
Config.Progress = 'auto'

-- Fuel System: 'native', 'ox_fuel', 'legacyfuel', 'ps-fuel'
Config.Fuel = 'ox_fuel'

Config.Debug               = false
Config.EnableGhostMode     = true    -- if true players can't collide with each other in the vehicle spawn area
Config.DefaultImage        = './assets/images/test-pp.png'
Config.JobName             = 'all'   -- 'all' to allow everyone, or a specific job name
Config.VehicleDeleteTimeout = 10000
Config.DailyMissions = {
  ["complete_mission"] = {
    header = "Complete One Mission !",
    label = "Complete at least one mission on National T&S.",
    max = 1,
    xp = 2500,
  },
  ["complete_special_mission"] = {
    header = "Complete One Special Delivery!",
    label = "Earn one companies trust and deliver 1 special delivery!",
    max = 1,
    xp = 2500,
  },
  ["on_the_roads"] = {
    header = "On The Roads !",
    label = "Transport goods for 30 minutes in one day.",
    max = 30,
    xp = 2500,
  },
}

Config.NpcLocation = {
  coords = vector4(806.30, -3183.797, 4.89, 170.07),
  model = `g_m_m_chiboss_01`,
  blip = {
    name   = 'Trucker Job',
    show   = true, -- if you want to disable the blip, set this to false
    sprite = 477,
    color  = 42,
    scale  = 0.7,
  }
}


Config.IllegalNPC = {
  coords = vector4(975.97, -2358.37, 30.82, 175.48),
  model = `s_m_y_dealer_01`,
  boardLocation = vector3(897.32, -3267.95, 5.5),
  money = 10000,
  item_name = "illegal_box",
}

Config.GiveXP = {
  min = 100,
  max = 500,
}

Config.Trucks = {
  {
    name  = "packer",
    image = "truck-1.png",
    label = "Packer",
    level = 1,
  },
  {
    name  = "hauler",
    image = "truck-2.png",
    label = "Hauler",
    level = 5,
  },
  {
    name  = "phantom3",
    image = "truck-3.png",
    label = "Phantom Classic",
    level = 10,
  },
  {
    name = "mule3",
    image = "truck-4.png",
    label = "Armored Mule",
    level = 15,
  },
  {
    name  = "phantom",
    image = "truck-5.png",
    label = "Phantom",
    level = 20,
  },
  {
    name  = "benson",
    image = "truck-6.png",
    label = "Benson",
    level = 25,
    desc  = "This vehicle is needed for a mission",
  },
  {
    name  = "pounder2",
    image = "truck-7.png",
    label = "Pounder Armored",
    level = 30,
    desc  = "This vehicle is needed for a mission",
  },
  {
    name  = "bison",
    image = "truck-8.png",
    label = "Bison",
    level = 35,
    desc  = "This vehicle is needed for a mission",
  },
  {
    name  = "terbyte",
    image = "truck-9.png",
    label = "Terbyte",
    level = 40,
    desc  = "This vehicle is needed for a mission",
  },
}

Config.KeyPressed = {
  mark_location = {
    label = "G",
    key = 133,
  }
}



Config.VehSpawn = vector4(828.43, -3209.70, 5.89, 175.74)
Config.Missions = {

  {
    id = 1,
    image = "map_1.png",
    small_image = 'map_1_small.png',
    header = "Paleto Forest Samwill Woods",
    companyIndex = 0,
    payment = 2500,
    reqPoint = 10,

    routes = {
      {
        label = 'LS Dock - Paleto Route',
        trailerSpawnAvaliableCoords = {
          vector4(798.7, -3216.5, 5.899686, 0),
          vector4(794.7504, -3215.694, 5.900031, 357.1012),
          vector4(789.9838, -3215.649, 5.900506, 5.107798),
          vector4(786.0539, -3215.573, 5.90051, 1.167372),
          vector4(782.1802, -3215.651, 5.900813, 4.534193),
          vector4(776.9627, -3216.09, 5.900813, 358.8745),
          vector4(772.7141, -3215.985, 5.900814, 1.223303)
        },
        trailerModel = "trailerlogs",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        destination = vector3(-557.17, 5380.73, 69.93),
      },
      {
        label = 'Grapeseed - Paleto Route',
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailerlogs",
        trailerSpawnAvaliableCoords = {
          vector4(1723.541, 4697.999, 42.7987, 91.37262),
          vector4(1723.211, 4704.551, 42.50185, 91.84235),
          vector4(1711.765, 4704.261, 42.71589, 99.38809),
        },
        destination = vector3(-557.17, 5380.73, 69.93),
        reqPoint = 5,
        extraPayment = 250,
      },
      {
        label = 'Factory - Paleto Route',
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailerlogs",
        attachModel = "prop_woodpile_01a",

        trailerSpawnAvaliableCoords = {
          vector4(1004.577, -2352.82, 30.50954, 272.484),
          vector4(1004.397, -2348.147, 30.50954, 263.0752),
          vector4(1005.497, -2340.967, 30.50954, 273.4695),
          vector4(1005.619, -2333.665, 30.50954, 277.6554),
          vector4(1006.049, -2325.625, 30.50958, 273.2463),
        },

        destination = vector3(-557.17, 5380.73, 69.93),
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Wood Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$2,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "3 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon  = "trust-icon.svg",
      },
    },
  },
  {
    id = 2,
    image = "map_2.png",
    small_image = 'map_2_small.png',
    companyIndex = 0,
    payment = 4500,
    reqPoint = 10,
    header = "Fame Or Shame TV Stuffs",
    routes = {
      {
        label = 'LS Dock - Richard Majestic Route',
        trailerModel = "tvtrailer",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerSpawnAvaliableCoords = {
          vector4(799.3639, -3214.31, 5.893721, 0),
          vector4(792.0329, -3215.035, 5.900221, 355.3375),
          vector4(786.2994, -3215.409, 5.900516, 357.7779),
          vector4(780.1738, -3216.303, 5.900813, 10.8169),
          vector4(774.7626, -3216.4, 5.900815, 358.2507),
          vector4(770.1282, -3216.466, 5.900771, 7.595522),
        },
        destination = vector3(-1046.85, -511.86, 36.04),
      },
      {
        label = 'Richards Majestic - Galileo Observotory Route',
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "tvtrailer",
        trailerSpawnAvaliableCoords = {
          vector4(-1047.13, -514.0089, 36.03854, 24.44029),
          vector4(-1038.265, -500.2329, 36.05179, 116.1902),
          vector4(-1027.843, -509.8654, 36.31044, 27.27471),
          vector4(-1031.929, -494.2613, 36.72496, 122.1846),
        },
        destination = vector3(-422.45, 1198.71, 325.64),
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Bale Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$4,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 3,
    image = "map_3.png",
    small_image = 'map_3_small.png',
    header = "Paleto Bay Tobaccos",
    companyIndex = 2,
    reqPoint = 10,
    payment = 10500,
    reqLevel = 25,

    routes = {
      {
        label = 'LS Dock - Paleto Bay Route',
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailers",
        trailerSpawnAvaliableCoords = {
          vector4(799.3649, -3214.31, 5.893924, 0),
          vector4(795.2145, -3214.251, 5.900215, 1.973009),
          vector4(790.6353, -3214.163, 5.900066, 4.824779),
          vector4(785.3427, -3214.404, 5.900518, 350.2079),
          vector4(779.6624, -3214.523, 5.900812, 6.768034),
          vector4(774.1818, -3215.198, 5.900813, 6.995431),
          vector4(770.2321, -3215.323, 5.900747, 359.741),
        },
        destination = vector3(-22.11, 6404.47, 31.49),

      },
      {
        label = 'Paleto Bay - Elysian Island Route',
        trailerModel = "trailers",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },

        trailerSpawnAvaliableCoords = {
          vector4(-19.89689, 6407.285, 31.49038, 227.0173),
          vector4(-22.22347, 6404.834, 31.48478, 226.5558),
          vector4(-37.39086, 6415.241, 31.49046, 315.7942),
        },
        destination = vector3(-246.92, -2574.15, 6.0),
        reqPoint = 5,
        extraPayment = 250,
      },

    },
    requirementsLabel = {
      {
        label = "Packed Cigar Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$10,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 4,
    image = "map_4.png",
    small_image = 'map_4_small.png',
    header = "Grapeseed Tobaccos",
    companyIndex = 2,
    reqPoint = 10,
    payment = 14500,
    routes = {
      {
        label = 'LS Dock - Grapeseed Route',
        trailerModel = "trailers4",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerSpawnAvaliableCoords = {
          vector4(799.3651, -3214.31, 5.893404, 0),
          vector4(794.5779, -3214.407, 5.900177, 357.5678),
          vector4(791.3696, -3214.817, 5.900245, 2.14888),
          vector4(786.3469, -3214.882, 5.900516, 358.6359),
          vector4(781.1396, -3215.533, 5.900811, 0.1206731),
          vector4(775.7214, -3215.284, 5.900813, 3.294684),
          vector4(771.1802, -3215.677, 5.900662, 358.6042),
          vector4(767.4213, -3215.72, 5.900539, 2.267155),
        },

        destination = vector3(2133.47, 4820.71, 41.22),
      },
      {
        label = 'Grapeseed - Elysian Island Route',
        trailerModel = "trailers4",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },

        trailerSpawnAvaliableCoords = {
          vector4(2412.109, 4988.813, 46.22875, 136.4334),
          vector4(2421.288, 4974.819, 46.03722, 145.2324),
          vector4(2407.5, 4958.54, 44.67709, 135.9021),
          vector4(2389.343, 4956.381, 42.94651, 178.8681),
        },
        destination = vector3(-137.71, -2508.03, 6.0),
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Packed Tobacco Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$14,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 5,
    image = "map_5.png",
    header = "Grapeseed Grains",
    small_image = 'map_5_small.png',
    companyIndex = 1,
    reqPoint = 10,
    payment = 5500,
    reqLevel = 25,
    routes = {
      {
        label = 'LS Dock - Grapeseed Route',
        trailerModel = "trailers3",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerSpawnAvaliableCoords = {
          vector4(799.3635, -3214.31, 5.894857, 0),
          vector4(795.4691, -3214.92, 5.900038, 357.4383),
          vector4(791.6484, -3215.038, 5.900298, 359.324),
          vector4(787.4124, -3215.577, 5.900514, 0.6382077),
          vector4(780.8134, -3214.466, 5.900812, 5.045791),
          vector4(775.407, -3215.005, 5.900815, 0.3904762),
          vector4(770.6196, -3215.428, 5.900711, 3.975594),
          vector4(767.7226, -3215.373, 5.900535, 6.866298),
        },
        destination = vector3(1825.45, 4945.33, 46.09),
      },
      {
        label = 'Grapeseed - Paleto Bay Route',
        trailerModel = "trailers3",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },

        trailerSpawnAvaliableCoords = {
          vector4(1825.418, 4945.323, 46.08889, 44.38203),
          vector4(1819.899, 4936.352, 44.98359, 46.74437),
          vector4(1834.017, 4953.001, 48.21677, 206.2652),
          vector4(1814.445, 4958.739, 46.59863, 133.9967),
          vector4(1838.183, 4979.438, 52.40214, 130.7265),
        },
        destination = vector3(71.9, 6633.71, 31.78),
        reqPoint = 5,
        extraPayment = 250,
      },
      {
        label = 'Grapeseed - Elysian Island Route',
        trailerModel = "trflat",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        attachModel = "prop_haybale_stack_01",
        attachModelHeight = 0.55,
        trailerSpawnAvaliableCoords = {
          vector4(1906.614, 4929.024, 48.94448, 335.812),
          vector4(1899.041, 4900.361, 47.78988, 167.9649),
          vector4(1883.976, 4900.872, 46.67866, 330.0008),
        },
        destination = vector3(277.82, -3147.5, 5.79),
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Bale Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$5,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "3 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 6,
    image = "map_6.png",
    header = "Grapeseed Grapes",
    small_image = 'map_6_small.png',
    payment = 7500,
    reqPoint = 10,
    companyIndex = 1,
    routes = {
      {
        label = 'Grapeseed - Elysian Island Route',
        trailerModel = "trflat",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        attachModel = "prop_haybale_stack_01",
        attachModelHeight = 0.55,

        trailerSpawnAvaliableCoords = {
          vector4(2550.891, 4681.521, 33.84339, 5.387225),
          vector4(2557.578, 4690.801, 33.88864, 43.56411),
          vector4(2545.668, 4669.637, 34.07682, 132.1466),
          vector4(2548.249, 4656.296, 34.07682, 25.37805),
        },
        destination = vector3(574.8, -3039.07, 6.07),

      }
    },
    requirementsLabel = {
      {
        label = "Food Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$7,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "1 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 7,
    image = "map_7.png",
    small_image = 'map_7_small.png',
    payment = 15500,
    reqPoint = 10,
    header = "LS Dock Luxury Vehicle Shipment",
    companyIndex = 4,
    reqLevel = 35,
    routes = {
      {
        label = 'LS Dock - Strawberry Route',
        trailerModel = "tr4",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },

        trailerSpawnAvaliableCoords = {
          vector4(799.3637, -3214.31, 5.894897, 0),
          vector4(795.0131, -3214.581, 5.900127, 1.922981),
          vector4(790.7404, -3215.17, 5.900508, 2.729019),
          vector4(787.0496, -3215.452, 5.900517, 5.227268),
          vector4(783.0282, -3215.314, 5.900508, 358.1991),
          vector4(778.2758, -3215.669, 5.900812, 4.232758),
          vector4(774.1027, -3216.291, 5.900815, 4.854816),
          vector4(770.3992, -3216.112, 5.900747, 2.843247),
        },
        destination = vector3(-157.69, -1165.17, 24.05),
      },
      {
        label = 'Strawberry - LS Airport Int.',
        trailerModel = "tr4",
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerSpawnAvaliableCoords = {
          vector4(-47.69642, -1081.629, 26.77104, 68.57233),
          vector4(-45.54648, -1077.242, 26.69767, 73.52732),
          vector4(-34.12594, -1079.569, 26.68957, 253.8504),
        },

        destination = vector3(-838.02, -2670.49, 13.81),
        reqPoint = 5,
        extraPayment = 250,

      },
    },
    requirementsLabel = {
      {
        label = "Vehicle Transport",
        icon = "supply-icon.svg",
      },
      {
        label = "$15,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 8,
    image = "map_8.png",
    small_image = 'map_8_small.png',
    payment = 20000,
    reqPoint = 10,
    header = "LSA Special Vehicle Shipment",
    companyIndex = 4,
    routes = {
      {
        trailerModel = "boattrailer",
        trailerlarge = "prop_byard_boat01",
        attachModelHeight = -0.15,
        vehicle = {
          "bison",
        },
        label = 'Richman - LS Airport Int. Route',

        trailerSpawnAvaliableCoords = {
          vector4(-1461.954, -28.19002, 54.64523, 50.54332),
          vector4(-1458.787, -20.94024, 54.58357, 41.07833),
          vector4(-1460.085, -38.1946, 54.68593, 329.4267),
        },
        destination = vector3(-980.72, -2229.58, 8.86),

      },
      {
        label = 'Richman - Banham Canyon',
        trailerModel = "boattrailer",
        attachModelHeight = -0.15,
        vehicle = {
          "bison",
        },
        attachModel = "prop_byard_boat02",

        trailerSpawnAvaliableCoords = {
          vector4(-1554.302, 22.0793, 58.5872, 344.896),
          vector4(-1562.858, 30.79218, 58.79086, 259.1096),
          vector4(-1575.615, 33.90485, 59.49263, 78.97023),
        },
        destination = vector3(-2784.54, 1429.48, 100.46),
        reqPoint = 5,
        extraPayment = 250,
      },
      {
        label = 'Tonga Hills - Vespucci Beachs',
        trailerModel = "boattrailer",
        attachModelHeight = -0.15,
        vehicle = {
          "bison",
        },
        attachModel = "prop_jetski_trailer_01",

        trailerSpawnAvaliableCoords = {
          vector4(-2584.48, 1924.628, 167.3072, 0),
          vector4(-2587.795, 1930.744, 167.3036, 271.4063),
          vector4(-2572.908, 1926.452, 167.7281, 230.8261),

        },
        destination = vector3(-1164.65, -1736.83, 3.61),
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Vehicle Transport",
        icon = "supply-icon.svg",
      },
      {
        label = "$20,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "3 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 9,
    image = "map_9.png",
    small_image = 'map_9_small.png',
    payment = 25000,
    reqPoint = 10,
    header = "iComputers Shipment",
    companyIndex = 5,
    reqLevel = 40,
    routes = {
      {
        label = 'LS Dock - Humane Labs',

        destination = vector3(3579.31, 3662.19, 33.9),
        vehicle = {
          "benson",
        },
      },
      {
        label = 'LS Dock - Pacific Bluffs',

        destination = vector3(-2354.94, 267.59, 165.57),
        vehicle = {
          "pounder2",
        },
        reqPoint = 5,
        extraPayment = 250,
      },
      {
        label = 'LS Dock - Pacific Bluffs - 2',

        destination = vector3(-310.86, -615.32, 33.56),
        vehicle = {
          "pounder2",
        },
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Computer Transport",
        icon = "supply-icon.svg",
      },
      {
        label = "$25,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "3 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 10,
    image = "map_10.png",
    small_image = 'map_10_small.png',
    payment = 30000,
    reqPoint = 10,
    header = "Life Invader Chip Cargo",
    companyIndex = 5,
    routes = {
      {
        vehicle = {
          "terbyte",
        },
        label = 'LS Dock - Rockford Hills ',


        destination = vector3(-1098.81, -256.21, 37.69),

      },
      {
        vehicle = {
          "terbyte",
        },
        label = 'LS Dock - Galileo Parks',
        destination = vector3(786.23, 1278.29, 360.3),

        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Chip Delivery",
        icon = "supply-icon.svg",
      },
      {
        label = "$30,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 11,
    image = "map_11.png",
    small_image = 'map_11_small.png',
    payment = 50000,
    reqPoint = 10,
    header = "Paleto Bay Oil Cargo",
    companyIndex = 6,
    reqLevel = 50,
    routes = {
      {
        label = 'Elysian Island - Paleto Bay',

        trailerSpawnAvaliableCoords = {
          vector4(-430.1912, -2713.818, 6.000201, 52.60108),
          vector4(-423.6715, -2720.323, 6.000213, 321.5811),
          vector4(-420.4599, -2724.332, 6.000213, 319.3563),
          vector4(-410.6932, -2714.565, 6.000213, 313.8806),
          vector4(-403.6332, -2704.035, 6.000215, 315.5544),
        },
        destination = vector3(199.53, 6623.06, 31.6),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "tanker",

      },
      {
        label = 'Paleto Bay - Elysian Island',

        trailerSpawnAvaliableCoords = {
          vector4(138.8657, 6586.398, 31.89746, 319.6139),
          vector4(133.5081, 6594.436, 31.88021, 314.3366),
          vector4(126.9384, 6601.843, 31.8919, 322.4238),
          vector4(120.8078, 6607.635, 31.9269, 312.2281),
        },
        destination = vector3(-443.77, -2268.62, 7.61),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "tanker",
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Oil Delivery",
        icon = "supply-icon.svg",
      },
      {
        label = "$50,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 12,
    image = "map_12.png",
    small_image = 'map_12_small.png',
    header = "Murrieta Oil Field Transport",
    companyIndex = 6,
    reqPoint = 10,
    payment = 35000,
    routes = {
      {
        label = 'El Burro Heights - Paleto Bay',
        trailerSpawnAvaliableCoords = {
          vector4(1370.86, -2079.354, 51.99849, 315.6981),
          vector4(1366.991, -2074.988, 51.9985, 315.4635),
          vector4(1362.24, -2069.208, 51.9985, 317.9874),
          vector4(1371.301, -2059.63, 51.9985, 314.6257),
          vector4(1376.063, -2063.744, 51.9985, 308.7762),
          vector4(1385.697, -2064.166, 51.99851, 306.0532),
        },
        destination = vector3(2553.42, 419.46, 108.46),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "tanker2",
      },
      {
        label = 'El Burro Heights - Greenwich',
        trailerSpawnAvaliableCoords = {
          vector4(1561.261, -2140.34, 77.5948, 99.74406),
          vector4(1565.059, -2155.518, 77.54481, 5.395184),
          vector4(1542.695, -2153.994, 77.5593, 88.18085),
          vector4(1539.718, -2173.329, 77.39249, 165.191),
        },
        destination = vector3(-1049.42, -2018.62, 12.74),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "tanker2",
        reqPoint = 5,
        extraPayment = 250,
      },
      {
        label = 'El Burro Heights - Route 68',

        trailerSpawnAvaliableCoords = {
          vector4(1485.465, -1606.348, 71.89415, 242.6715),
          vector4(1497.743, -1615.794, 71.69543, 141.402),
          vector4(1509.52, -1601.793, 73.13545, 311.8083),
        },
        destination = vector3(583.05, 2789.37, 41.75),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "tanker2",
        reqPoint = 5,
        extraPayment = 450,
      },
    },
    requirementsLabel = {
      {
        label = "Oil Transport",
        icon = "supply-icon.svg",
      },
      {
        label = "$35,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "3 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 13,
    image = "map_13.png",
    small_image = 'map_13_small.png',
    payment = 65000,
    reqPoint = 10,
    header = "MWS Army Tank Transport",
    companyIndex = 7,
    reqLevel = 60,

    routes = {
      {
        label = 'LSI Airport - Fort Zancudo',

        trailerSpawnAvaliableCoords = {
          vector4(-1095.619, -2372.029, 13.94515, 58.14845),
          vector4(-1105.638, -2379.091, 13.94514, 58.01603),
          vector4(-1120.548, -2385.924, 13.94515, 64.86921),
          vector4(-1129.853, -2396.959, 13.94514, 66.31636),
          vector4(-1136.191, -2408.424, 13.94514, 64.08057),
        },
        destination = vector3(-1746.37, 3070.96, 32.41),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "armytrailer",
        attachModel = "apc",
        attachModelHeight = -0.15,
      },
      {
        label = 'Fort Zancudo - Grand Senora Desert',

        trailerSpawnAvaliableCoords = {
          vector4(-2411.271, 3326.162, 32.82907, 238.754),
          vector4(-2399.641, 3321.778, 32.82915, 150.8668),
          vector4(-2390.864, 3316.742, 32.83007, 157.9598),
          vector4(-2397.354, 3304.089, 32.83007, 152.7684),
          vector4(-2405.431, 3304.176, 32.83008, 147.2577),
        },
        destination = vector3(1765.95, 3308.7, 40.74),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "armytrailer",
        attachModel = "rhino",
        reqPoint = 5,
        extraPayment = 250,
        attachModelHeight = -0.15,

      },
      {
        label = 'Fort Zancudo - Elysian Island',
        trailerSpawnAvaliableCoords = {
          vector4(-1847.776, 2791.808, 32.80645, 331.6275),
          vector4(-1855.043, 2795.284, 32.80646, 342.7047),
          vector4(-1862.238, 2798.547, 32.80646, 338.3475),
          vector4(-1868.848, 2803.545, 32.80646, 334.0842),
          vector4(-1877.157, 2808.3, 32.80646, 331.5829),
        },
        destination = vector3(494.93, -3160.68, 5.65),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "armytrailer",
        attachModel = "scarab",
        reqPoint = 5,
        extraPayment = 450,
        attachModelHeight = -0.15,

      },
    },
    requirementsLabel = {
      {
        label = "Tank Transport",
        icon = "supply-icon.svg",
      },
      {
        label = "$65,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "3 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 14,
    image = "map_14.png",
    payment = 80000,
    reqPoint = 10,
    small_image = 'map_14_small.png',
    header = "USAF Special Satellite Cargo",
    companyIndex = 7,
    routes = {
      {
        label = 'Elysian Island',

        trailerSpawnAvaliableCoords = {
          vector4(610.7145, -3049.899, 6.062814, 0),
          vector4(602.6535, -3037.587, 6.06929, 1.482356),
          vector4(593.4581, -3031.36, 6.06929, 358.5978),
          vector4(581.0555, -3031.443, 6.069289, 1.863618),
          vector4(566.8382, -3032.195, 6.069289, 359.8976),
        },
        destination = vector3(-2246.61, 3244.53, 32.39),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailerlarge",
      },
      {
        label = 'Fort Zancudo - Grand Senora Desert',

        trailerSpawnAvaliableCoords = {
          vector4(-1831.543, 2975.117, 32.81002, 59.00586),
          vector4(-1829.684, 2983.696, 32.80998, 70.00826),
          vector4(-1840.062, 2970.151, 32.81007, 68.85413),
          vector4(-1853.589, 2972.176, 32.81022, 324.7214),
          vector4(-1852.969, 2984.932, 32.81022, 333.3573),
        },
        destination = vector3(1135.95, -3245.87, 5.47),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailerlarge",
        -- attachModel = "prop_mb_ordnance_01",
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Military Cargo",
        icon = "supply-icon.svg",
      },
      {
        label = "$80,000 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  },
  {
    id = 15,
    image = "map_15.png",
    small_image = 'map_15_small.png',
    header = "You Tool Furniture Shipment",
    companyIndex = 3,
    reqPoint = 10,
    reqLevel = 25,

    payment = 10500,
    routes = {
      {
        label = 'LS Dock - You Tool Base',

        trailerSpawnAvaliableCoords = {
          vector4(799.3635, -3214.31, 5.894015, 0),
          vector4(792.3109, -3216.033, 5.900506, 355.4375),
          vector4(787.4438, -3215.966, 5.900507, 5.982008),
          vector4(783.1486, -3215.927, 5.900509, 6.275918),
          vector4(778.1464, -3215.754, 5.900811, 358.665),
          vector4(772.8068, -3215.604, 5.900813, 2.005733),
          vector4(768.1569, -3215.637, 5.90053, 3.204478),
        },
        destination = vector3(2761.16, 3445.91, 55.92),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailers2",
      },
      {
        label = 'Terminal - You Tool Base',

        trailerSpawnAvaliableCoords = {
          vector4(1200.047, -3235.618, 6.030974, 359.4393),
          vector4(1192.511, -3225.55, 5.847157, 274.8354),
          vector4(1192.599, -3217.634, 5.799772, 271.5442),
          vector4(1192.42, -3211.369, 5.830667, 272.2556),
          vector4(1193.088, -3204.163, 6.028035, 262.5639),
        },
        destination = vector3(2694.74, 3452.56, 55.37),
        vehicle = {
          "hauler",
          "packer",
          "phantom3",
          "mule3",
          "phantom",
        },
        trailerModel = "trailers3",
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Packed Cigar Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$10,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    }
  },
  {
    id = 16,
    image = "map_16.png",
    small_image = 'map_16_small.png',
    header = "You Tool Special Cargo",
    companyIndex = 3,
    reqPoint = 10,
    payment = 14500,
    routes = {
      {
        label = 'LS Dock - You Tool - Elysian Island',
        vehicleSpawn = vector3(855.14, -3208.81, 5.48),
        board = vector3(2760.2, 3471.69, 55.23),
        destination = vector3(141.65, -3089.36, 5.47),
        vehicle = {
          "mule3",
        },
      },
      {
        label = 'LS Dock - You Tool - Elysian Island 2',
        vehicleSpawn = vector3(855.14, -3208.81, 5.48),
        board = vector3(2760.2, 3471.69, 55.23),
        destination = vector3(191.87, 2787.62, 45.21),
        vehicle = {
          "mule3",
        },
        reqPoint = 5,
        extraPayment = 250,
      },
    },
    requirementsLabel = {
      {
        label = "Packed Tobacco Supply",
        icon = "supply-icon.svg",
      },
      {
        label = "$14,500 Profit",
        icon = "profit-icon.svg",
      },
      {
        label = "2 Different Route",
        icon = "route-icon.svg",
      },
      {
        label = "+1 Company Trust",
        icon = "trust-icon.svg",
      },
    },
  }
}


Config.FuelSystem = "cdn-fuel"                        -- LegacyFuel / x-fuel

Config.SetVehicleFuel = function(vehicle, fuel_level) -- you can change LegacyFuel export if you use another fuel system
  if Config.FuelSystem == 'LegacyFuel' then
    return exports["LegacyFuel"]:SetFuel(vehicle, fuel_level)
  elseif Config.FuelSystem == 'x-fuel' then
    return exports["x-fuel"]:SetFuel(vehicle, fuel_level)
  elseif Config.FuelSystem == 'cdn-fuel' then
    return exports['cdn-fuel']:SetFuel(vehicle, fuel_level)
  else
    return SetVehicleFuelLevel(vehicle, fuel_level + 0.0)
  end
end


Config.Vehiclekey          = true
Config.VehicleSystem       = "qb-vehiclekeys" -- cd_garage / qs-vehiclekeys / wasabi-carlock / qb-vehiclekeys
Config.Removekeys          = true
Config.RemoveVehicleSystem =
"qb-vehiclekeys"                                             -- cd_garage / qs-vehiclekeys / wasabi-carlock / qb-vehiclekeys

Config.GiveVehicleKey      = function(plate, model, vehicle) -- you can change vehiclekeys export if you use another vehicle key system
  if Config.Vehiclekey then
    if Config.VehicleSystem == 'cd_garage' then
      TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(vehicle))
    elseif Config.VehicleSystem == 'qs-vehiclekeys' then
      model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
      exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
    elseif Config.VehicleSystem == 'wasabi-carlock' then
      exports.wasabi_carlock:GiveKey(plate)
    elseif Config.VehicleSystem == 'qb-vehiclekeys' then
      TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    end
  end
end

Config.RemoveVehiclekey    = function(plate, model, vehicle)
  if Config.Removekeys then
    if Config.RemoveVehicleSystem == 'cd_garage' then
      TriggerServerEvent('cd_garage:RemovePersistentVehicles', exports['cd_garage']:GetPlate(vehicle))
    elseif Config.RemoveVehicleSystem == 'qs-vehiclekeys' then
      model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
      exports['qs-vehiclekeys']:RemoveKeys(plate, model)
    elseif Config.RemoveVehicleSystem == 'wasabi-carlock' then
      exports.wasabi_carlock:RemoveKey(plate)
    elseif Config.RemoveVehicleSystem == 'qb-vehiclekeys' then
      TriggerServerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
    end
  end
end
