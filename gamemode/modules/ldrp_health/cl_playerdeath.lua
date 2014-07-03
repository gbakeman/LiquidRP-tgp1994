--sounds for death: ambient\machines\thumper_hit.wav

--This actually looks pretty cool in my humble opinion
surface.CreateFont( "DeathFont",
{
	antialias	= true,
	blursize = 0.75,
	font	= "Roboto-Thin",
	shadow = true,
	size	= 80,
	weight	= 500
})

--------------------------------------------------------------------
-- Functions for while the player is dying
--------------------------------------------------------------------
local alphaMult, motionTime
local function DoPostProcessing()
	DrawMotionBlur( alphaMult, alphaMult * 2.0, motionTime )
end

local function DyingThink()
	if alphaMult < 0.5 then
		print("alphaMult: "..tostring(alphaMult), " moTime: "..tostring(motionTime))
		alphaMult = alphaMult + 0.008 --Over a period of 600 frames (10 seconds)
		motionTime = motionTime + 0.0006 --Arriving at 0.3
	end
end

local function InitPlayerDeath()
	alphaMult, motionTime = 0, 0
	hook.Add( "Think", "DyingThink", DyingThink )
	hook.Add( "RenderScreenspaceEffects", "DoDeathPostProc", DoPostProcessing )
end
usermessage.Hook( "health_InitPlayerDeath", InitPlayerDeath )

-------------------------------------------------------------------------------
-- Functions for after the player has died
-------------------------------------------------------------------------------
local sound1
local function LoopSound()
	if not sound1:IsPlaying() then
		sound1:Play()
	end
end

local textLine1, textLine2, tl1Fade, tl1Alpha
local tl1size_x, tl1size_y
local function HUDPaintDeath()
	if textLine1 == true then
		draw.DrawText( "No one could save you", "DeathFont", (ScrW() / 2) - 350, 100, color_black, nil )
	end
	
	--"Fade out" the first line if the second one is being drawn
	if tl1Fade == true and tl1Alpha < 255 then
		tl1Alpha = tl1Alpha + 0.2
	end
	
	--Draw the second line, and also the fade box on the first line
	if textLine2 == true then
		draw.DrawText( "You may start a new life now...", "DeathFont", (ScrW() / 2) - 450, 300, color_black, nil )
		surface.SetDrawColor( 255, 255, 255, tl1Alpha )
		surface.DrawRect( 0, 100, ScrW(), tl1size_y )
	end
end

local function PlayerDied()
	textLine1, textLine2, tl1Fade = false, false, false
	tl1Alpha = 0
	
	surface.SetFont( "DeathFont" ) --Calculate dimensions for the first text line
	tl1size_x, tl1size_y = surface.GetTextSize( "No one could save you" )
	
	--Remove the old PP hooks
	hook.Remove( "Think", "DyingThink" )
	hook.Remove( "RenderScreenspaceEffects", "DoDeathPostProc" )
	hook.Add( "HUDPaint", "HUDPaintDeath", HUDPaintDeath )
	
	LocalPlayer():SetDSP( 36 ) --Tinitus sound
	
	--Play an ambient sound in the background
	sound1 = CreateSound( LocalPlayer(), "ambient\\atmosphere\\ambience_base.wav" )
	sound2 = CreateSound( LocalPlayer(), "ambient\\levels\\labs\\teleport_postblast_thunder1.wav" )
	sound3 = CreateSound( LocalPlayer(), "ambient\\levels\\citadel\\strange_talk1.wav" )
	hook.Add( "Think", "DoSoundLoop", LoopSound )
	timer.Simple( 5, function() textLine1 = true sound3:Play() end ) --Show the first line of text
	timer.Simple( 8, function() tl1Fade = true end ) --Begin to fade out the first line
	timer.Simple( 10, function() textLine2 = true sound2:Play() end ) --And then the second (prompt to respawn)
	--Begin to end the sound with the fadeout
	timer.Simple( 20, function()
		hook.Remove( "Think", "DoSoundLoop" )
		hook.Remove( "HUDPaint", "HUDPaintDeath" )
		sound1:FadeOut(2)
	end )
	
end
usermessage.Hook( "health_FinishPlayerDeath", PlayerDied )