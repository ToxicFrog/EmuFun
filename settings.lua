-- user configurable settings

-- the configuration file prefix
emufun.CONFIG = ".config"
--emufun.CONFIG = ".config.bat" -- for windows

-- the default location of the game directory
emufun.GAMEDIR = "."

-- this function is used to launch a game. This is the standard configuration
-- for Linux, which assumes config files are actually bash scripts.
function emufun.launch(gamedir, rom, config)
    love.graphics.toggleFullscreen()
    os.execute('env GAMEDIR="%s" GAME="%s" CONFIG="%s" bash "%s"' % {
        gamedir,
        rom,
        config,
        config
    })
    love.event.clear()
    love.graphics.toggleFullscreen()
end

-- this is the "old-style" launcher, for when emufun is called by another program
-- which expects it to output the settings on stdout and then exit
--[[
function emufun.launch(gamedir, rom, config)
    print('GAMEDIR="%s" ROM="%s" CONFIG="%s"' % { gamedir, rom, config })
    emufun.quit()
end
--]]
