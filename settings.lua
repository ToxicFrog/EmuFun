local settings = {
	"emufun.cfg";	-- main program settings
	"controls.cfg";	-- keybindings
	"library.cfg";	-- top level library configuration
}

-- if this is our first time, write the default configuration files
for _,file in ipairs(settings) do
	--love.filesystem.write(file, love.filesystem.read(file))
end

-- load program configuration
eprintf("program ")
emufun.config = {}
local config = love.filesystem.load("emufun.cfg")
setfenv(config, emufun.config)
config()

-- load library configuration
eprintf("library ")

-- load input configuration
eprintf("controls ")
local config = love.filesystem.load("controls.cfg")
setfenv(config, { bind = input.bind })
config()
