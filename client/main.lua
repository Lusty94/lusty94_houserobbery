local QBCore = exports['qb-core']:GetCoreObject()
local inside = false
local currentHouse = nil
local closestHouse
local inRange
local IsLockpicking = false
local houseObj = {}
local POIOffsets = nil
local usingAdvanced = false
local CurrentCops = 0
local PoliceType = Config.CoreSettings.PoliceType
local NotifyType = Config.CoreSettings.NotifyType
local TargetType = Config.CoreSettings.TargetType


CreateThread(function()
    if Config.CoreSettings.UseBlips then
        for k, v in pairs(Config.Houses) do
            v.blip = AddBlipForCoord(v['coords'].x, v['coords'].y, v['coords'].z)
            SetBlipSprite(v.blip, 186)
            SetBlipDisplay(v.blip, 2)
            SetBlipScale(v.blip, 0.8)
            SetBlipColour(v.blip, 1)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('House Robbery')
            EndTextCommandSetBlipName(v.blip)
        end
    end
end)


local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function PoliceEntryNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('There Might Be Someone Inside, Please Be Careful!', "primary", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Warning!', 'There Might Be Someone Inside, Please Be Careful!', 2500, 'warning', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('inform', 'There Might Be Someone Inside, Please Be Careful!')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Warning!', 'There Might Be Someone Inside, Please Be Careful!', 'warning', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Warning!', description = 'There Might Be Someone Inside, Please Be Careful!', type = 'warning' })
	end
end

function EntryNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('Successfully Picked The Lock!', "success", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Success!', 'Successfully Picked The Lock!', 2500, 'success', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('inform', 'Successfully Picked The Lock!')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Success!', 'Successfully Picked The Lock!', 'success', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Success!', description = 'Successfully Picked The Lock!', type = 'success' })
	end
end

function FailureNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('Lock Pick Failed!', "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'Lock Pick Failed!', 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'Lock Pick Failed!')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'Lock Pick Failed!', 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'Lock Pick Failed!', type = 'error' })
	end
end

function CancelNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('Failed', "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'Failed', 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'Failed')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'Failed', 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'Failed', type = 'error' })
	end
end

function WrongTimeNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('Come Back Between: '..Config.CoreSettings.MinTime..' And '..Config.CoreSettings.MaxTime, "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'Come Back Between: '..Config.CoreSettings.MinTime..' And '..Config.CoreSettings.MaxTime, 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'Come Back Between: '..Config.CoreSettings.MinTime..' And '..Config.CoreSettings.MaxTime)
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'Come Back Between: '..Config.CoreSettings.MinTime..' And '..Config.CoreSettings.MaxTime, 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'Come Back Between: '..Config.CoreSettings.MinTime..' And '..Config.CoreSettings.MaxTime, type = 'error' })
	end
end

function MissingItemsNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('You Are Missing Items', "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'You Are Missing Items', 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'You Are Missing Items')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'You Are Missing Items', 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'You Are Missing Items', type = 'error' })
	end
end

function DoorAlreadyOpenNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('This Door Is Already Unlocked', "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'This Door Is Already Unlocked', 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'This Door Is Already Unlocked')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'This Door Is Already Unlocked', 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'This Door Is Already Unlocked', type = 'error' })
	end
end

function NotEnoughPoliceNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('Not Enough Police On Duty - Minimum Required: '..Config.CoreSettings.PoliceRequired, "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'Not Enough Police On Duty - Minimum Required: '..Config.CoreSettings.PoliceRequired, 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'Not Enough Police On Duty - Minimum Required: '..Config.CoreSettings.PoliceRequired)
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'Not Enough Police On Duty - Minimum Required: '..Config.CoreSettings.PoliceRequired, 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'Not Enough Police On Duty - Minimum Required: '..Config.CoreSettings.PoliceRequired, type = 'error' })
	end
end


function EmptyNotify()
    if NotifyType == 'qb' then
		QBCore.Functions.Notify('You Found Nothing Here!', "error", 2500)
	elseif NotifyType == 'okok' then
		exports['okokNotify']:Alert('Error!', 'You Found Nothing Here!', 2500, 'error', true)
	elseif NotifyType == 'mythic' then
		exports['mythic_notify']:DoHudText('error', 'You Found Nothing Here!')
	elseif NotifyType == 'boii' then
		exports['boii_ui']:notify('Error!', 'You Found Nothing Here!', 'error', 2500)
	elseif NotifyType == 'ox' then
		lib.notify({ title = 'Error!', description = 'You Found Nothing Here!', type = 'error' })
	end
end

RegisterNetEvent('lusty94_houserobbery:client:EmptyNotify', function()
    EmptyNotify()
end)

RegisterNetEvent('lusty94_houserobbery:client:cantCarry', function()
    if NotifyType == 'qb' then
        QBCore.Functions.Notify('You Cant Carry Anymore of This Item!', "error", Config.CoreSettings.Notify.Length.Error)
    elseif NotifyType == 'okok' then
        exports['okokNotify']:Alert('No Space!', 'You Cant Carry Anymore of This Item!', Config.CoreSettings.Notify.Length.Error, 'error', Config.CoreSettings.Notify.Sound)
    elseif NotifyType == 'mythic' then
        exports['mythic_notify']:DoHudText('error', 'You Cant Carry Anymore of This Item!')
    elseif NotifyType == 'boii' then
        exports['boii_ui']:notify('No Space!', 'You Cant Carry Anymore of This Item!', 'error', Config.CoreSettings.Notify.Length.Error)
    elseif NotifyType == 'ox' then
        lib.notify({ title = 'No Space!', description = 'You Cant Carry Anymore of This Item!', type = 'error' })
    end
end)


local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do Wait(5) end
end

local function openHouseAnim()
    loadAnimDict('anim@heists@keycard@')
    TaskPlayAnim(PlayerPedId(), 'anim@heists@keycard@', 'exit', 5.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(400)
    ClearPedTasks(PlayerPedId())
end

local function enterRobberyHouse(house)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_open', 0.25)
    openHouseAnim()
    Wait(250)
    local coords = { x = Config.Houses[house].coords.x, y = Config.Houses[house].coords.y, z = Config.Houses[house].coords.z - Config.CoreSettings.MinZOffset }
    local data = exports['qb-interior']:CreateHouseRobbery(coords)
    if not data then return end
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    currentHouse = house
    Wait(500)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if QBCore.Functions.GetPlayerData().job.name == "police"  then 
        PoliceEntryNotify()
	end
end

local function leaveRobberyHouse(house)
    local ped = PlayerPedId()
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_open', 0.25)
    openHouseAnim()
    Wait(250)
    DoScreenFadeOut(250)
    Wait(500)
    exports['qb-interior']:DespawnInterior(houseObj, function()
        TriggerEvent('qb-weathersync:client:EnableSync')
        Wait(250)
        DoScreenFadeIn(250)
        SetEntityCoords(ped, Config.Houses[house]['coords']['x'], Config.Houses[house]['coords']['y'], Config.Houses[house]['coords']['z'] + 0.5)
        SetEntityHeading(ped, Config.Houses[house]['coords']['h'])
        inside = false
        currentHouse = nil
    end)
end

local function alertCops()
    if math.random(1,100) < Config.CoreSettings.ChanceToAlertPolice then
        if PoliceType == 'qb' then
        TriggerServerEvent('police:server:policeAlert', 'House Robbery In Progress!')
        elseif PoliceType == 'ps' then
            exports['ps-dispatch']:HouseRobbery()
        end
    end
end

local function lockpickFinish(success)
    ClearPedTasks(PlayerPedId())
    if success then
        EntryNotify()
        TriggerServerEvent('qb-houserobbery:server:enterHouse', closestHouse)
    else
        if usingAdvanced then
            if math.random(1, 100) <= Config.CoreSettings.ChanceToBreakAdvancedLockPick then
                TriggerServerEvent('qb-houserobbery:server:removeAdvancedLockpick')
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['advancedlockpick'], 'remove')
            end
        else
            if math.random(1, 100) <= Config.CoreSettings.ChanceToBreakLockPick then
                TriggerServerEvent('qb-houserobbery:server:removeLockpick')
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['lockpick'], 'remove')
            end
        end
        FailureNotify()
    end
end

local function searchCabin(cabin, perfectAttempt)
    local coords = GetEntityCoords(PlayerPedId())
    local screwdriver = CreateObject('prop_tool_screwdvr03', coords, true, false, false)
    AttachEntityToEntity(screwdriver, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, 0.1, 0.06, 124.0, 0.0, 16.0, true, true, false, false, 1, true)
    local ped = PlayerPedId()
    if math.random(1, 100) <= 85 and not QBCore.Functions.IsWearingGloves() then
        local pos = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('evidence:server:CreateFingerDrop', pos) -- only for qb-policejob i think? if using another police resource change fingerprint event here
    end
    loadAnimDict('mini@repair')
    TaskPlayAnim(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 8.0, 8.0, -1, 17, 0, false, false, false)
    TriggerServerEvent('qb-houserobbery:server:SetBusyState', cabin, currentHouse, true)
    IsLockpicking = true
    Wait(1500)
    exports['boii_minigames']:skill_bar({
        style = 'default', -- Style template
        icon = 'fa-solid fa-lock-open', -- Any font-awesome icon; will use template icon if none is provided
        orientation = 1, -- Orientation of the bar; 1 = horizontal centre, 2 = vertical right.
        area_size = 10, -- Size of the target area in %
        perfect_area_size = 2, -- Size of the perfect area in %
        speed = 0.7, -- Speed the target area moves
        moving_icon = true, -- Toggle icon movement; true = icon will move randomly, false = icon will stay in a static position
        icon_speed = 3, -- Speed to move the icon if icon movement enabled; this value is / 100 in the javascript side true value is 0.03
    }, function(success)
        if success == 'perfect' then
            DeleteObject(screwdriver)
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('qb-houserobbery:server:searchFurniture', cabin, currentHouse, true)
            Config.Houses[currentHouse]['furniture'][cabin]['searched'] = true
            TriggerServerEvent('qb-houserobbery:server:SetBusyState', cabin, currentHouse, false)
            SetTimeout(500, function()
                IsLockpicking = false
            end)
        elseif success == 'success' then
            DeleteObject(screwdriver)
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('qb-houserobbery:server:searchFurniture', cabin, currentHouse)
            Config.Houses[currentHouse]['furniture'][cabin]['searched'] = true
            TriggerServerEvent('qb-houserobbery:server:SetBusyState', cabin, currentHouse, false)
            SetTimeout(500, function()
                IsLockpicking = false
            end)
        elseif success == 'failed' then
            DeleteObject(screwdriver)
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('qb-houserobbery:server:SetBusyState', cabin, currentHouse, false)
            CancelNotify()
            SetTimeout(500, function()
                IsLockpicking = false
            end)
        end
    end)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-houserobbery:server:GetHouseConfig', function(HouseConfig)
        Config.Houses = HouseConfig
    end)
end)

RegisterNetEvent('qb-houserobbery:client:ResetHouseState', function(house)
    Config.Houses[house]['opened'] = false
    for _, v in pairs(Config.Houses[house]['furniture']) do
        v['searched'] = false
    end
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('qb-houserobbery:client:enterHouse', function(house)
    enterRobberyHouse(house)
end)

RegisterNetEvent('qb-houserobbery:client:setHouseState', function(house, state)
    Config.Houses[house]['opened'] = state
end)

RegisterNetEvent('qb-houserobbery:client:setCabinState', function(house, cabin, state)
    Config.Houses[house]['furniture'][cabin]['searched'] = state
end)

RegisterNetEvent('qb-houserobbery:client:SetBusyState', function(cabin, house, bool)
    Config.Houses[house]['furniture'][cabin]['isBusy'] = bool
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced, success)
    if Config.CoreSettings.LimitTime then
        if GetClockHours() < Config.CoreSettings.MinTime or GetClockHours() > Config.CoreSettings.MaxTime then
            WrongTimeNotify()
            return
        end
    end
    usingAdvanced = isAdvanced
    if closestHouse ~= nil then
        if CurrentCops >= Config.CoreSettings.PoliceRequired then
            if not Config.Houses[closestHouse]['opened'] then
                if not usingAdvanced then
                    if Config.CoreSettings.RequireScrewdriver and not QBCore.Functions.HasItem('screwdriverset') then
                        MissingItemsNotify()
                        return
                    end
                end
                alertCops()
                loadAnimDict('mp_missheist_countrybank@nervous')
                TaskPlayAnim(PlayerPedId(), 'mp_missheist_countrybank@nervous', 'nervous_idle', 8.0, 8.0, -1, 49, 0.0, false, false, false)
                exports['boii_minigames']:safe_crack({
                    style = 'default',
                    difficulty = 1 -- Difficuly; This increases the amount of lock a player needs to unlock this scuffs out a little above 6 locks I would suggest to use levels 1 - 5 only.
                }, function(success)
                    if success then
                        ClearPedTasks(PlayerPedId())
                        lockpickFinish(success)
                    else
                        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'security-alarm', 0.5)
                        ClearPedTasks(PlayerPedId())
                        if math.random(1, 100) <= Config.CoreSettings.ChanceToLeaveFingerprints and not QBCore.Functions.IsWearingGloves() then
                            local pos = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent('evidence:server:CreateFingerDrop', pos)
                        end
                    end
                end)
            else
                DoorAlreadyOpenNotify()
            end
        else
            NotEnoughPoliceNotify()
        end
    end
end)

-- Threads

CreateThread(function()
    Wait(500)
    local requiredItems = {
        [1] = { name = QBCore.Shared.Items['advancedlockpick']['name'], image = QBCore.Shared.Items['advancedlockpick']['image'] },
        [2] = { name = QBCore.Shared.Items['screwdriverset']['name'], image = QBCore.Shared.Items['screwdriverset']['image'] },
    }
    local requiredItemsShowed = false
    while true do
        inRange = false
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)
        closestHouse = nil

        if Config.CoreSettings.LimitTime then
            if GetClockHours() < Config.CoreSettings.MinTime or GetClockHours() > Config.CoreSettings.MaxTime then
                WrongTimeNotify()
                return
            end
        end

        if not inside then
            for k, _ in pairs(Config.Houses) do
                local dist = #(PlayerPos - vector3(Config.Houses[k]['coords']['x'], Config.Houses[k]['coords']['y'], Config.Houses[k]['coords']['z']))
                if dist <= 1.5 then
                    closestHouse = k
                    inRange = true
                    if CurrentCops >= Config.CoreSettings.PoliceRequired then
                        if Config.Houses[k]['opened'] then
                            DrawText3Ds(Config.Houses[k]['coords']['x'], Config.Houses[k]['coords']['y'], Config.Houses[k]['coords']['z'], Lang:t('info.henter'))
                            if IsControlJustPressed(0, 38) then
                                enterRobberyHouse(k)
                            end
                        else
                            if not requiredItemsShowed then
                                requiredItemsShowed = true
                                TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                            end
                        end
                    end
                end
            end
        end
        if inside then Wait(1000) end
        if not inRange then
            if requiredItemsShowed then
                requiredItemsShowed = false
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
            end
            Wait(1000)
        end
        Wait(1)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if inside then
            if #(pos - vector3(Config.Houses[currentHouse]['coords']['x'] + POIOffsets.exit.x, Config.Houses[currentHouse]['coords']['y'] + POIOffsets.exit.y, Config.Houses[currentHouse]['coords']['z'] - Config.CoreSettings.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                DrawText3Ds(Config.Houses[currentHouse]['coords']['x'] + POIOffsets.exit.x, Config.Houses[currentHouse]['coords']['y'] + POIOffsets.exit.y, Config.Houses[currentHouse]['coords']['z'] - Config.CoreSettings.MinZOffset + POIOffsets.exit.z, Lang:t('info.hleave'))
                if IsControlJustPressed(0, 38) then
                    leaveRobberyHouse(currentHouse)
                end
            end
            for k, _ in pairs(Config.Houses[currentHouse]['furniture']) do
                if #(pos - vector3(Config.Houses[currentHouse]['coords']['x'] + Config.Houses[currentHouse]['furniture'][k]['coords']['x'], Config.Houses[currentHouse]['coords']['y'] + Config.Houses[currentHouse]['furniture'][k]['coords']['y'], Config.Houses[currentHouse]['coords']['z'] + Config.Houses[currentHouse]['furniture'][k]['coords']['z'] - Config.CoreSettings.MinZOffset)) < 1 then
                    if not Config.Houses[currentHouse]['furniture'][k]['searched'] then
                        if not Config.Houses[currentHouse]['furniture'][k]['isBusy'] then
                            DrawText3Ds(Config.Houses[currentHouse]['coords']['x'] + Config.Houses[currentHouse]['furniture'][k]['coords']['x'], Config.Houses[currentHouse]['coords']['y'] + Config.Houses[currentHouse]['furniture'][k]['coords']['y'], Config.Houses[currentHouse]['coords']['z'] + Config.Houses[currentHouse]['furniture'][k]['coords']['z'] - Config.CoreSettings.MinZOffset, Lang:t('info.aint') .. Config.Houses[currentHouse]['furniture'][k]['text'])
                            if not IsLockpicking then
                                if IsControlJustReleased(0, 38) then
                                    searchCabin(k)
                                end
                            end
                        else
                            DrawText3Ds(Config.Houses[currentHouse]['coords']['x'] + Config.Houses[currentHouse]['furniture'][k]['coords']['x'], Config.Houses[currentHouse]['coords']['y'] + Config.Houses[currentHouse]['furniture'][k]['coords']['y'], Config.Houses[currentHouse]['coords']['z'] + Config.Houses[currentHouse]['furniture'][k]['coords']['z'] - Config.CoreSettings.MinZOffset, Lang:t('info.hsearch'))
                        end
                    else
                        DrawText3Ds(Config.Houses[currentHouse]['coords']['x'] + Config.Houses[currentHouse]['furniture'][k]['coords']['x'], Config.Houses[currentHouse]['coords']['y'] + Config.Houses[currentHouse]['furniture'][k]['coords']['y'], Config.Houses[currentHouse]['coords']['z'] + Config.Houses[currentHouse]['furniture'][k]['coords']['z'] - Config.CoreSettings.MinZOffset, Lang:t('info.hsempty'))
                    end
                end
            end            
        end

        if not inside then
            Wait(5000)
        end
        Wait(3)
    end
end)

-- Util Command (can be commented out - used for setting new spots in the config)

RegisterCommand('gethroffset', function()
    local coords = GetEntityCoords(PlayerPedId())
    local houseCoords = vector3(
        Config.Houses[currentHouse]['coords']['x'],
        Config.Houses[currentHouse]['coords']['y'],
        Config.Houses[currentHouse]['coords']['z'] - Config.CoreSettings.MinZOffset
    )
    if inside then
        local xdist = coords.x - houseCoords.x
        local ydist = coords.y - houseCoords.y
        local zdist = coords.z - houseCoords.z
        print('X: ' .. xdist)
        print('Y: ' .. ydist)
        print('Z: ' .. zdist)
    end
end, false)
