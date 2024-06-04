local InputHandler = {}

local UserInputService = game:GetService("UserInputService")

function InputHandler:ConnectJump(Trove, Humanoid, JumpForce, Configuration)
    Trove:Add(UserInputService.JumpRequest:Connect(function()
        if self.Jump or not self.Grounded then
            return
        end

        self.Jump = true
        JumpForce += Configuration.JumpPower
        task.wait(0.1)
        self.Jump = false
    end))

    return JumpForce
end

return InputHandler