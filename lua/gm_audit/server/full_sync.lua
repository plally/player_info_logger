require("wait_group")

GMAudit.steamIDQueue = {}
function GMAudit.SyncAllUsers() 
	local steamIDs = {}
	local found = {}

	for k, v in pairs(ULib.ucl.users) do
		
		if string.StartWith(k, "STEAM") then
			local steamID64 = util.SteamIDTo64(k)
			found[steamID64] = true
			table.insert(steamIDs, steamID64)
		end
	end

	local offlineAwarnData = sql.Query("SELECT * FROM awarn_offlinedata") or {}
	for k, v in pairs(offlineAwarnData) do
		
	end

	timer.Adjust("GMAudit_ProcessQueue", 1, nil, nil)
	GMAudit.steamIDQueue = steamIDs
end

local MAX_BATCH_SIZE = 15

function GMAudit.ProcessQueue() 
	if not GMAudit.steamIDQueue then return end
	if #GMAudit.steamIDQueue <= 0 then 
		timer.Adjust("GMAudit_ProcessQueue", 5, nil, nil) -- Queue is empty slow down timer
		return 
	end

	local currentRequest = {}
	local wg = NewWaitGroup()

	for i=1, MAX_BATCH_SIZE do
		if #GMAudit.steamIDQueue <= 0 then break end
		local steamID = table.remove(GMAudit.steamIDQueue)
		wg.add()
		GMAudit.GetPlayerInfo(steamID, function(data)		
			table.insert(currentRequest, {
				id=steamID,
				data=data
			})
			wg.done()
		end)
	end
	
	local realm = GetConVar( "gm_audit_realm" )
	local token =  GetConVar( "gm_audit_token" )

	wg.whenDone(function()
		local delay = 0

		local url = string.format("https://gmod.pages.dev/realms/%s/players/batch", realm:GetString())
		print("GMAuditPlayerLogs: Making batch request to ", url)
		HTTP{
			url=url,
			method="POST",
			body=util.TableToJSON(currentRequest),
			headers={
				Accept="application/json",	
			},
			headers= {
				authorization=token:GetString() 
			},
			success = function(code, body)
				if code ~= 200 then
					print("GMAuditPlayerLogs: batch player update failed with", code)
				end
			end,
			type= "application/json",
		}
	end)	
end
timer.Create("GMAudit_ProcessQueue", 5, 0, GMAudit.ProcessQueue)
