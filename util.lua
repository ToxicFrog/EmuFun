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
