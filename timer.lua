-- settable, repeating timers
-- timers generate input events that match their names
-- so, to set up, say, a timer that fires every minute, you do
-- timer.create("mytimer", 60, 60)
-- timer.start("mytimer")
-- input.bind("mytimer", handle_mytimer)

timer = {}

local timers = {}

-- create a new (but not yet active) timer with the given delay and period
-- when started, it will fire after -delay- seconds and then repeat every
-- -period- seconds. If there is no period specified, the timer will fire
-- only once and must be manually restarted afterwards.
function timer.create(name, delay, period)
  print("timer created", name, delay, period)
  timers[name] = { delay = delay, period = period }
end

-- completely delete (and stop if running) a timer.
function timer.destroy(name)
  timers[name] = nil
end

-- start a timer. If the timer does not exist and t (and optionally period)
-- are specified, creates it first. If the timer does not exist and t is not
-- specified, does nothing.
-- If the timer does exist, starts it with the following rules:
-- - if t is specified, set the timer to go off in t seconds
-- - if t is unspecified but the timer is already running, leaves it alone
-- - if t is unspecified and the timer is not running, set it go off in -delay- seconds
function timer.start(name, t, period)
  if not timers[name] then
    if not t then
      return
    end
    timer.create(name, t, period)
  end

  print("timer started", name, delay, period)
  timers[name].t = t or timers[name].t or timers[name].delay
end

-- reset a timer to its default delay even if it's already running
function timer.reset(name)
  timer.start(name, timers[name].delay)
end

-- stop a timer without destroying it.
function timer.stop(name)
  if timers[name] then
    timers[name].t = nil
  end
end

local _update = love.update
function love.update(dt)
  for evt,timer in pairs(timers) do
    -- only active timers have .t set
    if timer.t then
      timer.t = timer.t - dt
      if timer.t <= 0 then
        print("timer fired", evt, timer.period)
        input.event(evt)
        -- non-repeating timers have period=nil so this automatically clears the timer
        timer.t = timer.period
      end
    end
  end
end
