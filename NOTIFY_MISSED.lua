-- First run establishes a baseline. Later runs replay up to 10 messages, then summarize the rest.
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

local pendingVersions = {}
local unseenCount = 0
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
        table.insert(pendingVersions, {version = version, indices = indices})
        unseenCount = unseenCount + #indices
    end
end

local notify = fetchNoCache("https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/BHUBNOTIFICATION.lua")
if type(notify) ~= "function" then return end

local maxMessages = 10
local dispatched = 0
for _, pending in ipairs(pendingVersions) do
    local updates = gameLog[pending.version]
    for _, index in ipairs(pending.indices) do
        if dispatched == maxMessages then
            local remaining = unseenCount - dispatched
            local ok = pcall(notify, {
                Title = "New Script Update | More updates",
                Content = string.format("And %d more update%s.", remaining, remaining == 1 and "" or "s"),
                Duration = 5,
            })
            if not ok then return end
            -- The summary acknowledges the remaining messages only after successful dispatch.
            pcall(writefile, filename, tostring(latest))
            return
        end
        local update = updates[index]
        local ok = pcall(notify, {
            Title = "New Script Update | " .. (update.Title or ""),
            Content = update.Content or "",
            Duration = update.Duration or 5,
            Image = update.Image,
            Theme = update.Theme,
        })
        if not ok then return end
        task.wait(0.085)
        dispatched = dispatched + 1
    end
    -- Persist only after dispatching this version successfully.
    if not pcall(writefile, filename, tostring(pending.version)) then return end
end
