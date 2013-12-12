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
    self:apply()
    self.name = (self.basename .. " [%s]") % (self.value and "ON" or "OFF")
    return 0
end

local keyboard_toggle = ToggleSetting:new {
    name = "Keyboard Input";
    value = input.keyboard_enabled;
    apply = function(self)
        -- Don't let the user turn off the controller and keyboard at the same time.
        if not self.value and not input.controller_enabled then
          self.value = true
        end
        input.keyboard_enabled = self.value
    end;
}

local controller_toggle = ToggleSetting:new {
    name = "Controller Input";
    value = input.controller_enabled;
    apply = function(self)
        -- Don't let the user turn off the controller and keyboard at the same time.
        if not self.value and not input.keyboard_enabled then
          self.value = true
        end
        -- Conversely, if we have no controllers, this can't be turned on.
        self.value = self.value and love.joystick.getNumJoysticks() > 0
        input.controller_enabled = self.value
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

local function reload()
    input.event "menu" -- reload automatically closes the menu
    input.event "reload"
end

emufun.menu = new "node.Menu" { name = "EmuFun";
    commands = {
        new "node.Node" { name = "Reload Directory", run = reload; icon = emufun.images.nothing };
        fullscreen_toggle;
        keyboard_toggle;
        controller_toggle;
        new "node.Node" { name = "Quit EmuFun", run = emufun.quit, icon = emufun.images.nothing };
        new "node.Node" { name = "[DEBUG] Throw Error", run = function() error "User Forced Error" end, icon = emufun.images.error };
    };
}
