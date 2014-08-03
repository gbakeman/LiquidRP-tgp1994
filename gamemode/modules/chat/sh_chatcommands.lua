local plyMeta = FindMetaTable("Player")
DarkRP.chatCommands = DarkRP.chatCommands or {}

local validChatCommand = {
	command = isstring,
	description = isstring,
	condition = fn.FOr{fn.Curry(fn.Eq, 2)(nil), isfunction},
	delay = isnumber
}

local checkChatCommand = function(tbl)
	for k,v in pairs(validChatCommand) do
		if not validChatCommand[k](tbl[k]) then
			return false, k
		end
	end
	return true
end

function DarkRP.declareChatCommand(tbl)
	local valid, element = checkChatCommand(tbl)
	if not valid then
		error("Incorrect chat command! " .. element .. " is invalid!", 2)
	end

	tbl.command = string.lower(tbl.command)
	DarkRP.chatCommands[tbl.command] = DarkRP.chatCommands[tbl.command] or tbl
	for k, v in pairs(tbl) do
		DarkRP.chatCommands[tbl.command][k] = v
	end
end

function DarkRP.removeChatCommand(command)
	DarkRP.chatCommands[string.lower(command)] = nil
end

function DarkRP.chatCommandAlias(command, ...)
	local name
	for k, v in pairs{...} do
		name = string.lower(v)

		DarkRP.chatCommands[name] = table.Copy(DarkRP.chatCommands[command])
		DarkRP.chatCommands[name].command = name
	end
end

function DarkRP.getChatCommand(command)
	return DarkRP.chatCommands[string.lower(command)]
end

function DarkRP.getChatCommands()
	return DarkRP.chatCommands
end

function DarkRP.getSortedChatCommands()
	local tbl = fn.Compose{table.ClearKeys, table.Copy, DarkRP.getChatCommands}()
	table.SortByMember(tbl, "command", true)

	return tbl
end

-- chat commands that have been defined, but not declared
DarkRP.getIncompleteChatCommands = fn.Curry(fn.Filter, 3)(fn.Compose{fn.Not, checkChatCommand})(DarkRP.chatCommands)

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
DarkRP.declareChatCommand{
	command = "/pm",
	description = "Send a private message to someone.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/w",
	description = "Say something in whisper voice.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/y",
	description = "Yell something out loud.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/me",
	description = "Chat roleplay to say you're doing things that you can't show otherwise.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "//",
	description = "Global server chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/a",
	description = "Global server chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/ooc",
	description = "Global server chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/advert",
	description = "Advertise something to everyone in the server.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/broadcast",
	description = "Broadcast something as a mayor.",
	delay = 1.5,
	condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
	command = "/channel",
	description = "Tune into a radio channel.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/radio",
	description = "Say something through the radio.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "g",
	description = "Group chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "credits",
	description = "Send the DarkRP credits to someone.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "rpname",
	description = "Change your roleplay name.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/cophelp",
	description = "Displays the cop help window.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/x",
	description = "Not sure yet, will update this when i find it.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buyshipment",
	description = "Buys a shipment of something.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buy",
	description = "Buy something.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buyvehicle",
	description = "Buy a vehicle.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buyammo",
	description = "Buy some ammo.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "holster",
	description = "Holster the item in your hands.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/help",
	description = "Shows the help menu.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "setprice",
	description = "Sets the price of the item you are looking at.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/mayorhelp",
	description = "Displays the mayor help window.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "nick",
	description = "Change your roleplay nickname.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/adminhelp",
	description = "Displays the admin help window.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/mobbosshelp",
	description = "Displays the mob boss help window.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "name",
	description = "Sets the name of the item you are looking at.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "price",
	description = "Set the price of the item you are looking at.",
	delay = 1.5
}
