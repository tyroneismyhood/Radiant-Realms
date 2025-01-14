--[=[
	A class which holds data and methods for ScriptSignals.

	@class ScriptSignal
]=]
local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal

--[=[
	A class which holds data and methods for ScriptConnections.

	@class ScriptConnection
]=]
local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

--[=[
	A boolean which determines if a ScriptConnection is active or not.

	@prop Connected boolean
	@within ScriptConnection

	@readonly
	@ignore
]=]

export type Class = typeof(setmetatable({
	_active = true,
	_head = nil :: ScriptConnectionNode?,
}, ScriptSignal))

export type ScriptConnection = typeof(setmetatable({
	Connected = true,
	_node = nil :: ScriptConnectionNode?,
}, ScriptConnection))

type ScriptConnectionNode = {
	_signal: Class,
	_connection: ScriptConnection?,
	_handler: (...any) -> (),

	_next: ScriptConnectionNode?,
	_prev: ScriptConnectionNode?,
}

local FreeThread: thread? = nil

local function RunHandlerInFreeThread(handler, ...)
	local thread = FreeThread :: thread
	FreeThread = nil

	handler(...)

	FreeThread = thread
end

local function CreateFreeThread()
	FreeThread = coroutine.running()

	while true do
		RunHandlerInFreeThread(coroutine.yield())
	end
end

--[=[
	Creates a ScriptSignal object.

	@return ScriptSignal
	@ignore
]=]
function ScriptSignal.new(): Class
	return setmetatable({
		_active = true,
		_head = nil,
	}, ScriptSignal)
end

--[=[
	Returns a boolean determining if the object is a ScriptSignal.

	```lua
	local janitor = Janitor.new()
	local signal = ScriptSignal.new()

	ScriptSignal.Is(signal) -> true
	ScriptSignal.Is(janitor) -> false
	```

	@param object any
	@return boolean
	@ignore
]=]
function ScriptSignal.Is(object): boolean
	return typeof(object) == "table" and getmetatable(object) == ScriptSignal
end

--[=[
	Returns a boolean determing if a ScriptSignal object is active.

	```lua
	ScriptSignal:IsActive() -> true
	ScriptSignal:Destroy()
	ScriptSignal:IsActive() -> false
	```

	@return boolean
	@ignore
]=]
function ScriptSignal:IsActive(): boolean
	return self._active == true
end

--[=[
	Connects a handler to a ScriptSignal object.

	```lua
	ScriptSignal:Connect(function(text)
		print(text)
	end)

	ScriptSignal:Fire("Something")
	ScriptSignal:Fire("Something else")

	-- "Something" and then "Something else" are printed
	```

	@param handler (...: any) -> ()
	@return ScriptConnection
	@ignore
]=]
function ScriptSignal:Connect(handler: (...any) -> ()): ScriptConnection
	assert(typeof(handler) == "function", "Must be function")

	if self._active ~= true then
		return setmetatable({
			Connected = false,
			_node = nil,
		}, ScriptConnection)
	end

	local _head: ScriptConnectionNode? = self._head

	local node: ScriptConnectionNode = {
		_signal = self :: Class,
		_connection = nil,
		_handler = handler,

		_next = _head,
		_prev = nil,
	}

	if _head ~= nil then
		_head._prev = node
	end

	self._head = node

	local connection = setmetatable({
		Connected = true,
		_node = node,
	}, ScriptConnection)

	node._connection = connection

	return connection :: ScriptConnection
end

--[=[
	Connects a handler to a ScriptSignal object, but only allows that
	connection to run once. Any `:Fire` calls called afterwards won't trigger anything.

	```lua
	ScriptSignal:ConnectOnce(function()
		print("Connection fired")
	end)

	ScriptSignal:Fire()
	ScriptSignal:Fire()

	-- "Connection fired" is only fired once
	```

	@param handler (...: any) -> ()
	@ignore
]=]
function ScriptSignal:ConnectOnce(handler: (...any) -> ())
	assert(typeof(handler) == "function", "Must be function")

	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		handler(...)
	end)
end

--[=[
	Yields the thread until a `:Fire` call occurs, returns what the signal was fired with.

	```lua
	task.spawn(function()
		print(
			ScriptSignal:Wait()
		)
	end)

	ScriptSignal:Fire("Arg", nil, 1, 2, 3, nil)
	-- "Arg", nil, 1, 2, 3, nil are printed
	```

	@yields
	@return ...any
	@ignore
]=]
function ScriptSignal:Wait(): ...any
	local thread
	do
		thread = coroutine.running()

		local connection
		connection = self:Connect(function(...)
			connection:Disconnect()
			task.spawn(thread, ...)
		end)
	end

	return coroutine.yield()
end

--[=[
	Fires a ScriptSignal object with the arguments passed.

	```lua
	ScriptSignal:Connect(function(text)
		print(text)
	end)

	ScriptSignal:Fire("Some Text...")

	-- "Some Text..." is printed twice
	```

	@param ... any
	@ignore
]=]
function ScriptSignal:Fire(...: any)
	local node: ScriptConnectionNode? = self._head
	while node ~= nil do
		if node._connection ~= nil then
			if FreeThread == nil then
				task.spawn(CreateFreeThread)
			end

			task.spawn(FreeThread :: thread, node._handler, ...)
		end

		node = node._next
	end
end

--[=[
	Disconnects all connections from a ScriptSignal object without making it unusable.

	```lua
	local connection = ScriptSignal:Connect(function() end)

	connection.Connected -> true
	ScriptSignal:DisconnectAll()
	connection.Connected -> false
	```

	@ignore
]=]
function ScriptSignal:DisconnectAll()
	local node: ScriptConnectionNode? = self._head
	while node ~= nil do
		local _connection = node._connection

		if _connection ~= nil then
			_connection.Connected = false
			_connection._node = nil
			node._connection = nil
		end

		node = node._next
	end

	self._head = nil
end

--[=[
	Destroys a ScriptSignal object, disconnecting all connections and making it unusable.

	```lua
	ScriptSignal:Destroy()

	local connection = ScriptSignal:Connect(function() end)
	connection.Connected -> false
	```

	@ignore
]=]
function ScriptSignal:Destroy()
	if self._active ~= true then
		return
	end

	self:DisconnectAll()
	self._active = false
end

--[=[
	Disconnects a connection, any `:Fire` calls from now on will not
	invoke this connection's handler.

	```lua
	local connection = ScriptSignal:Connect(function() end)

	connection.Connected -> true
	connection:Disconnect()
	connection.Connected -> false
	```

	@ignore
]=]
function ScriptConnection:Disconnect()
	if self.Connected ~= true then
		return
	end

	self.Connected = false

	local _node: ScriptConnectionNode = self._node
	local _prev = _node._prev
	local _next = _node._next

	if _next ~= nil then
		_next._prev = _prev
	end

	if _prev ~= nil then
		_prev._next = _next
	else
		-- _node == _signal._head

		_node._signal._head = _next
	end

	_node._connection = nil
	self._node = nil
end

-- Compatibility methods for TopbarPlus
ScriptConnection.destroy = ScriptConnection.Disconnect
ScriptConnection.Destroy = ScriptConnection.Disconnect
ScriptConnection.disconnect = ScriptConnection.Disconnect
ScriptSignal.destroy = ScriptSignal.Destroy
ScriptSignal.Disconnect = ScriptSignal.Destroy
ScriptSignal.disconnect = ScriptSignal.Destroy

ScriptSignal.connect = ScriptSignal.Connect
ScriptSignal.wait = ScriptSignal.Wait
ScriptSignal.fire = ScriptSignal.Fire

return ScriptSignal
