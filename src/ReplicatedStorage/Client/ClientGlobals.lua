local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ReplicaController = require(ReplicatedStorage.Client.ReplicaController)

type Replica = typeof(ReplicaController.GetReplicaById("")) & {
    Data: typeof(require(ServerStorage.Modules.DataTemplate)),
}

local function CreateClientGlobals()
    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local PlayerGUI = LocalPlayer:FindFirstChild("PlayerGui")

    if not PlayerGUI then
        PlayerGUI = LocalPlayer.ChildAdded:Wait()
        
        if PlayerGUI.Name ~= "PlayerGui" then
            PlayerGUI = LocalPlayer:WaitForChild("PlayerGui")
        end
    end

    -- Ensure CoreUI is loaded
    if not PlayerGUI:FindFirstChild("CoreUI") then
        PlayerGUI.ChildAdded:Wait()
    end

    return {
        Replica = nil :: Replica,
        PlayerGUI = PlayerGUI
    }
end

local ClientGlobals = CreateClientGlobals()

return ClientGlobals