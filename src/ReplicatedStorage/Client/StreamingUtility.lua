local StreamingUtility = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)

local NonAtomicError = `this function only works with Nonatomic models`
local AtomicError = `this function only works with Atomic models`

local function IsNonatomic(Model)
    local ModelStreamingMode = Model.ModelStreamingMode

    return ModelStreamingMode == Enum.ModelStreamingMode.Default or ModelStreamingMode == Enum.ModelStreamingMode.Nonatomic
end

local function IsAtomic(Model)
    local ModelStreamingMode = Model.ModelStreamingMode

    return ModelStreamingMode == Enum.ModelStreamingMode.Atomic
end

local function FindChildOfClassThatIsNamed(Object, ClassName, ObjectName)
	for i, v in Object:GetChildren() do
		if v:IsA(ClassName) and v.Name == ObjectName then
			return v
		end
	end
end

function StreamingUtility:ListenToChild(Object, ChildToListenFor, Callback)
	local HasLoaded = false

	local function PerformLoadCheck()
		local Child = FindChildOfClassThatIsNamed(Object, "Model", ChildToListenFor)

		if Child then
			assert(IsAtomic(Child), `ListenToChild encountered a model that wasn't Atomic ({Child.ModelStreamingMode})`)

			if not HasLoaded then
				HasLoaded = true
				task.spawn(Callback, Child)
			end
		else
			if HasLoaded then
				HasLoaded = false
				task.spawn(Callback, nil)
			end
		end
	end

	PerformLoadCheck()

	local Connection = Trove.new()

	Connection:Add(Object.ChildAdded:Connect(PerformLoadCheck))
	Connection:Add(Object.ChildRemoved:Connect(PerformLoadCheck))

	return Connection
end

function StreamingUtility:ExpectPrimaryPart(Object, Timeout)
	while not Object.PrimaryPart do
		Timeout -= task.wait()
		assert(Timeout > 0, `timed out expecting PrimaryPart on model "{Object}"`)
	end

	return Object.PrimaryPart
end

function StreamingUtility:OnModelStreamIn(Object, Callback)
	assert(IsNonatomic(Object), NonAtomicError)

	local LastPrimaryPart = Object.PrimaryPart

	if not LastPrimaryPart then
		task.spawn(Callback)
	end

	return Object:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
		if Object.PrimaryPart and not LastPrimaryPart then
			task.spawn(Callback)
		end

		LastPrimaryPart = Object.PrimaryPart
	end)
end

function StreamingUtility:OnModelStreamOut(Object, Callback)
	assert(IsNonatomic(Object), NonAtomicError)

	if not Object.PrimaryPart then
		task.spawn(Callback)
	end

	return Object:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
		if not Object.PrimaryPart then
			task.spawn(Callback)
		end
	end)
end

function StreamingUtility:IsModelStreamed(Object)
	assert(IsNonatomic(Object), NonAtomicError)

	if not Object.PrimaryPart then
		return false
	end
    
	return true
end

return StreamingUtility