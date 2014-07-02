local alphaMult, motionTime
local function DoPostProcessing()
	print("Do PP")
	if alphaMult < 0.5 then
		print("alphaMult: "..tostring(alphaMult), " moTime: "..tostring(motionTime))
		alphaMult = alphaMult + 0.008 --Over a period of 600 frames (10 seconds)
		motionTime = motionTime + 0.0006 --Arriving at 0.3
	end
	
	DrawMotionBlur( alphaMult, alphaMult * 2.0, motionTime )
end

local function InitPlayerDeath()
	alphaMult, motionTime = 0, 0
	hook.Add( "RenderScreenspaceEffects", "DoDeathPostProc", DoPostProcessing )
	print("Hooked!")
end
usermessage.Hook( "health_InitPlayerDeath", InitPlayerDeath )