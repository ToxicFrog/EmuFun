local Node = require "node.Node"
local File = Node:clone("node.File")

File.icon = emufun.images.file

function File:__init(...)
    Node.__init(self, ...)
    self.attr = self.cache:get(self.name)

    -- load configuration from disk, if present
    local cfg = new "Configuration" (self)
    self:loadConfig()
    self:configure(cfg)
    cfg:finalize()
end

function File:colour()
    if self.attr.seen then
        return 0, 192, 255
    else
        return Node.colour(self)
    end
end

-- Files named "foo.emufun" are loaded as config files and applied to themselves;
-- this lets you write a foo.emufun that shows up as foo and has a custom run
-- function.
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
            log.info("Executing command: %s", cmd)
            log.debug("  => %s", tostring(os.execute(cmd)))
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
        local fs = love.window.getFullscreen()
        window.fullscreen(false)

        local rv = exec(self.execute) or 0

        if not self.attr.seen then
            self.attr.seen = true
            self.cache:save()
        end

        window.fullscreen(fs)
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
