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

local axes = {}
for joy=0,love.joystick.getNumJoysticks()-1 do
    eprintf("init joystick %d\n", joy)
    axes[joy] = { hat = love.joystick.getHat(joy, 0); love.joystick.getAxes(0) }
end

function love.update(dt)
    local old_axes
    
    local function direction(value)
        return (value == 1 and "up")
        or (value == -1 and "down")
        or (value == 0 and "center")
        or "center"
    end
    
    local function do_axis(joy, axis, value)
        if old_axes[axis] ~= value then
            return event("joy_"..joy.."_axis_"..axis.."_"..direction(value))
            or event("joy_any", joy, "axis", axis, direction(value))
        end
    end
    
    local function do_hat(joy, value)
        if value ~= old_axes.hat then
            return event("joy_"..joy.."_hat_"..value)
            or event("joy_any", joy, "hat", value)
        end
    end
    
    for joy,joy_axes in pairs(axes) do
        local new_axes = { hat = love.joystick.getHat(joy, 0); love.joystick.getAxes(joy) }
        old_axes = joy_axes
        
        for axis,value in ipairs(new_axes) do
            do_axis(joy, axis, value)
        end
        
        do_hat(joy, new_axes.hat)
        axes[joy] = new_axes
    end
    
    love.timer.sleep(33 - (dt*1000))
end

