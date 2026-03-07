return {
    mining = {
        xpTables = {
            { level = 1, xp = 0 },
            { level = 2, xp = 10 },
            { level = 3, xp = 30 },
            { level = 4, xp = 60 },
            { level = 5, xp = 100 },
        },
        lootTables = {
            mining_table = {
                { name = 'metalscrap', chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'steel',      chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'copper',     chance = 0.5, min = 1, max = 4, level = 1 },
            }
        },
        tools = {
            red40_pickaxe = {
                level = 1,
                damage = true,
                minXp = 0,          -- Minimum XP required to use this tool
                maxXp = 10,         -- Stop earning xp after this level
                minUseTime = 5000,  -- Minimum time in milliseconds to use the tool
                maxUseTime = 10000, -- Maximum time in milliseconds to use the tool
                prop = `prop_tool_pickaxe`,
                bone = 57005,
                offset = vec3(0.09, -0.33, -0.12),
                rotation = vec3(252.0, 180.0, 0.0),
                anim = {
                    anim = 'amb@world_human_hammering@male@base',
                    dict = 'base',
                },
                type = 'pickaxe'
            },
            red40_drill = {
                level = 2,
                damage = true,
                minXp = 10,
                maxXp = 100,
                minUseTime = 3000, -- Minimum time in milliseconds to use the tool
                maxUseTime = 7000, -- Maximum time in milliseconds to use the tool
                prop = `hei_prop_heist_drill`,
                bone = 57005,
                offset = vec3(0.14, 0, -0.01),
                rotation = vec3(90.0, -90.0, 180.0),
                anim = {
                    anim = 'anim@heists@fleeca_bank@drilling',
                    dict = 'drill_straight_fail',
                },
                type = 'drill'
            },
            red40_laserdrill = {
                level = 3,
                damage = false,
                minXp = 20,
                maxXp = 200,
                minUseTime = 750,  -- Minimum time in milliseconds to use the tool
                maxUseTime = 2000, -- Maximum time in milliseconds to use the tool
                prop = `ch_prop_laserdrill_01a`,
                bone = 57005,
                offset = vec3(0.14, 0, -0.01),
                rotation = vec3(90.0, -90.0, 180.0),
                anim = {
                    anim = 'anim@heists@fleeca_bank@drilling',
                    dict = 'drill_straight_fail',
                },
                type = 'laserdrill'
            }
        },
        durability = function()
            return math.random(1, 5) -- Random durability loss between 1 and 5 for each use
        end,
        xpPerAction = function()
            return math.random(1, 3) -- Random XP between 1 and 3 for each successful action,
        end,
        locations = {
            {
                name = 'mine_shaft_1', -- Unique identifier for the location, referenced in logs
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Mines',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                lights = {
                    enabled = true,
                    prop = `prop_worklight_02a`,
                    locations = {
                        { coords = vector3(2989.3467, 2802.7656, 42.9675), rotation = vec3(0.0, 0.0, 118.795) },
                        { coords = vector3(2991.2056, 2781.1663, 42.6162), rotation = vec3(0.0, 0.0, 96.915) }
                    }
                },
                ore_locations = {
                    {
                        coords = {
                            --TODO better coords
                            vector3(3003.6047, 2760.3113, 43.798),
                            vector3(3005.9736, 2768.9956, 43.6523),
                            vector3(3005.0918, 2779.6118, 44.6404),
                            vector3(3003.2202, 2789.1477, 44.5051),
                            vector3(2995.3972, 2800.3584, 45.0069),
                            vector3(2988.5369, 2809.9109, 45.7465),
                            vector3(2984.0588, 2821.5955, 45.8532),
                            vector3(2976.114, 2833.5037, 45.6009),
                            vector3(2969.4429, 2840.8884, 44.5999),
                            vector3(2963.6855, 2848.9448, 46.9679),
                            vector3(2956.2261, 2852.1279, 47.34),
                            vector3(2946.8401, 2851.2656, 47.9002),
                            vector3(2959.2717, 2823.6438, 42.2595),
                            vector3(2949.6567, 2825.5923, 43.9303),
                            vector3(2920.584, 2809.6475, 43.4429),
                            vector3(2929.2534, 2791.4773, 39.3105),
                            vector3(2936.8098, 2766.1348, 39.5114),
                            vector3(2931.9058, 2770.8193, 39.0576),
                            vector3(2937.6362, 2738.3779, 45.2593),
                            vector3(2978.188, 2745.2825, 43.7559),
                            vector3(2996.1187, 2749.5212, 43.7843)
                        },
                        rotation = vec3(0.0, 0.0, 0.0),
                        prop = `prop_rock_4_b`,
                        rewards = 'mining_table', -- which loot table to pick from
                        min = 1,
                        max = 3
                    },
                },
                respawnTimeMin = 30000, -- Time in milliseconds for ores to respawn minimum
                respawnTimeMax = 60000, -- Time in milliseconds for ores to respawn maximum
            }
        }
    },
    panning = {
        xpTables = {
            { level = 1, xp = 0 },
            { level = 2, xp = 10 },
            { level = 3, xp = 30 },
            { level = 4, xp = 60 },
            { level = 5, xp = 100 },
        },
        lootTables = {
            pan_loot = {
                { name = 'metalscrap', chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'steel',      chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'copper',     chance = 0.5, min = 1, max = 4, level = 1 },
            }
        },
        tools = {
            red40_pan = {
                level = 1,
                damage = false,
                minXp = 0,          -- Minimum XP required to use this tool
                maxXp = 10,         -- Stop earning xp after this level
                minUseTime = 5000,  -- Minimum time in milliseconds to use the tool
                maxUseTime = 10000, -- Maximum time in milliseconds to use the tool
                prop = `bkr_prop_meth_tray_01b`,
                bone = 57005,
                offset = vec3(0.14, 0, -0.01),
                rotation = vec3(90.0, -90.0, 180.0),
                anim = {
                    anim = 'amb@medic@standing@tendtodead@base',
                    dict = 'base',
                },
                type = 'pan',
            },
            red40_sifter = {
                level = 2,
                damage = false,
                minXp = 10,
                maxXp = 100,
                minUseTime = 3000, -- Minimum time in milliseconds to use the tool
                maxUseTime = 7000, -- Maximum time in milliseconds to use the tool
                prop = `bkr_prop_meth_tray_01b`,
                bone = 57005,
                offset = vec3(0.14, 0, -0.01),
                rotation = vec3(90.0, -90.0, 180.0),
                anim = {
                    anim = 'amb@medic@standing@tendtodead@base',
                    dict = 'base',
                },
                type = 'sifter',
            },
        },
        durability = function()
            return math.random(1, 5) -- Random durability loss between 1 and 5 for each use
        end,
        xpPerAction = function()
            return math.random(1, 3) -- Random XP between 1 and 3 for each successful action,
        end,
        locations = {
            {
                name = 'panning_location_1',
                enabled = true,
                debug = false,
                blip = {
                    enable = true,
                    name = 'Panning Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                points = {
                    vector3(-1380.126, 2004.7308, 59.9556),
                    vector3(-1403.6226, 2008.2764, 59.9556),
                    vector3(-1405.707, 2003.3763, 59.9556),
                    vector3(-1379.6307, 1999.1255, 59.9556),
                },
                rewards = 'pan_loot',
                min = 1, -- Minimum amount of items to reward
                max = 3  -- Maximum amount of items to reward
            }
        }
    },
    washing = {
        xpTables = {
            { level = 1, xp = 0 },
            { level = 2, xp = 10 },
            { level = 3, xp = 30 },
            { level = 4, xp = 60 },
            { level = 5, xp = 100 },
        },
        lootTables = {
            wash_loot = {
                { name = 'metalscrap', chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'steel',      chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'copper',     chance = 0.5, min = 1, max = 4, level = 1 },
            }
        },

        tools = {
            red40_stone = {
                level = 1,
                minXp = 0,
                maxXp = 100,
                prop = `prop_rock_5_smash1`,
                bone = 60309,
                offset = vec3(0.1, 0.0, 0.05),
                rotation = vec3(90.0, -90.0, 90.0),
                minUseTime = 5000,  -- Minimum time in milliseconds to wash
                maxUseTime = 10000, -- Maximum time in milliseconds to wash
                rewards = 'wash_loot',
                min = 1,
                max = 3
            }
        },
        xpPerAction = function()
            return math.random(1, 3) -- Random XP between 1 and 3 for each successful action,
        end,
        locations = {
            {
                name = 'washing_location_1',
                enabled = true,
                debug = true,
                blip = {
                    enable = true,
                    name = 'Washing Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1832.7822, 419.7999, 159.3571)
                },
                points = {
                    vector3(1832.7822, 419.7999, 159.3571),
                    vector3(1834.6827, 405.8199, 159.3571),
                    vector3(1851.6012, 396.6167, 159.3571),
                    vector3(1858.0842, 405.7967, 159.3571),
                    vector3(1851.1173, 428.7765, 159.3571),
                },
            }
        }
    },
    cracking = {
        xpTables = {
            { level = 1, xp = 0 },
            { level = 2, xp = 10 },
            { level = 3, xp = 30 },
            { level = 4, xp = 60 },
            { level = 5, xp = 100 },
        },
        lootTables = {
            crack_loot = {
                { name = 'metalscrap', chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'steel',      chance = 0.5, min = 1, max = 4, level = 1 },
                { name = 'copper',     chance = 0.5, min = 1, max = 4, level = 1 },
            }
        },
        tools = {
            red40_drillbit = {
                level = 1,
                damage = true,
                minXp = 0,       -- Minimum XP required to use this tool
                maxXp = 10,      -- Stop earning xp after this level
                minTime = 5000,  -- Minimum time in milliseconds to crack
                maxTime = 10000, -- Maximum time in milliseconds to crack
            },
            red40_carbidedrillbit = {
                level = 2,
                damage = true,
                minXp = 10,
                maxXp = 100,
                minTime = 3000, -- Minimum time in milliseconds to crack
                maxTime = 7000, -- Maximum time in milliseconds to crack
            },
        },
        durability = function()
            return math.random(1, 5) -- Random durability loss between 1 and 5 for each use
        end,
        locations = {
            {
                name = 'cracking_location_1',
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Cracking Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                prop = `prop_vertdrill_01`,
                anim = {
                    anim = 'operate_02_hi_amy_skater_01',
                    dict = 'anim@amb@machinery@speed_drill@'
                },
                locations = {
                    { coords = vec3(1074.89, -1988.19, 30.89), rotation = vec3(0.0, 0.0, 0.0) },
                },
                rewards = 'crack_loot',
                min = 1,
                max = 3
            }
        }
    },
    jewelcutting = {
        recipes = { -- define categories of items that can be crafted, with their inputs and outputs, locale is matched to the key name for the list
            gems = {
                emerald = { input = { uncut_emerald = 1 }, amount = 1 },
                ruby = { input = { uncut_ruby = 1 }, amount = 1 },
                sapphire = { input = { uncut_sapphire = 1 }, amount = 1 },
                diamond = { input = { uncut_diamond = 1 }, amount = 1 },
            },
            rings = {
                gold_ring = { input = { gold_ingot = 1 }, amount = 1 },
                silver_ring = { input = { silver_ingot = 1 }, amount = 1 },
                platinum_ring = { input = { platinum_ingot = 1 }, amount = 1 },
                gold_diamond_ring = { input = { diamond = 1, gold_ingot = 1 }, amount = 1 },
                gold_emerald_ring = { input = { emerald = 1, gold_ingot = 1 }, amount = 1 },
                gold_ruby_ring = { input = { ruby = 1, gold_ingot = 1 }, amount = 1 },
                gold_sapphire_ring = { input = { sapphire = 1, gold_ingot = 1 }, amount = 1 },
                silver_diamond_ring = { input = { diamond = 1, silver_ingot = 1 }, amount = 1 },
                silver_emerald_ring = { input = { emerald = 1, silver_ingot = 1 }, amount = 1 },
                silver_ruby_ring = { input = { ruby = 1, silver_ingot = 1 }, amount = 1 },
                silver_sapphire_ring = { input = { sapphire = 1, silver_ingot = 1 }, amount = 1 },
                platinum_diamond_ring = { input = { diamond = 1, platinum_ingot = 1 }, amount = 1 },
                platinum_emerald_ring = { input = { emerald = 1, platinum_ingot = 1 }, amount = 1 },
                platinum_ruby_ring = { input = { ruby = 1, platinum_ingot = 1 }, amount = 1 },
                platinum_sapphire_ring = { input = { sapphire = 1, platinum_ingot = 1 }, amount = 1 },
            },
            necklace = {
                gold_necklace = { input = { gold_ingot = 1 }, amount = 1 },
                silver_necklace = { input = { silver_ingot = 1 }, amount = 1 },
                platinum_necklace = { input = { platinum_ingot = 1 }, amount = 1 },
                gold_diamond_necklace = { input = { diamond = 1, gold_necklace = 1 }, amount = 1 },
                gold_emerald_necklace = { input = { emerald = 1, gold_necklace = 1 }, amount = 1 },
                gold_ruby_necklace = { input = { ruby = 1, gold_necklace = 1 }, amount = 1 },
                gold_sapphire_necklace = { input = { sapphire = 1, gold_necklace = 1 }, amount = 1 },
                silver_diamond_necklace = { input = { diamond = 1, silver_necklace = 1 }, amount = 1 },
                silver_emerald_necklace = { input = { emerald = 1, silver_necklace = 1 }, amount = 1 },
                silver_ruby_necklace = { input = { ruby = 1, silver_necklace = 1 }, amount = 1 },
                silver_sapphire_necklace = { input = { sapphire = 1, silver_necklace = 1 }, amount = 1 },
                platinum_diamond_necklace = { input = { diamond = 1, platinum_necklace = 1 }, amount = 1 },
                platinum_emerald_necklace = { input = { emerald = 1, platinum_necklace = 1 }, amount = 1 },
                platinum_ruby_necklace = { input = { ruby = 1, platinum_necklace = 1 }, amount = 1 },
                platinum_sapphire_necklace = { input = { sapphire = 1, platinum_necklace = 1 }, amount = 1 },
            },
            earring = {
                gold_earring = { input = { gold_ingot = 1 }, amount = 1 },
                silver_earring = { input = { silver_ingot = 1 }, amount = 1 },
                platinum_earring = { input = { platinum_ingot = 1 }, amount = 1 },
                gold_diamond_earring = { input = { diamond = 1, gold_earring = 1 }, amount = 1 },
                gold_emerald_earring = { input = { emerald = 1, gold_earring = 1 }, amount = 1 },
                gold_ruby_earring = { input = { ruby = 1, gold_earring = 1 }, amount = 1 },
                gold_sapphire_earring = { input = { sapphire = 1, gold_earring = 1 }, amount = 1 },
                silver_diamond_earring = { input = { diamond = 1, silver_earring = 1 }, amount = 1 },
                silver_emerald_earring = { input = { emerald = 1, silver_earring = 1 }, amount = 1 },
                silver_ruby_earring = { input = { ruby = 1, silver_earring = 1 }, amount = 1 },
                silver_sapphire_earring = { input = { sapphire = 1, silver_earring = 1 }, amount = 1 },
                platinum_diamond_earring = { input = { diamond = 1, platinum_earring = 1 }, amount = 1 },
                platinum_emerald_earring = { input = { emerald = 1, platinum_earring = 1 }, amount = 1 },
                platinum_ruby_earring = { input = { ruby = 1, platinum_earring = 1 }, amount = 1 },
                platinum_sapphire_earring = { input = { sapphire = 1, platinum_earring = 1 }, amount = 1 },
            }
        },
        locations = {
            {
                name = 'jewel_cutting_location_1',
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Jewel Cutting Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                prop = `gr_prop_gr_speeddrill_01c`,
                anim = {
                    anim = 'operate_02_hi_amy_skater_01',
                    dict = 'anim@amb@machinery@speed_drill@'
                },
                locations = {
                    { coords = vec3(1074.89, -1988.19, 30.89), rotation = vec3(0.0, 0.0, 0.0) },
                },
            }
        }
    },
    smelting = {
        recipes = {
            { gold_ingot = 1,     input = { gold_ore = 2 },           amount = 1 },
            { gold_ingot = 1,     input = { gold_necklace = 4 },      amount = 1 },
            { gold_ingot = 1,     input = { gold_ring = 4 },          amount = 1 },
            { silver_ingot = 1,   input = { silver_ore = 2 },         amount = 1 },
            { silver_ingot = 1,   input = { silver_necklace = 4 },    amount = 1 },
            { silver_ingot = 1,   input = { silver_ring = 4 },        amount = 1 },
            { platinum_ingot = 1, input = { platinum_ore = 2 },       amount = 1 },
            { platinum_ingot = 1, input = { platinum_necklace = 4 },  amount = 1 },
            { platinum_ingot = 1, input = { platinum_ring = 4 },      amount = 1 },
            { copper_ingot = 1,   input = { copper_ore = 2 },         amount = 1 },
            { iron_ingot = 1,     input = { iron_ore = 2 },           amount = 1 },
            { aluminum_ingot = 1, input = { aluminum_ore = 2 },       amount = 1 },
            { steel_ingot = 1,    input = { iron_ore = 1, coal = 1 }, amount = 1 },
            { glass_pane = 1,     input = { sand = 2 },               amount = 1 },
        },
        locations = {
            {
                name = 'smelting_location_1',
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Smelting Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                prop = `red40_forge`,
                anim = {
                    anim = 'operate_02_hi_amy_skater_01',    -- change
                    dict = 'anim@amb@machinery@speed_drill@' -- change
                },
                locations = {
                    { coords = vec3(1074.89, -1988.19, 30.89), rotation = vec3(0.0, 0.0, 0.0) },
                },
            }
        }
    },
    peds = {
        style = 'ox_lib',    -- 'ox_inventory' or 'ox_lib'
        moneyItem = 'money', -- which item to use for sale stashes
        locations = {
            {
                name = 'ore_vendor_1',
                label = 'Ore Vendor',
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Ore Vendor',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                coords = vec4(1075.2479, -1992.1158, 29.8811, 0),
                pedModel = `s_m_m_dockwork_01`,
                pedAnim = {
                    anim = 'base',
                    dict = 'amb@world_human_stand_mobile@male@text@enter',
                },
                pedScenario = 'WORLD_HUMAN_STANDING_MOBILE', -- takes priority over animations
                buys = {
                    copper_ore = 10,
                    iron_ore = 15,
                    gold_ore = 25,
                    metalscrap = 5,
                    copper = 20,
                    uncut_emerald = 50,
                    uncut_ruby = 50,
                    uncut_sapphire = 50,
                    uncut_diamond = 100,
                },
                sells = {
                    red40_pickaxe = 100,
                    red40_drill = 500,
                    red40_laserdrill = 1000,
                    red40_pan = 50,
                    red40_sifter = 200,
                    red40_drillbit = 25,
                    red40_carbidedrillbit = 100,
                }
            }
        }
    }
}