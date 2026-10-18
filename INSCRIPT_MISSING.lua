-- Call after NOTIFY_MISSED.lua has established the saved version for this game/player.
-- This is a single check; it never advances the original reader's saved version.
if type(isfile) ~= "function" or type(readfile) ~= "function" then return end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then return end

local filename = "SavedBHUBLOGReconcilation" .. tostring(game.GameId) .. player.Name
local readOK, currentVersion = pcall(function()
    if isfile(filename) then return tonumber(readfile(filename)) end
end)
if not readOK or type(currentVersion) ~= "number" or currentVersion < 1 or currentVersion % 1 ~= 0 then return end

local fetchOK, fetchNoCache = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/UTILS/fetchNoCache.lua"))()
end)
if not fetchOK or type(fetchNoCache) ~= "function" then return end

local logOK, allLogs = pcall(fetchNoCache, "https://raw.githubusercontent.com/diepedyt/BHUB_UPDATE/refs/heads/main/LOG.lua")
local gameLog = logOK and type(allLogs) == "table" and allLogs[game.GameId]
if type(gameLog) ~= "table" then return end

local latest = 0
for version, updates in pairs(gameLog) do
    if type(version) == "number" and version > latest and version % 1 == 0 and type(updates) == "table" then
        latest = version
    end
end
if currentVersion >= latest then return end

local notifyOK, notify = pcall(fetchNoCache, "https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/BHUBNOTIFICATION.lua")
if not notifyOK or type(notify) ~= "function" then return end

local TeleportService = game:GetService("TeleportService")
local PlaceId, JobId = game.PlaceId, game.JobId
pcall(notify, {
    Title = "Script Outdated",
    Content = "Script Has Updated! Please rejoin the game and execute again to get the latest version.",
    Duration = 30,
    Actions = {
        {
            Name = "Rejoin Now",
            Callback = function()
                if #Players:GetPlayers() <= 1 then
                    Players.LocalPlayer:Kick("\nRejoining...")
                    wait()
                    TeleportService:Teleport(PlaceId, Players.LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
                end
            end,
        },
    },
})
