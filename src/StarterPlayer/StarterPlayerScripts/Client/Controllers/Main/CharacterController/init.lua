local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)
local TeleportUtils = require(script.TeleportUtils)
local LeapUtils = require(script.LeapUtils)
local MountUtils = require(script.MountUtils)
local VIPUtils = require(script.VIPUtils)

local CharacterController = Knit.CreateController({
    Name = "CharacterController"
})

local Replica = ClientGlobals.Replica
local Player = Players.LocalPlayer
local Character
local Humanoid
local CurrentMountPlatform
local UpdateFunction
local SpawnTeleportFinished = false

function CharacterController:Init()
    self.AlreadyRan = false
    self.CurrentTeleportRequest = nil
end

function CharacterController:GetPlayerStats()
    return {
        BaseSpeed = 18,
        RunSpeed = 16, --// Gotta make this go based off data
        MountSpeed = 40, --// Gotta make this go based off data
        JumpPower = 50,
    }
end

function CharacterController:GetMountPlatform()
    return CurrentMountPlatform
end

function CharacterController:HasDoneFirstTeleport()
    return SpawnTeleportFinished
end

function CharacterController:Teleport(Position, Destination, DisableSound)
    if self.CurrentTeleportRequest then
        self.CurrentTeleportRequest:cancel()
        self.CurrentTeleportRequest = nil
    end

    if not Player.Character or not Player.Character.PrimaryPart or Player.Character.Humanoid.Health <= 0 then
        return
    end

    self.CurrentTeleportRequest = Promise.new(function(Resolve)
        TeleportUtils.MoveCoverIn(DisableSound)
        TeleportUtils.MoveCharacterTo(Position)
        TeleportUtils.MoveCoverOut()
        Resolve()
    end)

    return self.CurrentTeleportRequest
end

function CharacterController:ForwardLeap()
    LeapUtils.ForwardLeap(Player, self)
end

function CharacterController:KnitStart()
    self:Init()

    local function OnCharacterAdded(CharacterModel)
        Character = CharacterModel :: Model
        Humanoid = Character:WaitForChild("Humanoid")
        
        UpdateFunction = function()
            MountUtils.UpdateCharacterStats(self, Humanoid, Character, CurrentMountPlatform)
        end

        MountUtils.InitMount(self, Character, Humanoid, UpdateFunction)

        Character:GetAttributeChangedSignal("Shifting"):Connect(UpdateFunction)
        Character:GetAttributeChangedSignal("NoMoving"):Connect(UpdateFunction)
    end

    if Player.Character then
        task.spawn(OnCharacterAdded, Player.Character)
    end

    Player.CharacterAdded:Connect(OnCharacterAdded)

    for _, path in ipairs({"Upgrades", "Pets"}) do
        Replica:ListenToChange(path, function()
            if UpdateFunction then
                UpdateFunction()
            end
        end)
    end

    Replica:ListenToChange("Gamepasses", function()
        VIPUtils.ToggleVIPWall(Replica)
    end)

    VIPUtils.SetupVIPWallInteractions()
    
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.KeyCode == Enum.KeyCode.LeftShift then
            if Character and Humanoid and Character:IsDescendantOf(workspace) and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                LeapUtils.HandleLeapInput(self, Humanoid)
            end
        end
    end)
end

function CharacterController:KnitInit()

end

return CharacterController