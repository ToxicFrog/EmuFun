local Node = require "node.Node"
local Directory = require "node.Directory"

local function liberror(message)
    local node = new "node.Node" (message)
    node.icon = emufun.images.error

    node:add_command("Restart EmuFun", emufun.restart)
    node:add_command("Quit EmuFun", emufun.quit)

    return node
end

function emufun.loadgames()
    eprintf("Reading game library: ")
    emufun.library = {}

    local lib = Directory:new(arg[2] or os.getenv("GAMEDIR") or emufun.config.library_path)
    lib:populate()
    lib.displayname = "EmuFun Library"

    if not lib[1] then
        -- we couldn't find anything in the gamedir!
        eprintf("failed!\n")

        lib = liberror("Media library is empty!")
    end
    eprintf("done\n")

    table.insert(emufun.library, lib)
    
    return emufun.gamelist()
end
