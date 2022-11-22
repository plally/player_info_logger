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