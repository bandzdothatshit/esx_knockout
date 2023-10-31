ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('knockout:server:help')
AddEventHandler('knockout:server:help', function(targetid, playerheading, playerCoords,  playerlocation)
	_source = source
	TriggerClientEvent('knockout:client:helpup',targetid, playerheading, playerCoords, playerlocation)
	TriggerClientEvent('knockout:client:helpingup', _source)
end)