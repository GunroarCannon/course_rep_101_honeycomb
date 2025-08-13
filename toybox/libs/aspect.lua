local aspect =
{
    _VERSION = 1000,
    _URL = "https://gist.github.com/Vovkiv/f234b4c9263d4642f87d48ce8db37be8",
    _INTERPRETER = {
        love = 11.3,
    },
    _DESCRIPTION = "Can handle best fit scaling for games with specific resolution in Love2d",
    _LICENSE = "None",
    _NAME = "Aspect Scaling",
}
--[[
local aspect = require("aspect")
aspect.setGame(1024, 600)
aspect.setColor(1, 0.3, 0.9, 1)
love.window.setMode(800, 600, {resizable = true})

love.update = function(dt)
    aspect.update()
end

love.draw = function()
    aspect.start()
    love.graphics.rectangle("line", 100, 100, 100, 100)
    aspect.stop()
end
--]]

aspect.scale = 0

aspect.gameWidth = 800 -- size to which game should be scaled to
aspect.gameHeight = 600

aspect.windowWidth = 0 -- size of window, which can be used instead of love's love.graphics.getWidth()\Height()
aspect.windowHeight = 0

aspect.gameAspect = 0 -- aspect of game, based on gameWidth / gameHeight; updates on every update()
aspect.windowAspect = 0 -- aspect of window, based on love.graphics.getWidth() / love.graphics.getHeight(); updates on every update()

aspect.xOff = 0 -- offset of black bars
aspect.yOff = 0

aspect.x1, aspect.y1, aspect.w1, aspect.h1 = 0, 0, 0, 0 -- data of black bars; if bars left-right then: 1 bar is left, 2 is right
aspect.x2, aspect.y2, aspect.w2, aspect.h2 = 0, 0, 0, 0 -- if top-bottom then: 1 bar is upper, 2 is bottom

aspect.r, aspect.g, aspect.b, aspect.a = 0, 0, 0, 0 -- colors of black bars; red, green, blue, alpha

local rs = aspect 
aspect.drawBars = function(color)
  -- Function that will draw back bars.
  -- Can be called outside of rs.start rs.stop.
  -- Might be useful when you need just to draw black bars, without scaling via rs.start.
  
  -- do nothing if we don't need draw bars or we in aspect scaling mode (1; with black bars)
  if nil then-- not rs.drawBars or rs.scaleMode ~= 1 then
    return
  end
  
  -- get colors, that was before rs.stop() function
  local r, g, b, a = love.graphics.getColor()
  
  -- prepare to draw black bars
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set color for black bars
  love.graphics.setColor(getColor(color or "black"))--0,0,0)--rs.r, rs.g, rs.b, rs.a)

  -- HERE
  --For example, you want start to draw black bars on -10 and +10 (for left and right side respectively) coordinates to, for example, create shaking effect:
  local width = 10
  love.graphics.rectangle("fill", rs.x1 - width, rs.y1, rs.w1 + width, rs.h1)
  -- draw right or bottom most
  love.graphics.rectangle("fill", rs.x2, rs.y2, rs.w2 + width, rs.h2)
 -- So now black bars will be drawed extended by 10 pixels for both left and right sides
  
  -- return original colors that was before rs.stop()
  love.graphics.setColor(r, g, b, a)
  
  -- end black bars rendering
  love.graphics.pop()
end

aspect.setColor = function(r, g, b, a) -- set color of black bars
    aspect.r = r
    aspect.g = g
    aspect.b = b
    aspect.a = a
end

aspect.setGame = function(w, h) -- set size which game should be scaled to
    aspect.gameWidth = w
    aspect.gameHeight = h
end

aspect.update = function()
    local x1, y1, w1, h1, x2, y2, w2, h2
    local scale
    local xOff, yOff
    local a_ -- used to decrease calculations

    local gameWidth, gameHeight = aspect.gameWidth, aspect.gameHeight
    local windowWidth, windowHeight = love.graphics._getWidth(), love.graphics._getHeight()

    local gameAspect = gameWidth / gameHeight
    local windowAspect = windowWidth / windowHeight

    if gameAspect > windowAspect then -- if window height > game height
        scale = windowWidth / gameWidth
        a_ = math.abs((gameHeight * scale - windowHeight) / 2)
        x1, y1, w1, h1 = 0, 0, windowWidth, a_
        x2, y2, w2, h2 = 0, windowHeight, windowWidth, -a_
        xOff, yOff = 0, windowHeight / 2 - (scale * gameHeight) / 2

    elseif gameAspect < windowAspect then -- if window width > game width
        scale = windowHeight / gameHeight
        a_ = math.abs((gameWidth * scale - windowWidth) / 2)
        x1, y1, w1, h1 = 0, 0, a_, windowHeight
        x2, y2, w2, h2 = windowWidth, 0, -a_, windowHeight
        xOff, yOff = windowWidth / 2 - (scale * gameWidth) / 2, 0

    else -- if window and game size equal
        scale = windowWidth / gameWidth
        x1, y1, w1, h1 = 0, 0, 0, 0
        x2, y2, w2, h2 = 0, 0, 0, 0
        xOff, yOff = 0, 0
    end

    aspect.x1, aspect.y1, aspect.w1, aspect.h1 = x1, y1, w1, h1
    aspect.x2, aspect.y2, aspect.w2, aspect.h2 = x2, y2, w2, h2
    aspect.xOff, aspect.yOff = xOff, yOff
    aspect.scale = scale
    aspect.windowWidth, aspect.windowHeight = windowWidth, windowHeight
    aspect.gameAspect, aspect.windowAspect = gameAspect, windowAspect
end

aspect.start = function()
    love.graphics.push()
    love.graphics.translate(aspect.xOff, aspect.yOff) -- create offset of graphics
    local scale = aspect.scale
    love.graphics.scale(scale, scale)
end

aspect.stop = function()
    love.graphics.pop()

    love.graphics.push("all") -- "all" used here to return original colors after stop function
    local r, g, b, a = aspect.a, aspect.g, aspect.b, aspect.a
    local x1, y1, w1, h1 = aspect.x1, aspect.y1, aspect.w1, aspect.h1
    local x2, y2, w2, h2 = aspect.x2, aspect.y2, aspect.w2, aspect.h2
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", x1, y1, w1, h1)
    love.graphics.rectangle("fill", x2, y2, w2, h2)
    love.graphics.pop()
end

function aspect.toGame(x,y)
    x = x-aspect.xOff
    y = y-aspect.yOff
    x = x/aspect.scale
    y = y/aspect.scale
    return x,y
end 
return aspect