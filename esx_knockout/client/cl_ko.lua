ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
		N_0x4757f00bc6323cfe(GetHashKey("WEAPON_UNARMED"), 0.5) 
		Wait(0)
    end
end)

local knockedOut = false
local wait = 45
local count = 60
local KOCooldown = false

Citizen.CreateThread(function()
	while true do
		Wait(1)
		local myPed = GetPlayerPed(-1)
		if IsPedInMeleeCombat(myPed) then
			if GetEntityHealth(myPed) < 130 then
				SetPlayerInvincible(PlayerId(), true)
				SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
				chatnotify('(( You were knocked out, if not helped up then you will automatically wake up soon. ))')
				wait = 25
				knockedOut = true
				SetEntityHealth(myPed, 150)
			end
		end
		if knockedOut == true then
			SetPlayerInvincible(PlayerId(), true)
			DisablePlayerFiring(PlayerId(), true)
			SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
			ResetPedRagdollTimer(myPed)
			
			if wait >= 0 then
				count = count - 1
				if count == 0 then
					count = 60
					wait = wait - 1
					SetEntityHealth(myPed, GetEntityHealth(myPed)+4)
				end
			else
				SetPlayerInvincible(PlayerId(), false)
				knockedOut = false
				exports['dlrms_notify']:SendAlert('info', 'You wake up dazed and confused...')
			end
		end
	end
end)

RegisterCommand('helpup', function(source, args, user)
	if KOCooldown == false then
	local target, closestDistance = getNearPlayer()
	if target ~= -1 and closestDistance < 1.0 then
		playerheading = GetEntityHeading(GetPlayerPed(-1))
		playerlocation = GetEntityForwardVector(PlayerPedId())
		playerCoords = GetEntityCoords(GetPlayerPed(-1))
		local target_id = GetPlayerServerId(target)
		Wait(1000)
		KOCooldown = true
		TriggerServerEvent('knockout:server:help', target_id, playerheading, playerCoords, playerlocation)
		if KOCooldown == true then
			chatnotify('You must wait 3 seconds before using this command again!')
			Wait(3000)
			KOCooldown = false	
		end	
	end
end
end)

RegisterNetEvent("knockout:client:helpup")
AddEventHandler("knockout:client:helpup", function(playerheading, playercoords, playerlocation)
    local coords = GetEntityCoords(playerPed)
	playerPed = GetPlayerPed(-1)
    loadanimdict('missheist_agency3amcs_4a')
	SetEntityInvincible(playerPed, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
	SetEntityCoords(playerPed, x, y, z - .50)
	SetEntityHeading(playerPed, playerheading - 230.0)

   	TaskPlayAnim(playerPed, 'missheist_agency3amcs_4a',  'help_standup_crew2', 8.0, 8.0, 4500, 36, 0, 0, 0, 0)
	SetPlayerInvincible(PlayerId(), false)
	knockedOut = false
end)

RegisterNetEvent("knockout:client:helpingup")
AddEventHandler("knockout:client:helpingup", function()
	playerPed = GetPlayerPed(-1)
    loadanimdict('missheist_agency3amcs_4a')
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player

   	TaskPlayAnim(playerPed, 'missheist_agency3amcs_4a',  'help_standup_player1', 8.0, 8.0, 4500, 36, 0, 0, 0, 0)
	
	knockedOut = false
end)

function getPlayers()
    local playerList = {}
    for i = 0, 256 do
        local player = GetPlayerFromServerId(i)
        if NetworkIsPlayerActive(player) then
            table.insert(playerList, player)
        end
    end
    return playerList
end

function getNearPlayer()
    local players = getPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function chatnotify(text)
	TriggerEvent("chat:addMessage", {
	--template = '<div style="color: rgba(255, 99, 71, 1); font-family: arial; font-weight: bold; text-shadow: 0px 0px 3px #000000; width: fit-content; max-width: 300%; overflow: hidden; word-break: break-word; "> {0} </div>',
	template = '<div style="color: rgba(255, 99, 71, 1); width: fit-content; max-width: 300%; overflow: hidden; word-break: break-word; "> {0} </div>',
	args = { text }
	})
end

function loadanimdict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end