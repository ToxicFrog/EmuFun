local cache = require "cache"
local Node = require "node.Node"
local File = Node:clone("node.File")

File.icon = emufun.images.file

function File:__init(...)
    Node.__init(self, ...)

    -- load configuration from disk, if present
    local cfg = new "Configuration" (self)
    self:loadConfig()
    self:configure(cfg)
    cfg:finalize()

    -- load cache data
    self.metadata = lfs.attributes(self:path())
    self.cache = cache.get(self:path())
    if self.metadata.modification ~= self.cache.ts then
        LOG.DEBUG("File '%s' updated (%d ~= %d), updating cache", self:path(), self.metadata.modification, self.cache.ts)
        self.cache.ts = self.metadata.modification
        cache.save()
    end
end

function File:colour()
    if self.cache.flags.seen then
        return 0, 192, 255
    else
        return Node.colour(self)
    end
end

function File:loadConfig()
    if self.name:match("%.emufun$") then
        self.config = assert(loadfile(self:path()))
    end
end

if love._os == "Windows" then
    function File:expandcommand(string)
        return '"' .. string:gsub("$%b{}", function(match)
            match = match:sub(3,-2)
            if type(self[match]) == "function" then
                return '"' .. tostring(self[match](self)) .. '"'
            else
                return '"' .. tostring(self[match]) .. '"'
            end
        end) .. '"'
    end
else
    function File:expandcommand(string)
        local function escape(string)
            return (string:gsub("'", [['\'']]))
        end
        return (string:gsub("$%b{}", function(match)
            match = match:sub(3,-2)
            if type(self[match]) == "function" then
                return "'" .. escape(tostring(self[match](self))) .. "'"
            else
                return "'" .. escape(tostring(self[match])) .. "'"
            end
        end))
    end
end

function File:run()
    local function exec(v)
        if type(v) == "function" then
            return v(self)
        elseif type(v) == "string" then
            local cmd = self:expandcommand(v)
            os.execute(cmd)
            return false
        elseif type(v) == "table" then
            local rv
            for _,command in ipairs(v) do
                rv = exec(v)
            end
            return rv
        else
            return new "node.Message" { name = "Error executing commands for " .. self:path(), message = "Unknown command type " .. type(v), parent = self.parent }
        end
    end

    -- the configuration file should define a command to execute
    -- if not, we fall through to the error
    if self.execute then
        if emufun.config.fullscreen then
            love.graphics.toggleFullscreen()
        end

        local rv = exec(self.execute) or 0

        if not self.cache.flags.seen then
            self.cache.flags.seen = true
            cache.save()
        end

        if emufun.config.fullscreen then
            love.graphics.toggleFullscreen()
        end
        return rv
    end
    
    return new "node.Message" { name = "Error!", message = "No configuration available to execute this file", parent = self.parent }
end

function File:dir()
    return self.parent:path()
end

function File:extension()
    return self.name:match("%.([^%.]+)$")
end

return File
