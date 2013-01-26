local Node = require "node.Node"

-- this is called when we don't have a valid game directory for
-- whatever reason. It sets up a fake gamedir in memory which the user can
-- use to quit or restart
function emufun.filenotfound(reason)
    emufun.root = Node:new("ERROR")
    
    local screen = emufun.root:add("Error: "..reason)
    function screen:populate() end

    screen:add_command("Restart EmuFun", emufun.restart)
    screen:add_command("Quit EmuFun", emufun.quit)
    
    return emufun.gamelist()
end
