local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)

local NotificationsFrame = ClientGlobals.PlayerGUI.CoreUI.Notifications

local function Notify(Style, Content, Color)
    local OutputClone = NotificationsFrame.UIListLayout.Template:Clone()

    if typeof(Color) == "Color3" then
        OutputClone.TextLabel.TextColor3 = Color

    elseif type(Color) == "string" then
        -- GUIUtility:CopyGradient(OutputClone.TextLabel.UIGradient, Color)

    elseif Style == 1 then
        -- GUIUtility:CopyGradient(OutputClone.TextLabel.UIGradient, "LabelGreen")

    elseif Style == 2 then
        -- GUIUtility:CopyGradient(OutputClone.TextLabel.UIGradient, "LabelRed")
        SoundService.Effects.Error:Play()
    else
        OutputClone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    OutputClone.TextLabel.Text = Content
    OutputClone.TextLabel.Size = UDim2.new(1.5, 0, 1.5, 0)
    OutputClone.Visible = false
    OutputClone.Parent = NotificationsFrame

    local PopInTween = TweenService:Create(OutputClone.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
        Size = UDim2.new(1.2, 0, 1.2, 0),
        Rotation = 0
    })

    OutputClone.Visible = true
    PopInTween:Play()
    task.wait(3)

    local fadeOutTween = TweenService:Create(OutputClone.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
        TextTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        Rotation = 360
    })
    
    fadeOutTween:Play()
    task.wait(0.7)
    OutputClone:Destroy()
end

return {
    Notify = Notify
}
