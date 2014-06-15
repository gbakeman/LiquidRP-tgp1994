local LDRP = {}

function LDRP.GetPaycheck(ply,cmd,args)
	if !LDRP_SH.UsePaycheckLady then ply:ChatPrint("Paycheck lady is not used but in the map.") return end
	
	if LDRP_SH.ShopPoses["Paycheck Lady"] and ply:GetPos():Distance(LDRP_SH.ShopPoses["Paycheck Lady"]) < 300 then
		if ply.CurCheck and ply.CurCheck > 0 then
			ply:LiquidChat("PAYCHECK", Color(0,192,10), "Earned a paycheck of $" .. ply.CurCheck)
			ply:AddMoney(ply.CurCheck)
			ply.CurCheck = nil
		else
			ply:LiquidChat("PAYCHECK", Color(0,192,10), "Your paycheck is not available!")
		end
	end
end
concommand.Add("_pcg",LDRP.GetPaycheck)

function LDRP.BankCMD(ply,cmd,args)
	if LDRP_SH.ShopPoses["Bank"] and ply:GetPos():Distance(LDRP_SH.ShopPoses["Bank"]) > 300 then return end
	local Type = args[1]
	local Item = args[2]
	if !Type or !Item or (Type != "money" and !LDRP_SH.AllItems[Item]) or Item == "curcash" then return end
	
	if Type == "bank" then
		if ply:HasItem(Item) and ply:CanBCarry(Item) then
			ply:AddItem(Item,-1)
			ply:AddBItem(Item,1)
			ply:LiquidChat("BANK", Color(0,192,10), "Banked one " .. (LDRP_SH.NicerWepNames[Item] or LDRP_SH.AllItems[Item].nicename or Item))
		else
			ply:LiquidChat("BANK", Color(0,192,10), "You need to free inventory space up before banking this.")
		end
	elseif Type == "takeout" then
		if ply:HasBItem(Item) and ply:CanCarry(Item) then
			ply:AddItem(Item,1)
			ply:AddBItem(Item,-1)
			local Name = (LDRP_SH.AllItems[Item].nicename or Item)
			ply:LiquidChat("BANK", Color(0,192,10), "Took out one " .. (LDRP_SH.NicerWepNames[Name] or Name))
		else
			ply:LiquidChat("BANK", Color(0,192,10), "You need to free inventory space up before taking this out.")
		end
	elseif Type == "money" then
		local Cash = tonumber(Item)
		if !Cash then ply:LiquidChat("BANK", Color(0,192,10), "Specify a number to deposit or withdraw.") return end
		
		if Cash < 0 then
			local Am = math.abs(Cash)
			if ply:CanAfford(Am) then
				ply:LiquidChat("BANK", Color(0,192,10), "Deposited $" .. Am .. " into your bank.")
				ply:AddMoney(Cash)
				ply:AddBMoney(Am)
			else
				ply:LiquidChat("BANK", Color(0,192,10), "You don't have enough in your wallet.")
			end
		elseif Cash > 0 then
			local Chk = ply:HasBItem("curcash")
			if Chk and Chk >= Cash then
				ply:LiquidChat("BANK", Color(0,192,10), "Withdrew $" .. Cash .. " from your bank.")
				ply:AddMoney(Cash)
				ply:AddBMoney(-Cash)
			else
				ply:LiquidChat("BANK", Color(0,192,10), "You don't have enough in your bank.")
			end
		else
			ply:LiquidChat("BANK", Color(0,192,10), "Input an amount!")
		end
	end
end
concommand.Add("_bnk",LDRP.BankCMD)