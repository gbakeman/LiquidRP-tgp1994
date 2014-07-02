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
 Jobs
 ---------------------------------------------------------*/

local function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
DarkRP.defineChatCommand("/help", GetHelp)

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