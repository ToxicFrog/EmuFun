function love.conf(t)
    t.name = "EmuFun"
    t.author = "Ben 'ToxicFrog' Kelly"
    t.identity = "emufun"
    t.version = "0.9.1"

    t.console = true -- enable console on windows for debug logging

    t.window.title = 'EmuFun'
    t.window.resizable = false
    t.window.width = 0
    t.window.height = 0
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"

    t.modules.graphics = true
    t.modules.window = true
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
