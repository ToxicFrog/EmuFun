function love.conf(t)
    t.name = "EmuFun"
    t.author = "Ben 'ToxicFrog' Kelly"
    t.identity = "emufun"
    t.version = 0

    t.screen.width = 640
    t.screen.height = 480
    t.screen.fullscreen = false
    t.screen.vsync = true
    t.screen.fsaa = 0

    t.modules.joystick = true
    t.modules.graphics = true
    t.modules.keyboard = true
    t.modules.event = true
    t.modules.timer = true
    t.modules.mouse = true

    t.modules.audio = false
    t.modules.image = false
    t.modules.sound = false
    t.modules.physics = false
end
