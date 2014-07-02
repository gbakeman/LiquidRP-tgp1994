/*---------------------------------------------------------------------------
DarkRP hooks
---------------------------------------------------------------------------*/

function GM:CanDropWeapon(ply, weapon)
	if not IsValid(weapon) then return false end
	local class = string.lower(weapon:GetClass())
	if self.Config.DisallowDrop[class] then return false end

	if not GAMEMODE.Config.restrictdrop then return true end

	for k,v in pairs(CustomShipments) do
		if v.entity ~= class then continue end

		return true
	end

	return false
end

function GM:DatabaseInitialized()
	FPP.Init()
	DarkRP.initDatabase()
end

/*---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------*/

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end
	if (ply:GetCount("Props") > 30 and !ply:IsVIP()) then
		return Notify(ply, 0, 5, "Prop limit reached. Become VIP for more props!")
	elseif (ply:GetCount("Props") > 70) then
		return Notify(ply, 0, 5, "Prop limit reached (70 props for donating!)")
	end
	
	-- If prop spawning is enabled or the user has admin or prop privileges
	local allowed = ((GAMEMODE.Config.propspawning or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_prop")) or ply:IsAdmin()) and true) or false

	if RPArrestedPlayers[ply:SteamID()] then return false end
	model = string.gsub(tostring(model), "\\", "/")
	if string.find(model,  "//") then Notify(ply, 1, 4, "You can't spawn this prop as it contains an invalid path. " ..model) 
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") tried to spawn prop with an invalid path "..model) return false end

	if allowed then
		if !ply:IsVIP() then
			if GAMEMODE.Config.proppaying then
				if ply:CanAfford(GAMEMODE.Config.propcost) then
					Notify(ply, 0, 4, "Deducted " .. CUR .. GAMEMODE.Config.propcost)
					ply:addMoney(-GAMEMODE.Config.propcost)
					return true
				else
					Notify(ply, 1, 4, "Need " .. CUR .. GAMEMODE.Config.propcost)
					return false
				end
			else
				return true --Allow regular players to spawn props
			end
		else
			Notify(ply, 0, 4, "Free prop! (VIP)")
			return true
		end
	end
	return false
end

local function canSpawnWeapon(ply, class)
	if (not GAMEMODE.Config.adminweapons == 0 and ply:IsAdmin()) or
		(GAMEMODE.Config.adminweapons == 1 and ply:IsSuperAdmin()) then
		return true
	end
	GAMEMODE:Notify(ply, 1, 4, "You can't spawn weapons")

	return false
end

function GM:PlayerSpawnSWEP(ply, model)
	return canSpawnWeapon(ply, class) and self.BaseClass:PlayerSpawnSWEP(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerGiveSWEP(ply, class, model)
	return canSpawnWeapon(ply, class) and self.BaseClass:PlayerGiveSWEP(ply, class, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
	ent.Owner = ply
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:EntityRemoved(ent)
	self.BaseClass:EntityRemoved(ent)
	if ent:IsVehicle() then
		local found = ent.Owner
		if IsValid(found) then
			found.Vehicles = found.Vehicles or 1
			found.Vehicles = found.Vehicles - 1
		end
	end
	
	for k,v in pairs(DarkRPEntities or {}) do
		if IsValid(ent) and ent:GetClass() == v.ent and ent.dt and IsValid(ent.dt.owning_ent) and not ent.IsRemoved then
			local ply = ent.dt.owning_ent
			local cmdname = string.gsub(v.ent, " ", "_")
			if not ply["max"..cmdname] then
				ply["max"..cmdname] = 1
			end
			ply["max"..cmdname] = ply["max"..cmdname] - 1
			ent.IsRemoved = true
		end
	end
end

function GM:ShowSpare1(ply)
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end

function GM:ShowSpare2(ply)
	umsg.Start("ChangeJobVGUI", ply)
	umsg.End()
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- If it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() and ent.SID then
			ent = Player(ent.SID)
		end

		-- If we know by now who killed the NPC, pay them. (NPCs kill each other apparently)
		if IsValid(ent) and ent:IsPlayer() and GAMEMODE.Config.npckillpay > 0 then
			ent:addMoney(GAMEMODE.Config.npckillpay)
			Notify(ent, 0, 4, string.format(LANGUAGE.npc_killpay, CUR .. GAMEMODE.Config.npckillpay))
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)
end


local function IsInRoom(listener, talker) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = talker:GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine( tracedata )
	
	return not trace.HitWorld
end

local threed = GM.Config.voice3D
local vrad = GM.Config.voiceradius
local dynv = GM.Config.dynamicvoice
function GM:PlayerCanHearPlayersVoice(listener, talker, other)
	if vrad and listener:GetShootPos():Distance(talker:GetShootPos()) < 550 then
		if dynv then
			if IsInRoom(listener, talker) then
				return true, threed
				else
				return false, threed
			end
		end
		return true, threed
		elseif vrad then
			return false, threed
	end
	return true, threed
end

function GM:CanTool(ply, trace, mode)
	local ent = trace.Entity

	if table.HasValue(LDRP_Protector.Restrict.Tools, string.lower(mode)) then Notify(ply, 1, 5, "This tool is restricted!") return false end
	if ent and ent:IsValid() then
		local Class = ent:GetClass()
		if table.HasValue(LDRP_Protector.NoPhysgun, string.lower(Class)) then return false end
	end
	
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity.nodupe and (mode == "weld" or
					mode == "weld_ez" or
					mode == "spawner" or
					mode == "duplicator" or
					mode == "adv_duplicator") then
			return false
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and not GAMEMODE.Config.allowvnocollide then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply.IsSleeping then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "suicide", ""))
		return false
	end
	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "suicide", ""))
		return false
	end
	return true
end

function GM:CanDrive(ply, ent)
	GAMEMODE:Notify(ply, 1, 4, "Drive disabled for now.")
	return false -- Disabled until people can't minge with it anymore
end

local allowedProperty = {
	remover = true,
	ignite = false,
	extinguish = true,
	keepupright = true,
	gravity = true,
	collision = true,
	skin = true,
	bodygroups = true
}
function GM:CanProperty(ply, property, ent)
	if allowedProperty[property] and ent:CPPICanTool(ply, "remover") then
		return true
	end

	if property == "persist" and ply:IsSuperAdmin() then
		return true
	end
	GAMEMODE:Notify(ply, 1, 4, "Property disabled for now.")
	return false -- Disabled until antiminge measure is found
end

function GM:PlayerShouldTaunt(ply, actid)
	return false
end

local CacheNames = LDRP_SH.NicerWepNames
local CacheModels = LDRP_SH.AllItems
local FilterWeps = {"weapon_real_cs_grenade","weapon_real_cs_smoke","weapon_real_cs_flash"}

function GM:DoPlayerDeath(ply, attacker, dmginfo, ...)
	if GAMEMODE.Config.dropweapondeath and ply:Team() != TEAM_POLICE and ply:Team() != TEAM_CHIEF then
		for k,v in pairs(ply:GetWeapons()) do
			local c = v:GetClass()
			if table.HasValue(FilterWeps,c) then continue end
			if CacheNames[c] then
				local weapon = ents.Create("spawned_weapon")
				weapon.ShareGravgun = true
				weapon:SetPos(ply:GetPos()+Vector(0,0,5))
				weapon:SetModel(CacheModels[c].mdl)
				weapon.weaponclass = c
				weapon.nodupe = true
				weapon.ammohacked = true
				weapon:Spawn()
			end
		end
	end
	ply:CreateRagdoll()
	ply:AddDeaths( 1 )
	if IsValid(attacker) and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if weapon.IsUsing and weapon.IsUsing != ply then return false end
	if RPArrestedPlayers[ply:SteamID()] then return false end
	if ply:IsAdmin() and GAMEMODE.Config.AdminsCopWeapons then return true end
	
	if GAMEMODE.Config.license and not ply.DarkRPVars.HasGunlicense and not ply:GetTable().RPLicenseSpawn then
		if GAMEMODE.NoLicense[string.lower(weapon:GetClass())] or not weapon:IsWeapon() then
			return true
		end
		return false
	end
	return true
end

local function removelicense(ply) 
	if not IsValid(ply) then return end 
	ply:GetTable().RPLicenseSpawn = false 
end

local function SetPlayerModel(ply, cmd, args)
	if not args[1] then return end
	ply.rpChosenModel = args[1]
end
concommand.Add("_rp_ChosenModel", SetPlayerModel)


function GM:PlayerSetModel(ply)
	local teamNr = ply:Team()
	if RPExtraTeams[teamNr] and RPExtraTeams[teamNr].PlayerSetModel then
		local model = RPExtraTeams[teamNr].PlayerSetModel(ply)
		if model then ply:SetModel(model) return end
	end

	local EndModel = ""
	if GAMEMODE.Config.enforceplayermodel then
		local TEAM = RPExtraTeams[teamNr]
		if not TEAM then return end

		if istable(TEAM.model) then
			local ChosenModel = string.lower(ply:getPreferredModel(teamNr) or "")

			local found
			for _,Models in pairs(TEAM.model) do
				if ChosenModel == string.lower(Models) then
					EndModel = Models
					found = true
					break
				end
			end

			if not found then
				EndModel = TEAM.model[math.random(#TEAM.model)]
			end
		else
			EndModel = TEAM.model
		end

		ply:SetModel(EndModel)
	else
		local cl_playermodel = ply:GetInfo("cl_playermodel")
		local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
		ply:SetModel(ply:getPreferredModel(teamNr) or modelname)
	end

	ply:SetupHands()
end

local function formatDarkRPValue(value)
	if value == nil then return "nil" end

	if isentity(value) and not IsValid(value) then return "NULL" end
	if isentity(value) and value:IsPlayer() then return string.format("Entity [%s][Player]", value:EntIndex()) end

	return tostring(value)
end

local function selectDefaultWeapon(ply)
	-- Switch to prefered weapon if they have it
	local cl_defaultweapon = ply:GetInfo("cl_defaultweapon")

	if ply:HasWeapon(cl_defaultweapon) then
		ply:SelectWeapon(cl_defaultweapon)
	end
end

function GM:PlayerLoadout(ply)
	if ply:isArrested() then return end

	player_manager.RunClass(ply, "Spawn")

	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, function() removelicense(ply) end)

	local Team = ply:Team() or 1

	if not RPExtraTeams[Team] then return end
	for k,v in pairs(RPExtraTeams[Team].weapons or {}) do
		ply:Give(v)
	end

	if RPExtraTeams[ply:Team()].PlayerLoadout then
		local val = RPExtraTeams[ply:Team()].PlayerLoadout(ply)
		if val == true then
			selectDefaultWeapon(ply)
			return
		end
	end

	for k, v in pairs(self.Config.DefaultWeapons) do
		ply:Give(v)
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_tool")) or ply:IsAdmin()  then
		ply:Give("gmod_tool")
	end

	if ply:HasPriv("rp_commands") and GAMEMODE.Config.AdminsCopWeapons then
		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		ply:Give("weaponchecker")
	end

	selectDefaultWeapon(ply)
end

local RemoveOnDisco = {"money_printer","gunlab","letter","drug_lab","drug"}
function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")
	
	for k, v in pairs( ents.GetAll() ) do
		if table.HasValue(RemoveOnDisco,v:GetClass()) and v.dt.owning_ent == ply then v:Remove() end
	end
	
	--Put the player's weapons in their inventory so it will save
	for _, v in ipairs( ply:GetWeapons() ) do
		local wepType = v:GetClass()
		if ply:CanCarry( wepType ) then
			ply:AddItem( wepType, 1 )
		end
	end
	
	ply:SavePlayer()
	GAMEMODE.vote.DestroyVotesWithEnt(ply)
	
	if ply:Team() == TEAM_MAYOR and tobool(GetConVarNumber("DarkRP_LockDown")) then -- Stop the lockdown
		UnLockdown(ply)
	end
	
	if ply.SleepRagdoll and IsValid(ply.SleepRagdoll) then
		ply.SleepRagdoll:Remove()
	end
	
	ply:UnownAll()
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") disconnected")
end