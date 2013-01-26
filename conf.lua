function love.conf(t)
    t.name = "EmuFun"
    t.author = "Ben 'ToxicFrog' Kelly"
    t.identity = "emufun"
    t.version = "0.8.0"

    t.screen.width = 800
    t.screen.height = 600
    t.screen.fullscreen = false
    t.screen.vsync = true
    t.screen.fsaa = 0

    t.modules.graphics = true
    t.modules.image = true      -- for loading the default filetype images
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.event = true      -- or none of the event handlers work
    t.modules.timer = true      -- for framerate limiting
    t.modules.mouse = true      -- for mouse.setVisible

    t.modules.audio = false
    t.modules.sound = false
    t.modules.physics = false
end
