hook.Add("AWarnPlayerIDWarned", "GMAudit_LogWarns", function( steamID64, caller, reason )
    print("Syncing data for", steamID64)
        table.insert(GMAudit.steamIDQueue, 1, steamID64)
end)

hook.Add("AWarnPlayerWarned", "GMAudit_LogWarns", function( target, caller, reason)
    print("Syncing data for", target:SteamID64())
    table.insert(GMAudit.steamIDQueue, 1, target:SteamID64())
end)

hook.Add( "PlayerInitialSpawn", "GMAudit_SyncData", function( ply, transition )
    if not transition then
        table.insert(GMAudit.steamIDQueue, 1, ply:SteamID64())
    end
end )

hook.Add( "PlayerDisconnected", "GMAudit_SyncData", function(ply)
    table.insert(GMAudit.steamIDQueue, 1, ply:SteamID64())
end )

hook.Add("ULibUserGroupChange", "GMAudit_SyncData", function(id, allows, denies, new_group, old_group)
    table.insert(GMAudit.steamIDQueue, 1, util.SteamIDTo64(id))
end)

hook.Add("ULibUserRemoved", "GMAudit_SyncData", function(id, user_info)
    table.insert(GMAudit.steamIDQueue, 1, util.SteamIDTo64(id))
end)

hook.Add("ULibPlayerUnBanned", "GMAudit_SyncData", function(id, ban_data)
    table.insert(GMAudit.steamIDQueue, 1, util.SteamIDTo64(id))
    GMAudit.SyncServerData()
end)

hook.Add( "ULibPlayerBanned", "GMAudit_SyncData", function(id, _)
        table.insert(GMAudit.steamIDQueue, 1, util.SteamIDTo64(id))
    GMAudit.SyncServerData()
end)