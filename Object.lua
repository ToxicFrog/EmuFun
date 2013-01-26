local Object = {}

Object.__index = Object

function Object:new(...)
	local obj = setmetatable({}, self)
	obj:__init(...)
	return obj
end

function Object:clone()
	local child = {}

	for k,v in pairs(self) do
		child[k] = v
	end
	child.__index = child
	
	return child
end

return Object
