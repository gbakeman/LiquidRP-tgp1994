/*---------------------------------------------------------
 Shipments
 ---------------------------------------------------------*/
local NoDrop = {} -- Drop blacklist
local AlwaysAllow = {"pickaxe","pickaxe1","pickaxevip","hammer"} -- Always allow these
local function DropWeapon(ply)

	local ent = ply:GetActiveWeapon()
	if not IsValid(ent) then return "" end
	
	local canDrop = hook.Call("CanDropWeapon", GAMEMODE, ply, ent)
	if not canDrop then
		Notify(ply, 1, 4, LANGUAGE.cannot_drop_weapon)
		return ""
	end

	local RP = RecipientFilter()
	RP:AddAllPlayers()
	
	umsg.Start("anim_dropitem", RP) 
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true
	
	timer.Simple(1, function() 
		if IsValid(ply) and IsValid(ent) and ent:GetModel() then 
			ply:DropDRPWeapon(ent)
		end 
	end)
	return ""
end
DarkRP.defineChatCommand("/drop", DropWeapon)
DarkRP.defineChatCommand("/dropweapon", DropWeapon)
DarkRP.defineChatCommand("/weapondrop", DropWeapon)

/*---------------------------------------------------------
Spawning 
 ---------------------------------------------------------*/
local function SetSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			Notify(ply, 0, 4, string.format(LANGUAGE.created_spawnpos, v.name))
		end
	end

	if t then
		DB.StoreTeamSpawnPos(t, pos)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("/setspawn", SetSpawnPos)

local function AddSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			Notify(ply, 0, 4, string.format(LANGUAGE.updated_spawnpos, v.name))
		end
	end

	if t then
		DB.AddTeamSpawnPos(t, pos)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("/addspawn", AddSpawnPos)

local function RemoveSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t
	
	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			Notify(ply, 0, 4, string.format(LANGUAGE.updated_spawnpos, v.name))
		end
	end

	if t then
		DB.RemoveTeamSpawnPos(t)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("/removespawn", RemoveSpawnPos)

/*---------------------------------------------------------
 Helps
 ---------------------------------------------------------*/
local function HelpCop(ply)
	ply:SetDarkRPVar("helpCop", not ply.DarkRPVars.helpCop)
	return ""
end
DarkRP.defineChatCommand("/cophelp", HelpCop)

local function HelpMayor(ply)
	ply:SetDarkRPVar("helpMayor", not ply.DarkRPVars.helpMayor)
	return ""
end
DarkRP.defineChatCommand("/mayorhelp", HelpMayor)

local function HelpBoss(ply)
	ply:SetDarkRPVar("helpBoss", not ply.DarkRPVars.helpBoss)
	return ""
end
DarkRP.defineChatCommand("/mobbosshelp", HelpBoss)

local function HelpAdmin(ply)
	ply:SetDarkRPVar("helpAdmin", not ply.DarkRPVars.helpAdmin)
	return ""
end
DarkRP.defineChatCommand("/adminhelp", HelpAdmin)

local function closeHelp(ply)
	ply:SetDarkRPVar("helpCop", false)
	ply:SetDarkRPVar("helpBoss", false)
	ply:SetDarkRPVar("helpMayor", false)
	ply:SetDarkRPVar("helpAdmin", false)
	return ""
end
DarkRP.defineChatCommand("/x", closeHelp)

function ShowSpare1(ply)
	ply:ConCommand("gm_showspare1\n")
end
concommand.Add("gm_spare1", ShowSpare1)

function ShowSpare2(ply)
	ply:ConCommand("gm_showspare2\n")
end
concommand.Add("gm_spare2", ShowSpare2)

function GM:ShowTeam(ply)
	umsg.Start("KeysMenu", ply)
		umsg.Bool(ply:GetEyeTrace().Entity:IsVehicle())
	umsg.End()
end

function GM:ShowHelp(ply)
	ply:SendLua([[RunConsoleCommand("__trd","start")]])
end

local function LookPersonUp(ply, cmd, args)
	if not args[1] then 
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", ""))
		return 
	end
	local P = GAMEMODE:FindPlayer(args[1])
	if not IsValid(P) then
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		return
	end
	ply:PrintMessage(2, "Nick: ".. P:Nick())
	ply:PrintMessage(2, "Steam name: "..P:SteamName())
	ply:PrintMessage(2, "Steam ID: "..P:SteamID())
end
concommand.Add("rp_lookup", LookPersonUp)

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
local function MakeLetter(ply, args, type)
	if not GAMEMODE.Config.letters then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/write / /type", ""))
		return ""
	end

	if ply.maxletters and ply.maxletters >= GAMEMODE.Config.maxletters then
		Notify(ply, 1, 4, string.format(LANGUAGE.limit, "letter"))
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)), "/write / /type"))
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	ftext = string.gsub(ftext, "\\n", "\n") .. "\n\nYours,\n"..ply:Nick()
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter.dt.owning_ent = ply
	letter.ShareGravgun = true
	letter:SetPos(trace.HitPos)
	letter.nodupe = true
	letter:Spawn()

	letter:GetTable().Letter = true
	letter.type = type
	letter.numPts = numParts

	local startpos = 1
	local endpos = 39
	letter.Parts = {}
	for k=1, numParts do
		table.insert(letter.Parts, string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	PrintMessageAll(2, string.format(LANGUAGE.created_x, ply:Nick(), "mail"))
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters + 1
	timer.Simple(600, function() if IsValid(letter) then letter:Remove() end end)
end

local function WriteLetter(ply, args)
	if args == "" then return "" end
	MakeLetter(ply, args, 1)
	return ""
end
DarkRP.defineChatCommand("/write", WriteLetter)

local function TypeLetter(ply, args)
	if args == "" then return "" end
	MakeLetter(ply, args, 2)
	return ""
end
DarkRP.defineChatCommand("/type", TypeLetter)

local function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	Notify(ply, 4, 4, string.format(LANGUAGE.cleaned_up, "mails"))
	return ""
end
DarkRP.defineChatCommand("/removeletters", RemoveLetters)

local function SetPrice(ply, args)
	if args == "" then return "" end

	local a = tonumber(args)
	if not a then return "" end
	local b = math.Clamp(math.floor(a), GAMEMODE.Config.pricemin, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 500)
	local trace = {}

	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	
	if not IsValid(tr.Entity) then Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave")) return "" end
	
	local class = tr.Entity:GetClass()
	if IsValid(tr.Entity) and (class == "gunlab" or class == "microwave" or class == "drug_lab") and tr.Entity.SID == ply.SID then
		tr.Entity.dt.price = b
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave"))
	end
	return ""
end
DarkRP.defineChatCommand("/price", SetPrice)
DarkRP.defineChatCommand("/setprice", SetPrice)

local function BuyPistol(ply, args)
	if args == "" then return "" end
	if RPArrestedPlayers[ply:SteamID()] then return "" end

	if not GAMEMODE.Config.enablebuypistol then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buy", ""))
		return ""
	end
	if GAMEMODE.Config.noguns then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buy", ""))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	
	local class = nil
	local model = nil
	
	local custom = false
	local price = 0
	for k,v in pairs(CustomShipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) then
			custom = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false			
			local RestrictBuyPistol = GAMEMODE.Config.restrictbuypistol
			if not RestrictBuyPistol or 
			(RestrictBuyPistol and (not v.allowed[1] or table.HasValue(v.allowed, ply:Team()))) then
				canbuy = true
			end
			
			if not canbuy then
				Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buy"))
				return ""
			end
		end
	end
	
	if not class then
		Notify(ply, 1, 4, string.format(LANGUAGE.unavailable, "weapon"))
		return ""
	end
	
	if not custom then
		if ply:Team() == TEAM_GUN then
			price = math.ceil(GetConVarNumber(args .. "cost") * 0.88)
		else
			price = GetConVarNumber(args .. "cost")
		end
	end
	
	if not ply:CanAfford(price) then
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "/buy"))
		return ""
	end
	
	ply:AddMoney(-price)
	
	Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, args, tostring(price)))
	
	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.nodupe = true
	weapon:Spawn()

	return ""
end
DarkRP.defineChatCommand("/buy", BuyPistol)

local function BuyShipment(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if RPArrestedPlayers[ply:SteamID()] then return "" end
	
	local found = false
	local foundKey
	for k,v in pairs(CustomShipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == b then
					canbecome = true
				end
			end
			if not canbecome then
				Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyshipment"))
				return "" 
			end
		end
	end
	
	if not found then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyshipment", args))
		return ""
	end
	
	local cost = found.price
	
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "shipment"))
		return ""
	end
	
	ply:AddMoney(-cost)
	Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, args, CUR .. tostring(cost)))
	local crate = ents.Create("spawned_shipment")
	crate.SID = ply.SID
	crate.dt.owning_ent = ply
	crate:SetContents(foundKey, found.amount, found.weight)
	
	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate.nodupe = true
	crate:Spawn()
	if found.shipmodel then
		crate:SetModel(found.shipmodel)
		crate:PhysicsInit(SOLID_VPHYSICS)
		crate:SetMoveType(MOVETYPE_VPHYSICS)
		crate:SetSolid(SOLID_VPHYSICS)
	end
	local phys = crate:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	return ""
end
DarkRP.defineChatCommand("/buyshipment", BuyShipment)

local function BuyVehicle(ply, args)
	if RPArrestedPlayers[ply:SteamID()] then return "" end
	if args == "" then return "" end
	local found = false
	for k,v in pairs(CustomVehicles) do
		if string.lower(v.name) == string.lower(args) then found = CustomVehicles[k] break end
	end
	if not found then return "" end
	if found.allowed and not table.HasValue(found.allowed, ply:Team()) then Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyvehicle")) return ""  end 
	
	if not ply.Vehicles then ply.Vehicles = 0 end
	if GAMEMODE.Config.maxvehicles ~= 0 and ply.Vehicles >= GAMEMODE.Config.maxvehicles then
		Notify(ply, 1, 4, string.format(LANGUAGE.limit, "vehicle"))
		return ""
	end
	ply.Vehicles = ply.Vehicles + 1
	
	if not ply:CanAfford(found.price) then Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "vehicle")) return "" end
	ply:AddMoney(-found.price)
	Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, found.name, CUR .. found.price))
	
	local Vehicle = list.Get("Vehicles")[found.name]
	if not Vehicle then Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "")) return "" end
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	local tr = util.TraceLine(trace)
	
	local ent = ents.Create(Vehicle.Class)
	if not ent then return "" end
	ent:SetModel(Vehicle.Model)
	if Vehicle.KeyValues then
		for k, v in pairs(Vehicle.KeyValues) do
			ent:SetKeyValue(k, v)
		end            
	end
	
	local Angles = ply:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180
	ent:SetAngles(Angles)
	ent:SetPos(tr.HitPos)
	ent.VehicleName = found.name
	ent.VehicleTable = Vehicle
	ent.Owner = ply
	ent:Spawn()
	ent:Activate()
	ent.SID = ply.SID
	ent.ClassOverride = Vehicle.Class
	if Vehicle.Members then
		table.Merge(ent, Vehicle.Members)
	end
	ent:Own(ply)
	gamemode.Call("PlayerSpawnedVehicle", ply, ent) -- VUMod compatability
	
	return ""
end
DarkRP.defineChatCommand("/buyvehicle", BuyVehicle)

local function BuyAmmo(ply, args)
	if args == "" then return "" end

	if ply:isArrested() then return "" end

	if GAMEMODE.Config.noguns then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "ammo", ""))
		return ""
	end

	local found
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		if v.ammoType == args then
			found = v
			break
		end
	end

	if not found or (found.customCheck and not found.customCheck(ply)) then
		GAMEMODE:Notify(ply, 1, 4, (found and found.CustomCheckFailMsg) or string.format(LANGUAGE.unavailable, "ammo"))
		return ""
	end

	if not ply:CanAfford(found.price) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "ammo"))
		return ""
	end

	GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, found.name, GAMEMODE.Config.currency..tostring(found.price)))
	ply:AddMoney(-found.price)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local ammo = ents.Create("spawned_weapon")
	ammo:SetModel(found.model)
	ammo.ShareGravgun = true
	ammo:SetPos(tr.HitPos)
	ammo.nodupe = true
	function ammo:PlayerUse(user, ...)
		user:GiveAmmo(found.amountGiven, found.ammoType)
		self:Remove()
		return true
	end
	ammo:Spawn()

	return ""
end
DarkRP.defineChatCommand("/buyammo", BuyAmmo, 1)

for k,v in pairs(DarkRPEntities) do
	local function buythis(ply, args)
		if RPArrestedPlayers[ply:SteamID()] then return "" end
		if type(v.allowed) == "table" and not table.HasValue(v.allowed, ply:Team()) then
			Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, v.cmd))
			return "" 
		end
		local cmdname = string.gsub(v.ent, " ", "_")
		local disabled = tobool(GetConVarNumber("disable"..cmdname))
		if disabled then
			Notify(ply, 1, 4, string.format(LANGUAGE.disabled, v.cmd, ""))
			return "" 
		end
		if cmdname == "money_printer" and (ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF) then Notify(ply, 2, 4, "Money printers aren't allowed as cops!") return "" end
		
		local max = GetConVarNumber("max"..cmdname)
		if not max or max == 0 then max = tonumber(v.max) end
		
		if ply:IsVIP() and cmdname == "money_printer" then max = max+1 end
		
		if ply["max"..cmdname] and tonumber(ply["max"..cmdname]) >= tonumber(max) then
			Notify(ply, 1, 4, string.format(LANGUAGE.limit, v.cmd))
			return ""
		end
		
		local price = GetConVarNumber(cmdname.."_price")
		if price == 0 then 
			price = v.price
		end
		
		if not ply:CanAfford(price) then
			Notify(ply, 1, 4,  string.format(LANGUAGE.cant_afford, v.name))
			return ""
		end
		ply:AddMoney(-price)
		
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply
		
		local tr = util.TraceLine(trace)
		
		local item = ents.Create(v.ent)
		item.dt = item.dt or {}
		item.dt.owning_ent = ply
		item:SetPos(tr.HitPos)
		item.SID = ply.SID
		item.onlyremover = true
		if CPPI then item:CPPISetOwner( ply ) end
		item:Spawn()
		Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, v.name, CUR..price))
		if not ply["max"..cmdname] then
			ply["max"..cmdname] = 0
		end
		ply["max"..cmdname] = ply["max"..cmdname] + 1
		return ""
	end
	DarkRP.defineChatCommand(v.cmd, buythis)
end

/*---------------------------------------------------------
 Jobs
 ---------------------------------------------------------*/
--[[local function CreateAgenda(ply, args)
	if DarkRPAgendas[ply:Team()] then
		ply:SetDarkRPVar("agenda", args)
		
		Notify(ply, 2, 4, LANGUAGE.agenda_updated)
		for k,v in pairs(DarkRPAgendas[ply:Team()].Listeners) do
			for a,b in pairs(team.GetPlayers(v)) do
				Notify(b, 2, 4, LANGUAGE.agenda_updated)
			end
		end
	else
		Notify(ply, 1, 6, string.format(LANGUAGE.unable, "agenda", "Incorrect team"))
	end
	return ""
end
DarkRP.defineChatCommand("/agenda", CreateAgenda)]]

local function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
DarkRP.defineChatCommand("/help", GetHelp)

local function ChangeJob(ply, args)
	local netent, netstr = net.ReadEntity(), net.ReadString()
	if netent then ply = netent end
	if netstr then args = netstr end
	
	if args == "" then return "" end

	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 1, 5, string.format(LANGUAGE.unable, "/job", ">2"))
		return ""
	end

	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait,  math.ceil(10 - (CurTime() - ply.LastJob)), "/job"))
		return ""
	end
	ply.LastJob = CurTime()

	if not ply:Alive() then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ""))
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/job", ""))
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ">2"))
		return ""
	end

	if len > 25 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", "<26"))
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	for k,v in pairs(RPExtraTeams) do
		if jl == v.name then
			ply:ChangeTeam(k)
		end
	end
	NotifyAll(2, 4, string.format(LANGUAGE.job_has_become, ply:Nick(), args))
	ply:UpdateJob(args)
	return ""
end
DarkRP.defineChatCommand("/job", ChangeJob)
util.AddNetworkString("ChangeJob")
net.Receive( "ChangeJob", ChangeJob )

local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:TeamBan()
		if target:Alive() then
			target:ChangeTeam(TEAM_CITIZEN, true)
			if target:isArrested() then
				target:arrest()
			end
		else
			target.demotedWhileDead = true
		end

		GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.demoted, target:Nick()))
	else
		GAMEMODE:NotifyAll(1, 4, string.format(LANGUAGE.demoted_not, target:Nick()))
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		GAMEMODE:Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", "<100"))
		return ""
	end
	local p = GAMEMODE:FindPlayer(tableargs[1])
	if p == ply then
		GAMEMODE:Notify(ply, 1, 4, "Can't demote yourself.")
		return ""
	end

	local canDemote, message = hook.Call("CanDemote", GAMEMODE, ply, p, reason)
	if canDemote == false then
		GAMEMODE:Notify(ply, 1, 4, message or string.format(LANGUAGE.unable, "demote", ""))

		return ""
	end

	if p then
		if CurTime() - ply.LastVoteCop < 80 then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"))
			return ""
		end
		if not RPExtraTeams[p:Team()] or RPExtraTeams[p:Team()].candemote == false then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", ""))
		else
			GAMEMODE:TalkToPerson(p, team.GetColor(ply:Team()), "(DEMOTE) "..ply:Nick(),Color(255,0,0,255), "I want to demote you. Reason: "..reason, p)
			GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.demote_vote_started, ply:Nick(), p:Nick()))
			DB.Log(string.format(LANGUAGE.demote_vote_started, ply:Nick(), p:Nick()) .. " (" .. reason .. ")",
				false, Color(255, 128, 255, 255))
			p.IsBeingDemoted = true

			GAMEMODE.vote:create(p:Nick() .. ":\n"..string.format(LANGUAGE.demote_vote_text, reason), "demote", p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		return ""
	end
end
DarkRP.defineChatCommand("/demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
	if answer ~= 1 then return end
	local Pteam = ply:Team()
	local Tteam = target:Team()
	ply:ChangeTeam(Tteam, true)
	target:ChangeTeam(Pteam, true)
	Notify(ply, 2, 4, LANGUAGE.team_switch)
	Notify(target, 2, 4, LANGUAGE.team_switch)
end

local function SwitchJob(ply) --Idea by Godness.
	if not GAMEMODE.Config.allowjobswitch then return "" end
	local eyetrace = ply:GetEyeTrace()
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end
	ques:Create("Switch job with "..ply:Nick().."?", "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity)
	return ""
end
DarkRP.defineChatCommand("/switchjob", SwitchJob)
DarkRP.defineChatCommand("/switchjobs", SwitchJob)
DarkRP.defineChatCommand("/jobswitch", SwitchJob)
	

local function DoTeamBan(ply, args, cmdargs)
	if not args or args == "" then return "" end
	
	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamban [player name/ID] [team name/id] Use this to ban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args,  a + 1)
	end
	
	local target = GAMEMODE:FindPlayer(ent)
	if not target or not IsValid(target) then 
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"))
		return ""
	end
	
	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", target)) or not ply:IsAdmin() then 
		Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamban"))
		return ""
	end

	local found = false
	for k,v in pairs(team.GetAllTeams()) do
		if string.lower(v.Name) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == Team then
			found = true
			break
		end
	end
	
	if not found then
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[Team] = 1
	NotifyAll(0, 5, ply:Nick() .. " has banned " ..target:Nick() .. " from being a " .. team.GetName(Team))
	return ""
end
DarkRP.defineChatCommand("/teamban", DoTeamBan)
concommand.Add("rp_teamban", DoTeamBan)

local function DoTeamUnBan(ply, args, cmdargs)
	if not ply:IsAdmin() then 
		Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamunban"))
		return ""
	end
	
	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamunban [player name/ID] [team name/id] Use this to unban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args,  a + 1)
	end
	
	local target = GAMEMODE:FindPlayer(ent)
	if not target or not IsValid(target) then 
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"))
		return ""
	end
	
	local found = false
	for k,v in pairs(team.GetAllTeams()) do
		if string.lower(v.Name) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == Team then
			found = true
			break
		end
	end
	
	if not found then
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[Team] = 0
	NotifyAll(1, 5, ply:Nick() .. " has unbanned " ..target:Nick() .. " from being a " .. team.GetName(Team))
	return ""
end
DarkRP.defineChatCommand("/teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)


/*---------------------------------------------------------
Talking 
 ---------------------------------------------------------*/
local function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then return "" end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)
	if msg == "" then return "" end
	target = GAMEMODE:FindPlayer(name)

	if target then
		local col = team.GetColor(ply:Team())
		GAMEMODE:TalkToPerson(target, col, "(PM) "..ply:Nick(),Color(255,255,255,255), msg, ply)
		GAMEMODE:TalkToPerson(ply, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply)
	else
		Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(name)))
	end

	return ""
end
DarkRP.defineChatCommand("/pm", PM)

local function Whisper(ply, args)
	local DoSay = function(text)
		if text == "" then return "" end
		TalkToRange(ply, "(".. LANGUAGE.whisper .. ") " .. ply:Nick(), text, 90) 
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/w", Whisper)

local function Yell(ply, args)
	local DoSay = function(text)
		if text == "" then return "" end
		TalkToRange(ply, "(".. LANGUAGE.yell .. ") " .. ply:Nick(), text, 550) 
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/y", Yell)

local function Me(ply, args)
	if args == "" then return "" end
	
	local DoSay = function(text)
		if text == "" then return "" end
		if GAMEMODE.Config.alltalk then
			for _, target in pairs(player.GetAll()) do
				GAMEMODE:TalkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. text)
			end
		else
			TalkToRange(ply, ply:Nick() .. " " .. text, "", 250)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/me", Me)

local function OOC(ply, args)
	if not GAMEMODE.Config.ooc then
		Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "OOC", ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then return "" end
		local col = team.GetColor(ply:Team())
		local col2 = Color(255,255,255,255)
		if not ply:Alive() then
			col2 = Color(255,200,200,255)
			col = col2
		end
		for k,v in pairs(player.GetAll()) do
			GAMEMODE:TalkToPerson(v, col, "(OOC) "..ply:Name(), col2, text, ply)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("//", OOC, true)
DarkRP.defineChatCommand("/a", OOC, true)
DarkRP.defineChatCommand("/ooc", OOC, true)

local function PlayerAdvertise(ply, args)
	if args == "" then return "" end
	local DoSay = function(text)
		if text == "" then return end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team())
			GAMEMODE:TalkToPerson(v, col, LANGUAGE.advert .." "..ply:Nick(), Color(255,255,0,255), text, ply)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/advert", PlayerAdvertise)

local function MayorBroadcast(ply, args)
	if args == "" then return "" end
	if ply:Team() ~= TEAM_MAYOR then Notify(ply, 1, 4, "You have to be mayor") return "" end
	local DoSay = function(text)
		if text == "" then return end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team())
			GAMEMODE:TalkToPerson(v, col, "[Broadcast!] " ..ply:Nick(), Color(170, 0, 0,255), text, ply)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/broadcast", MayorBroadcast)

local function SetRadioChannel(ply,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 99 then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/channel", "0<channel<100"))
		return ""
	end
	Notify(ply, 2, 4, "Channel set to "..args.."!")
	ply.RadioChannel = tonumber(args)
	return ""
end
DarkRP.defineChatCommand("/channel", SetRadioChannel)

local function SayThroughRadio(ply,args)
	if not ply.RadioChannel then ply.RadioChannel = 1 end
	if not args or args == "" then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/radio", ""))
		return ""
	end
	local DoSay = function(text)
		if text == "" then return end
		for k,v in pairs(player.GetAll()) do
			if v.RadioChannel == ply.RadioChannel then
				GAMEMODE:TalkToPerson(v, Color(180,180,180,255), "Radio ".. tostring(ply.RadioChannel), Color(180,180,180,255), text, ply)
			end
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/radio", SayThroughRadio)

local function MakeZombieSoundsAsHobo(ply)
	if not ply.nospamtime then 
		ply.nospamtime = CurTime() - 2
	end
	if not TEAM_HOBO or ply:Team() ~= TEAM_HOBO or CurTime() < (ply.nospamtime + 1.3) or (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then
		return
	end
	ply.nospamtime = CurTime()
	local ran = math.random(1,3)
	if ran == 1 then
		ply:EmitSound("npc/zombie/zombie_voice_idle"..tostring(math.random(1,14))..".wav", 100,100)
	elseif ran == 2 then
		ply:EmitSound("npc/zombie/zombie_pain"..tostring(math.random(1,6))..".wav", 100,100)
	elseif ran == 3 then
		ply:EmitSound("npc/zombie/zombie_alert"..tostring(math.random(1,3))..".wav", 100,100)
	end
end
concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo)