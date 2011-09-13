local co = coroutine

function emufun.calibration()
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    local message = "?"
    local controls = {}
    
    local function calibrate()
        local function ask_input(gesture)
            local key
            repeat
                key = co.yield(gesture)
                print(key, controls[key])
            until not controls[key]
            return key
        end
        
        local function command(gesture, fn)
            controls[ask_input(gesture)] = fn
        end
        
        command("up", emufun.prev_game)
        command("down", emufun.next_game)
        command("left", emufun.prev_system)
        command("right", emufun.next_system)
        command("ok", emufun.down)
        command("cancel", emufun.up)
        
        table.copy(controls, input)
        
        input.key_any = nil
        input.joy_any = nil
        
        return emufun.loadgames()
    end
    
    local calibrator = co.wrap(calibrate)
    message = calibrator()
        
    function love.draw()
        local lg = love.graphics
        
        lg.printf("CALIBRATION", 0, 0, W, "center")
        lg.printf("Press button for "..message, 0, H/2-20, W, "center")
    end
        
    function input.key_any(key)
        message = calibrator("key_"..key)
    end
        
    function input.joy_any(joy, type, a, b)
        local name
        if type == "button" then
            name = ("joy_%d_button_%d"):format(joy, a)
        elseif type == "axis" and b ~= "center" then
            name = ("joy_%d_axis_%d_%s"):format(joy, a, b)
        elseif type == "hat" and a ~= "c" then
            name = ("joy_%d_hat_%s"):format(joy, a)
        else
            return
        end
        message = calibrator(name)
    end
end
