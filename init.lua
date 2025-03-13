local path = ...
local function require_relative(p)
	return require(table.concat({ path, p }, "."))
end

local _batteries = {
	---@type Class
	class = require_relative("class"),
	---@type Assert
	assert = require_relative("assert"),
	---@type MathX
	mathx = require_relative("mathx"),
	---@type TableX
	tablex = require_relative("tablex"),
	---@type StringX
	stringx = require_relative("stringx"),
	---@type Sort
	sort = require_relative("sort"),
	---@type Functional
	functional = require_relative("functional"),
	---@type Sequence
	sequence = require_relative("sequence"),
	---@type Set
	set = require_relative("set"),
	---@type Vec2
	vec2 = require_relative("vec2"),
	---@type Vec3
	vec3 = require_relative("vec3"),
	---@type Intersect
	intersect = require_relative("intersect"),
	---@type Timer
	timer = require_relative("timer"),
	---@type PubSub
	pubsub = require_relative("pubsub"),
	---@type StateMachine
	state_machine = require_relative("state_machine"),
	---@type Async
	async = require_relative("async"),
	---@type ManualGC
	manual_gc = require_relative("manual_gc"),
	---@type Colour
	colour = require_relative("colour"),
	---@type Pretty
	pretty = require_relative("pretty"),
	---@type Measure
	measure = require_relative("measure"),
	---@type MakePooled
	make_pooled = require_relative("make_pooled"),
	---@type PathFind
	pathfind = require_relative("pathfind"),
}

---Make batteries globally available.
---@return Batteries
function _batteries:export()
	for k, v in pairs(self) do
		if _G[k] == nil then
			_G[k] = v
		end
	end

	--overlay tablex and functional and sort routines onto table
	self.tablex.shallow_overlay(table, self.tablex)
	--now we can use it through table directly
	table.shallow_overlay(table, self.functional)
	self.sort:export()

	--overlay onto global math table
	table.shallow_overlay(math, self.mathx)

	--overlay onto string
	table.shallow_overlay(string, self.stringx)

	--overwrite assert wholesale (it's compatible)
	assert = self.assert

	--like ipairs, but in reverse
	_G.ripairs = self.tablex.ripairs

	--export the whole library to global `batteries`
	_G.batteries = self

	return self
end

---@type Batteries
return _batteries
