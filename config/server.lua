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
                minXp = 0,  -- Minimum XP required to use this tool
                maxXp = 10, -- Stop earning xp after this level
                minUseTime = 5000,  -- Minimum time in milliseconds to use the tool
                maxUseTime = 10000, -- Maximum time in milliseconds to use the tool
                prop = `prop_tool_pickaxe`,
                bone = 57005,
                offset = vec3(0.09, -0.53, -0.22),
                rotation = vec3(252.0, 180.0, 0.0),
                anim = {
                    anim = 'base',
                    dict = 'amb@world_human_hammering@male@base'
                },
                type = 'pickaxe'
            },
            red40_drill = {
                level = 2,
                damage = true,
                minXp = 10,
                maxXp = 100,
                minUseTime = 3000,  -- Minimum time in milliseconds to use the tool
                maxUseTime = 7000,  -- Maximum time in milliseconds to use the tool
                prop = `hei_prop_heist_drill`,
                offset = vec3(0.14, 0, -0.01),
                rotation = vec3(90.0, -90.0, 180.0),
                anim = {
                    anim = "drill_straight_fail",
                    dict = "anim@heists@fleeca_bank@drilling"
                },
                type = 'drill'
            },
            red40_laserdrill = {
                level = 3,
                damage = false,
                minXp = 20,
                maxXp = 200,
                minUseTime = 1000,  -- Minimum time in milliseconds to use the tool
                maxUseTime = 5000,  -- Maximum time in milliseconds to use the tool
                prop = `ch_prop_laserdrill_01a`,
                offset = vec3(0.14, 0, -0.01),
                rotation = vec3(90.0, -90.0, 180.0),
                anim = {
                    anim = "drill_straight_fail",
                    dict = "anim@heists@fleeca_bank@drilling"
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
                        { coords = vec3(1074.89, -1988.19, 30.89), rotation = vec3(0.0, 0.0, 0.0) },
                    }
                },
                ore_locations = {
                    {
                        coords = {
                            vec3(1074.89, -1988.19, 30.89)
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
                maximumOres = 5,        -- Maximum number of ores that can be present at the location at any given time
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
                minXp = 0,  -- Minimum XP required to use this tool
                maxXp = 10, -- Stop earning xp after this level
            },
            red40_sifter = {
                level = 2,
                damage = false,
                minXp = 10,
                maxXp = 100,
            },
        },
        durability = function()
            return math.random(1, 5) -- Random durability loss between 1 and 5 for each use
        end,
        locations = {
            {
                name = 'panning_location_1',
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Panning Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                points = {
                    vec3(1074.89, -1988.19, 30.89),
                    vec3(1074.89, -1987.19, 30.89),
                    vec3(1074.89, -1986.19, 30.89),
                    vec3(1074.89, -1985.19, 30.89),
                },
                minTime = 5000,  -- Minimum time in milliseconds to pan
                maxTime = 10000, -- Maximum time in milliseconds to pan
                rewards = 'pan_loot',
                min = 1,
                max = 3
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
        locations = {
            {
                name = 'washing_location_1',
                enabled = true,
                blip = {
                    enable = true,
                    name = 'Washing Spot',
                    sprite = 436,
                    color = 1,
                    coords = vec3(1074.89, -1988.19, 30.89)
                },
                points = {
                    vec3(1074.89, -1988.19, 30.89),
                    vec3(1074.89, -1987.19, 30.89),
                    vec3(1074.89, -1986.19, 30.89),
                    vec3(1074.89, -1985.19, 30.89),
                },
                minTime = 5000,  -- Minimum time in milliseconds to wash
                maxTime = 10000, -- Maximum time in milliseconds to wash
                rewards = 'wash_loot',
                min = 1,
                max = 3
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
                minXp = 0,  -- Minimum XP required to use this tool
                maxXp = 10, -- Stop earning xp after this level
                minTime = 5000,  -- Minimum time in milliseconds to crack
                maxTime = 10000, -- Maximum time in milliseconds to crack
            },
            red40_carbidedrillbit = {
                level = 2,
                damage = true,
                minXp = 10,
                maxXp = 100,
                minTime = 3000,  -- Minimum time in milliseconds to crack
                maxTime = 7000,  -- Maximum time in milliseconds to crack
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
                    anim = 'operate_02_hi_amy_skater_01', -- change
                    dict = 'anim@amb@machinery@speed_drill@' -- change
                },
                locations = {
                    { coords = vec3(1074.89, -1988.19, 30.89), rotation = vec3(0.0, 0.0, 0.0) },
                },
            }
        }
    },
    peds = {
        style = 'ox_inventory', -- 'ox_inventory' or 'ox_lib'
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
                coords = vec4(1074.89, -1988.19, 30.89, 0),
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