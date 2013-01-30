local Object = {}

Object.__index = Object
Object._NAME = "Object"

function Object:new(...)
	local obj = setmetatable({}, self)
	obj:__init(...)
	return obj
end

function Object:clone(name)
	local child = {}

	for k,v in pairs(self) do
		child[k] = v
	end
	child.__index = child
	child._NAME = name
	
	return child
end

-- global object creator
function new(class)
	class = require(class)
	return function(...)
		return class:new(...)
	end
end

return Object
