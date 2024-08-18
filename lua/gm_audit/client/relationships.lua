-- disable for now
do return end

timer.Create( "GMAudit_Upload", 120, 0, function()
    local relationships = {}
    for _, v in pairs( player.GetHumans() ) do
        local steamID = v:SteamID64()
        if steamID then
            relationships[steamID] = v:GetFriendStatus()
        end
    end

    net.Start( "GMAudit_Relationships" )
    net.WriteTable( relationships )
    net.SendToServer()
end )
