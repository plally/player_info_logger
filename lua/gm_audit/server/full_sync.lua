require("wait_group")

GMAudit.steamIDQueue = {}
function GMAudit.SyncAllULibUsers() 
	local steamIDs = {}
	for k, v in pairs(ULib.ucl.users) do
		
		if string.StartWith(k, "STEAM") then
			local steamID64 = util.SteamIDTo64(k)
			table.insert(steamIDs, steamID64)
		end
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
	
	print("Items left in queue:", #GMAudit.steamIDQueue)
	wg.whenDone(function()
		local delay = 0

		local url = string.format("https://gmod.pages.dev/realms/%s/players/batch", realm:GetString())
		print("Making batch request", #currentRequest)
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
				print("CODE", #currentRequest, code, body)
			end,
			type= "application/json",
		}
	end)	
end
timer.Create("GMAudit_ProcessQueue", 5, 0, GMAudit.ProcessQueue)
