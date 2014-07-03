hook.Add( "PlayerDisconnected", "SavePlayerItems", function(ply)
	--Put the player's weapons in their inventory so it will save
	for _, v in ipairs( ply:GetWeapons() ) do
		local wepType = v:GetClass()
		if ply:CanCarry( wepType ) then
			ply:AddItem( wepType, 1 )
		end
	end
	
	ply:SavePlayer()
end )