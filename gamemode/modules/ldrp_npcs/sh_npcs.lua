local LDRP = {}

local LeaveMessages = {"Oh, sorry.","Oh okay.","Sorry, didn't know","Fine then...","I just wanted to talk."}
LDRP_SH.AllNPCs = {}
LDRP_SH.ModelToName = {}
function LDRP.AddNPC(name,mdl,Team,descrpt,buttons)
	LDRP_SH.AllNPCs[name] = {}
	LDRP_SH.AllNPCs[name].mdl = mdl
	LDRP_SH.ModelToName[mdl] = name
	LDRP_SH.AllNPCs[name].descrpt = descrpt
	LDRP_SH.AllNPCs[name].buttons = button
	LDRP_SH.AllNPCs[name].NeedTeam = Team

	local usermsg = string.Replace(name, " ", "")
	LDRP_SH.AllNPCs[name].uname = usermsg
	
	if CLIENT then
		local function NPCUMSG(um)
			local z = um:ReadFloat()
			if z == (nil or 0) then
				LDRP_SH.OpenNPCWindow(name,mdl,descrpt,buttons)
			else	
				LDRP_SH.OpenNPCWindow(name,mdl,("I only talk to " .. team.GetName(z) .. "s."),{[LeaveMessages[math.random(1,#LeaveMessages)]] = function() end})
			end
		end
		usermessage.Hook(usermsg,NPCUMSG)
	end
end

hook.Add("loadCustomDarkRPItems", "LiquidRP_AddNPCs", function()
	LDRP.AddNPC("Paycheck Lady","models/humans/group01/female_01.mdl",nil,"Hello, I hand out paychecks to people.",
	{
		["Can I pick my paycheck up?"] = function() RunConsoleCommand("_pcg") end,
		["I have to go, sorry."] = function() end
	})

	LDRP_SH.WeedBagWorth = 60
	LDRP_SH.SeedWorth = 100
	LDRP_SH.SporeWorth = 40
	LDRP_SH.ShroomWorth = 20

	LDRP.AddNPC("Drug Dealer","models/gman.mdl",{TEAM_DRUGDEALER},"Yo man, need some drugs?",
	{
		["I need weed seeds. (NEEDS LVL 2 GROWING)"] = {
			["Can I get 1 seed bag. ($" .. LDRP_SH.SeedWorth .. ")"] = function() RunConsoleCommand("_dd","buy","weed") end,
			["Can I get 5 seed bags. ($" .. LDRP_SH.SeedWorth*5 .. ")"] = function() RunConsoleCommand("_dd","buy","weed","5") end
		},
		["I'd like to sell my weed. ($" .. LDRP_SH.WeedBagWorth .. " per bag)"] = function() RunConsoleCommand("_dd","sell","weed") end,
		["I need mushroom spores. (NEEDS LVL 3 GROWING]"] = {
			["Can I get 1 spore. ($" .. LDRP_SH.SporeWorth .. ")"] = function() RunConsoleCommand("_dd","buy","shrooms") end,
			["Can I get 5 spores. ($" .. LDRP_SH.SporeWorth*5 .. ")"] = function() RunConsoleCommand("_dd","buy","shrooms","5") end
		},
		["I'd like to sell my shrooms. ($" .. LDRP_SH.ShroomWorth .. " per bag)"] = function() RunConsoleCommand("_dd","sell","shrooms") end
	})

	LDRP.AddNPC("Secret NPC","models/humans/group01/female_06.mdl",nil,"Hey, I am a secret.",
	{
		["Wow!"] = function() LocalPlayer():ChatPrint("I honestly don't care about secrets, but let's make him feel good!") end
	})

	LDRP.AddNPC("Bail NPC","models/police.mdl",nil,"Hello. I can bail you out of jail for $500",
	{
		["Fuck yeah man!"] = function() RunConsoleCommand("_bmo") end,
		["No thanks, I like jail"] = function() LocalPlayer():ChatPrint("Fuck that dipshit. What a shitty cop") end
	})

	LDRP.AddNPC("Tutorial Lady","models/humans/group01/female_07.mdl",nil,"Hey! Would you like to repeat the tutorial?",
	{
		["Yes, that'd be nice."] = function()
			if !LDRP_SH.ShowTutorial then
				LocalPlayer():ChatPrint("Sorry, but the tutorial is disabled :(")
			else
				RunConsoleCommand("_repetut")
			end end,
		["No, thanks though."] = function() end
	})

	LDRP_SH.CarrotBuyPrice = 28
	LDRP_SH.CarrotSeedPrice = 50

	LDRP.AddNPC("Rules","models/humans/group01/male_06.mdl",nil,"Would you like to read the rules?",{
		["Yes please"] = function() RunConsoleCommand("rules") end,
		["Nah I'd rather minge"] = function() end
	})
end)

function LDRP.AddCustomNPC(name,mdl,usermsg)
	LDRP_SH.AllNPCs[name] = {}
	LDRP_SH.AllNPCs[name].mdl = mdl
	LDRP_SH.ModelToName[mdl] = name
	LDRP_SH.AllNPCs[name].uname = usermsg
end
LDRP.AddCustomNPC("Banker","models/humans/group01/male_05.mdl","SendBankMenu")

--[[		STORES		]]--
LDRP_SH.AllStores = {}
LDRP_SH.AllStores.Sells = {}
LDRP_SH.AllStores.Buys = {}
function LDRP.CreateStore(name,model,Saying,Sells,Buys)
	
	for b,v in pairs(Sells) do
		local k = string.lower(b)
		LDRP_SH.AllStores.Sells[k] = {}
		LDRP_SH.AllStores.Sells[k].Cost = v
		LDRP_SH.AllStores.Sells[k].NPC = name
	end
	for b,v in pairs(Buys) do
		local k = string.lower(b)
		LDRP_SH.AllStores.Buys[k] = {}
		LDRP_SH.AllStores.Buys[k].Cost = v
		LDRP_SH.AllStores.Buys[k].NPC = name
	end
	LDRP_SH.AllNPCs[name] = {}
	LDRP_SH.AllNPCs[name].mdl = model
	
	LDRP_SH.ModelToName[model] = name
	
	local usermsg = string.Replace(name, " ", "")
	LDRP_SH.AllNPCs[name].uname = usermsg
	
	if CLIENT then
		local function NPCUMSG(um)
			LDRP_SH.OpenStoreMenu(name,model,Saying,Sells,Buys)
		end
		usermessage.Hook(usermsg,NPCUMSG)
	end
end
LDRP.CreateStore("General Store","models/humans/group01/male_09.mdl","Welcome to the General Store!",{["Carrot Seed"] = LDRP_SH.CarrotSeedPrice,["Melon Seed"] = 75,["Pistol Ammo"] = 100,["Rifle Ammo"] = 140,["Shotgun Ammo"] = 140},{["Carrot"] = LDRP_SH.CarrotBuyPrice,["Melon"] = 50})
LDRP.CreateStore("Miner","models/humans/group01/male_03.mdl","I'm too lazy to mine rocks. Do it for me.",{["Pickaxe"] = 120,["hammer"] = 200},{["Stone"] = 12,["Gold"] = 36,["Ruby"] = 55})
