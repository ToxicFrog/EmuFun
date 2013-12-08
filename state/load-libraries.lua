local Node = require "node.Node"
local Directory = require "node.Directory"

local function liberror(message)
    local node = new "node.Node" { name = message }
    node.icon = emufun.images.error

    node:add_command("Quit EmuFun", emufun.quit)

    return node
end

local root = new "node.Node" { name = "EmuFun" }
root.icon = emufun.images.directory

local getfenv = getfenv
local _config = emufun.config._library_config_fn
function root:config()
    return _config(getfenv())
end

local library = new "node.Node" { name = "Media Library", parent = root }
library.icon = emufun.images.directory

function library:run()
    return unpack(self)
end
function library:path()
    return ""
end

root:add(library)

local configs = new "node.Directory" { name = "Configuration Files", parent = root }
function configs:path(name)
    return love.filesystem.getSaveDirectory().."/config/"..(name or "")
end

-- TODO: add a "text" file type, with appropriate default editor and icon, and
-- add a library rule for editing files of that type.
configs.config = loadstring [[
    name_matches "%.cfg" {
        hidden = false;
        execute = emufun.config.editor.." ${path}";
    }
]]

root:add(configs)

for _,path in ipairs(emufun.config.library_paths) do
    local lib = new "node.Directory" { name = path, parent = library }
    lib:populate()

    if lib[1] then
        library:add(lib)
    end
end

if #library == 0 then
    library:add(liberror("Media library is empty!"))
end

return state "gamelist" (root, library)
