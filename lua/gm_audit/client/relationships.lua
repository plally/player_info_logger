timer.Create("GMAudit_Upload", 120, 0, function()
    local relationships = {}
    for _, v in pairs(player.GetHumans()) do
        relationships[v:SteamID64()] = v:GetFriendStatus()
    end

    net.Start("GMAudit_Relationships")
        net.WriteTable(relationships)
    net.SendToServer()
end)