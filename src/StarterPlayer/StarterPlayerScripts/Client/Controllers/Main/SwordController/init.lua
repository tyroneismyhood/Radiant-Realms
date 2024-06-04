local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)
local MobileButton = require(ReplicatedStorage.Client.MobileButton)
local LoadAnimations = require(script.LoadAnimations)
local SwingLogic = require(script.SwingLogic)
local InitializeCharacter = require(script.HandlePlayerEvents)

local Player = Players.LocalPlayer
local Replica = ClientGlobals.Replica

local SwordController = Knit.CreateController({ Name = "SwordController" })

function SwordController:GetHitboxSize()
    return SwingLogic.GetHitboxSize()
end

function SwordController:KnitStart()
    InitializeCharacter(Player)

    ContextActionService:BindAction("SwingSword", function(_, State)
        if State == Enum.UserInputState.Begin then
            SwingLogic.SwingSword()
            return Enum.ContextActionResult.Pass
        end
    end, true, Enum.KeyCode.ButtonR2, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)

    MobileButton:WrapAction("SwingSword", "Swing", {
        PositionSmall = UDim2.new(0.35, 0, 1, -150),
        SizeSmall = 60,
        PositionBig = UDim2.new(0.35, 0, 1, -320),
        SizeBig = 100,
    })

    Replica:ListenToChange("EquippedSword", function()
        LoadAnimations.UpdateIdleAnimation()
    end)

    LoadAnimations.UpdateIdleAnimation()

    RunService.Heartbeat:Connect(SwingLogic.UpdateSwing)
end

function SwordController:KnitInit()

end

return SwordController
