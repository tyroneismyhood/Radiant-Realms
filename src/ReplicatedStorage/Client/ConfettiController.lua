local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local ConfettiShapesAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ConfettiShapes")

local ConfettiShapes = {
    ["Circle"] = 20,
    ["Square"] = 20,
    ["Triangle"] = 20,
    ["Heart"] = 10,
    ["Star"] = 5,
    ["Diamond"] = 5,
}

local ConfettiUtility = {}

ConfettiUtility.__index = ConfettiUtility

local function GetRandomConfettiShape()
    local TotalWeight = 0

    for _, Weight in pairs(ConfettiShapes) do
        TotalWeight += Weight
    end

    local Randomized = math.random(TotalWeight)
    local Count = 0

    for Shape, Weight in pairs(ConfettiShapes) do
        Count += Weight

        if Randomized <= Count then
            return ConfettiShapesAssets:FindFirstChild(Shape)
        end
    end
end

local function GetParticle(CurrentColor, Parent)
    local Label = GetRandomConfettiShape():Clone()

    Label.ImageColor3 = CurrentColor
    Label.Parent = Parent
    Label.Rotation = math.random(360)
    Label.Visible = true
    Label.ZIndex = 20

    return Label
end

local function GetRandomColor(ColorsList)
    return ColorsList[math.random(#ColorsList)]
end

function ConfettiUtility.New(Options)
    if not Options then 
		return 
	end

    local self = setmetatable({}, ConfettiUtility)

    local ColorsList = Options.Colors or {
        Color3.fromRGB(168, 100, 253),
        Color3.fromRGB(41, 205, 255),
        Color3.fromRGB(120, 255, 68),
        Color3.fromRGB(255, 113, 141),
        Color3.fromRGB(253, 255, 106),
    }

    local XForce = math.abs(Options.Force.X)

    Options.Force = Vector2.new(Options.Force.X, Options.Force.Y + (0 - XForce) * 0.8)
    self.Gravity = Options.Gravity or Vector2.new(0, 1)
    self.EmitterPosition = Options.Position
    self.EmitterPower = Options.Force
    self.Position = Vector2.new(0, 0)
    self.Power = Options.Force
    self.Colors = ColorsList
    self.CurrentColor = GetRandomColor(ColorsList)
    self.Label = GetParticle(self.CurrentColor, Options.Parent)
    self.DefaultSize = 30
    self.Size = 1
    self.Side = -1
    self.OutOfBounds = false
    self.Enabled = false
    self.Cycles = 0

    return self
end

function ConfettiUtility:Update()
    if self.Enabled and not self.OutOfBounds then
        self.Label.ImageColor3 = self.CurrentColor
        self.Position = Vector2.new(0, 0)
		self.Power = Vector2.new(self.EmitterPower.X + math.random(10) - 5, self.EmitterPower.Y + math.random(10) - 5)
		self.Cycles = self.Cycles + 1
    end

    if (not self.Enabled and self.OutOfBounds) or (not self.Enabled and (self.Cycles == 0)) then
		self.Label.Visible = false
		self.OutOfBounds = true
		self.CurrentColor = self.Colors[math.random(#self.Colors)]
		
        return
	else
		self.Label.Visible = true
	end

    local StartPosition, CurrentPosition, CurrentPower = self.EmitterPosition, self.Position, self.Power
	local ImageLabel = self.Label

	if ImageLabel then
		-- position
		local newPosition = Vector2.new(CurrentPosition.X - CurrentPower.X, CurrentPosition.Y - CurrentPower.Y)
		local newPower = Vector2.new((CurrentPower.X / 1.05) - self.Gravity.X, (CurrentPower.Y / 1.05) - self.Gravity.Y)
		local ViewportSize = Camera.ViewportSize

		ImageLabel.Position = UDim2.new(StartPosition.X, newPosition.X, StartPosition.Y, newPosition.Y)

		self.OutOfBounds = (ImageLabel.AbsolutePosition.X > ViewportSize.X and self.Gravity.X > 0)
			or (ImageLabel.AbsolutePosition.Y > ViewportSize.Y and self.Gravity.Y > 0)
			or (ImageLabel.AbsolutePosition.X < 0 and self.Gravity.X < 0)
			or (ImageLabel.AbsolutePosition.Y < 0 and self.Gravity.Y < 0)
		self.Position, self.Power = newPosition, newPower

		-- spin
		if newPower.Y < 0 then
			if self.Size <= 0 then
				self.Side = 1
				ImageLabel.ImageColor3 = self.CurrentColor
			end

			if self.Size >= self.DefaultSize then
				self.Side = -1
				ImageLabel.ImageColor3 = Color3.new(self.CurrentColor.r * 0.9, self.CurrentColor.g * 0.9, self.CurrentColor.b * 0.9)
			end

			self.Size = self.Size + (self.Side * 2)
			ImageLabel.Size = UDim2.new(0, self.DefaultSize, 0, self.Size)
		end
	end
end

function ConfettiUtility:Toggle()
	self.Enabled = not self.Enabled
end

function ConfettiUtility:Destroy()
	self.Label:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return ConfettiUtility