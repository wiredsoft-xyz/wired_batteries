--[[
MIT LICENSE

Copyright (c) 2025 WiredSoft SAS

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

---@class Signal
---@field id string
---@field subscribers table<number, {callback: function, once: boolean}>
---@field _next_handle number

---@class SignalManager
local SignalManager = {
	---@type table<string, Signal>
	events = {}
}

---@return Signal
---@param id string
function SignalManager.new(id)
	assert(type(id) == "string", "Signal ID must be a string")

	if SignalManager.events[id] then return SignalManager.events[id] end

	SignalManager.events[id] = {
		id = id,
		subscribers = {},
		_next_handle = 1
	}

	return SignalManager.events[id]
end

---@param id string
---@param callback function
---@param once? boolean
---@return number handle
function SignalManager.subscribe(id, callback, once)
	assert(type(callback) == "function", "Callback must be a function")

	local event = SignalManager.events[id] or SignalManager.new(id)
	local handle = event._next_handle
	event._next_handle = event._next_handle + 1

	event.subscribers[handle] = {
		callback = callback,
		once = once or false
	}

	return handle
end

---@param id string
---@param callback function
---@return number handle
function SignalManager.subscribe_once(id, callback)
	return SignalManager.subscribe(id, callback, true)
end

---@param id string
---@param ... any
function SignalManager.emit(id, ...)
	local event = SignalManager.events[id]
	if not event then return end

	local to_remove = {}

	for handle, subscriber in pairs(event.subscribers) do
		local success, err = pcall(subscriber.callback, ...)
		if not success then
			print(string.format("Error in signal '%s' callback: %s", id, err))
		end

		if subscriber.once then table.insert(to_remove, handle) end
	end

	-- Remove one-time subscribers
	for _, handle in ipairs(to_remove) do
		event.subscribers[handle] = nil
	end
end

---@param id string
---@param handle number
---@return boolean
function SignalManager.unsubscribe(id, handle)
	local event = SignalManager.events[id]
	if not event or not event.subscribers[handle] then return false end

	event.subscribers[handle] = nil
	return true
end

---@param id string
---@return boolean
function SignalManager.clear(id)
	local event = SignalManager.events[id]
	if not event then
		return false
	end

	event.subscribers = {}
	event._next_handle = 1
	return true
end

function SignalManager.clear_all()
	SignalManager.events = {}
end

return SignalManager
