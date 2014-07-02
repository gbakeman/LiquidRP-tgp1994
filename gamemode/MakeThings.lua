local requiredTeamItems = {"color", "model", "description", "weapons", "command", "max", "salary", "admin", "vote"}
local validEntity = {"ent", model = checkModel, "price", "max", "cmd", "name"}
local function checkValid(tbl, requiredItems)
	for k,v in pairs(requiredItems) do
		local isFunction = type(v) == "function"

		if (isFunction and not v(tbl[k])) or (not isFunction and tbl[v] == nil) then
			return isFunction and k or v
		end
	end
end

CustomVehicles = {}
function AddCustomVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it)
	local function warn(add)
		local text
		if Name_of_vehicle then text = Name_of_vehicle end
		text = text.." FAILURE IN CUSTOM VEHICLE!"
		print(text)
		hook.Add("PlayerSpawn", "VehicleError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text.." "..add) end end)		
	end
	if not Name_of_vehicle or not price or not model then
		warn("The name, model or the price is invalid/missing")
		return
	end
	local found = false
	for k,v in pairs(list.Get("Vehicles")) do
		if string.lower(k) == string.lower(Name_of_vehicle) then found = true break end
	end
	if not found and SERVER then
		warn("Vehicle not found!")
		return
	end
	table.insert(CustomVehicles, {name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it})
end

/*---------------------------------------------------------------------------
Decides whether a custom job or shipmet or whatever can be used in a certain map
---------------------------------------------------------------------------*/
function GM:CustomObjFitsMap(obj)
	if not obj or not obj.maps then return true end

	local map = string.lower(game.GetMap())
	for k,v in pairs(obj.maps) do
		if string.lower(v) == map then return true end
	end
	return false
end

DarkRPAgendas = {}

function AddAgenda(Title, Manager, Listeners)
	if not Manager then 
		hook.Add("PlayerSpawn", "AgendaError", function(ply)
		if ply:IsAdmin() then ply:ChatPrint("WARNING: Agenda made incorrectly, there is no manager! failed to load!") end end) 
		return 
	end
	DarkRPAgendas[Manager] = {Title = Title, Listeners = Listeners} 
end

GM.DarkRPGroupChats = {}
function GM:AddGroupChat(funcOrTeam, ...)
	-- People can enter either functions or a list of teams as parameter(s)
	if type(funcOrTeam) == "function" then
		table.insert(self.DarkRPGroupChats, funcOrTeam)
	else
		local teams = {funcOrTeam, ...}
		table.insert(self.DarkRPGroupChats, function(ply) return table.HasValue(teams, ply:Team()) end)
	end
end

GM.AmmoTypes = {}

function GM:AddAmmoType(ammoType, name, model, price, amountGiven, customCheck)
	table.insert(self.AmmoTypes, {
		ammoType = ammoType,
		name = name,
		model = model,
		price = price,
		amountGiven = amountGiven,
		customCheck = customCheck
	})
end