---@class xpTable
---@field level number
---@field xp number

---@class lootTable
---@field name string
---@field chance number
---@field min number
---@field max number
---@field level number

---@class animationData
---@field dict string
---@field anim string

---@class blipData
---@field name string
---@field sprite number
---@field color number
---@field scale number
---@field coords vector3

---@class locationPoint
---@field coords vector3
---@field rotation vector3

---@class miningTools
---@field level number
---@field damage boolean
---@field minXp number
---@field maxXp number
---@field minUseTime number
---@field maxUseTime number
---@field prop number|string
---@field bone number
---@field offset vector3
---@field rotation vector3
---@field type 'pickaxe' | 'drill' | 'laserdrill'
---@field anim animationData

---@class lightPoint
---@field enabled boolean
---@field prop number|string
---@field locations locationPoint[]

---@class oreLocation
---@field coords vector3[]
---@field prop number|string|boolean
---@field rotation vector3
---@field rewards string
---@field min number
---@field max number

---@class miningLocations
---@field name string
---@field enabled boolean
---@field blip blipData
---@field lights lightPoint
---@field oreLocations oreLocation[]
---@field respawnTimeMin number
---@field respawnTimeMax number

---@class Red40Mining
---@field xpTables xpTable[]
---@field lootTables table<string, lootTable[]>
---@field tools table<string, miningTools>
---@field durability function
---@field xpPerAction function
---@field locations miningLocations[]

---@class panningTools
---@field level number
---@field damage boolean
---@field minXp number
---@field maxXp number
---@field minUseTime number
---@field maxUseTime number
---@field prop number|string
---@field bone number
---@field offset vector3
---@field rotation vector3
---@field anim animationData
---@field type 'pan' | 'sifter'

---@class panningLocations
---@field name string
---@field enabled boolean
---@field debug boolean
---@field blip blipData
---@field points vector3[]
---@field rewards string
---@field thickness number?
---@field min number
---@field max number

---@class Red40Panning
---@field xpTables xpTable[]
---@field lootTables table<string, lootTable[]>
---@field durability function
---@field xpPerAction function
---@field tools table<string, panningTools>
---@field locations panningLocations[]

---@class washingTools
---@field level number
---@field minXp number
---@field maxXp number
---@field prop number|string
---@field bone number
---@field offset vector3
---@field rotation vector3
---@field rewards string
---@field min number
---@field max number

---@class washingLocations
---@field name string
---@field enabled boolean
---@field debug boolean
---@field blip blipData
---@field points vector3[]

---@class Red40Washing
---@field xpTables xpTable[]
---@field lootTables table<string, lootTable[]>
---@field xpPerAction function
---@field tools table<string, washingTools>
---@field locations washingLocations[]

---@class crackingTools
---@field level number
---@field minXp number
---@field maxXp number
---@field damage boolean
---@field minUseTime number
---@field maxUseTime number

---@class crackingItems
---@field rewards string
---@field prop number|string
---@field offset vector3
---@field rotation vector3
---@field min number
---@field max number

---@class crackingLocations
---@field name string
---@field enabled boolean
---@field blip blipData
---@field prop number|string|boolean
---@field anim animationData
---@field locations locationPoint[]

---@class Red40Cracking
---@field xpTables xpTable[]
---@field lootTables table<string, lootTable[]>
---@field durability function
---@field xpPerAction function
---@field tools table<string, crackingTools>
---@field crackableItems table<string, crackingItems>
---@field locations crackingLocations[]

---@class pedLocation
---@field name string
---@field label string
---@field coords vector3
---@field enabled boolean
---@field blip blipData
---@field pedModel number|string
---@field pedAnim animationData
---@field pedScenario string
---@field buys table<string, number>|boolean
---@field sells table<string, number>|boolean

---@class Red40Peds
---@field locations pedLocation[]
---@field style 'ox_inventory' | 'ox_lib'
---@field moneyItem string

---@class Red40Recipe
---@field output table<string, number>
---@field input table<string, number>
---@field level number

---@class smeltingLocation
---@field name string
---@field enabled boolean
---@field blip blipData
---@field prop number|string|boolean
---@field anim animationData
---@field locations locationPoint[]
---@field minUseTime number
---@field maxUseTime number
---@field smelts string[]

---@class Red40Smelting
---@field xpTables xpTable[]
---@field recipes table<string, Red40Recipe[]>
---@field xpPerAction function
---@field locations smeltingLocation[]

---@class jewelcuttingLocation
---@field name string
---@field enabled boolean
---@field blip blipData
---@field prop number|string|boolean
---@field anim animationData
---@field locations locationPoint[]
---@field minUseTime number
---@field maxUseTime number
---@field recipes string[]

---@class Red40Jewelry
---@field xpTables xpTable[]
---@field recipes table<string, Red40Recipe[]>
---@field xpPerAction function
---@field locations jewelcuttingLocation[]