/*---------------------------------------------------------------------------
DarkRP hooks
---------------------------------------------------------------------------*/
function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:playerBuyDoor(ply, ent)
	if ply:Team() == TEAM_HOBO then
		return false, DarkRP.getPhrase("door_hobo_unable")
	end

	return true
end

function GM:getDoorCost(ply, ent)
	return GAMEMODE.Config.doorcost ~= 0 and GAMEMODE.Config.doorcost or 30
end

function GM:getVehicleCost(ply, ent)
	return GAMEMODE.Config.vehiclecost ~= 0 and  GAMEMODE.Config.vehiclecost or 40
end

function GM:canDropWeapon(ply, weapon)
	if not IsValid(weapon) then return false end
	local class = string.lower(weapon:GetClass())
	local team = ply:Team()

	if not GAMEMODE.Config.dropspawnedweapons then
	if RPExtraTeams[team] and table.HasValue(RPExtraTeams[team].weapons, class) then return false end
	end

	if self.Config.DisallowDrop[class] then return false end

	if not GAMEMODE.Config.restrictdrop then return true end

	for k,v in pairs(CustomShipments) do
		if v.entity ~= class then continue end

		return true
	end

	return false
end

function GM:ShowTeam(ply)
end

function GM:PlayerDeath(ply, weapon, killer)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerDeath then
		RPExtraTeams[ply:Team()].PlayerDeath(ply, weapon, killer)
	end

	if GAMEMODE.Config.deathblack then
		SendUserMessage("blackScreen", ply, true)
	end

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end

	if GAMEMODE.Config.showdeaths then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	end

	ply:Extinguish()

	if ply:InVehicle() then ply:ExitVehicle() end

	if ply:isArrested() and not GAMEMODE.Config.respawninjail  then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GAMEMODE.Config.jailtimer - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("died_in_jail", ply:Nick()))
		end
		DarkRP.notify(ply, 4, 4, DarkRP.getPhrase("dead_in_jail"))
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + math.Clamp(GAMEMODE.Config.respawntime, 0, 10)
	end
	ply.DeathPos = ply:GetPos()

	if GAMEMODE.Config.dropmoneyondeath then
		local amount = GAMEMODE.Config.deathfee
		if not ply:canAfford(GAMEMODE.Config.deathfee) then
			amount = ply:getDarkRPVar("money")
		end

		if amount > 0 then
			ply:addMoney(-amount)
			DarkRP.createMoneyBag(ply:GetPos(), amount)
		end
	end

	if IsValid(ply) and (ply ~= killer or ply.Slayed) and not ply:isArrested() then
		ply:setDarkRPVar("wanted", nil)
		ply.DeathPos = nil
		ply.Slayed = false
	end

	ply:GetTable().ConfiscatedWeapons = nil

	local KillerName = (killer:IsPlayer() and killer:Nick()) or tostring(killer)

	local WeaponName = IsValid(weapon) and ((weapon:IsPlayer() and IsValid(weapon:GetActiveWeapon()) and weapon:GetActiveWeapon():GetClass()) or weapon:GetClass()) or "unknown"
	if IsValid(weapon) and weapon:GetClass() == "prop_physics" then
		WeaponName = weapon:GetClass() .. " (" .. (weapon:GetModel() or "unknown") .. ")"
	end

	if killer == ply then
		KillerName = "Himself"
		WeaponName = "suicide trick"
	end

	DarkRP.log(ply:Nick() .. " was killed by " .. KillerName .. " with a " .. WeaponName, Color(255, 190, 0))
end

local function initPlayer(ply)
	timer.Simple(5, function()
		if not IsValid(ply) then return end

		if GetGlobalBool("DarkRP_Lockdown") then
			SetGlobalBool("DarkRP_Lockdown", true) -- so new players who join know there's a lockdown, is this bug still there?
		end
	end)

	ply:initiateTax()

	ply:updateJob(team.GetName(GAMEMODE.DefaultTeam))
	ply:setSelfDarkRPVar("salary", RPExtraTeams[GAMEMODE.DefaultTeam].salary or GAMEMODE.Config.normalsalary)

	ply:GetTable().Ownedz = { }
	ply:GetTable().OwnedNumz = 0

	ply:GetTable().LastLetterMade = CurTime() - 61
	ply:GetTable().LastVoteCop = CurTime() - 61

	ply:SetTeam(GAMEMODE.DefaultTeam)

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	for i = 1, #RPExtraTeams do
		if GAMEMODE.Config.restrictallteams then
			ply:teamBan(i, 0)
		end
	end
end

function GM:PlayerSpawnSENT(ply, class)
	return checkAdminSpawn(ply, "adminsents", "gm_spawnsent") and self.BaseClass:PlayerSpawnSENT(ply, class) and not ply:isArrested()
end

function GM:PlayerSpawnedSENT(ply, ent)
	self.BaseClass:PlayerSpawnedSENT(ply, ent)
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") spawned SENT "..ent:GetClass(), Color(255, 255, 0))
end

function GM:PlayerSpawnVehicle(ply, model, class, info)
	return checkAdminSpawn(ply, "adminvehicles", "gm_spawnvehicle") and self.BaseClass:PlayerSpawnVehicle(ply, model, class, info) and not ply:isArrested()
end

function GM:PlayerSpawnedVehicle(ply, ent)
	self.BaseClass:PlayerSpawnedVehicle(ply, ent)
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") spawned Vehicle "..ent:GetClass(), Color(255, 255, 0))
end

function GM:PlayerSpawnNPC(ply, type, weapon)
	return checkAdminSpawn(ply, "adminnpcs", "gm_spawnnpc") and self.BaseClass:PlayerSpawnNPC(ply, type, weapon) and not ply:isArrested()
end

function GM:PlayerSpawnedNPC(ply, ent)
	self.BaseClass:PlayerSpawnedNPC(ply, ent)
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") spawned NPC "..ent:GetClass(), Color(255, 255, 0))
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") has joined the game", Color(0, 130, 255))
	ply.DarkRPVars = ply.DarkRPVars or {}
	ply:restorePlayerData()
	initPlayer(ply)
	ply.SID = ply:UserID()

	timer.Simple(1, function()
		if not IsValid(ply) then return end
		local group = GAMEMODE.Config.DefaultPlayerGroups[ply:SteamID()]
		if group then
			ply:SetUserGroup(group)
		end
	end)

	for k,v in pairs(ents.GetAll()) do
		if IsValid(v) and v:GetTable() and v.deleteSteamID == ply:SteamID() and v.DarkRPItem then
			v.SID = ply.SID
			if v.Setowning_ent then
				v:Setowning_ent(ply)
			end
			v.deleteSteamID = nil
			timer.Destroy("Remove"..v:EntIndex())
			ply:addCustomEntity(v.DarkRPItem)

			if v.dt and v.Setowning_ent then v:Setowning_ent(ply) end
		end
	end
end

function GM:PlayerSelectSpawn(ply)
	local spawn = self.BaseClass:PlayerSelectSpawn(ply)

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSelectSpawn then
		RPExtraTeams[ply:Team()].PlayerSelectSpawn(ply, spawn)
	end

	local POS
	if spawn and spawn.GetPos then
		POS = spawn:GetPos()
	else
		POS = ply:GetPos()
	end

	local CustomSpawnPos = DarkRP.retrieveTeamSpawnPos(ply:Team())
	if GAMEMODE.Config.customspawns and not ply:isArrested() and CustomSpawnPos and next(CustomSpawnPos) ~= nil then
		POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
	end

	-- Spawn where died in certain cases
	if GAMEMODE.Config.strictsuicide and ply:GetTable().DeathPos then
		POS = ply:GetTable().DeathPos
	end

	if ply:isArrested() then
		POS = DarkRP.retrieveJailPos() or ply:GetTable().DeathPos -- If we can't find a jail pos then we'll use where they died as a last resort
	end

	-- Make sure the player doesn't get stuck in something
	POS = DarkRP.findEmptyPos(POS, {ply}, 600, 30, Vector(16, 16, 64))

	return spawn, POS
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)

	player_manager.SetPlayerClass(ply, "player_DarkRP")

	ply:SetNoCollideWithTeammates(false)
	ply:CrosshairEnable()
	ply:UnSpectate()
	ply:SetHealth(tonumber(GAMEMODE.Config.startinghealth) or 100)

	-- Kill any colormod
	SendUserMessage("blackScreen", ply, false)

	if GAMEMODE.Config.babygod and not ply.IsSleeping and not ply.Babygod then
		timer.Destroy(ply:EntIndex() .. "babygod")

		ply.Babygod = true
		ply:GodEnable()
		local c = ply:GetColor()
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor(Color(c.r, c.g, c.b, 100))
		timer.Create(ply:EntIndex() .. "babygod", GAMEMODE.Config.babygodtime or 0, 1, function()
			if not IsValid(ply) or not ply.Babygod then return end
			ply.Babygod = nil
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:SetColor(Color(c.r, c.g, c.b, c.a))
			ply:GodDisable()
		end)
	end
	ply.IsSleeping = false

	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
	if ply:isCP() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp)
	end

	if ply:isArrested() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	end

	ply:Extinguish()
	if ply:GetActiveWeapon() and IsValid(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish()
	end

	for k,v in pairs(ents.FindByClass("predicted_viewmodel")) do -- Money printer ignite fix
		v:Extinguish()
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:changeTeam(GAMEMODE.DefaultTeam)
	end

	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)

	local _, pos = self:PlayerSelectSpawn(ply)
	ply:SetPos(pos)

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSpawn then
		RPExtraTeams[ply:Team()].PlayerSpawn(ply)
	end

	ply:AllowFlashlight(true)

	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") spawned")
end

/*---------------------------------------------------------------------------
Remove with a delay if the player doesn't rejoin before the timer has run out
---------------------------------------------------------------------------*/
local function removeDelayed(ent, ply)
	local removedelay = GAMEMODE.Config.entremovedelay

	ent.deleteSteamID = ply:SteamID()
	timer.Create("Remove"..ent:EntIndex(), removedelay, 1, function()
		for _, pl in pairs(player.GetAll()) do
			if IsValid(pl) and IsValid(ent) and pl:SteamID() == ent.deleteSteamID then
				ent.SID = pl.SID
				ent.deleteSteamID = nil
				return
			end
		end

		SafeRemoveEntity(ent)
	end)
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")

	for k, v in pairs(ents.GetAll()) do
		local class = v:GetClass()
		for _, customEnt in pairs(DarkRPEntities) do
			if class == customEnt.ent and v.SID == ply.SID then
				removeDelayed(v, ply)
				break
			end
		end
		if v:IsVehicle() and v.SID == ply.SID then
			removeDelayed(v, ply)
		end
	end

	if ply:isMayor() then
		for _, ent in pairs(ply.lawboards or {}) do
			if IsValid(ent) then
				removeDelayed(ent, ply)
			end
		end
	end

	DarkRP.destroyVotesWithEnt(ply)

	if isMayor and GetGlobalBool("DarkRP_LockDown") then -- Stop the lockdown
		DarkRP.unLockdown(ply)
	end

	if isMayor and GAMEMODE.Config.shouldResetLaws then
		DarkRP.resetLaws()
	end

	if IsValid(ply.SleepRagdoll) then
		ply.SleepRagdoll:Remove()
	end

	ply:keysUnOwnAll()
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") disconnected", Color(0, 130, 255))

	local agenda = ply:getAgendaTable()

	-- Clear agenda
	if agenda and ply:Team() == agenda.Manager and team.NumPlayers(ply:Team()) <= 1 then
		agenda.text = nil
		for k,v in pairs(player.GetAll()) do
			if v:getAgendaTable() ~= agenda then continue end
			v:setSelfDarkRPVar("agenda", agenda.text)
		end
	end

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerDisconnected then
		RPExtraTeams[ply:Team()].PlayerDisconnected(ply)
	end
end

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 or GAMEMODE.Config.realisticfalldamage then
		if GAMEMODE.Config.falldamagedamper then return flFallSpeed / GAMEMODE.Config.falldamagedamper else return flFallSpeed / 15 end
	else
		if GAMEMODE.Config.falldamageamount then return GAMEMODE.Config.falldamageamount else return 10 end
	end
end
local InitPostEntityCalled = false
function GM:InitPostEntity()
	InitPostEntityCalled = true

	local physData = physenv.GetPerformanceSettings()
	physData.MaxVelocity = 2000
	physData.MaxAngularVelocity	= 3636

	physenv.SetPerformanceSettings(physData)

	-- Scriptenforcer enabled by default? Fuck you, not gonna happen.
	if not GAMEMODE.Config.disallowClientsideScripts then
		game.ConsoleCommand("sv_allowcslua 1\n")
	end
	game.ConsoleCommand("physgun_DampingFactor 0.9\n")
	game.ConsoleCommand("sv_sticktoground 0\n")
	game.ConsoleCommand("sv_airaccelerate 100\n")
	-- sv_alltalk must be 0
	-- Note, everyone will STILL hear everyone UNLESS rp_voiceradius is 1!!!
	-- This will fix the rp_voiceradius not working
	game.ConsoleCommand("sv_alltalk 0\n")

	if GAMEMODE.Config.unlockdoorsonstart then
		for k, v in pairs(ents.GetAll()) do
			if not v:isDoor() then continue end
			v:Fire("unlock", "", 0)
		end
	end
end
timer.Simple(0.1, function()
	if not InitPostEntityCalled then
		GAMEMODE:InitPostEntity()
	end
end)