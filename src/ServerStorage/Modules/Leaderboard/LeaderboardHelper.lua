local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local LeaderboardHelper = {}

LeaderboardHelper.__index = LeaderboardHelper

local LeaderboardConfig = require(script.Parent.LeaderboardConfig)

local Boards = {}
local IsBannedFunction = nil

function LeaderboardHelper:SetIsBannedFunction(Function)
    IsBannedFunction = Function
end

local function ValidPlayer(Player)
    return Player.UserId >= 0
end

function LeaderboardHelper.New(LeaderboardName)
    local self = setmetatable({
        Name = LeaderboardName,
        RankData = {},
        DataStore = DataStoreService:GetOrderedDataStore(`Leaderboard{LeaderboardName}{LeaderboardHelper.Scope}`),
        IsAscending = false,
        NumberPlayers = 100
    }, LeaderboardHelper)

    function self:GetValue(Player)
        warn(`Implement the GetValue function on {LeaderboardName}`)
        return nil
    end

    function self:GetRank(Player)
        for i, v in self.RankData do
            if v.UserID == Player.UserId then
                return i
            end
        end
    end

    table.insert(Boards, self)
    return self
end

function LeaderboardHelper:SaveSessionValues(NoDelay)
    for _, v in Players:GetPlayers() do
        if not ValidPlayer(v) then
            continue
        end

        local Value = self:GetValue(v)

        if IsBannedFunction and IsBannedFunction(v) then
            Value = -1
        end

        if Value == nil then
            continue
        end

        local Success, Error = pcall(function()
            self.DataStore:SetAsync(v.UserId, Value)
        end)

        if not Success then
            warn(`Failed to save to leaderboard. Value = {tostring(Value)} Key = {v.UserId} Board = {self.Name}`)
        end

        if not NoDelay then
            task.wait(LeaderboardConfig.SAVE_SETASYNC_OFFSET)
        end
    end
end

function LeaderboardHelper:Update()
    local Pages = self.DataStore:GetSortedAsync(self.IsAscending, self.NumberPlayers)
    local TopPlayers = Pages:GetCurrentPage()

    table.clear(self.RankData)

    for Rank, Data in TopPlayers do
        local UserID = Data.key
        local Value = Data.value

        self.RankData[Rank] = {
            UserID = tonumber(UserID),
            Value = Value
        }
    end

    LeaderboardConfig.Signal.new():Fire(self, self.RankData)
end

return LeaderboardHelper
