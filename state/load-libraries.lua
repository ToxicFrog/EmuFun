local Node = require "node.Node"
local Directory = require "node.Directory"

local function liberror(message)
    local node = new "node.Node" (message)
    node.icon = emufun.images.error

    node:add_command("Quit EmuFun", emufun.quit)

    return node
end

local root,library

root = new "node.Node" ("EmuFun")
root.icon = emufun.images.directory

library = new "node.Node" ("Media Library", root)
library.icon = emufun.images.directory
library.config = love.filesystem.load("library.cfg")
function library:run()
    return unpack(self)
end
function library:path()
    return ""
end

root:add(library)

for _,path in ipairs(emufun.config.library_paths) do
    local lib = Directory:new(path, library)
    lib:populate()

    if lib[1] then
        library:add(lib)
    end
end

if #library == 0 then
    library:add(liberror("Media library is empty!"))
end

return state "gamelist" (root, library)
