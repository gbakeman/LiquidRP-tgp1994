DarkRP.registerDarkRPVar( "remainingTime", fp{fn.Flip(net.WriteInt), 16}, fp{net.ReadInt, 16} )

GM.Config.deathTime = 20 --How many seconds the player has left before they cannot be revived.