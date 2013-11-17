-- Emufun main menu, accessed via the menu key at any time
local Node = require "node.Node"
local ToggleSetting = Node:clone("ToggleSetting")

ToggleSetting.icon = emufun.images.nothing

function ToggleSetting:__init(...)
    Node.__init(self, ...)
    self.basename = self.basename or self.name
    self.name = (self.basename .. " [%s]") % (self.value and "ON" or "OFF")
end

function ToggleSetting:run()
    self.value = not self.value
    self.name = (self.basename .. " [%s]") % (self.value and "ON" or "OFF")
    self:apply()
    return 0
end

local kitten_toggle = ToggleSetting:new {
    name = "Kitten Mode";
    value = false;
    apply = function(self)
        input.keyboard_enabled = not self.value
    end;
}

local fullscreen_toggle = ToggleSetting:new {
    name = "Fullscreen";
    value = emufun.config.fullscreen;
    apply = function(self)
        if emufun.config.fullscreen ~= self.value then
            love.graphics.toggleFullscreen()
        end
        emufun.config.fullscreen = self.value
    end;
}

emufun.menu = new "node.Menu" { name = "EmuFun";
    commands = {
        fullscreen_toggle;
        kitten_toggle;
        new "node.Node" { name = "Quit EmuFun", run = emufun.quit, icon = emufun.images.nothing };
    };
}

print "created menu"