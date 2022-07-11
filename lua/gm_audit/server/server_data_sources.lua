
function GMAudit.SyncServerData()
    local realm = GetConVar( "gm_audit_realm" )
    local token =  GetConVar( "gm_audit_token" )
    local data = {
        data={
            ulibBans=ULib.bans
        }
    }

    HTTP{
        url="https://gmod.pages.dev/realms/cfc/cfc3/__data.json",
        method="POST",
        body=util.TableToJSON(data),
        headers={
            Accept="application/json",	
        },
        headers= {
            authorization=token:GetString() 
        },
        success = function(code, body)
            if code ~= 200 then
                print("GMAuditPlayerLogs:server update failed with", code)
            end
        end,
        type= "application/json",
    }

end
