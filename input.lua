-- Input handling library. This is meant to simplify the handling of keyboard
-- and joystick events.
-- Note that it doesn't really support joystick axes except as d-pads - that is
-- to say, pushing an axis all the way will register as (say) "up" and anything
-- else is "center".
require "timer"

timer.create("IDLE", 60)
timer.start("IDLE")

input = {}

input.keyboard_enabled = true
input.controller_enabled = true

-- event bindings
local bindings = {}

-- Dispatch an event with the given names and arguments.
-- Returns true if an event handler existed, false otherwise
function input.event(name, ...)
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
-- key_a() or, if that doesn't exist, key_any('a')
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

-- same as above, but for joysticks. Joystick events are parameterized by both
-- stick and button; button 3 on stick 0 shows up as joy_0_button_3.
function love.joystickpressed(j, b)
    if input.controller_enabled then
        return input.event("joy_"..j.."_button_"..b, j, "button", b)
    end
end

function love.joystickreleased(j, b)
    if input.controller_enabled then
        return input.event("!joy_"..j.."_button_"..b, j, "button", b)
    end
end

-- joystick axis handling. At initialization, read the state of every axis on
-- every joystick and record them. We emit events only if the state of an
-- axis changes between frames, so that someone holding a stick up doesn't
-- trigger (say) joy_0_axis_2_up every single frame.
local function readJoystick(j)
    local function dir(val)
        if val > 0.95 then
            return "up"
        elseif val < -0.95 then
            return "down"
        else
            return "center"
        end
    end

    local axes = { hats = {}; love.joystick.getAxes(j) }
    for i=1,love.joystick.getNumHats(j) do
        axes.hats[i] = love.joystick.getHat(j, i)
    end
    for a=1,#axes do
        axes[a] = dir(axes[a])
    end

    return axes
end

local joysticks = {}
for joy=1,love.joystick.getNumJoysticks() do
    joysticks[joy] = readJoystick(joy)
end

-- Every frame, scan joystick axes, compare them to the previous frame, and
-- emit events for any that have changed.
local _update = love.update
function love.update(dt)
    _update(dt)

    if not input.controller_enabled then
        return
    end

    -- scan joysticks
    for j,axes in ipairs(joysticks) do
        new_axes = readJoystick(j)

        -- check hats
        for h,ndir in ipairs(new_axes.hats) do
            -- hat has moved since last time
            local dir = axes.hats[h]
            if ndir ~= dir then
                input.event("!joy_"..j.."_hat_"..h.."_"..dir, j, "hat", h, dir)
                input.event("joy_"..j.."_hat_"..h.."_"..ndir, j, "hat", h, ndir)
            end
        end

        -- check sticks
        for a,ndir in ipairs(new_axes) do
            local dir = axes[a]
            if ndir ~= dir then
                input.event("!joy_"..j.."_axis_"..a.."_"..dir, j, "axis", a, dir)
                input.event("joy_"..j.."_axis_"..a.."_"..ndir, j, "axis", a, ndir)
            end
        end

        -- store results
        joysticks[j] = new_axes
    end
end
