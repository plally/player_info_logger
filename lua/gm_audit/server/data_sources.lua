require("wait_group")

GMAudit.DataSources = {
    -- awarnName
    function(steamID, data, wg)
        local offlineData = sql.Query(string.format("SELECT * FROM awarn_offlinedata WHERE unique_id='%s'", steamID))
        if offlineData and #offlineData > 0 then
            data.name = offlineData[1].playername
            data.awarnName = offlineData[1].playername
        end		
        wg.done()
    end,

    -- ulib
    function(steamID, data, wg)
        local ulibData = ULib.ucl.users[util.SteamIDFrom64(steamID)]
        if ulibData then 
            data.ulibGroup = ulibData.group
            data.ulibName = ulibData.name
        end

        data.ulibBan = ULib.bans[util.SteamIDFrom64(steamID)]
        wg.done()
    end,

    -- cfctime
    function(steamID, data, wg)
        CFCTime.Storage:GetTotalTime(steamID, function(t) 
            data.playtime = t 
            wg.done()
        end)	
    end,
    
    -- awarn
    function(steamID, data, wg)
        local warningRows = sql.Query(string.format("SELECT * FROM awarn_warnings WHERE unique_id='%s'", steamID))
        
        if warningRows and #warningRows > 0 then
            local warns = {}
            for _, warning in pairs(warningRows) do
                table.insert(warns, {
                    type="AWARN",
                    data={
                        actor=warning.admin,
                        message=warning.reason,
                        date=warning.date
                    }
                })
            end
            data.warns = warns
        end
        wg.done()
    end,

    function(steamID, data, wg)
        if TimedPunishments then
            local punishments = TimedPunishments.Data:getPunishments(steamID)
            data.punishments = punishments
        end

        wg.done()
    end,

    -- on the server
    function(steamID, data, wg)
        local ply = player.GetBySteamID64( steamID )
        if not IsValid(ply) then wg.done(); return end
        data.name = ply:GetName()
        data.lastPlayedName = ply:GetName()
        data.lastPlayed = os.time()

        wg.done()
    end
}

function GMAudit.GetPlayerInfo(steamID64, callback) 
    local data = {}
    local wg = NewWaitGroup()

    for _, f in pairs(GMAudit.DataSources) do
        wg.add()
        f(steamID64, data, wg)
    end
 
    wg.whenDone(function()
        callback(data)
    end)
end
