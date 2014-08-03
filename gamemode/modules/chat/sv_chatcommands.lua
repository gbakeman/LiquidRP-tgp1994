/*---------------------------------------------------------
Talking
 ---------------------------------------------------------*/

local function GroupMsg(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return
		end

		local t = ply:Team()
		local col = team.GetColor(ply:Team())

		local hasReceived = {}
		for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
			-- not the group of the player
			if not func(ply) then continue end

			for _, target in pairs(player.GetAll()) do
				if func(target) and not hasReceived[target] then
					hasReceived[target] = true
					DarkRP.talkToPerson(target, col, DarkRP.getPhrase("group") .. " " .. ply:Nick(), Color(255,255,255,255), text, ply)
				end
			end
		end
		if next(hasReceived) == nil then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/g", ""))
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("g", GroupMsg, 1.5)

-- here's the new easter egg. Easier to find, more subtle, doesn't only credit FPtje and unib5
-- WARNING: DO NOT EDIT THIS
-- You can edit DarkRP but you HAVE to credit the original authors!
-- You even have to credit all the previous authors when you rename the gamemode.
local CreditsWait = true
local function GetDarkRPAuthors(ply, args)
	local target = DarkRP.findPlayer(args); -- Only send to one player. Prevents spamming
	if not IsValid(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("player_doesnt_exist"))
		return ""
	end

	if not CreditsWait then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("wait_with_that")) return "" end
	CreditsWait = false
	timer.Simple(60, function() CreditsWait = true end)--so people don't spam it

	local rf = RecipientFilter()
	rf:AddPlayer(target)
	if ply ~= target then
		rf:AddPlayer(ply)
	end

	umsg.Start("DarkRP_Credits", rf)
	umsg.End()

	return ""
end
DarkRP.defineChatCommand("credits", GetDarkRPAuthors, 50)
