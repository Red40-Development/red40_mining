local config = require 'config.client'
local sharedConfig = require 'config.shared'.mining

if not sharedConfig.enabled then
    return
end

local orePoints = {}
local playerState = LocalPlayer.state

RegisterNetEvent('red40_mining:client:updateMiningSpot', function(oreId, looted)
    local orePoint = orePoints[oreId]

    if orePoint then
        orePoints[oreId].looted = looted
        if looted and orePoint.propNumber then
            orePoint:onExit()
        elseif not looted then
            orePoint:onEnter()
        end
    end
end)

lib.callback.register('red40_mining:client:mineSpot', function(waitTime)
    --TODO add animation, skillcheck (optional), and sounds here (tool config based)
    local success = lib.progressBar({
        duration = waitTime,
        label = locale('mining_ore'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            mouse = false,
        },
    })
    return success
end)

local function buildOrePoints(orePoint)
    local point = lib.points.new({
        coords = orePoint.coords,
        distance = 200,
        prop = orePoint.prop,
        rot = orePoint.rot,
        id = orePoint.id,
        looted = orePoint.looted,
    })
    function point:onEnter()
        if not self.looted then
            lib.requestModel(self.prop, 10000)
            self.propNumber = CreateObject(self.prop, self.coords.x, self.coords.y, self.coords.z, false, true, false)
            SetModelAsNoLongerNeeded(self.prop)
            SetEntityRotation(self.propNumber, self.rot.x, self.rot.y, self.rot.z, 2, true)
            FreezeEntityPosition(self.propNumber, true)
            SetEntityInvincible(self.propNumber, true)
        end
    end

    function point:onExit()
        if self.propNumber and DoesEntityExist(self.propNumber) then
            DeleteEntity(self.propNumber)
            self.propNumber = nil
        end
    end

    function point:nearby()
        if not self.isClosest or not playerState.red40_mining.activity == 'mining' then return end
        if not self.looted and self.currentDistance < 2 then
            if config.use3dText then
                DrawText3d({ coords = self.coords, text = locale('mine_ore_3d')})
            else
                local textOpen, text = lib.isTextUIOpen()
                textOpen = textOpen and text == locale('mine_ore')
                if not textOpen then
                    lib.showTextUI(locale('mine_ore'))
                end
            end
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('red40_mining:server:startMining', self.id)
            end
        else
            local textOpen, text = lib.isTextUIOpen()
            if textOpen and text == locale('mine_ore') then
                lib.hideTextUI()
            end
        end
    end

    orePoints[orePoint.id] = point
end


CreateThread(function()
    local points = lib.callback.await('red40_mining:server:getMiningPoints')

    for i = 1, #points do
        local point = points[i]
        buildOrePoints(point)
    end
end)

