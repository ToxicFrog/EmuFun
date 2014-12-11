--[[
Metadata cache implementation for EmuFun. Each Cache object is responsible
for a single associated cache file; at present each file corresponds to a
single directory, but there's nothing blocking the implementation of an old-
style global cache option, apart from the way Files and Directories query the
cache.


Planned change:
- API turns into attributes directly on the nodes; Node:getattr() and
  Node:setattr() access them (or perhaps node.attr.* + metatables). Setting an
  attribute automatically updates the cache.
- When a node is created, it's passed a cache that should hold its information;
  it queries the cache to get that info, and if it's missing, adds it. It
  assumes that the info is up to date if present -- it's the responsibility of
  the cache loader to check the timestamp of the cache itself against the ts of
  the directory containing it.
- Caches are stored per-directory (as, say, .emufun-metadata). A cache file uses
  relative paths and contains all the information for the contents of the dir.
  It *doesn't* contain information for the directory itself -- that's in the
  cache file in ../. Otherwise, when opening a directory with a lot of subdirs,
  we'd have to read the cache files for all of those subdirs.
- When a directory is opened, it needs to check itself to see if it has an up
  to date cache file; if so, it should load that and pass it to its children
  rather than using readdir().
- Cache format is still up in the air, but something table.dump-based is
  probably the way to go rather than the current ad hoc format.
- Attributes: ts and seen are the currently known ones. Possible future ones:
  colour, icon, seen_count, others?
]]

local Cache = require "Object" :clone("Cache")

flags.register("cache-name") {
  help = "Name of the metadata cache file in each directory";
  default = ".emufun.cache";
  type = flags.string;
}

function Cache:__init(path)
  self.path = path and (path .. "/" .. emufun.config.cache_name);
  self.contents = {};
  self:load()
end

-- The metadata cache is a line-oriented format; each line holds the record for
-- one path, consisting of <attributes> \t <path>.
-- The attributes are semicolon-separated. Each one is either key=value, or
-- just key (in which case the value is implicitly true).
function Cache:load()
  if not self.path then return end
  if not lfs.exists(self.path) then
    log.debug("Creating new cache: %s", self.path)
    self.ts = 0
    self.contents = {}
    return
  end

  log.debug("Loading cache: %s", self.path)
  self.ts = lfs.attributes(self.path, "modification")
  self.contents = {}
  for line in io.lines(self.path) do
    local attrs,path = line:match("(%S*)\t(.*)")
    self.contents[path] = {}
    for attr in attrs:gmatch("[^;]+") do
      local k,v = attr:match("^([^=]+)=(.*)")
      if k then
        self.contents[path][k] = tonumber(v) or v
      else
        self.contents[path][attr] = true
      end
    end
  end
end

function Cache:save()
  if not self.path then return end
  log.debug("Saving cache: %s", self.path)

  local fd,err = io.open(self.path, "wb")
  if not fd then
    log.error("Cache save failed: %s", tostring(err))
    return
  end

  for path,data in pairs(self.contents) do
    local attrs = {}
    for k,v in pairs(data) do
      if v == true then
        table.insert(attrs, k)
      elseif v then
        table.insert(attrs, "%s=%s" % { k, tostring(v) })
      end
    end
    fd:write("%s\t%s\n" % { table.concat(attrs, ";"), path })
  end

  fd:close()
end

function Cache:get(path)
  if not self.contents[path] then
    self.contents[path] = {}
  end
  return self.contents[path]
end

function Cache:all()
  return pairs(self.contents)
end

function Cache:remove(path)
  self.contents[path] = nil
end

return Cache
