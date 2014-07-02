TEAM_DOCTOR = DarkRP.createJob("Doctor", {
	color = Color(57, 204, 204, 255),
	model = "models/player/magnusson.mdl",
	description = [[All of those years working for your M.D have finally
		payed off. People would be helpless with your advanced knowledge
		of the body and how it works. Treat people, get paid, repeat.]],
	weapons = {"med_kit"},
	command = "doctor",
	max = 2,
	salary = 0,
	admin = 0,
	vote = false,
	hasLicense = false,
	medic = true
})