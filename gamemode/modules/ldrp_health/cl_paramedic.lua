TEAM_PARAMEDIC = DarkRP.createJob("Paramedic", {
	color = Color(57, 204, 204, 255),
	model = "models/player/magnusson.mdl",
	description = [[Run around looking for dumb people getting shot and help 
	nurse them back to better health, or take them to the hospital if wounds
	are too extreme]],
	weapons = {"med_kit"},
	command = "paramedic",
	max = 2,
	salary = 0,
	admin = 0,
	vote = false,
	hasLicense = false,
	medic = true
})