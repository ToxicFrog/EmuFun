local settings = {
	"emufun.cfg";	-- main program settings
	"controls.cfg";	-- keybindings
	"library.cfg";	-- top level library configuration
}

-- if this is our first time, write the default configuration files
for _,file in ipairs(settings) do
  love.filesystem.write(file, love.filesystem.read(file))
end

-- load program configuration
eprintf("program ")
emufun.config = { flags = {} }
local config = love.filesystem.load("emufun.cfg")
setfenv(config, emufun.config)
config()

-- parse command line flags
for _,arg in pairs(arg) do
  local flag = arg:match("^%-(%w)") or arg:match("^%-%-([%S])")
  if flag then
    emufun.config.flags[flag] = true
  end
end

-- load input configuration
eprintf("controls ")
local config = love.filesystem.load("controls.cfg")
setfenv(config, setmetatable({ emufun = emufun, love = love }, { __index = input }))
config()

