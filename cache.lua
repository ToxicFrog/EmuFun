local cache = {}

local _cache = {}
local CACHE_PATH = love.filesystem.getSaveDirectory().."/cache"

-- cache format
-- TS\tFLAGS\tPATH\n
function cache.load()
  LOG.INFO("Loading cache...")
  for line in io.lines(CACHE_PATH) do
    local ts,flags,path = line:match("(%d+)\t(%w*)\t(.*)")
    _cache[path] = { ts = tonumber(ts), flags = {} }
    for flag in flags:gmatch("[^:]+") do
      _cache[path].flags[flag] = true
    end
  end
end

function cache.save()
  LOG.INFO("Saving cache...")
  local fd = io.open(CACHE_PATH..".tmp", "wb")
  for path,data in pairs(_cache) do
    local flags = {}
    for flag in pairs(data.flags) do
      table.insert(flags, flag)
    end
    fd:write("%d\t%s\t%s\n" % { data.ts, table.concat(flags, ":"), path })
  end
  fd:close()
  os.rename(CACHE_PATH..".tmp", CACHE_PATH)
end

function cache.get(path)
  if not _cache[path] then
    _cache[path] = { ts = 0, flags = {} }
  end
  return _cache[path]
end

function cache.set(path, data)
  _cache[path] = data
end

io.open(CACHE_PATH, "a"):close() -- create cache file if it doesn't already exist
cache.load()
return cache
