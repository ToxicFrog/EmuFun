-- infrastructure for loading and running emufun configuration files
-- this is the environment that configuration files are run in, and provides
-- all the functions that they can use

local env = {}
local Node = require "node.Node"
local Configuration = Node:clone("Configuration")

local function firstof(k, ...)
	for _,t in ipairs {...} do
		if t[k] ~= nil then
			return t[k]
		end
	end
	return nil
end

local tests = {}

function tests._is(x,y)
	return x == y
end

function tests._in(x, y)
	for _,v in ipairs(y) do
		if x == v then return true end
	end
	return false
end

function tests._matches(x,y)
	return x:match(y) ~= nil
end

function tests._contains(x,y)
	return x:find(y, 1, true) ~= nil
end

function Configuration:mkcond(key, testname, ...)
	local test = tests[testname]
	local vals = {...}
	local function f()
		local lhs = self.env[key]
		if type(lhs) == "function" then
			lhs = lhs(self.node)
		end

		for _,rhs in ipairs(vals) do
			if test(lhs, rhs) then
				return true
			end
		end
	end

	return function(settings)
		table.insert(self.conds, {f,settings})
	end
end

-- initialize a new Configuration for the given node.
function Configuration:__init(node)
	self.fns = {}
	self.conds = {}
	self.env = {}
	self.node = node

	local mt = {}
	function mt.__index(env, k)
		-- if they're requesting a conditional function, generate and return one
		-- conditional functions take a list of matching values and return a function
		-- that takes a table of settings to apply when the condition matches
		local prop,test = k:match("(%w+)(_%w+)")
		if tests[test] then
			return function(...)
				return self:mkcond(prop, test, ...)
			end
		end

		-- otherwise forward to _G
		return firstof(k, node, emufun, love, _G)
	end

	setmetatable(self.env, mt)
end

-- add a configuration function to this node. It will be added to the
-- queue.
function Configuration:add(fn)
	table.insert(self.fns, fn)
end

-- finalize the configuration and bind its settings to the associated node.
-- This first executes all :added configuration functions; unconditional
-- settings and conditionals that succeed are applied immediately. Conditionals
-- that fail are deferred and retried once all configuration functions have
-- executed. Retries cease when there are no deferred conditionals left, or
-- none of the remaining ones have succeeded.
-- Once this process is complete, the resulting settings are applied to the
-- corresponding node.
function Configuration:finalize()
	for _,fn in ipairs(self.fns) do
		setfenv(fn, self.env)
		fn()
	end

	repeat
		local pass = false
		local newconds = {}
		for _,cond in ipairs(self.conds) do
			local r = self:realize(cond)
			if r then
				pass = true
			else
				table.insert(newconds, cond)
			end
		end
		self.conds = newconds
	until not pass or (#self.conds == 0)

	for k,v in pairs(self.env) do
		self.node[k] = v
	end
end

function Configuration:realize(cond)
	if cond[1]() then
		for k,v in pairs(cond[2]) do
			self.env[k] = v
		end
		return true
	end
end

return Configuration
