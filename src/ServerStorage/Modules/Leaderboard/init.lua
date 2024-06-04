local Leaderboard = {}

local LeaderboardConfig = require(script.LeaderboardConfig)
local LeaderboardBoard = require(script.LeaderboardHelper)

local Signal = LeaderboardConfig.Signal
local Promise = LeaderboardConfig.Promise
local Boards = {}

Leaderboard.__index = Leaderboard
Leaderboard.BoardUpdated = Signal.new()

function Leaderboard.SetIsBannedFunction(Function)
    LeaderboardBoard:SetIsBannedFunction(Function)
end

function Leaderboard.GetBoard(BoardName)
    for _, v in Boards do
        if v.Name == BoardName then
            return v
        end
    end
end

function Leaderboard.ForceSaveAndUpdateNow()
    warn("Saving and updating...")

    for i, v in Boards do
        local Success, Error = pcall(function()
            v:SaveSessionValues()
        end)

        warn(`Saving {math.floor(i / #Boards) * 100}%`)

        if not Success then
            warn("Error updating leaderboard! " .. Error)
        end
    end

    for i, v in Boards do
        local Success, Error = pcall(function()
            v:Update()
        end)

        warn(`Updating {math.floor(i / #Boards) * 100}%`)

        if not Success then
            warn("Error updating leaderboard! " .. Error)
        end
    end

    warn("Updated leaderboards!")
end

local OnUpdateSignal = Signal.new()

function Leaderboard.WaitForNextRefresh()
    return Promise.fromEvent(OnUpdateSignal)
end

function Leaderboard.Init()
    task.spawn(function()
        task.wait(5)
        
        while true do
            for _, v in Boards do
                local Success, Error = pcall(function()
                    v:SaveSessionValues()
                end)

                if not Success then
                    warn("Error updating leaderboard! " .. Error)
                end

                task.wait(LeaderboardConfig.SAVE_OFFSET_TIME)
            end

            task.wait(LeaderboardConfig.SAVE_INTERVAL)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(5)

            for _, v in Boards do
                local Success, Error = pcall(function()
                    v:Update()
                end)

                if not Success then
                    warn("Error updating leaderboard! " .. Error)
                end

                task.wait(LeaderboardConfig.UPDATE_OFFSET_TIME)
            end

            OnUpdateSignal:Fire()
            task.wait(LeaderboardConfig.UPDATE_INTERVAL)
        end
    end)
end

return Leaderboard
