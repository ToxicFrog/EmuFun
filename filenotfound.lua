function emufun.filenotfound(reason)
    local W,H = love.graphics.getWidth(),love.graphics.getHeight()
    input.key_any = nil
    input.joy_any = nil

    function love.draw()
        local lg = love.graphics
        local clip = lg.setScissor

        lg.printf("Error reading game directory:\n"..(os.getenv("GAMEDIR") or "./").."\n\n"..reason, 20, 40, W-40, "center")
        
    end
end
