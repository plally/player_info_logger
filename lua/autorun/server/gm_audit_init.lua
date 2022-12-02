GMAudit = GMAudit or {}
include("gm_audit/server/config.lua")
include("gm_audit/server/full_sync.lua")
include("gm_audit/server/data_sources.lua")
include("gm_audit/server/events.lua")
include("gm_audit/server/full_sync.lua")
include("gm_audit/server/game_events.lua")
include("gm_audit/server/server_data_sources.lua")
include("gm_audit/server/relationships.lua")

AddCSLuaFile("gm_audit/client/relationships.lua")