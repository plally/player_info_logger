function GMAudit.SyncServerData()
    local realm = GetConVar( "gm_audit_realm" ):GetString()
    local token =  GetConVar( "gm_audit_token" ):GetString()
    local data = {
        data={
            ulibBans=ULib.bans
        }
    }
	
	print(string.format("https://gmod.pages.dev/realms/%s/__data.json", realm))
    HTTP{
        url=string.format("https://gmod.pages.dev/realms/%s/__data.json", realm),
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