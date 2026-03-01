---
description: 'FiveM Lua development standards and best practices'
applyTo: '**/*.lua, locales/*.json'
---

# FiveM Lua Development Instructions
Instructions for building high-quality FiveM Lua scripts with best practices and standards.

## Project Context
- Paid FiveM Lua resource for GTA V that contains code that can't be modified by the end user.
- Supports multiple frameworks: ESX, QB, QBX
- Uses `ox_lib` for shared utilities and localization
- Uses `oxmysql` for database interactions
- Prefers `ox_target` for target interactions but also design for the alternative of lib.zones for `[E]` style interactions
- Uses
This is a FiveM resource for GTA V. It is structured for compatibility with multiple frameworks (ESX, QB, QBX) and uses [ox_lib](https://github.com/overextended/ox_lib) for shared utilities and localization.

## FiveM Lua specific modifications
This runtime [imports](http://lua-users.org/wiki/LuaPowerPatches) many (small) useful changes to the Lua runtime, all bound to preprocessor flags:

#### Compound Operators:
Add ``+=, -=, *=, /=, <<=, >>=, &=, |=, and ^=`` to the language. The increment and decrement operators (``++, --``) have not been implemented due to one of those operators being reserved.

#### Safe Navigation:
An indexing operation that suppresses errors on accesses into undefined tables (similar to the safe-navigation operators in C#, Kotlin, etc.), e.g.,

```lua
t?.x?.y == nil
```

#### In Unpacking:
Support for unpacking named values from tables using the ``in`` keyword, e.g,

```lua
local a,b,c in t
```

is functionally equivalent to:

```lua
local a,b,c = t.a,t.b,t.c
```

#### Set Constructors:
Syntactic sugar to improve the syntax for specifying sets, i.e.,

```lua
t = { .a, .b }
```

is functionally equivalent to:

```lua
t = { a = true, b = true }
```

## Architecture & Key Components
- **fxmanifest.lua**: Declares resource metadata, dependencies, and script entry points.
- **bridge/**: Contains framework-specific glue code for ESX, QB, and QBX (client/server). Use these to interface with player data, notifications, and commands.
- **client/**: Main client logic.
- **server/**: Main server logic.
- **config/**: Centralized configuration for client, server, and shared settings. Always use these for tuning gameplay parameters.
- **locales/**: Localization files (JSON) for multi-language support.
- **stream/**: Contains models, textures, and map data if the resource includes custom assets.

## Developer Workflows
- **Linting**: Run lint checks via GitHub Actions (`.github/workflows/lint.yml`). Uses `iLLeniumStudios/fivem-lua-lint-action@v2` with custom libraries. Linting is triggered on push and PRs to the default branch.
- **Configuration**: All gameplay and system tuning should be done in `config/` files. Do not hardcode values in scripts.
- **Framework Integration**: Use the appropriate bridge file for framework-specific logic. Example: `bridge/client/esx.lua` for ESX notifications.
- **Escrow Ignore**: Files listed in `fxmanifest.lua` under `escrow_ignore` are excluded from asset escrow and intended for public modification.

## Patterns & Conventions
- **Require Configs**: Always load configuration via `require 'config.[name]'`.
- **Bridge**: Functions within bridges are specified as global functions to permit their use across the context of the resource. It is important to remember that while the language server can't differentiate between client and server, the bridge files are loaded in the appropriate context.
- **Debug & Error Printing** `lib.print.error` for errors and `lib.print.debug` for debug messages. `lib.print.info` for general information.
- **Localization**: Use `locale()` for all user-facing messages.
- **Keybinds**: Client keybinds are registered via `lib.addKeybind`.
- **Commands**: Server commands are registered via `lib.addCommand` see [documentation](https://coxdocs.dev/ox_lib/Modules/AddCommand/Server).
- **Callbacks**: Use callbacks where appropriate for waiting for cross network traffic.
- **Exports**: Use exports for shared functionality between resources on the same side of the network. We register exports with `exports('exportName', exportFunction)`.
- **Net Events**: Use `TriggerClientEvent` and `TriggerServerEvent` for cross-network communication. Use `RegisterNetEvent` to listen for events from cross-network. Use `AddEventHandler` to handle client-client or server-server event traffic.
- **Server Events**: `RegisterNetEvent` on the server side is provided with a hidden source parameter, which is the player ID of the client that triggered the event. Remember to localize where appropriate such as if we perform asynchronous operations i.e `CreateThread` or `SetTimeout`.

## Integration Points
- **ox_lib**: Performance enhancing library for FiveM Lua scripts. Use it for utilities, localization, and shared functionality. Documentation is located [here](https://coxdocs.dev/ox_lib/). If you are unsure on a specific implementation, refer to the documentation or ask the user.
- **oxmysql**: Database interaction library. Use it for all database queries and transactions.
- **Frameworks**: ESX, QB, QBX frameworks are goals for support. If a bridge file for one of these frameworks does not exist then that framework is not supported. Use the bridge files to interface with player data and notifications. If you are unsure about if a function should be in the bridge ask the user.
- **FiveM Native Functions**: Use FiveM native functions for game interactions. Refer to the [FiveM Native Reference](https://docs.fivem.net/natives/) for a listing. If you have questions about a specific native function, ask the user for clarification.

## Callback examples
This is an example of a callback built using ox_lib. These are secure implementations that resist external tampering and are designed to be used in FiveM scripts. They are registered on either side of the network and can be used synchronously or asynchronously.

### Server side registration of callback
```lua
lib.callback.register('my_resource:server:getPlayerData', function(source)
    -- Fetch player data from the database or server state
    local playerData = {
        id = source,
        name = GetPlayerName(source),
        money = 1000, -- Example static value
    }
    return playerData
end)
```

### Client side registration of callback
```lua
-- Example of a client-side Lua callback
lib.callback.register('my_resource:client:getPlayerPosition', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    return { x = coords.x, y = coords.y, z = coords.z }
end)
```

### Server side usage of callback (synchronous)
```lua
local playerData = lib.callback.await('my_resource:server:getPlayerData')
lib.print.info(('Player ID: %s, Name: %s, Money: %d'):format(playerData.id, playerData.name, playerData.money))
```
### Client side usage of callback (synchronous)
```lua
-- Example of using the client-side callback
local playerPosition = lib.callback.await('my_resource:client:getPlayerPosition', source)
lib.print.info(('Player Position: X: %f, Y: %f, Z: %f'):format(playerPosition.x, playerPosition.y, playerPosition.z))
```

### Client side usage of callback (asynchronous)
```lua
-- Example of using the server-side callback asynchronously
lib.callback('my_resource:server:getPlayerData', source, function(playerData)
    lib.print.info(('Player ID: %s, Name: %s, Money: %d'):format(playerData.id, playerData.name, playerData.money))
end)
```

### Server side usage of callback (asynchronous)
```lua
-- Example of using the client-side callback asynchronously
lib.callback('my_resource:client:getPlayerPosition', source, function(playerPosition)
    lib.print.info(('Player Position: X: %f, Y: %f, Z: %f'):format(playerPosition.x, playerPosition.y, playerPosition.z))
end)
```

## Lua Best Practices
## Resource Structure & Scoping
- **Separate client/server files** into distinct folders (`client/`, `server/`)
- **Limit variable scope** to the smallest visibility needed: local → function → export → event
- **Group related code** by functionality or call structure within files
- **Use underscores in resource names** (avoid spaces and special characters for export compatibility)
- **Name files lowercase** with dashes or underscores instead of spaces

## Function Design
- **Keep functions small** and single-purpose
- **Use camelCase for local functions**, PascalCase for global functions
- **Start function names with verbs**: `getPlayerObject()` not `player()`
- **Limit parameters to 3 or fewer** - use tables for complex data
- **Avoid boolean parameters** in APIs - use separate functions instead
- **Declare anonymous functions as variables** for performance in loops
- **Use guard clauses** for early returns to reduce nesting

## Event Patterns
- **Name events**: `{resourceName}:{client/server}:{eventName}`
- **Use past tense** for event names (what happened, not what should happen)
- **Use callbacks** instead of separate events for getting data back
- **Use functions** instead of events for single-resource, non-networked operations
- **Secure network events** with `GetInvokingResource()` validation:
```lua
RegisterNetEvent('resource:client:eventName', function()
    if GetInvokingResource() then return end
    -- handle event
end)
```

## Performance Optimizations
- **Remove `Citizen.` prefix**: Use `Wait()`, `CreateThread()`, `SetTimeout()` directly
- **Use backticks for hashes**: `` `hash` `` instead of `GetHashKey('hash')`
- **Use `joaat(variable)`** instead of `GetHashKey(variable)`
- **Use Vector3 math**: `#(coord1 - coord2)` instead of `GetDistanceBetweenCoords()`
- **Use `cache.ped`** instead of `GetPlayerPed(-1)`
- **Avoid `table.insert()`** - use `myTable[#myTable + 1] = value`
- **Use numeric for loops** for arrays instead of `pairs()`
- **Cache table dereferences** and maintain array size variables for large arrays

## Variable & Table Conventions
- **ALL_CAPS for constants**, camelCase for local variables, PascalCase for globals
- **Use `_` for unused variables** in loops
- **Prefer enums over multiple booleans** for state representation
- **Imply array indices** unless keys have semantic meaning
- **Use dot notation** for constant keys, bracket notation for variable keys
- **Extract duplicate table lookups** into local variables

## Error Handling & Validation
- **Use `assert()`** instead of `if condition then error()`
- **Check pre-conditions liberally** with meaningful error messages
- **Fail loudly** for unexpected states - avoid silent failures when appropriate
- **Consider errors as return values** for expected failure cases in APIs
- **Make API functions idempotent** when possible

## Code Quality
- **Use positive boolean expressions** when possible
- **Use `or` operator** for default values instead of if-else blocks
- **Don't write `if true then return true`** - return the expression directly
- **Declare variables close** to where they're used
- **Group global variables** at the top of files
- **Use lua-language-server annotations** for exports and complex functions

## Key Files
- `fxmanifest.lua`: Resource manifest and entry points
- `config/`: All gameplay and system configuration
- `bridge/`: Framework integration
- `server/main.lua`: Core server logic
- `client/main.lua`: Core client logic
- `web`: Contains web assets if applicable. These are written in ReactJS and are built outside of the FiveM Resource. These cannot be escrowed as they are client facing code
- `locales/`: Localization
