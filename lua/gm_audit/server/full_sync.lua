require("wait_group")

JSON_NULL = util.SHA256( tostring(os.time()) .. "JSON_NULL" )
function TableToJSONWithNull( tbl )
	local out = util.TableToJSON(tbl)
	
	return string.Replace(out, '"'..JSON_NULL..'"', "null")
end

GMAudit.steamIDQueue = {}
function GMAudit.SyncAllUsers() 
	local steamIDs = {}

	for k, _ in pairs(ULib.ucl.users) do
		table.insert(steamIDs, k)
	end

	for k, _ in pairs(ULib.bans) do
		table.insert(steamIDs, k)
	end

	local warnings = sql.Query("SELECT unique_id FROM awarn_warnings") or {}
	for _, v in ipairs(warnings) do 
		table.insert(steamIDs, v.unique_id) 
	end

	timer.Adjust("GMAudit_ProcessQueue", 5, nil, nil)

	-- Copy steamIDs to uniqueSteamIDs without duplicates
	local uniqueSteamIDs = {}
	local found = {}
	for _, v in ipairs(steamIDs) do
		if not found[v] then
			if string.StartWith(v, "STEAM") then
				v = util.SteamIDTo64(v)
			end

			if #v == 17 then
				table.insert(uniqueSteamIDs, v)
				found[v] = true
			end
		end
	end

	GMAudit.steamIDQueue = uniqueSteamIDs
end

local MAX_BATCH_SIZE = 15

GMAudit.PlayerBatchURL = "https://gmod.pages.dev/api/realms/%s/players/batch"
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
			if table.Count(data) == 0 then return end
			table.insert(currentRequest, {
				key=steamID,
				data=data
			})
			wg.done()
		end)
	end
	
	local realm = GetConVar( "gm_audit_realm" )
	local token =  GetConVar( "gm_audit_token" )

	wg.whenDone(function()
		local delay = 0

		local url = string.format(GMAudit.PlayerBatchURL, realm:GetString())
		print("GMAuditPlayerLogs: Making batch request to ", url)
		HTTP{
			url=url,
			method="POST",
			body=TableToJSONWithNull(currentRequest),
			headers={
				Accept="application/json",	
			},
			headers= {
				authorization=token:GetString() 
			},
			success = function(code, body)
				if code ~= 200 then
					print("GMAuditPlayerLogs: batch player update failed with", code)
					GMAudit.failedRequests = GMAudit.failedRequests or {}
					table.insert(GMAudit.failedRequests, {request=currentRequest, code=code, body=body})
				end
			end,
			type= "application/json",
		}
	end)	
end
timer.Create("GMAudit_ProcessQueue", 5, 0, GMAudit.ProcessQueue)
