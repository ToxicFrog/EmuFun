local cache = {}

local _cache = {}
local CACHE_PATH = love.filesystem.getSaveDirectory().."/cache"

-- cache format
-- TS\tFLAGS\tPATH\n
function cache.load()
  log.info("Loading cache...")
  for line in io.lines(CACHE_PATH) do
    local ts,flags,path = line:match("(%d+)\t(%w*)\t(.*)")
    _cache[path] = { ts = tonumber(ts), flags = {} }
    for flag in flags:gmatch("[^,]+") do
      local k,v = flag:match("^([^:]+):(.*)")
      if k then
        _cache[path].flags[k] = v
      else
        _cache[path].flags[flag] = true
      end
    end
  end
end

function cache.save()
  log.info("Saving cache...")
  local fd = io.open(CACHE_PATH..".tmp", "wb")
  for path,data in pairs(_cache) do
    local flags = {}
    for flag in pairs(data.flags) do
      table.insert(flags, flag)
    end
    fd:write("%d\t%s\t%s\n" % { data.ts, table.concat(flags, ":"), path })
  end
  fd:close()
  local res,err = os.remove(CACHE_PATH)
  if res then
    res,err = os.rename(CACHE_PATH..".tmp", CACHE_PATH)
  end
  if not res then
    log.error("Cache save failed: %s", tostring(err))
  end
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
