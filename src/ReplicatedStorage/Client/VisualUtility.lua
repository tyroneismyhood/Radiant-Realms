local VisualUtility = {}

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage.Packages.Promise)

local function InstancesOfClass(Object, Class)
    local Table = Object:GetDescendants()
    local Result = {}

    table.insert(Table, Object)
    
    for i,v in Table do
        if v:IsA(Class) then
            table.insert(Result, v)
        end
    end

    return Result
end

local function Tween(TweenInformation, Callback)
    local Elapsed = 0
    local Duration = TweenInformation.Time
    local EaseStyle = TweenInformation.EasingStyle
    local EaseDirection = TweenInformation.EasingDirection

    return Promise.new(function(Resolve, Reject, OnCancel)
        Callback(0)

        if OnCancel(function()
            Callback(1)
        end) then
            return
        end

        while Elapsed < Duration do
            Elapsed += task.wait()

            local Alpha = math.min(1, TweenService:GetValue(Elapsed / Duration, EaseStyle, EaseDirection))

            Callback(Alpha)
        end

        Callback(1)
        Resolve()
    end)
end

local function GetLifetime(Root)
	local Descendants = {
        Root,
        unpack(Root:GetDescendants())
    }

	local Lifetime = 0

	for _, v in Descendants do
		if v:IsA("ParticleEmitter") then
			Lifetime = math.max(Lifetime, v.Lifetime.Max)
		end
	end

	return Lifetime
end

VisualUtility.Tween = Tween

function VisualUtility:PushZOffset(Root, Distance)
    local Descendants = {
        Root,
        unpack(Root:GetDescendants())
    }

    for _,v in Descendants do
        if v:IsA("ParticleEmitter") then
            v.ZOffset += Distance
        end
    end
end

function VisualUtility:PlayEffectIn(Root, Parent)
    Root.Parent = Parent
    VisualUtility:EmitDescendants(Root)
    Debris:AddItem(Root, GetLifetime(Root) + 0.5)
end

function VisualUtility:PlayEffect(Root)
    VisualUtility:EmitDescendants(Root)
    Debris:AddItem(Root, GetLifetime(Root) + 0.5)
end

function VisualUtility:PlaySoundAt(Sound, Position)
    local Attachment = Instance.new("Attachment")

    Attachment.Name = `SoundAnchor.{Sound}`
    Attachment.WorldCFrame = CFrame.new(Position)
    Attachment.Parent = workspace.Terrain
    Sound.Parent = Attachment
    Sound:Play()
    Debris:AddItem(Attachment, Sound.TimeLength)
end

function VisualUtility:EmitDescendants(Root)
	local Descendants = {
        Root, 
        unpack(Root:GetDescendants())
    }

	for _, v in Descendants do
		if v:IsA("ParticleEmitter") then
			VisualUtility:Emit(v)
		end
	end
end

function VisualUtility:Emit(ParticleEmitter)
	local DelayTime = ParticleEmitter:GetAttribute("EmitDelay")
	local EmitCount = ParticleEmitter:GetAttribute("EmitCount")

	if DelayTime then
		task.delay(DelayTime, function()
			ParticleEmitter:Emit(EmitCount)
		end)
	else
		ParticleEmitter:Emit(EmitCount)
	end
end

function VisualUtility:ColorSequenceAtTime(Sequence, Time)
	-- If time is 0 or 1, return the first or last value respectively
	if Time == 0 then
		return Sequence.Keypoints[1].Value

	elseif Time == 1 then
		return Sequence.Keypoints[#Sequence.Keypoints].Value
	end

	-- Otherwise, step through each sequential pair of keypoints
	for i = 1, #Sequence.Keypoints - 1 do
		local ThisKeypoint = Sequence.Keypoints[i]
		local NextKeypoint = Sequence.Keypoints[i + 1]

		if Time >= ThisKeypoint.Time and Time < NextKeypoint.Time then
			-- Calculate how far alpha lies between the points
			local Alpha = (Time - ThisKeypoint.Time) / (NextKeypoint.Time - ThisKeypoint.Time)
			-- Evaluate the real value between the points using alpha
			return Color3.new(
				(NextKeypoint.Value.R - ThisKeypoint.Value.R) * Alpha + ThisKeypoint.Value.R,
				(NextKeypoint.Value.G - ThisKeypoint.Value.G) * Alpha + ThisKeypoint.Value.G,
				(NextKeypoint.Value.B - ThisKeypoint.Value.B) * Alpha + ThisKeypoint.Value.B
			)
		end
	end
end

function VisualUtility:SetTransparencyModifier(Particle, Mod)
	if not Particle:GetAttribute("OriginalTransparency") then
		Particle:SetAttribute("_OriginalTransparency", Particle.Transparency)
	end

	local OriginalTransparency = Particle:GetAttribute("OriginalTransparency")
	local Modded = {}

	for i, v in OriginalTransparency.Keypoints do
		Modded[i] = NumberSequenceKeypoint.new(v.Time, v.Value * Mod, v.Envelope)
	end

	Particle.Transparency = NumberSequence.new(Modded)
end

function VisualUtility:FadeParticleIn(TweenInformation, Particle)
	local Particles = InstancesOfClass(Particle, "ParticleEmitter")
	
	return Tween(TweenInformation, function(t)
		for i, v in Particles do
			VisualUtility:SetTransparencyModifier(v, 1 - t)
		end
	end)
end

function VisualUtility.FadeParticleOut(TweenInformation, Particle)
	local Particles = InstancesOfClass(Particle, "ParticleEmitter")

	return Tween(TweenInformation, function(t)
		for i, v in Particles do
			VisualUtility:SetTransparencyModifier(v, t)
		end
	end)
end

function VisualUtility:SetDescendantsEnabled(Ancestor, Enabled)
	for i, v in Ancestor:GetChildren() do
		if v:IsA("ParticleEmitter") then
			v.Enabled = Enabled
		end
	end
end

function VisualUtility:ScaleParticle(Emitter, SizeFactor)
	SizeFactor = SizeFactor or 1

	local NewEmitterSize = {}

	for i, v in Emitter.Size.Keypoints do
		local NewValue = v.Value * SizeFactor
		local NewEnvelope = v.Envelope * SizeFactor

		table.insert(NewEmitterSize, NumberSequenceKeypoint.new(v.Time, NewValue, NewEnvelope))
	end

	Emitter.Size = NumberSequence.new(NewEmitterSize)
	Emitter.Speed = NumberRange.new(Emitter.Speed.Min * SizeFactor, Emitter.Speed.Max * SizeFactor)
	Emitter.Drag *= SizeFactor
	Emitter.Acceleration *= SizeFactor
	Emitter.ZOffset *= SizeFactor
end

function VisualUtility.ScaleEffect(Root, SizeFactor)
	for i, v in Root:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			VisualUtility:ScaleParticle(v, SizeFactor)
		end
	end
end

return VisualUtility