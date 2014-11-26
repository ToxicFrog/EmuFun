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
  default = love.filesystem.getSaveDirectory().."/logs/%Y-%m-%d %H.%M.%S.log";
  type = flags.string;
}

local _log

log = {}
setmetatable(log, log)

function log.init()
  local file = os.date(flags.parsed.log_file)

  if flags.parsed.log_file ~= "" then
    if lfs then
      lfs.rmkdir(lfs.dirname(file))
    end
    _log = io.open(file, "a")
    log.info("Opened log file '%s'", file)
  end
end

function log:__call(level, ...)
  for i=level,#log_levels do
    if flags.parsed.log_level == log_levels[i] then
      print(log_levels[level]:upper(), string.format(...))
      if _log then
        _log:write(log_levels[level]:upper().."\t"..string.format(...).."\n")
        _log:flush()
      end
      return
    end
  end
end

function log.error(...)
  return log(1, ...)
end

function log.warning(...)
  return log(2, ...)
end

function log.info(...)
  return log(3, ...)
end

function log.debug(...)
  return log(4, ...)
end
