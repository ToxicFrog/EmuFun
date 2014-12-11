local Node = require "node.Node"
local File = require "node.File"
local Configuration = require "Configuration"
local Directory = Node:clone("node.Directory")

Directory.icon = emufun.images.directory

function Directory:__init(...)
    Node.__init(self, ...)
    self.attr = self.cache:get(self.name)
    self.attr.dir = true

    local cfg = new "Configuration" (self)
    -- Only our parent's configuration applies to us; ./.emufun doesn't affect
    -- us and we haven't loaded it yet anyways.
    self.parent:configure(cfg)
    cfg:finalize()
end

function Directory:colour()
    if self.attr.seen then
        return 0, 192, 255
    else
        return Node.colour(self)
    end
end

function Directory:walk(f)
    self:populate()
    return Node.walk(self, f)
end

function Directory:run()
    -- "running" a directory just populates it and CDs into it
    self:populate()

    if #self == 0 then
        return new "node.Message" { name = self.name, message = "Directory is empty!", parent = self.parent }
    end

    return self
end

-- An emufun config file inside a directory applies to that directory's children,
-- but not to the directory itself. Thus, it's not loaded until we populate the
-- directory.
function Directory:loadConfigForChildren()
    for _,name in ipairs(emufun.config.cfg_names) do
        local config = loadfile(self:path(name))
        if config then
            self.config = config
            break
        end
    end
end

function Directory:populate(...)
    -- Load the configuration file, if one exists and we haven't previously.
    self:loadConfigForChildren()

    -- Load the metadata cache.
    -- We stat() the cache whenever this happens to see if we need to reread
    -- the disk or can just rely on the cache.
    local ts = lfs.attributes(self:path(), "modification")
    local cache = new "Cache" (self:path())

    if not self.config or cache.ts < ts then
        self:loadConfigForChildren()
    end

    local nodes
    if cache.ts >= ts then
        log.debug("Directory '%s' cache hit", self:path())
        nodes = self:populateFromCache(cache)
    else
        log.debug("Directory '%s' cache miss (%d < %d)", self:path(), cache.ts, ts)
        nodes = self:populateFromDisk(cache)
        cache:save()
    end

    -- Replace current population of children.
    for i=1,#self do
        self[i] = nil
    end
    for node in pairs(nodes) do
        if not node.hidden then
            self:add(node)
        end
    end

    self:sort()
end

function Directory:populateFromCache(cache)
    local nodes = {}
    for path,attrs in cache:all() do
        local node = new(attrs.dir and "node.Directory" or "node.File") {
            name = path, parent = self, cache = cache;
        }
        nodes[node] = true
    end
    return nodes
end

function Directory:populateFromDisk(cache)
    local nodes = {}
    for item in lfs.dir(self:path()) do
        local is_dir = lfs.attributes(self:path(item), "mode") == "directory"
        local node = new(is_dir and "node.Directory" or "node.File") {
            name = item, parent = self, cache = cache;
        }
        nodes[node] = true
    end
    return nodes
end

function Directory:dir()
    return self:path()
end

return Directory
