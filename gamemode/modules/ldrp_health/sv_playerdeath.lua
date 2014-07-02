umsg.PoolString( "health_InitPlayerDeath")

--[[
	Prevent the player from completely dying.
]]
local function HangInThere( ply )
	return ply:getDarkRPVar( "canRespawn" )
end
hook.Add( "PlayerDeathThink", "HangInThere", HangInThere )

--[[
	Begin the process for killing the player, allowing for medics to reach them.
]]
local function InitDeathProcess( ply, inflictor, attacker )
	ply:setDarkRPVar( "isDying", true, ply )
	ply:setDarkRPVar( "canRespawn", false, ply )
	
	umsg.Start( "health_InitPlayerDeath", ply )
	umsg.End()
	
	local painSound = math.random( 1, 9 )
	ply:EmitSound( "vo/npc/male01/pain0"..painSound..".wav" )
end
hook.Add( "PlayerDeath", "InitDeathProcess", InitDeathProcess )