local FrameCounter = {}

local RunService = game:GetService("RunService")

-- Frame counters for RenderStepped and Heartbeat
FrameCounter.CounterRS = 0
FrameCounter.CounterHB = 0

-- Function to get the current RenderStepped frame count
function FrameCounter:GetRenderFrameID()
    return FrameCounter.CounterRS
end

-- Function to get the current Heartbeat frame count
function FrameCounter:GetPhysicsFrameID()
    return FrameCounter.CounterHB
end

-- Increment RenderStepped frame count each frame
RunService.RenderStepped:Connect(function(deltaTime)
    FrameCounter.CounterRS += 1
end)

-- Increment Heartbeat frame count each frame
RunService.Heartbeat:Connect(function(deltaTime)
    FrameCounter.CounterHB += 1
end)

return FrameCounter