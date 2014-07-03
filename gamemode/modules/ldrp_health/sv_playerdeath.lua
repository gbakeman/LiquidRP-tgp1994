umsg.PoolString( "health_InitPlayerDeath")
local gm = GM or GAMEMODE

--[[
	Prevent the player from completely dying.
]]
local function HangInThere( ply )
	return false
end
hook.Add( "PlayerDeathThink", "HangInThere", HangInThere )

-- Countdown the player's time before they are officially dead
local function Countdown( ply )
	local timeLeft = ply:getDarkRPVar( "remainingTime" ) - 1
	ply:setDarkRPVar( "remainingTime", timeLeft, ply )
	
	-- Player has died, send this information over to the client for
	-- notification purposes
	if timeLeft == 0 then
		print("Telling player they died.")
		--Start by fading out the screen
		ply:ScreenFade( SCREENFADE.OUT, nil, 3, 20 )
		umsg.Start( "health_FinishPlayerDeath", ply )
		umsg.End()
		--Allow the player to respawn again
		timer.Simple( 20, function() hook.Remove( "PlayerDeathThink", "HangInThere" ) end )
	end
end

-- Broadcasts to paramedics that a player needs help. Returns false if there are no paramedics.
local function BroadcastToParamedics()
	local plys = team.GetPlayers( TEAM_PARAMEDIC )
	print("There are "..#plys.." players on the paramedic team.")
end

--[[
	Begin the process for killing the player, allowing for medics to reach them.
]]
local function InitDeathProcess( ply, inflictor, attacker )
	BroadcastToParamedics()
	
	ply:setDarkRPVar( "remainingTime", gm.Config.deathTime, ply )
	
	umsg.Start( "health_InitPlayerDeath", ply )
	umsg.End()
	
	--Start the ultimate countdown for our dying player
	timer.Create( "subRemainingTime", 1, gm.Config.deathTime, function() Countdown( ply ) end )
	
	local painSound = math.random( 1, 9 )
	ply:EmitSound( "vo/npc/male01/pain0"..painSound..".wav" )
end
hook.Add( "PlayerDeath", "InitDeathProcess", InitDeathProcess )