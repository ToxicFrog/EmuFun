local log_levels = { "error", "warning", "info", "debug" }

LOG = {}
setmetatable(LOG, LOG)

function LOG:__call(level, ...)
  for i=level,#log_levels do
    if emufun.config.flags["log_"..log_levels[i]] then
      print(log_levels[level]:upper(), string.format(...))
      if emufun._log then
        emufun._log:write(log_levels[level]:upper().."\t"..string.format(...).."\n")
        emufun._log:flush()
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
