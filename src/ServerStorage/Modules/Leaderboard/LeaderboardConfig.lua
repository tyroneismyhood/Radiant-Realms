local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardConfig = {
    UPDATE_INTERVAL = 60 * 3, -- 3 minutes
    UPDATE_OFFSET_TIME = 7, -- Time between updating each board
    SAVE_INTERVAL = 60 * 5, -- 5 minutes
    SAVE_OFFSET_TIME = 30, -- Time between saving each board
    SAVE_SETASYNC_OFFSET = 16, -- Time between each SetAsync call
    
    HighRanks = {
        [1] = Color3.fromRGB(218, 165, 32),
        [2] = Color3.fromRGB(175, 175, 175),
        [3] = Color3.fromRGB(205, 127, 50),
    },
    
    Promise = require(ReplicatedStorage.Packages.Promise),
    Signal = require(ReplicatedStorage.Packages.Signal),
}

return LeaderboardConfig