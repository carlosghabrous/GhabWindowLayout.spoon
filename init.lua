local obj = {}

obj.__index = obj
obj.name = "GhabWindowLayout"


local screens = {}
screens.laptop = hs.screen{x=0, y=0}
screens.extra = hs.screen{x=1, y=0}

local layouts = {}
layouts.upTwoThirds = hs.geometry.rect(0, 0, 1, 0.67)
layouts.downOneThird = hs.geometry.rect(0, 0.67, 1, 0.33)

local layoutLaptopOnly = {
        {"Firefox", nil, screens.laptop, hs.layout.maximized, nil, nil}, -- first space
        {"Code", nil, screens.laptop, hs.layout.maximized, nil, nil}, -- second space
        {"iTerm2", nil, screens.laptop, hs.layout.maximized, nil, nil}, -- third space
        {"Spotify", nil, screens.laptop, hs.layout.maximized, nil, nil},
    }
    
    local layoutExtraScreen = {
        {"Firefox", nil, screens.laptop, hs.layout.maximized, nil, nil},
        {"Code", nil, screens.extra, layouts.upTwoThirds, nil, nil},
        {"iTerm2", nil, screens.extra, layouts.downOneThird, nil, nil},
        {"Spotify", nil, screens.laptop, hs.layout.maximized, nil, nil},
    }

local defaultLayouts = {}
defaultLayouts[1] = layoutLaptopOnly
defaultLayouts[2] = layoutExtraScreen

local function loadConfiguration(n_screens)
    return defaultLayouts[n_screens]
end

function obj:restoreLastRecordedLayout(n_screens)
    obj.logger.i("File not found. Restoring default layouts...")
    layout = loadConfiguration(n_screens)
    hs.layout.apply(layout)
end

-- SECTION 
-- This part of the file is about moving windows to other spaces
function obj:_doFocusedWindowChecks(window)
    if not window then
        obj.logger.w("Focused window does not exist (nil)")
        return 
    end 
    
    if not window:isStandard() then
        obj.logger.wf("%d%s", window:id(), "is not a standard window")
        return
    end 
    
    if window:isFullScreen() then
        obj.logger.wf("%d%s", window:id(), "cannot be moved, is fulled-screen")
        return
    end
end

function obj:_getSpacesForScreen(window)
    local spacesForScreen = nil
    local screenUUID = window:screen():getUUID()

    for screen, spaces in pairs(hs.spaces.allSpaces()) do
        spacesForScreen = spaces
        if screen == screenUUID then break end
    end

    return spacesForScreen
end

function obj:_selectDestinationSpace(window, spaces, direction)
    local thisSpace = hs.spaces.windowSpaces(window)

    if not thisSpace then return else thisSpace = thisSpace[1] end
    obj.logger.df("%s: %s", "this space is", thisSpace)

    local destSpace = nil
    for i, space in ipairs(spaces) do
        obj.logger.df("%s: %d, %s: %s", "i is", i, "space is", space)
        if space == thisSpace then
            if direction == "left" then
                if i > 1 then
                    destSpace = spaces[i-1]
                    break
                end
            elseif direction == "right" then
                if i < #(spaces) then
                    destSpace = spaces[i+1]
                    break
                end
            end
        end
    end

    return destSpace
end

function obj:moveWindowToSpace(direction)
    local focusedWindow = hs.window.focusedWindow()
    if focusedWindow == nil then obj.logger.i("focused window DOES NOT EXIST!") end
    obj:_doFocusedWindowChecks(focusedWindow)

    local spacesForScreen = obj:_getSpacesForScreen(focusedWindow)
    if spacesForScreen == nil then return end
    
    local destSpace = obj:_selectDestinationSpace(focusedWindow, spacesForScreen, direction)
    
    if destSpace == nil then 
        obj.logger.wf("%s %s %s", "cannot move to the", direction, "from this space")
        return
    end
    
    obj.logger.df("%s %s: %s", "new selected space for dir", direction, destSpace)
    hs.spaces.moveWindowToSpace(focusedWindow, destSpace)
end

function obj:initWindowToSpaceBinding()

    hs.hotkey.bind({"ctrl", "alt"}, "right", function()
        obj:moveWindowToSpace("right")
    end)

    hs.hotkey.bind({"ctrl", "alt"}, "left", function()
        obj:moveWindowToSpace("left")
    end)
end

function obj:initWindowMovementBinding()
    local hotKey = {"ctrl", "alt"}

    hs.hotkey.bind(hotKey, "right", function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x + 20
        win:setFrame(f)
    end)

    hs.hotkey.bind(hotKey, "left", function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x - 20
        win:setFrame(f)
    end)

    hs.hotkey.bind(hotKey, "up", function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.y = f.y - 20
        win:setFrame(f)
    end)

    hs.hotkey.bind(hotKey, "down", function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.y = f.y + 20
        win:setFrame(f)
    end)
end

-- Function
-- Sets the default log level and initializes a log instance with that default value
function obj:initLogger()
    local logLevel = 6
    obj.logger = hs.logger.new(obj.name)
    obj.logger.setLogLevel(logLevel)
    
end

-- Function
function obj:init()
    hs.application.enableSpotlightForNameSearches(true)
    obj:initLogger()
    
    obj.logger.i(string.format("Loading %s...", obj.name))
    
    obj.logger.i("Loading bindings...")
    obj:initWindowMovementBinding()
    obj:initWindowToSpaceBinding()

    obj.logger.i("Restoring last layout...")
    obj:restoreLastRecordedLayout(#(hs.screen.allScreens()))
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