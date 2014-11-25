local log_levels = { "error", "warning", "info", "debug" }

local function valid_log_level(flag, s)
  for _,level in pairs(log_levels) do
    if s == level then return s end
  end
  error("Invalid log level: '%s'" % s)
end

flags.register("log-level", "v") {
  help = "Degree of verbosity in logging (error, warning, info, or debug)";
  default = "warning";
  type = valid_log_level;
}
flags.register("log-file") {
  help = "Save logs to this file. strftime() escapes are permitted.";
  default = love.filesystem.getSaveDirectory().."/logs/%F %H.%M.%S.log";
  type = flags.string;
}

local _log
local _log_level = "warning"

LOG = {}
setmetatable(LOG, LOG)

function LOG.init()
  local file = os.date(flags.parsed.log_file)
  _log_level = flags.parsed.log_level

  if flags.parsed.log_file ~= "" then
    if lfs then
      lfs.rmkdir(lfs.dirname(file))
    end
    _log = io.open(file, "a")
  end
end

function LOG:__call(level, ...)
  for i=level,#log_levels do
    if _log_level == log_levels[i] then
      print(log_levels[level]:upper(), string.format(...))
      if _log then
        _log:write(log_levels[level]:upper().."\t"..string.format(...).."\n")
        _log:flush()
      end
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
