GMAudit.ServerDataURL = "https://gmod.pages.dev/api/realms/%s"
function GMAudit.SyncServerData()
    local realm = GetConVar( "gm_audit_realm" ):GetString()
    local token =  GetConVar( "gm_audit_token" ):GetString()
    local data = {
        data={
            ulibBans=ULib.bans
        }
    }
	
	print(string.format(GMAudit.ServerDataURL, realm))
    HTTP{
        url=string.format(GMAudit.ServerDataURL, realm),
        method="POST",
        body=util.TableToJSON(data),
        headers={
            Accept="application/json",	
        },
        headers= {
            authorization=token 
        },
        success = function(code, body)
            if code ~= 200 then
                print("GMAuditPlayerLogs:server update failed with", code)
            end
        end,
        type= "application/json",
    }

end

function GMAudit.SyncPlayers()
    local realm = GetConVar( "gm_audit_realm" ):GetString()
    local token =  GetConVar( "gm_audit_token" ):GetString()
    local players = {}
	for _, ply in ipairs(player.GetHumans()) do 
		table.insert(players, {
			steamID64 = ply:SteamID64(), 
			name = ply:GetName(), 
			rank = ply:GetUserGroup(),
			avatarURL = ply.SteamLookup.PlayerSummary.response.players[1].avatarfull
		}) 
	end

    local data = {
        data={
            onlinePlayers=players,
        }
    }
	
	print(string.format(GMAudit.ServerDataURL, realm))
    HTTP{
        url=string.format(GMAudit.ServerDataURL, realm),
        method="POST",
        body=util.TableToJSON(data),
        headers={
            Accept="application/json",	
        },
        headers= {
            authorization=token 
        },
        success = function(code, body)
            if code ~= 200 then
                print("GMAuditPlayerLogs:server update failed with", code)
            end
        end,
        type= "application/json",
    }

end
timer.Create( "GMAudit_SyncPlayers", 30, 0, GMAudit.SyncPlayers)