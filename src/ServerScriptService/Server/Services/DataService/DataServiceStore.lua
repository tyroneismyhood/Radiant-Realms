local ServerStorage = game:GetService("ServerStorage")

local ProfileService = require(ServerStorage.Modules.ProfileService)
local ProfileTemplate = require(ServerStorage.Modules.DataTemplate)

local function InitializeProfileStore()
    local GameProfileStore = ProfileService.GetProfileStore("GameDataV1", ProfileTemplate)
    
    return GameProfileStore
end

return InitializeProfileStore