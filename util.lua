function eprintf(...)
    return io.stderr:write(string.format(...))
end

getmetatable("").__mod = function(self, arg)
    if type(arg) == "table" then
        return self:format(unpack(arg))
    else
        return self:format(arg)
    end
end

function io.readn(name, len)
    local fd = io.open(name, "rb")
    if not fd then return nil end
    
    local buf = fd:read(len)
    fd:close()
    return buf
end

function table.copy(from, to)
    to = to or {}
    
    for k,v in pairs(from) do
        to[k] = v
    end
    
    return to
end
