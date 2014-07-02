GM.Version = "2"
GM.Name = "LiquidRP"
GM.Author = "DarkRP Creators, Jackool and Deadman123/Derp, TGP1994"

CUR = "$" --Removed?
DeriveGamemode("sandbox")

AddCSLuaFile("libraries/interfaceloader.lua")
AddCSLuaFile("libraries/modificationloader.lua")
AddCSLuaFile("libraries/disjointset.lua")
AddCSLuaFile("libraries/fn.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")

include("modules/von.lua") --Temporary until I figure out how to officially bundle lua modules
AddCSLuaFile("modules/von.lua")
include("MakeThings.lua") -- this
include("shared.lua") -- and this up here to load before LDRP
AddCSLuaFile("client/help.lua")

include("liquiddrp/sv_playerfuncs.lua") -- Player functions for LiquidDRP; load it early rather than later
include("liquiddrp/sh_liquiddrp.lua") -- Same with shared LDRP

-- Checking if counterstrike is installed correctly
if table.Count(file.Find("*", "cstrike")) == 0 and table.Count(file.Find("cstrike_*", "GAME")) == 0 then
	timer.Create("TheresNoCSS", 10, 0, function()
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("Counter Strike: Source is incorrectly installed!")
		v:ChatPrint("You need it for DarkRP to work!")
		print("Counter Strike: Source is incorrectly installed!\nYou need it for DarkRP to work!")
		end
	end)
end

RPArrestedPlayers = {}

AddCSLuaFile("MakeThings.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("ammotypes.lua")
AddCSLuaFile("cl_vgui.lua")
AddCSLuaFile("showteamtabs.lua")
AddCSLuaFile("sh_commands.lua")
AddCSLuaFile("client/help.lua")

GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("libraries/interfaceloader.lua")

include("config/_MySQL.lua")
include("config/config.lua")
include("licenseweapons.lua")

include("libraries/modificationloader.lua")
include("libraries/fn.lua")
include("libraries/disjointset.lua")

include("sh_commands.lua")

include("ammotypes.lua")
include("sv_gamemode_functions.lua")
include("main.lua")
include("player.lua")
include("util.lua")

include("client/help.lua")

/*---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------*/
local fol = GM.FolderName.."/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
for k,v in pairs(files) do
	if DarkRP.disabledDefaults["modules"][k] then continue end

	include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
	if folder == "." or folder == ".." or DarkRP.disabledDefaults["modules"][folder] then continue end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
		AddCSLuaFile(fol..folder .. "/" ..File)

		if File == "sh_interface.lua" then continue end
		include(fol.. folder .. "/" ..File)
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
		if File == "sv_interface.lua" then continue end
		include(fol.. folder .. "/" ..File)
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
		if File == "cl_interface.lua" then continue end
		AddCSLuaFile(fol.. folder .. "/" ..File)
	end
end

include("server/database.lua")
MySQLite.initialize()

DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
DarkRP.DARKRP_LOADING = nil

DarkRP.finish()

-----[[ Liquid DarkRP (BY JACKOOL) ]]-----------
local function LoadLiquidDarkRP()
	local function LiquidInclude(typ,fle)
		local realf = "liquiddrp/" .. fle .. ".lua"
		if typ == "sh" then
			include(realf)
			AddCSLuaFile(realf)
		elseif typ == "cl" then
			AddCSLuaFile(realf)
		elseif typ == "sv" then
			include(realf)
		end
	end

	LiquidInclude("sv","sv_resources")
	LiquidInclude("sv","sv_playerfuncs")
	LiquidInclude("cl","sh_liquiddrp")
	LiquidInclude("sv","sv_inventory")
	LiquidInclude("sv","sv_bank")
	LiquidInclude("sv","sv_skills")
	LiquidInclude("sv","sv_mining")
	LiquidInclude("cl","cl_dermaskin")
	LiquidInclude("cl","cl_stores")
	
	LiquidInclude("sv","sv_crafting")
	LiquidInclude("cl","cl_crafting")
	
	LiquidInclude("sh","sh_qmenu")
	LiquidInclude("cl","cl_qmenu")
	LiquidInclude("sv","sv_qmenu")
	
	LiquidInclude( "cl", "cl_skills" )
end
-------------------------------------------------

LoadLiquidDarkRP() -- Load before FPP and FAdmin because they're annoying

-- Falco's prop protection
local BlockedModelsExist = sql.QueryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS1;") ~= false
if not BlockedModelsExist then
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS1(model VARCHAR(140) NOT NULL PRIMARY KEY);")
	include("fpp/fpp_defaultblockedmodels.lua") -- Load the default blocked models
end
AddCSLuaFile("fpp/sh_cppi.lua")
AddCSLuaFile("fpp/sh_settings.lua")
AddCSLuaFile("fpp/client/fpp_menu.lua")
AddCSLuaFile("fpp/client/fpp_hud.lua")
AddCSLuaFile("fpp/client/fpp_buddies.lua")
if UseFadmin then
	AddCSLuaFile("fadmin_darkrp.lua")
	include("fadmin_darkrp.lua")
end
if UseFPP then
	include("fpp/sh_settings.lua")
	include("fpp/sh_cppi.lua")
	include("fpp/server/fpp_settings.lua")
	include("fpp/server/fpp_core.lua")
	include("fpp/server/fpp_antispam.lua")
end

local function GetAvailableVehicles(ply)
	if not ply:IsAdmin() then return end
	ServerLog("Available vehicles for custom vehicles:")
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(list.Get("Vehicles")) do
		ServerLog("\""..k.."\"")
		print("\""..k.."\"")
	end
end
concommand.Add("rp_getvehicles_sv", GetAvailableVehicles)

-- Vehicle fix from tobba!
function debug.getupvalues(f)
	local t, i, k, v = {}, 1, debug.getupvalue(f, 1)
	while k do
		t[k] = v
		i = i+1
		k,v = debug.getupvalue(f, i)
	end
	return t
end
	
for k,v in pairs(LDRP_DLC.SV) do
	if v == "after" then include(k) end
end