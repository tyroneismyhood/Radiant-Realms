local Input = {}

local UserInputService = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera
local ThumbstickPosition = Vector3.zero
local Controller

function Input:EvalKeys(...)
    local Sum = 0

    for _,KeyValuePair in ipairs({...}) do
        if UserInputService:IsKeyDown(KeyValuePair[1]) then
            Sum += KeyValuePair[2]
        end
    end

    return math.sign(Sum)
end

-- Returns input direction relative to the camera
coroutine.wrap(function()
    Controller = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)()

function Input:GetInputDirection()
    if not Controller then
		return Vector3.zero
	end

    local MovementVector = Controller:GetMoveVector()

    if MovementVector.Magnitude == 0 then
        return Vector3.zero
    end

    local CameraCFrame = Camera.CFrame
    local Forward = CameraCFrame.LookVector * Vector3.new(1, 0, 1)
    local Right = CameraCFrame.RightVector * Vector3.new(1, 0, 1)

    return (Forward.Unit * -MovementVector.Z + Right.Unit * MovementVector.X).Unit
end

UserInputService.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Gamepad1 and Input.KeyCode == Enum.KeyCode.Thumbstick1 then
        ThumbstickPosition = Vector3.new(Input.Position.X, 0, Input.Position.Y)
    end
end)

return Input