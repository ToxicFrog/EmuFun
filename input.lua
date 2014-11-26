-- Input handling library. This is meant to simplify the handling of keyboard
-- and joystick events.
-- Note that it doesn't really support joystick axes except as d-pads - that is
-- to say, pushing an axis all the way will register as (say) "up" and anything
-- else is "center".
require "timer"

timer.create("IDLE", 60)
timer.start("IDLE")

input = {}

-- Keyboard input always starts enabled. Controller input is enabled
-- only if at least one controller is present.
-- TODO: Allow the user to force a rescan of controllers, so that
-- controllers can be added and removed while emufun is running -
-- assuming that the engine supports this.
input.keyboard_enabled = true
input.controller_enabled = love.joystick.getJoystickCount() > 0

-- event bindings
local bindings = {}

-- window focus status
local focus = true
function love.focus(f)
    focus = f
end

-- Dispatch an event with the given names and arguments.
-- Returns true if an event handler existed, false otherwise
function input.event(name, ...)
    -- silently disregard all events if not focused
    if not focus then return end
    timer.reset("IDLE")

    if name:sub(1,1) == "!" then
        -- if a keyup event, stop the key-repeat timer
        timer.stop(name:sub(2))
    else
        timer.start(name)
    end
    if bindings[name] then
        bindings[name](...)
        return true
    end
    return false
end

function input.bind(from, to, up)
    if type(to) == "string" then
        bindings[from] = function(...)
            return input.event(to, ...)
        end
        bindings["!"..from] = function(...)
            return input.event(up or "!"..to, ...)
        end
    else
        bindings[from] = to
        bindings["!" .. from] = up
    end
end

function input.unbind(from, rest, ...)
    bindings[from] = nil
    if rest then
        return input.unbind(rest, ...)
    end
end

function input.unbindall()
    bindings = {}
end

-- enable key repeat for the given event
-- delay the amount of time to wait until it starts repeating, period is how
-- frequently to emit the repeated events.
-- eg: love.set_repeat("key_a", 1.0, 0.5)
function input.setRepeat(event, delay, period)
    if delay then
        timer.create(event, delay, period)
    else
        timer.destroy(event)
    end
end

-- love2d callback function for keyboard events. Pressing 'a' will trigger event
-- key_a.
function love.keypressed(name, num)
    if input.keyboard_enabled then
        return input.event("key_"..name)
    end
end

function love.keyreleased(name, num)
    if input.keyboard_enabled then
        return input.event("!key_"..name)
    end
end

-- The same, but for gamepads. Note that each event triggers "pad_X_Y", but if
-- there is no event handler, falls through to "pad_*_Y", so that you can bind
-- things to (e.g.) "the A button on any connected gamepad".
function love.gamepadpressed(pad, button)
    if input.controller_enabled then
        return input.event("pad_"..pad:getID().."_"..button)
            or input.event("pad_*_"..button)
    end
end

function love.gamepadreleased(pad, button)
    if input.controller_enabled then
        return input.event("!pad_"..pad:getID().."_"..button)
            or input.event("!pad_*_"..button)
    end
end
