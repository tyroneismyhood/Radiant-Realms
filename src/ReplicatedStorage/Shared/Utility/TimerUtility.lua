local TimerService = {}

TimerService.__index = TimerService

local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Parent.Parent.Packages.Signal)

function TimerService:New(Interval)
	assert(type(Interval) == "number", "Argument #1 to TimerService:New must be a number; got " .. type(Interval))
	assert(Interval >= 0, "Argument #1 to TimerService:New must be greater or equal to 0; got " .. tostring(Interval))
	
	local self = setmetatable({}, TimerService)
	
	self.RunHandle = nil
	self.Interval = Interval
	self.UpdateSignal = RunService.Heartbeat
	self.TimeFunction = time
	self.AllowDrift = true
	self.Tick = Signal.new()
	
	return self
end

function TimerService:Simple(Interval, Callback, StartNow, UpdateSignal, TimeFunction)
    local Update = UpdateSignal or RunService.Heartbeat
    local Time = TimeFunction or time
    local NextTick = Time() + Interval
    local Connection

    if StartNow then
        task.defer(Callback)
    end

    Connection = Update:Connect(function()
        local Now = Time()

        if Now >= NextTick then
            NextTick = Now + Interval
            task.defer(Callback)
        end
    end)

    -- Return a function to disconnect
    return function() 
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end

function TimerService:Is(Object)
	return type(Object) == "table" and getmetatable(Object) == TimerService
end

function TimerService:StartTimerCommon(allowDrift)
	function TimerService:StartTimerCommon(allowDrift)
		local Time = self.TimeFunction
		local Start = Time()
		local NextTick = Start + self.Interval
		local TickNumber = 1
	
		self.RunHandle = self.UpdateSignal:Connect(function()			
			self.RunHandle = self.UpdateSignal:Connect(function()
				local Now = Time()
				
				if allowDrift then
					-- Drifting behavior
					if Now >= NextTick then
						NextTick = Now + self.Interval
						self.Tick:Fire()
					end
				else
					-- Non-drifting behavior
					while Now >= NextTick do
						TickNumber += 1
						NextTick = Start + (self.Interval * TickNumber)
						self.Tick:Fire()
					end
				end
			end)
		end)
	end
end

function TimerService:StartTimer()
    self:StartTimerCommon(true)
end

function TimerService:StartTimerNoDrift()
    assert(self.Interval > 0, "Interval must be greater than 0 when AllowDrift is set to false")
    self:StartTimerCommon(false)
end

function TimerService:Start()
	if self.RunHandle then
		return
	end
	
	if self.AllowDrift then
		self:StartTimer()
	else
		self:StartTimerNoDrift()
	end
end

function TimerService:StartNow()
	if self.RunHandle then
		return
	end
	
	self.Tick:Fire()
	self:Start()
end

function TimerService:Stop()
    if self.RunHandle then
        self.RunHandle:Disconnect()
        self.RunHandle = nil
    end
end
function TimerService:IsRunning()
	return self.RunHandle ~= nil
end

function TimerService:Destroy()
    self:Stop()

    if self.Tick then
        self.Tick:Destroy()
        self.Tick = nil
    end
end

return TimerService