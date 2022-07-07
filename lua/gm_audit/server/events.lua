do return end
require("wait_group")


local lastTimestamp = 0

local eventHandlers = {}

eventHandlers.RequestPlayerInfo = function(event)
    table.insert(GMAudit.steamIDQueue, 1, event.data.steamID64)
end

local function handleNewEvent(event, dryRun)
    if event.timestamp <= lastTimestamp then return end
    
    lastTimestamp = event.timestamp
        
    if dryRun then return end
                    
    local handler = eventHandlers[event.action]
    
    if handler then handler(event) end
end


local function fetchEvents(dryRun)
    local url = string.format("https://gmod.pages.dev/%s/events", realm:GetString())

    http.Fetch(url, function(body, size, headers, code)
   
        local data = util.JSONToTable(body)
        if not data then return end

        local alreadyHandled = {}
        for _, event in ipairs(data) do
            if not dryRun and not alreadyHandled[event.data.steamID64] then
                handleNewEvent(event, dryRun)
                alreadyHandled[event.data.steamID64] = true
            end
        end
    end)
    
end 

fetchEvents(true)
timer.Create("GMAudit_PollForEvents", 10, 0, fetchEvents)