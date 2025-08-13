--error(love.graphics.getWidth().."_"..love.graphics.getHeight()))
--[[]]require('toybox.LGML')({
  entry = 'dreamer.game',
  debug = false
})--]]
--[[
local moonshine = require 'moonshine'

function love.load()
  effect = moonshine(600,600,moonshine.effects.boxblur)
       --             .chain(moonshine.effects.boxblur)
  --effect.filmgrain.size = 2
end

local img = love.graphics.newImage("h.jpg") 
function love.draw()
--love.graphics.setColor(1,0,0)
    effect(function() 
      love.graphics.draw(img,100,50,0,.25,.25)--("fill", 300,0, 200,200+10*love.timer.getDelta())
    love.graphics.print(love.timer.getFPS(),30,50,0,2,2)
    end)
    
end]]