local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Knit = require(ReplicatedStorage.Packages.Knit)
local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)
local MobileButton = require(ReplicatedStorage.Client.MobileButton)

local MessageController
local MountService
local Player = Players.LocalPlayer
local Replica = ClientGlobals.Replica

local MountController = Knit.CreateController({Name = "MountController"})
local trove = Trove.new()

function MountController:ToggleMount()
    if Player.Character and Player.Character:FindFirstChild("Mount") then
        MountService:Unmount()
    else
        MountService:Mount():andThen(function(Status)
            if Status then
                self:PlayMountEffects()
                print("ok")
            end
        end)
    end
end

function MountController:PlayMountEffects()
    task.delay(.2, function()
        local HoverboardEffect = ReplicatedStorage.Assets.Effects.HoverboardEffect:Clone()

        HoverboardEffect.Parent = workspace.GameObjects.Debris
        HoverboardEffect.Position = Player.Character.HumanoidRootPart.Position
        HoverboardEffect.Attachment["Hoverboard Spawn"]:Emit(5)
        Debris:AddItem(HoverboardEffect, 3)
    end)
end

function MountController:BindActions()
    ContextActionService:BindAction("Mount", function(_, state)
        if state == Enum.UserInputState.Begin then
            self:ToggleMount()

            return Enum.ContextActionResult.Sink
        end
    end, true, Enum.KeyCode.Q, Enum.KeyCode.DPadUp)

    MobileButton:WrapAction("Mount", "Mount", {
        PositionSmall = UDim2.new(0.35, 60, 1, -150),
        SizeSmall = 60,
        PositionBig = UDim2.new(0.35, 110, 1, -320),
        SizeBig = 100,
    })
end

function MountController:SetupUIBindings()

end

function MountController:KnitStart()
    self:SetupUIBindings()
    self:BindActions()

    trove:Add(Replica:ListenToChange("Gamepasses", function()
        self:BindActions()
    end))
end

function MountController:KnitInit()
    MountService = Knit.GetService("MountService")
    MessageController = Knit.GetController("MessageController")
end

function MountController:destroy()
    trove:Destroy()
end

return MountController