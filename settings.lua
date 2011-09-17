-- user configurable settings

-- the configuration file prefix
emufun.CONFIG = ".config"
--emufun.CONFIG = ".config.bat" -- for windows

-- the default location of the game directory
emufun.GAMEDIR = "."

-- graphics configuration. If omitted or commented out (which is the default),
-- emufun will use fullscreen and the largest available resolution.
--emufun.WIDTH = 1680
--emufun.HEIGHT = 1050
--emufun.FULLSCREEN = true

-- this function is used to launch a game. This is the standard configuration
-- for Linux, which assumes config files are actually bash scripts. Arguments
-- are passed in as environment variables GAMEDIR, GAME, and CONFIG.
function emufun.launch(gamedir, rom, config)
    if emufun.FULLSCREEN then love.graphics.toggleFullscreen() end
    
    os.execute('env GAMEDIR="%s" GAME="%s" CONFIG="%s" bash "%s"' % {
        gamedir,
        rom,
        config,
        config
    })
    love.event.clear()

    if emufun.FULLSCREEN then love.graphics.toggleFullscreen() end
end

-- this is the "old-style" launcher, for when emufun is called by another program
-- which expects it to output the settings on stdout and then exit
--[[
function emufun.launch(gamedir, rom, config)
    print('GAMEDIR="%s" ROM="%s" CONFIG="%s"' % { gamedir, rom, config })
    emufun.quit()
end
--]]
