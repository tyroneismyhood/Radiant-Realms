local MobileButton = {}
local ContentProvider = game:GetService("ContentProvider")

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)
local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)

local Assets = ReplicatedStorage.Assets
local CoreUI = ClientGlobals.PlayerGUI.CoreUI

function MobileButton:IsSmallScreen()
    local MinimumAxis = math.min(CoreUI.AbsoluteSize.X, CoreUI.AbsoluteSize.Y)

    return MinimumAxis <= 500
end

function MobileButton:SetContextGuiEnabled(Enabled)
    local ContextGUI = ClientGlobals.PlayerGUI:FindFirstChild("ContextActionGui")

    if ContextGUI then
        ContextGUI.Enabled = Enabled
    end
end


function MobileButton:WrapAction(ActionName, ActionText, Style)
    coroutine.wrap(function()
        local ContextButton = ContextActionService:GetButton(ActionName)

        if not ContextButton or ContextButton:FindFirstChild("TouchActionTemplate") then
            return
        end

        local function Update()
            if self:IsSmallScreen() then
                ContextButton.Position = Style.PositionSmall
                ContextButton.Size = UDim2.fromOffset(Style.SizeSmall, Style.SizeSmall)
            else
                ContextButton.Position = Style.PositionBig
                ContextButton.Size = UDim2.fromOffset(Style.SizeBig, Style.SizeBig)
            end
        end

        local Wrap = Assets.UI.TouchActionTemplate:Clone()

        Wrap.Size = UDim2.fromScale(1, 1)
        Wrap.Visible = true
        Wrap.TextLabel.Text = ActionText
        Wrap.Parent = ContextButton

        local NewTrove = Trove.new()

        NewTrove:Add(CoreUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update))
       
        NewTrove:Add(ContextButton.MouseButton1Down:Connect(function()
            Wrap.ImageRectOffset = Vector2.new(144, 0)
        end))

        NewTrove:Add(ContextButton.MouseButton1Up:Connect(function()
            Wrap.ImageRectOffset = Vector2.new(0, 0)
        end))

        ContextButton.ImageTransparency = 1
        Update()
        NewTrove:AttachToInstance(ContextButton)
    end)()
end

function MobileButton:ChangeText(ActionName, ActionText)
    coroutine.wrap(function()
        local ContextButton = ContextActionService:GetButton(ActionName)

        if not ContextButton then
            return
        end

        local Wrap = ContextButton:FindFirstChild("TouchActionTemplate")
        
        if Wrap then
            Wrap.TextLabel.Text = ActionText
        end
    end)()
end

return MobileButton