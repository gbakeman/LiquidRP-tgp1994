--Note: Don't add the galil, dual elites, or g3sg1 - they're meant to be crafted.

-- Pistols/one handed
DarkRP.createShipment("Desert eagle", {
	model = "models/weapons/w_pist_deagle.mdl",
	entity = "weapon_real_cs_desert_eagle",
	price = 215,
	amount = 10,
	seperate = true,
	pricesep = 215,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Fiveseven", {
	model = "models/weapons/w_pist_fiveseven.mdl",
	entity = "weapon_real_cs_five-seven",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 205,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Glock", {
	model = "models/weapons/w_pist_glock18.mdl",
	entity = "weapon_real_cs_glock18",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 160,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("P228", {
	model = "models/weapons/w_pist_p228.mdl",
	entity = "weapon_real_cs_p228",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 185,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("USP", {
	model = "models/weapons/w_pist_usp.mdl",
	entity = "weapon_real_cs_usp",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 185,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Knife", {
	model = "models/weapons/w_knife_t.mdl",
	entity = "weapon_real_cs_knife",
	price = 0,
	amount = 4,
	seperate = true,
	pricesep = 300,
	noship = true,
	allowed = {TEAM_GUN}
})

--Two handed weapons
DarkRP.createShipment("AK47", {
	model = "models/weapons/w_rif_ak47.mdl",
	entity = "weapon_real_cs_ak47",
	price = 2450,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("MP5", {
	model = "models/weapons/w_smg_mp5.mdl",
	entity = "weapon_real_cs_mp5a5",
	price = 2200,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("M4", {
	model = "models/weapons/w_rif_m4a1.mdl",
	entity = "weapon_real_cs_m4a1",
	price = 2450,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Mac 10", {
	model = "models/weapons/w_smg_mac10.mdl",
	entity = "weapon_real_cs_mac10",
	price = 2150,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Pump shotgun", {
	model = "models/weapons/w_shot_m3super90.mdl",
	entity = "weapon_real_cs_pumpshotgun",
	price = 1750,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Sniper Rifle", {
	model = "models/weapons/w_snip_g3sg1.mdl",
	entity = "ls_sniper",
	price = 3750,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("SIG SG-500 Automatic Sniper", {
	model = "models/weapons/w_snip_sg550.mdl",
	entity = "weapon_real_cs_sg550",
	price = 3900,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

--Tossed weapons
DarkRP.createShipment("Explosive Grenade", {
	model = "models/weapons/w_eq_fraggrenade.mdl",
	entity = "weapon_real_cs_grenade",
	price = 0,
	amount = 4,
	seperate = true,
	pricesep = 850,
	noship = true,
	allowed = {TEAM_HEAVYWEP}
})

DarkRP.createShipment("Smoke Grenade", {
	model = "models/weapons/w_eq_smokegrenade.mdl",
	entity = "weapon_real_cs_smoke",
	price = 0,
	amount = 4,
	seperate = true,
	pricesep = 700,
	noship = true,
	allowed = {TEAM_HEAVYWEP}
})

DarkRP.createShipment("Flash Grenade", {
	model = "models/weapons/w_eq_flashbang.mdl",
	entity = "weapon_real_cs_flash",
	price = 0,
	amount = 4,
	seperate = true,
	pricesep = 700,
	noship = true,
	allowed = {TEAM_HEAVYWEP}
})

--Entities
DarkRP.createEntity("Drug lab", {
	ent = "drug_lab",
	model = "models/props_lab/crematorcase.mdl",
	price = 400,
	max = 3,
	cmd = "buydruglab",
	allowed = {TEAM_GANG, TEAM_MOB}
})

DarkRP.createEntity("Money printer", {
	ent = "money_printer",
	model = "models/props_c17/consolebox01a.mdl",
	price = 1000,
	max = 2,
	cmd = "buymoneyprinter"
})

DarkRP.createEntity("Money Printer Cooler", {
	ent = "cooler",
	model = "models/nukeftw/faggotbox.mdl",
	price = 300,
	max = 2,
	cmd = "buycooler",
})

DarkRP.createEntity("Gun lab", {
	ent = "gunlab",
	model = "models/props_c17/TrapPropeller_Engine.mdl",
	price = 500,
	max = 1,
	cmd = "buygunlab",
	allowed = TEAM_GUN
})

/*
How to add custom vehicles:
FIRST
go ingame, type rp_getvehicles for available vehicles!
then:
AddCustomVehicle(<One of the vehicles from the rp_getvehicles list>, <Model of the vehicle>, <Price of the vehicle>, <OPTIONAL jobs that can buy the vehicle>)
Examples:
AddCustomVehicle("Jeep", "models/buggy.mdl", 100 )
AddCustomVehicle("Airboat", "models/airboat.mdl", 600, {TEAM_GUN})
AddCustomVehicle("Airboat", "models/airboat.mdl", 600, {TEAM_GUN, TEAM_MEDIC})

Add those lines under your custom shipments. At the bottom of this file or in data/CustomShipments.txt

HOW TO ADD CUSTOM SHIPMENTS:
AddCustomShipment("<Name of the shipment(no spaces)>"," <the model that the shipment spawns(should be the world model...)>", "<the classname of the weapon>", <the price of one shipment>, <how many guns there are in one shipment>, <OPTIONAL: true/false sold seperately>, <OPTIONAL: price when sold seperately>, < true/false OPTIONAL: /buy only = true> , OPTIONAL which classes can buy the shipment, OPTIONAL: the model of the shipment)

Notes:
MODEL: you can go to Q and then props tab at the top left then search for w_ and you can find all world models of the weapons!
CLASSNAME OF THE WEAPON
there are half-life 2 weapons you can add:
weapon_pistol
weapon_smg1
weapon_ar2
weapon_rpg
weapon_crowbar
weapon_physgun
weapon_357
weapon_crossbow
weapon_slam
weapon_bugbait
weapon_frag
weapon_physcannon
weapon_shotgun
gmod_tool

But you can also add the classnames of Lua weapons by going into the weapons/ folder and look at the name of the folder of the weapon you want.
Like the player possessor swep in addons/Player Possessor/lua/weapons You see a folder called weapon_posessor 
This means the classname is weapon_posessor

YOU CAN ADD ITEMS/ENTITIES TOO! but to actually make the entity you have to press E on the thing that the shipment spawned, BUT THAT'S OK!
YOU CAN MAKE GUNDEALERS ABLE TO SELL MEDKITS!

true/false: Can the weapon be sold seperately?(with /buy name) if you want yes then say true else say no

the price of sold seperate is the price it is when you do /buy name. Of course you only have to fill this in when sold seperate is true.


EXAMPLES OF CUSTOM SHIPMENTS(remove the // to activate it): */

--Seats
AddCustomVehicle( "Pod", "models/vehicles/prisoner_pod_inner.mdl", 125 )
AddCustomVehicle( "Chair_Wood", "models/nova/chair_wood01.mdl", 50 )
AddCustomVehicle( "Chair_Plastic", "models/nova/chair_plastic01.mdl", 60 )
AddCustomVehicle( "Seat_Jeep", "models/nova/jeep_seat.mdl", 70 )
if IsMounted( "ep2" ) then AddCustomVehicle( "Seat_Jalopy", "models/nova/jalopy_seat.mdl", 75 ) end --So garry put in the model, but not the texture?
AddCustomVehicle( "Seat_Airboat", "models/nova/airboat_seat.mdl", 72 )
AddCustomVehicle( "Chair_Office1", "models/nova/chair_office01.mdl", 75 )
AddCustomVehicle( "Chair_Office2", "models/nova/chair_office02.mdl", 95 )
AddCustomVehicle( "phx_seat", "models/props_phx/carseat2.mdl", 85 )

--HL2 vehicles
AddCustomVehicle("Airboat", "models/airboat.mdl", 600, { TEAM_CARDEALER })
AddCustomVehicle("Jeep", "models/buggy.mdl", 350, { TEAM_CARDEALER })

--EP2 jalopy
if IsMounted( "ep2" ) then AddCustomVehicle( "Jalopy", "models/vehicle.mdl", 500, { TEAM_CARDEALER } ) end

--EXAMPLE OF AN ENTITY(in this case a medkit)
--AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10, false, 10, false, {TEAM_GUN}, "models/props_c17/oildrum001_explosive.mdl")
--EXAMPLE OF A BOUNCY BALL:   		NOTE THAT YOU HAVE TO PRESS E REALLY QUICKLY ON THE BOMB OR YOU'LL EAT THE BALL LOL
--AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10, true, 10, true)
-- ADD CUSTOM SHIPMENTS HERE(next line):
