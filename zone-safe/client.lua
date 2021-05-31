--Zone Safe edit by Naben

local zones = {
	{ ['x'] = 231.41, ['y'] = -785.72, ['z'] = 27.52},
	{ ['x'] = 231.38, ['y'] = -876.35, ['z'] = 30.49 },
	{ ['x'] = 407.58, ['y'] = -987.89, ['z'] = 29.27 },
	{ ['x'] = -802.43, ['y'] = -223.08, ['z'] = 37.17 },
	{ ['x'] = -535.36, ['y'] = -220.56, ['z'] = 37.64 },
	{ ['x'] = -519.118, ['y'] = -249.15, ['z'] = 36.27 },
	{ ['x'] = 84.45, ['y'] = -285.87, ['z'] = 110.20 }, --------------------------------c'est les zones safe , tes libres d'en rajoutée , ou d'en supprimer
	{ ['x'] = 375.72, ['y'] = 2543.78, ['z'] = 44.62 },
	{ ['x'] = 1769.55, ['y'] = 3331.33, ['z'] = 41.32 },
    { ['x'] = 1200.41, ['y'] = -1460.74, ['z'] = 34.85 },	
    { ['x'] = 921.57, ['y'] = 49.33, ['z'] = 80.9 },	
	{ ['x'] = 1105.63, ['y'] = 213.31, ['z'] = -49.44 },	
	{ ['x'] = 1147.62, ['y'] = 265.91, ['z'] = -51.84 },	

}

local notifIn = false
local notifOut = false
local closestZone = 1


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-------                              Creating Blips at the locations. 							--------------
-------You can comment out this section if you dont want any blips showing the zones on the map.--------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
----------------   Getting your distance from any one of the locations  --------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
---------   Setting of friendly fire on and off, disabling your weapons, and sending pNoty   -----------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
	
		if dist <= 50.0 then  ------------------------------------------------------------------------------ Here you can change the RADIUS of the Safe Zone. Remember, whatever you put here will DOUBLE because 
			if not notifIn then																			  -- it is a sphere. So 50 will actually result in a diameter of 100. I assume it is meters. No clue to be honest.
				NetworkSetFriendlyFireOption(false)
				ClearPlayerWantedLevel(PlayerId())
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
                  TriggerEvent("seatbelt:notify", "~g~Tes en Zone Safe !")
					 -- text = "<b style='color:#1E90FF'>Vous êtes en zone Safe</b>",
					-- type = "success",
					-- timeout = (3000),
					-- layout = "bottomcenter",
					-- queue = "global"
				-- })
				notifIn = true
				notifOut = false
			end
		else
			if not notifOut then
				NetworkSetFriendlyFireOption(true)
				 TriggerEvent("seatbelt:notify", "~r~Tes plus en Zone Safe !")
					-- text = "<b style='color:#1E90FF'>Vous n'êtes plus en zone Safe</b>",
					-- type = "error",
					-- timeout = (3000),
					-- layout = "bottomcenter",
					-- queue = "global"
				-- })
				notifOut = true
				notifIn = false
			end
		end
		if notifIn then
		DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
		DisablePlayerFiring(player,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
      	DisableControlAction(0, 106, true) -- Disable in-game mouse controls
			if IsDisabledControlJustPressed(2, 37) then --if Tab is pressed, send error message
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) -- if tab is pressed it will set them to unarmed (this is to cover the vehicle glitch until I sort that all out)
				 TriggerEvent("seatbelt:notify", "~p~Pas d'armes ici ou j'te démarre!")
					-- text = "<b style='color:#1E90FF'>You can not use weapons in a Safe Zone</b>",
					-- type = "error",
					-- timeout = (3000),
					-- layout = "bottomcenter",
					-- queue = "global"
				-- })
			end
			if IsDisabledControlJustPressed(0, 106) then --if LeftClick is pressed, send error message
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) -- If they click it will set them to unarmed
				 TriggerEvent("seatbelt:notify", "~y~Fait pas le bandit ici ou j'te fume !")
					-- text = "<b style='color:#1E90FF'>You can not do that in a Safe Zone</b>",
					-- type = "error",
					-- timeout = (3000),
					-- layout = "bottomcenter",
					-- queue = "global"
				-- })
			end
		end
	end
end)