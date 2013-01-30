-- infrastructure for loading and running emufun configuration files
-- this is the environment that configuration files are run in, and provides
-- all the functions that they can use

local env = {}
local Node = require "node.Node"

local function firstof(k, ...)
	for _,t in ipairs {...} do
		if t[k] ~= nil then
			return t[k]
		end
	end
	return nil
end

local function contains(t, k)
	return t[k] ~= nil
end

function Node:configure_env()
	local mt = {}

	function mt.__newindex(proxy,k,v)
		self[k] = v
	end

	function mt.__index(proxy,k)
		if contains(self, k) then
			return self[k]
		elseif contains(env, k) then
			return function(...) return env[k](self, ...) end
		else
			return firstof(k, emufun, love, _G)
		end
	end

	return setmetatable({}, mt)
end

local function bind(self)
	return function(settings)
		for k,v in pairs(settings) do
			self[k] = v
		end
	end
end

local function skip() end

local function test(self, f, lhs, ...)
	if lhs == nil then return skip end
	for _,rhs in ipairs {...} do
		if f(lhs, rhs) then return bind(self) end
	end
	return skip
end

function env:type_is(...)
	return test(self, function(x,y) return x == y end, self.type, ...)
end

function env:type_contains(...)
	return test(self, function(x,y) return x:find(y) end, self.type, ...)
end

function env:type_matches(...)
	return test(self, function(x,y) return x:match(y) end, self.type, ...)
end

function env:name_is(...)
	return test(self, function(x,y) return x == y end, self.name, ...)
end

function env:name_contains(...)
	return test(self, function(x,y) return x:find(y) end, self.name, ...)
end

function env:name_matches(...)
	return test(self, function(x,y) return x:match(y) end, self.name, ...)
end

function env:extension(...)
	return test(self, function(x,y) return x:match("%."..y.."$") end, self.name, ...)
end

function env:path_is(...)
	return test(self, function(x,y) return x == y end, self:path(), ...)
end

function env:path_contains(...)
	return test(self, function(x,y) return x:find(y) end, self:path(), ...)
end

function env:path_matches(...)
	return test(self, function(x,y) return x:match(y) end, self:path(), ...)
end
