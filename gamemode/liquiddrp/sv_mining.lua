local LDRP = {}

LDRP_SH.SpawnedRockPositions = {}
LDRP.AllRockPositions = {} --Keep track of past and present rock positions, and the rock types

function LDRP.SpawnRock(Type, Position, Override, NoQuery )
	local Tbl = LDRP_SH.Rocks[Type]
	if !Tbl then return end
	
	local Count = 0
	for k,v in pairs(ents.FindByClass("rock_base")) do
		if v:IsValid() and v.RockType == Type then Count = Count+1 end
	end
	if Count >= Tbl.max and !Override then return end
	
	local Rock = ents.Create("rock_base")
	Rock.RockType = Type
	Rock:Spawn()
	
	--Put it in the database if necessary
	if not NoQuery then --Sorry for the double negative
		-- Since the rock's position is stored as its center of mass, we need to bump up its
		-- position by its radius (essentially half of its height)
		Position:Add( Vector(0, 0, Rock:GetModelRadius()) )
		MySQLite.query([[INSERT INTO ]]..Prefix..[[_rocks
			(map, position, type) VALUES ("]] ..
			game:GetMap() .. [[", "]] ..
			tostring( Position ) .. [[", "]] ..
			Type .. [[");]])
	end
	
	Rock:SetPos(Position) --Allow for the position to be adjusted
	
	table.insert(LDRP_SH.SpawnedRockPositions, Position)
	
	for _, v in ipairs( LDRP.AllRockPositions ) do
		if v.Position == Position then return end
	end
	--This rock is in a new position.
	table.insert(LDRP.AllRockPositions, { ["Position"] = Position, ["Type"] = Type })
end

local function InitLoadRocks()
	MySQLite.query([[
		CREATE TABLE IF NOT EXISTS ]]..Prefix..[[_rocks (
			map CHAR(128) NOT NULL,
			position CHAR(64) NOT NULL,
			type CHAR(32) NOT NULL
		)
	]])

	MySQLite.query("SELECT * FROM "..Prefix.."_rocks WHERE map = '" .. game:GetMap() .. "';", function( data )
		if not data then return end
		table.foreach( data, function( _, v )
			local pos = string.Split( v.position, " " )
			pos = Vector( pos[1], pos[2], pos[3] )
			LDRP.SpawnRock( v.type, pos, true, true )
		end )
		GAMEMODE:WriteOut( "Spawned "..#data.." rocks.", Severity.Info )
	end )
end
hook.Add( "DarkRPDBInitialized", "LoadRocksFromDB", InitLoadRocks )

function LDRP:RemoveRock( entity )
	local entPos = entity:GetPos()
	local foundIndex
	
	for k, v in ipairs( LDRP.AllRockPositions ) do
		if v.Position == entPos then
			foundIndex = k
			break
		end
	end
	
	if not foundIndex then return false end --??
	table.remove( LDRP.AllRockPositions, k )
	entity:Remove()
	MySQLite.query("DELETE FROM "..Prefix.."_rocks WHERE map = '".. game:GetMap()
		.. "' AND position = '" .. tostring( entPos ) .."';")
	
	return true
end

local function RemoveRockCmd( ply, cmd, args )
	if !ply:IsAdmin() then
		GAMEMODE:Notify( ply, 1, 3, "You must be an administrator to use this function." )
		return
	end
	
	local ent = ply:GetEyeTrace().Entity
	
	if IsValid( ent ) and ent:GetClass() == "rock_base" then
		if LDRP:RemoveRock( ent ) == false then
			GAMEMODE:Notify( ply, 1, 3, "The rock was not found in the ARP table, aborting." )
		else
			GAMEMODE:Notify( ply, 3, 4, "The rock at "..tostring( ent:GetPos() ).." was successfully removed." )
		end
	else
		GAMEMODE:Notify( ply, 1, 3, "You don't seem to be looking at a rock." )
		return
	end
end
concommand.Add( "ldrp_removerock", RemoveRockCmd )

local function GetAvailPoses()
	local available = {}
	for _, v in ipairs( LDRP.AllRockPositions ) do
		--Have we already discovered all possible available positions?
		if #available >= (#LDRP.AllRockPositions - #LDRP_SH.SpawnedRockPositions) then break end
		if not table.HasValue( LDRP_SH.SpawnedRockPositions, v.Position ) then
			table.insert( available, v )
		end
	end
	
	return available
end

concommand.Add("ldrp_spawnrock",function(ply,cmd,args)
	if !ply:IsAdmin() then ply:ChatPrint("Admin only!") return end
	
	local Type = args[1]
	if !LDRP_SH.Rocks[Type] then
		ply:ChatPrint("Invalid rock (command format: ldrp_spawnrock 'Stone'), here are the rock types:")
		for k,v in pairs(LDRP_SH.Rocks) do
			ply:ChatPrint("'" .. k .. "'")
		end
	else
		LDRP.SpawnRock(Type,ply:GetEyeTrace().HitPos,true)
	end
end)

LDRP_SH.SpawnRock = LDRP.SpawnRock


timer.Create("RandomRockSpawn", 400, 0, function()
	local numPoses = #LDRP_SH.SpawnedRockPositions
	local availPoses = GetAvailPoses()
	
	if numPoses >= 8 or #availPoses == 0 then return end --Too many rocks, or no open positions.

	for _, v in ipairs( availPoses ) do
		local rockType = LDRP_SH.Rocks[v.Type]
		if math.random(1, rockType.spawnchance) == 1 then --Good to go, try to spawn this rock
			LDRP.SpawnRock(v.Type, v.Position)
		end
	end
end)