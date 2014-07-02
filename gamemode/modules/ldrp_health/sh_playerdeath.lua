DarkRP.registerDarkRPVar( "canRespawn", net.WriteBit, fn.Compose{tobool, net.ReadBit} )
DarkRP.registerDarkRPVar( "isDying", net.WriteBit, fn.Compose{tobool, net.ReadBit} )