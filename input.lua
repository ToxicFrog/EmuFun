-- Input handling library. This is meant to simplify the handling of keyboard
-- and joystick events.
-- Note that it doesn't really support joystick axes except as d-pads - that is
-- to say, pushing an axis all the way will register as (say) "up" and anything
-- else is "center".
input = {}

-- Dispatch an event with the given names and arguments.
-- Returns true if an event handler existed, false otherwise
local function event(name, ...)
    if input[name] then
        input[name](...)
        return true
    end
    return false
end

-- love2d callback function for keyboard events. Pressing 'a' will trigger event
-- key_a() or, if that doesn't exist, key_any('a')
function love.keypressed(name, num)
    return event("key_"..name)
    or event("key_any", name)
end

-- same as above, but for joysticks. Joystick events are parameterized by both
-- stick and button; button 3 on stick 0 shows up as joy_0_button_3.
function love.joystickpressed(joystick, button)
    local name = "joy_"..joystick.."_button_"..button
    
    return event(name)
    or event("joy_any", joystick, "button", button)
end

-- joystick axis handling. At initialization, read the state of every axis on
-- every joystick and record them. We emit events only if the state of an
-- axis changes between frames, so that someone holding a stick up doesn't
-- trigger (say) joy_0_axis_2_up every single frame.
local axes = {}
for joy=0,love.joystick.getNumJoysticks()-1 do
    axes[joy] = { hat = love.joystick.getHat(joy, 0); love.joystick.getAxes(0) }
end

-- Every frame, scan joystick axes, compare them to the previous frame, and
-- emit events for any that have changed.
function love.update(dt)
    local old_axes
    
    -- translate a joystick axis value into a descriptive string
    local function direction(value)
        return (value == 1 and "up")
        or (value == -1 and "down")
        or "center"
    end
    
    -- check a single axis, and emit an event if it changed
    local function do_axis(joy, axis, value)
        if old_axes[axis] ~= value then
            return event("joy_"..joy.."_axis_"..axis.."_"..direction(value))
            or event("joy_any", joy, "axis", axis, direction(value))
        end
    end
    
    -- check a hat-switch, and emit an event if it changed.
    -- FIXME: this should work for multiple hats on the same stick.
    local function do_hat(joy, value)
        if value ~= old_axes.hat then
            return event("joy_"..joy.."_hat_"..value)
            or event("joy_any", joy, "hat", value)
        end
    end
    
    -- iterate over all the axes on all the joysticks and check them
    for joy,joy_axes in pairs(axes) do
        local new_axes = { hat = love.joystick.getHat(joy, 0); love.joystick.getAxes(joy) }
        old_axes = joy_axes
        
        for axis,value in ipairs(new_axes) do
            do_axis(joy, axis, value)
        end
        
        do_hat(joy, new_axes.hat)
        axes[joy] = new_axes
    end
    
    -- cap framerate at 30fps
    love.timer.sleep(33 - (dt*1000))
end

