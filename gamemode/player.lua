/*---------------------------------------------------------
/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:IsCP()
	local Team = self:Team()
	return Team == TEAM_POLICE or Team == TEAM_CHIEF or Team == TEAM_MAYOR
end

function meta:RestorePlayerData()
	if not IsValid(self) then return end
	DB.RetrievePlayerData(self, function(data)
		if not IsValid(self) then return end

		self.DarkRPUnInitialized = nil

		local info = data and data[1] or {}
		if not info.rpname or info.rpname == "NULL" then info.rpname = string.gsub(self:SteamName(), "\\\"", "\"") end

		info.wallet = info.wallet or GAMEMODE.Config.startingmoney
		info.salary = info.salary or GAMEMODE.Config.normalsalary

		self:setDarkRPVar("money", tonumber(info.wallet))
		self:setDarkRPVar("salary", tonumber(info.salary))

		self:setDarkRPVar("rpname", info.rpname)

		if not data then
			DB.CreatePlayerData(self, info.rpname, info.wallet, info.salary)
		end
	end, function() -- Retrieving data failed, go on without it
		self.DarkRPUnInitialized = nil

		self:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
		self:setDarkRPVar("salary", GAMEMODE.Config.normalsalary)
		self:setDarkRPVar(string.gsub(self:SteamName(), "\\\"", "\""))

		error("Failed to retrieve player information from MySQL server")
	end)
end

/*---------------------------------------------------------
 Admin/automatic stuff
 ---------------------------------------------------------*/
function meta:HasPriv(priv)
	return (FAdmin and FAdmin.Access.PlayerHasPrivilege(self, priv)) or self:IsAdmin()
end

function meta:InitiateTax()
	local taxtime = GAMEMODE.Config.wallettaxtime
	local uniqueid = self:UniqueID() -- so we can destroy the timer if the player leaves
	timer.Create("rp_tax_"..uniqueid, taxtime or 600, 0, function()
		if not IsValid(self) then
			timer.Destroy("rp_tax_"..uniqueid)
			return
		end

		if not GAMEMODE.Config.wallettax then
			return -- Don't remove the hook in case it's turned on afterwards.
		end

		local money = self:getDarkRPVar("money")
		local mintax = GAMEMODE.Config.wallettaxmin / 100
		local maxtax = GAMEMODE.Config.wallettaxmax / 100 -- convert to decimals for percentage calculations
		local startMoney = GAMEMODE.Config.startingmoney

		if money < (startMoney * 2) then
			return -- Don't tax players if they have less than twice the starting amount
		end

		-- Variate the taxes between twice the starting money ($1000 by default) and 200 - 2 times the starting money (100.000 by default)
		local tax = (money - (startMoney * 2)) / (startMoney * 198)
			  tax = math.Min(maxtax, mintax + (maxtax - mintax) * tax)

		self:addMoney(-tax * money)
		GAMEMODE:Notify(self, 3, 7, "Tax day! "..math.Round(tax * 100, 3) .. "% of your income was taken!")

	end)
end

function meta:ResetDMCounter()
	if not IsValid(self) then return end
	self.kills = 0
	return true
end

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
function meta:UnownAll()
	for k, v in pairs(ents.GetAll()) do
		if v:IsOwnable() and v:OwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	if self:GetTable().Ownedz then
		for k, v in pairs(self:GetTable().Ownedz) do
			v:UnOwn(self)
			self:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v:GetTable().Ownedz then
			for n, m in pairs(v:GetTable().Ownedz) do
				if IsValid(m) and m:AllowedToOwn(self) then
					m:RemoveAllowed(self)
				end
			end
		end
	end

	self:GetTable().OwnedNumz = 0
end

function meta:DoPropertyTax()
	if not GAMEMODE.Config.propertytax then return end
	if (self:IsCP()) and GAMEMODE.Config.cit_propertytax then return end

	local numowned = self:GetTable().OwnedNumz

	if numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:CanAfford(tax) then
		if tax ~= 0 then
			self:addMoney(-tax)
			Notify(self, 0, 5, string.format(LANGUAGE.property_tax, CUR .. tax))
		end
	else
		Notify(self, 1, 8, LANGUAGE.property_tax_cant_afford)
		self:UnownAll()
	end
end

function meta:DropDRPWeapon(weapon)
	if GAMEMODE.Config.restrictdrop then
		local found = false
		for k,v in pairs(CustomShipments) do
			if v.entity == weapon:GetClass() then
				found = true
			break
		end
	end

	if not found then return end
	end

	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
	self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

	local ent = ents.Create("spawned_weapon")
	local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()

	ent.ShareGravgun = true
	ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
	ent:SetModel(model)
	ent:SetSkin(weapon:GetSkin())
	ent.weaponclass = weapon:GetClass()
	ent.nodupe = true
	ent.clip1 = weapon:Clip1()
	ent.clip2 = weapon:Clip2()
	ent.ammoadd = ammo

	self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

	ent:Spawn()

	weapon:Remove()
end

--[[---------------------------------------------------------------------------
Player:IsWalking
This determines if the player's current animation is walking.
-----------------------------------------------------------------------------]]
function meta:IsWalking()
	return string.StartWith( self:GetSequenceName(self:GetSequence()), "walk" )
end

--[[---------------------------------------------------------------------------
Player:IsRunning
Determines if the player's current animation is a running animation. Note that
this applies if the player is simply holding a move key or if they're
sprinting.
-----------------------------------------------------------------------------]]
function meta:IsRunning()
	return string.StartWith( self:GetSequenceName(self:GetSequence()), "run" )
end

--[[---------------------------------------------------------------------------
Player:IsSwimming
Determinies if the player is currently swimming.
-----------------------------------------------------------------------------]]
function meta:IsSwimming()
	return string.StartWith( self:GetSequenceName(self:GetSequence()), "swimming" )
end

--[[---------------------------------------------------------------------------
Player:IsJumping
Determines if the player is in the jumping animation.
-----------------------------------------------------------------------------]]
function meta:IsJumping()
	return string.StartWith( self:GetSequenceName(self:GetSequence()), "jump" )
end