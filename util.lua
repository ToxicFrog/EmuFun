function eprintf(...)
    return io.stderr:write(string.format(...))
end

function state(name)
    return function(...)
        return love.filesystem.load("state/" .. name .. ".lua")(...)
    end
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

-- temporary settings structure
emufun.config = { flags = { log_debug = true } }

local log_levels = { "error", "warning", "info", "debug" }

LOG = {}
setmetatable(LOG, LOG)

function LOG:__call(level, ...)
    for i=level,#log_levels do
        if emufun.config.flags["log_"..log_levels[i]] then
            print(log_levels[level]:upper(), ...)
            return
        end
    end
end

function LOG.ERROR(...)
    return LOG(1, ...)
end

function LOG.WARNING(...)
    return LOG(2, ...)
end

function LOG.INFO(...)
    return LOG(3, ...)
end

function LOG.DEBUG(...)
    return LOG(4, ...)
end
