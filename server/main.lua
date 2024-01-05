local QBCore = exports['qb-core']:GetCoreObject()
local InvType = Config.CoreSettings.InventoryType


-- Functions

local function ResetHouseStateTimer(house)
    CreateThread(function()
        Wait(Config.CoreSettings.TimeToCloseDoors * 60000)
        Config.Houses[house]['opened'] = false
        for _, v in pairs(Config.Houses[house]['furniture']) do
            v['searched'] = false
        end
        TriggerClientEvent('qb-houserobbery:client:ResetHouseState', -1, house)
    end)
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-houserobbery:server:GetHouseConfig', function(_, cb)
    cb(Config.Houses)
end)

-- Events

RegisterNetEvent('qb-houserobbery:server:SetBusyState', function(cabin, house, bool)
    Config.Houses[house]['furniture'][cabin]['isBusy'] = bool
    TriggerClientEvent('qb-houserobbery:client:SetBusyState', -1, cabin, house, bool)
end)

RegisterNetEvent('qb-houserobbery:server:enterHouse', function(house)
    local src = source
    if not Config.Houses[house]['opened'] then
        ResetHouseStateTimer(house)
        TriggerClientEvent('qb-houserobbery:client:setHouseState', -1, house, true)
    end
    TriggerClientEvent('qb-houserobbery:client:enterHouse', src, house)
    Config.Houses[house]['opened'] = true
end)

RegisterNetEvent('qb-houserobbery:server:searchFurniture', function(cabin, house, perfectAttempt)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local tier = Config.Houses[house].tier
    local availableItems = Config.Rewards[tier][Config.Houses[house].furniture[cabin].type]
    local itemCount = 1
    local cashChance = math.random(1,100)
    
    if itemCount > 0 then
        for _ = 1, itemCount do
            local selectedItem = availableItems[math.random(1, #availableItems)]
            local itemInfo = QBCore.Shared.Items[selectedItem.item]       
            if InvType == 'qb' then
                player.Functions.AddItem(selectedItem.item, math.random(selectedItem.min, selectedItem.max))
            elseif InvType == 'ox' then
                exports.ox_inventory:AddItem(src,selectedItem.item, math.random(selectedItem.min, selectedItem.max))

                if exports.ox_inventory:CanCarryItem(src, selectedItem.item, math.random(selectedItem.min, selectedItem.max)) then
                    exports.ox_inventory:AddItem(src,selectedItem.item, math.random(selectedItem.min, selectedItem.max))
                else
                    TriggerClientEvent('lusty94_houserobbery:client:cantCarry', src)
                end
            end
            if cashChance <= Config.CoreSettings.ChanceToFindCashIfPerfect then
                if perfectAttempt then
                    if InvType == 'qb' then
                        player.Functions.AddMoney('cash', math.random(5,10))
                    elseif InvType == 'ox' then
                        exports.ox_inventory:AddItem(src, 'money', math.random(5,10))
                    end
                end
            end
            TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, 'add')
            Wait(500)
        end
    else
        TriggerClientEvent('lusty94_houserobbery:client:EmptyNotify', src)
    end

    Config.Houses[house]['furniture'][cabin]['searched'] = true
    TriggerClientEvent('qb-houserobbery:client:setCabinState', -1, house, cabin, true)
end)

RegisterNetEvent('qb-houserobbery:server:removeAdvancedLockpick', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if InvType == 'qb' then
        Player.Functions.RemoveItem('advancedlockpick', 1)
    elseif InvType == 'ox' then
        exports.ox_inventory:RemoveItem(src,'advancedlockpick', 1)
    end
end)

RegisterNetEvent('qb-houserobbery:server:removeLockpick', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if InvType == 'qb' then
        Player.Functions.RemoveItem('lockpick', 1)
    elseif InvType == 'ox' then
        exports.ox_inventory:RemoveItem(src,'lockpick', 1)
    end
end)
