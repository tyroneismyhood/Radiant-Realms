local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Input = require(ReplicatedStorage.Controllers.Input)
local Utilities = require(ReplicatedStorage.Shared.Utility.Utility)
local Knit = require(ReplicatedStorage.Packages.Knit)

local AnimationHandler = require(script.AnimationHandler)
local MovementHandler = require(script.MovementHandler)
local InputHandler = require(script.InputHandler)

local MountPlatform = {}

MountPlatform.__index = MountPlatform

type PlatformConfig = {
	BaseFloorHeight: number,
	WaveHeight: number?,
	Acceleration: number,
	TopSpeed: number,
	Gravity: number?,
	JumpPower: number,
	Animation: Animation,
}

function MountPlatform.New(Character, MountModel, Configuration)
    local Attachment = Character.PrimaryPart.ForcesAttachment
    local BodyVelocity = Instance.new("BodyVelocity")
    local BodyPosition = Instance.new("BodyPosition")
    local AlignOrientation = Instance.new("AlignOrientation")

    BodyVelocity.Name = "MountVelocity"
    BodyVelocity.MaxForce = Vector3.new(1e9, 0, 1e9)
    BodyVelocity.P = 5000
    BodyVelocity.Parent = Character.PrimaryPart

    BodyPosition.Name = "MountPos"
    BodyPosition.D = 300
    BodyPosition.P = 8000
    BodyPosition.MaxForce = Vector3.new(0, 0, 0)
    BodyPosition.Parent = Character.PrimaryPart

    AlignOrientation.Name = "MountGyro"
    AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    AlignOrientation.Attachment0 = Attachment
    AlignOrientation.MaxTorque = 1e9
    AlignOrientation.Responsiveness = 50
    AlignOrientation.MaxAngularVelocity = 30
    AlignOrientation.Parent = Character

    local self = setmetatable({
        Character = Character,
        RootPart = Character.HumanoidRootPart,
        Humanoid = Character.Humanoid,
        Model = MountModel,
        BodyVelocity = BodyVelocity,
        BodyPosition = BodyPosition,
        AlignGyro = AlignOrientation,
        Configuration = Configuration,
        Speed = 0,
        DownForce = 0,
        Trove = Trove.new(),
        Jump = false,
        LookAtPosition = nil,
    }, MountPlatform)

    local CurrVelocity = Character.PrimaryPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
    self.Speed = math.clamp(CurrVelocity.Magnitude, 0, self.Configuration.TopSpeed)
    self.Animation = Configuration.Animation

    self.Trove:Add(BodyVelocity)
    self.Trove:Add(BodyPosition)
    self.Trove:Add(AlignOrientation)
    self:Start(Character, Configuration)

    return self
end

function MountPlatform:SetLookAt(Position)
    self.LookAtPosition = Position
end

function MountPlatform:Start(Character, Configuration)
    local function ChangeSpeed(Delta)
        self.Speed = math.clamp(self.Speed + Delta, 0, self.Configuration.TopSpeed)
    end

    local CastParams = RaycastParams.new()
    CastParams.FilterType = Enum.RaycastFilterType.Exclude
    CastParams.FilterDescendantsInstances = {
        workspace.GameObjects.Characters,
        workspace.GameObjects.Debris,
    }
    CastParams.CollisionGroup = "Player"
    CastParams.RespectCanCollide = true

    self.Humanoid.AutoRotate = false
    self.Humanoid.PlatformStand = true

    AnimationHandler:StopAnimation(self.Animation)
    AnimationHandler:LoadAnimation(self.Humanoid, Configuration.Animation)

    local Grounded
    local JumpForce = 0

    JumpForce = InputHandler:ConnectJump(self.Trove, self.Humanoid, JumpForce, Configuration)

    function self:ForceJump()
        if self.Jump then
            return false
        end

        self.Jump = true
        JumpForce += self.Configuration.JumpPower
        task.wait(0.1)
        self.Jump = false

        return true
    end

    local MoveDirection = Utilities:FloorUnitVector(self.RootPart.CFrame.LookVector)

    self.Trove:Add(RunService.Stepped:Connect(function()
        self.LookAtPosition = nil
    end))

    self.Trove:Add(RunService.RenderStepped:Connect(function(dt)
        if not self.Model.PrimaryPart then
            return
        end

        local InputDirectionCamera = Input:GetInputDirection(self.Humanoid)

        if InputDirectionCamera.Magnitude == 0 then
            ChangeSpeed(-self.Configuration.Acceleration * 1.618 * dt)
        else
            ChangeSpeed(self.Configuration.Acceleration * dt)
            MoveDirection = InputDirectionCamera
        end

        local MidPart = self.Model.PrimaryPart
        local WaveHeight = self.Configuration.WaveHeight or 0
        local FinalGroundOffset = MidPart.Size.Y / 2
            + self.RootPart.Size.Y / 2
            + self.Humanoid.HipHeight
            + self.Configuration.BaseFloorHeight
            + WaveHeight

        local CastTop = self.RootPart.CFrame.p + Vector3.new(0, 5, 0)
        local Radius = math.max(MidPart.Size.X, MidPart.Size.Z) / 2
        local Upper = workspace:Spherecast(self.RootPart.CFrame.p, Radius / 3, Vector3.new(0, 5, 0), CastParams)

        if Upper then
            CastTop = Upper.Position - Vector3.new(0, Radius / 3, 0)
        end

        Grounded = workspace:Spherecast(
            CastTop,
            Radius,
            Vector3.new(0, -(self.RootPart.Size.Y / 2 + self.Humanoid.HipHeight + MidPart.Size.Y + WaveHeight + 5), 0),
            CastParams
        )

        if Grounded then
            if Grounded.Instance:HasTag("RespawnBrick") then
                -- TeleportController:TeleportToWorld(Replica.Data.CurrentWorld)
            end

            local GroundPosition = Grounded.Position
            local Offset = 0

            if self.Configuration.WaveHeight then
                Offset = math.sin(time() * 0.7) * self.Configuration.WaveHeight
            end

            self.BodyPosition.Position = Vector3.new(0, GroundPosition.Y + FinalGroundOffset + Offset, 0)
        end

        local Gravity = self.Configuration.Gravity or workspace.Gravity
        local FinalForce = MovementHandler:GetFinalForce(self, MoveDirection)

        JumpForce = math.clamp(JumpForce - Gravity * dt, 0, 999)

        local ForceY = false

        if JumpForce > 0 then
            self.DownForce = JumpForce
            ForceY = true
        elseif not Grounded then
            self.DownForce -= Gravity * dt
            ForceY = true
        else
            self.DownForce = 0
        end

        if not ForceY then
            self.BodyPosition.MaxForce = Vector3.new(0, 1e9, 0)
        else
            self.BodyPosition.MaxForce = Vector3.new(0, 0, 0)
        end

        self.BodyVelocity.MaxForce = Vector3.new(1e9, ForceY and 1e9 or 0, 1e9)
        self.BodyVelocity.Velocity = Vector3.new(FinalForce.X, self.DownForce, FinalForce.Z)

        local LookDirection

        if self.LookAtPosition then
            LookDirection = Utilities:FloorUnitVector(self.LookAtPosition - self.RootPart.Position)
        elseif MoveDirection.Magnitude > 0 then
            LookDirection = Utilities:FloorUnitVector(MoveDirection)
        else
            LookDirection = Utilities:FloorUnitVector(self.RootPart.CFrame.LookVector)
        end

        self.AlignGyro.CFrame = CFrame.lookAt(self.RootPart.Position, self.RootPart.Position + LookDirection)
        self.RootPart.CFrame = CFrame.lookAt(
            self.RootPart.Position,
            self.RootPart.Position + Utilities:FloorUnitVector(self.RootPart.CFrame.LookVector)
        )
    end))
end

function MountPlatform:Destroy()
    self.Trove:Destroy()

    if self.Humanoid:IsDescendantOf(game) then
        self.Humanoid.PlatformStand = false
        self.Humanoid.AutoRotate = true
        self.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end

    AnimationHandler:StopAnimation(self.Animation)
end

Knit.OnStart():andThen(function()
    -- TeleportController = Knit.GetController("TeleportController")
end)

return MountPlatform