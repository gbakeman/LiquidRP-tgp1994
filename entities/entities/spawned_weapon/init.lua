AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()

	phys:Wake()
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	if self:Getamount() == 0 then
		self:Setamount(1)
	end
end

function ENT:DecreaseAmount()
	local amount = self.dt.amount

	self.dt.amount = amount - 1

	if self.dt.amount <= 0 then
		self:Remove()
		self.PlayerUse = false
		self.Removed = true -- because it is not removed immediately
	end
end

function ENT:Use(activator,caller)
	local class = self.Entity.weaponclass
	local ammohax = self.Entity.ammohacked
	local cancarry = activator:CanCarry(class,1)
	local item = LDRP_SH.ItemTable( class )
	
	if item and item.cuse then --Actually "use" the item before picking it up.
		item.use( activator )
		self:Remove()
		activator:LiquidChat("GAME", Color(0,200,200), "Equipped a weapon.")
		return
	end
	
	if cancarry then
		self:Remove()
		activator:LiquidChat("GAME", Color(0,200,200), "Picked up a weapon.")
		activator:AddItem(class,1)
	elseif cancarry == nil then --Player attempted to pick up an item not in LDRP's item database, try DarkRP's weapon pickup code
		if type(self.PlayerUse) == "function" then
		local val = self:PlayerUse(activator, caller)
		if val ~= nil then return val end
		elseif self.PlayerUse ~= nil then
			return self.PlayerUse
		end

		local class = self:GetWeaponClass()
		local weapon = ents.Create(class)

		if not weapon:IsValid() then return false end

		if not weapon:IsWeapon() then
			weapon:SetPos(self:GetPos())
			weapon:SetAngles(self:GetAngles())
			weapon:Spawn()
			weapon:Activate()
			self:DecreaseAmount()
			return
		end

		local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
		if not CanPickup then return end
		weapon:Remove()

		hook.Call("PlayerPickupDarkRPWeapon", nil, activator, self, weapon)

		activator:Give(class)
		weapon = activator:GetWeapon(class)

		if self.clip1 then
			weapon:SetClip1(self.clip1)
			weapon:SetClip2(self.clip2 or -1)
		end

		activator:GiveAmmo(self.ammoadd or 0, weapon:GetPrimaryAmmoType())

		self:DecreaseAmount()
	else
		activator:LiquidChat("GAME", Color(0,200,200), "You need to free up inventory space to pick this up.")
	end
end
