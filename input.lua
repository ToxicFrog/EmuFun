local function event(name, ...)
    if input[name] then
        input[name](...)
        return true
    end
    return false
end

function love.keypressed(name, num)
    return event("key_"..name)
    or event("key_any", name)
end

function love.joystickpressed(joystick, button)
    local name = "joy_"..joystick.."_button_"..button
    
    return event(name)
    or event("joy_any", joystick, "button", button)
end

local axes = { hat = love.joystick.getHat(0, 0); love.joystick.getAxes(0) }

function love.update(dt)
    local function direction(value)
        return (value == 1 and "up")
        or (value == -1 and "down")
        or (value == 0 and "center")
        or value
    end
    
    local function do_axis(joy, axis, value)
        if axes[axis] ~= value then
            eprintf("axis %d:%d changed from %d to %d\n", joy, axis, value, axes[axis])
            return event("joy_"..joy.."_axis_"..axis.."_"..direction(value))
            or event("joy_any", joy, "axis", axis, direction(value))
        end
    end
    
    local function do_hat(joy, value)
        if value ~= axes.hat then
            return event("joy_"..joy.."_hat_"..value)
            or event("joy_any", joy, "hat", value)
        end
    end
    
    local new_axes = { hat = love.joystick.getHat(0, 0); love.joystick.getAxes(0) }
    
    for axis,value in ipairs(new_axes) do
        do_axis(0, axis, value)
    end
    
    do_hat(0, new_axes.hat)
    
    axes = new_axes
    
    love.timer.sleep(33 - (dt*1000))
end

