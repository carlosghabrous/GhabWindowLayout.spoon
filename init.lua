local obj = {}

obj.__index = obj
obj.name = "GhabWindowLayout"


-- local laptopScreen = hs.screen.allScreens()[1]:name()
-- local extraScreen = hs.screen.allScreens()[2]:name()

-- local layoutLaptopOnly = {
    --     {"Firefox", nil, laptopScreen, hs.layout.maximized, nil, nil}, -- first space
    --     {"Code", nil, laptopScreen, hs.layout.maximized, nil, nil}, -- second space
    --     {"iTerm2", nil, laptopScreen, hs.layout.maximized, nil, nil}, -- third space
    --     {"Spotify", nil, extraScreen, hs.layout.maximized, nil, nil},
    -- }
    
-- local layoutExtraScreen = {
    --     {"Firefox", nil, laptopScreen, hs.layout.maximized, nil, nil},
    --     {"Code", nil, extraScreen, hs.layout.maximized, nil, nil},
    --     {"iTerm2", nil, extraScreen, hs.layout.maximized, nil, nil},
    -- }
    
    -- function obj:_numberOfScreens()
    --     local count = 0
    --     for _ in pairs(hs.screen.allScreens()) 
    --     do 
    --         count = count + 1
    --     end
    --     return count
    -- end
function obj:restoreLastRecordedLayout
end


function obj:initWindowMovementBinding
end

-- Function
-- Sets the default log level and initializes a log instance with that default value
function obj:initLogger()
    local logLevel = 3
    obj.logger = hs.logger.new(obj.name)
    obj.logger.setLogLevel(logLevel)
    
end

-- Function
function obj:init()
    obj:initLogger()
    
    obj.logger.i(string.format("Loading %s...", obj.name))
    
    obj.logger.i("Loading bindings...")
    obj:initWindowMovementBinding()

    obj.logger.i("Restoring last layout...")
    obj:restoreLastRecordedLayout()

    -- if self:_numberOfScreens() == 2 then
    --     hs.layout.apply(layoutExtraScreen)
    -- else
    --     hs.layout.apply(layoutLaptopOnly)
    -- end
        
end

-- bind this to key combination
-- select the current window
-- hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), 2)

return obj  
  --[[
    1. If one monitor only (mac)
      a. Firefox in first space
      b. Terminal in second space
      c. Code in third
      d. Spotify in fourth
  
    2. If two monitors
      a. Firefox in first space (mac)
      b. Terminal: second monitor (bottom third) (dell)
      c. Code: second monitor (upper 2/3s) (dell)
      d. Spotify in second space (mac)
  ]]