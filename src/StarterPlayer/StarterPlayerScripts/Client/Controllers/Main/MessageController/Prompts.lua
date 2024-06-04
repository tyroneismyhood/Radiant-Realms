local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)

local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)

local FrameController
local CurrentPrompt = nil
local Assets = ReplicatedStorage.Assets

local function PromiseButtonPressed(Button, ...)
    return Promise.fromEvent(Button.Activated):andThenReturn(...)
end

local function Prompt(MessageData)
    if CurrentPrompt then
        return Promise.resolve(nil)
    end

    if MessageData.ReturnFrame == nil then
        MessageData.ReturnFrame = FrameController.CurrentFrame
    end

    local MessageFrame = Assets.UI.MessageTemplate:Clone()

    if MessageData.PromptType == "Choice" then
        MessageFrame.Buttons.Yes.Visible = true
        MessageFrame.Buttons.No.Visible = true

        if MessageData.ButtonTexts then
            MessageFrame.Buttons.Yes.TextLabel.Text, MessageFrame.Buttons.No.TextLabel.Text = unpack(MessageData.ButtonTexts)
        end
    else
        MessageFrame.Buttons.Yes.Visible = true
        MessageFrame.Buttons.Yes.Position = UDim2.fromScale(0.5, 0.5)
        MessageFrame.Buttons.Yes.TextLabel.Text = "Ok"
        MessageFrame.Buttons.No.Visible = false
    end

    MessageFrame.Position = UDim2.fromScale(0.5, -0.6)
    MessageFrame.Content.Text = MessageData.Content
    MessageFrame.Parent = ClientGlobals.PlayerGUI.Displays
    MessageFrame:TweenPosition(UDim2.fromScale(0.5, 0.5), "Out", "Elastic", 0.5, true)
    CurrentPrompt = true

    return Promise.race({
        PromiseButtonPressed(MessageFrame.Buttons.Yes, true),
        PromiseButtonPressed(MessageFrame.Buttons.No, false),
        Promise.fromEvent(FrameController.Closed):andThenReturn(nil),
    }):tap(function()
        CurrentPrompt = nil
        MessageFrame:TweenPosition(UDim2.fromScale(0.5, 1.5), "In", "Bounce", 0.5, true)

        task.delay(0.5, function()
            MessageFrame:Destroy()
        end)
    end)
end

return {
    Prompt = Prompt
}
