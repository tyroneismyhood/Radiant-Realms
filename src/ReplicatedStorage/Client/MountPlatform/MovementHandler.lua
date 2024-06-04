local MovementHandler = {}

function MovementHandler:ChangeSpeed(self, Delta)
    self.Speed = math.clamp(self.Speed + Delta, 0, self.Configuration.TopSpeed)
end

function MovementHandler:GetMoveDirection(RootPart, Humanoid)
    return Humanoid.MoveDirection ~= Vector3.zero and Humanoid.MoveDirection or RootPart.CFrame.LookVector
end

function MovementHandler:GetFinalForce(self, MoveDirection)
    local FinalForce = MoveDirection * self.Speed + Vector3.new(0, self.DownForce, 0)
    return FinalForce
end

return MovementHandler