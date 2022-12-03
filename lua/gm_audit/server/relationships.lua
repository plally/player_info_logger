GMAudit.RelationshipsBaseURL = "https://gm_audit_backend.vulpes.workers.dev/v1/players/relationships"
util.AddNetworkString("GMAudit_Relationships")
net.Receive("GMAudit_Relationships", function(_, ply) -- TOOD should store in own table so relationships can still be uploaded if player leaves
    ply.relationships = net.ReadTable()
end)

local requiredRelationships = {
    friend = "friend",
    request = "requestrecipient"
}

for k, v in pairs(requiredRelationships) do
    requiredRelationships[v] = k
end

function checkRelationshipPairs(a, b) 
    local expected = requiredRelationships[a]
    if expected then
        return b == expected
    end
    return true
end


function GMAudit.checkRelationships()
    for _, ply in pairs(player.GetHumans()) do  -- TODO get rid of scope pyramid
        local validatedRelationships = {}
        for otherSteamID, relationship in pairs(ply.relationships or {}) do
            local otherPly = player.GetBySteamID64(otherSteamID)
            if IsValid(otherPly) and otherPly.relationships then
                local otherRelationship = otherPly.relationships[ply:SteamID64()]
                if checkRelationshipPairs(relationship, otherRelationship) then
                    validatedRelationships[otherSteamID] = relationship
                else
                    print(ply:GetName() .." is "..relationship.." with "..otherPly:GetName().. " but "..otherPly:GetName().." is not "..requiredRelationships[relationship])
                end
            end
        end
        ply.relationshipsProcessed = false -- TODO only set this to true if they change
        ply.validatedRelationships = validatedRelationships
    end
end

timer.Create("GMAudit_RelationshipsAggregate", 15, 0, function()
    GMAudit.checkRelationships()
    for _, ply in pairs(player.GetHumans()) do 
        for steamID, relationship in pairs(ply.validatedRelationships or {}) do
            if relationship ~= "none" and not ply.relationshipsProcessed then -- use none status to clean up relationships
                GMAudit.CreateRelationship({
                    ["type"] = "client_"..relationship,
                    ["player_id"] = ply:SteamID64(),
                    ["other_player_id"] = steamID,
                })
            end
        end
        ply.relationshipsProcessed = true
    end
end)

function GMAudit.CreateRelationship(item)
    HTTP{
        url=GMAudit.RelationshipsBaseURL,
        method="POST",
        body=util.TableToJSON(item),
        headers={
            Accept="application/json",	
        },
        headers= {
            -- authorization=token:GetString() 
        },
        success = function(code, body)
            if code ~= 200 then
                print("GMAudit: relationships update failed", code)
            end
        end,
        type= "application/json",
    }
end