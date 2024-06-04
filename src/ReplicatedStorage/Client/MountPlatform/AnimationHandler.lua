local AnimationHandler = {}

function AnimationHandler:LoadAnimation(Humanoid, Animation)
    if self.Animation then
        self.Animation:Stop()
        self.Animation:Destroy()
    end

    self.Animation = Humanoid:LoadAnimation(Animation)
    self.Animation:Play()
end

function AnimationHandler:StopAnimation(Animation)
    if Animation then
        Animation:Stop()
        Animation:Destroy()
        Animation = nil
    end
end

return AnimationHandler