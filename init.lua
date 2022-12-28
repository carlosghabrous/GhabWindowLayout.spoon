local obj = {}

obj.__index = obj
obj.name = "GhabWindowLayout"

local laptopScreen = hs.screen.allScreens()[1]:name()
local extraScreen = hs.screen.allScreens()[2]:name()

local layoutLaptopOnly = {
    {"Firefox", nil, laptopScreen, hs.layout.maximized, nil, nil},
}

local layoutExtraScreen = {
    {"Firefox", nil, laptopScreen, hs.layout.maximized, nil, nil},
    {"Code", nil, extraScreen, hs.layout.apply(), nil, nil},
}

function obj:_numberOfScreens()
    local count = 0
    for _ in pairs(hs.screen.allScreens()) 
    do 
        count = count + 1
    end
    return count
end

function obj:init()
    print(string.format("Loading %s...", obj.name))

    if self:_numberOfScreens() == 2 then
        hs.layout.apply(layoutExtraScreen)
    else
        hs.layout.apply(layoutLaptopOnly)
    end
        
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