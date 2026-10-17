
if isfile and writefile and readfile then

    local fName = ("SavedBHUBLOGReconcilation"..game.gameId..game.Players.LocalPlayer.Name)
    
    local function get()
        task.spawn(function()
            return (isfile(fName) and readfile(fName))
        end)
    end

    local function set(i)
        task.spawn(function()
            writefile(fName, tostring(i)
        end)
    end
    
    local fetchNoCache = loadstring(game:HttpGet("https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/UTILS/fetchNoCache.lua"))()
  
    local lastNotifiedVers = (get() or 0)
    local gameId = game.gameId

    local BHUB_NOTIFY = fetchNoCache("https://raw.githubusercontent.com/diepedyt/BHUB/refs/heads/main/BHUBNOTIFICATION.lua")
    
    local BHUB_LOG = fetchNoCache("https://raw.githubusercontent.com/diepedyt/BHUB_UPDATE/refs/heads/main/LOG.lua")
    local gLog = BHUB_LOG[gameId]

    if gLog then

        local latestEntry = 0
        for entry, _ in pairs(gLog) do
            if entry > latestEntry then
                latestEntry = entry
            end
        end

        if lastNotifiedVers == latestEntry then return end
        if lastNotifiedVers == 0 then
            set(latestEntry)
            return
        end
        set(latestEntry)

        for entry, updates in pairs(gLog) do
            if entry > lastNotifiedVers then
                for _, update in pairs(gLog[lastNotifiedVers]) do
                    BHUB_NOTIFY({
                        Title = update.Title or "",
                        Content = update.Content or "",
                        Duration = update.Duration or 5,
                        Image = update.Image,
                        Theme = updated.Theme
                    })
                end
            end
        end
        
    end
  
end
