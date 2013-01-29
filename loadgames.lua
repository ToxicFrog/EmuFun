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

    for _,path in ipairs(emufun.config.library_paths) do
        local lib = Directory:new(path)
        lib:populate()

        if lib[1] then
            table.insert(emufun.library, lib)
        end
    end
    
    if #emufun.library == 0 then
        table.insert(emufun.library, liberror("Media library is empty!"))
    end
    eprintf("done.\n")

    return emufun.gamelist()
end
