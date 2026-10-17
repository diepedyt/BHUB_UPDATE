-- First run establishes a baseline. Later runs replay unseen versions in order.
if type(isfile) ~= "function" or type(writefile) ~= "function" or type(readfile) ~= "function" then
    return
end

local player = game:GetService("Players").LocalPlayer
if not player then return end

-- Preserve the existing filename so installed clients keep their last seen version.
local filename = "SavedBHUBLOGReconcilation" .. tostring(game.GameId) .. player.Name
local lastSeen = 0
local readOK = pcall(function()
    if isfile(filename) then
        lastSeen = tonumber(readfile(filename)) or 0
    end
end)
if not readOK or lastSeen < 0 or lastSeen % 1 ~= 0 then return end

local fetchNoCache = loadstring(game:HttpGet("https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/UTILS/fetchNoCache.lua"))()
local allLogs = fetchNoCache("https://raw.githubusercontent.com/diepedyt/BHUB_UPDATE/refs/heads/main/LOG.lua")
local gameLog = type(allLogs) == "table" and allLogs[game.GameId]
if type(gameLog) ~= "table" then return end

local versions = {}
for version, updates in pairs(gameLog) do
    if type(version) == "number" and version > 0 and version % 1 == 0 and type(updates) == "table" then
        table.insert(versions, version)
    end
end
table.sort(versions)
local latest = versions[#versions]
if not latest or lastSeen >= latest then return end

if lastSeen == 0 then
    pcall(writefile, filename, tostring(latest))
    return
end

local notify = fetchNoCache("https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/BHUBNOTIFICATION.lua")
if type(notify) ~= "function" then return end

for _, version in ipairs(versions) do
    if version > lastSeen then
        local updates = gameLog[version]
        local indices = {}
        for index, update in pairs(updates) do
            if type(index) == "number" and index > 0 and index % 1 == 0 and type(update) == "table" then
                table.insert(indices, index)
            end
        end
        table.sort(indices)
        for _, index in ipairs(indices) do
            local update = updates[index]
            local ok = pcall(notify, {
                Title = update.Title or "",
                Content = update.Content or "",
                Duration = update.Duration or 5,
                Image = update.Image,
                Theme = update.Theme,
            })
            if not ok then return end
        end
        -- Persist only after dispatching this version successfully.
        if not pcall(writefile, filename, tostring(version)) then return end
    end
end
