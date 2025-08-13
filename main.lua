
--error(love.graphics.getWidth().."_"..love.graphics.getHeight())
require('toybox.LGML')({
  entry = 'course_rep.game',
  debug = false
})
RELEASE = true


function getTimeText(text)
    if type(text) == "string" then return text end
    
            local floor =   math.floor 
            local hours = floor(text/(60*60))
            text = text-hours*(60*60)
        
            local minutes = floor(text/60)
            text = text - minutes*60
        
            local seconds = floor(text)   
            text = string.format("%s%s:%s%s:%s%s",hours<10 and "0" or "" ,hours,minutes<10 and "0" or "" , minutes,seconds<10 and "0" or "" ,seconds)
         
        return text
end

function getTimeText2(text)
    if type(text) == "string" then return text end
    
            local floor =   math.floor 
            local hours = floor(text/(60*60))
            text = text-hours*(60*60)
        
            local minutes = floor(text/60)
            text = text - minutes*60
        
            local seconds = floor(text)
            text = text - seconds
            local nin = floor(text*10)
            
            text = string.format("%s%s:%s%s:%s%s:%s%s%s",hours<10 and "0" or "" ,
            hours,minutes<10 and "0" or "" , minutes,seconds<10 and "0" or "" ,seconds,
            nin<100 and "0" or "", nin<10 and 0 or "",nin)
         
        return text
end


--[[
ROT=require 'toybox.libs.src.rot'
require "toybox.LGML"
local lgs = love.graphics.setColor
love.graphics.setCkolor = function(r,g,b,a)
    if type(r) == "table" then
        return love.graphics.setColor(r[1],r[2],r[3],r[4])
    end
    --if (r+g+b)==0 then error() end
    local n = 255 or r>.9 and 255 or 1 log(r..","..g..","..b..","..tostring(a or "--"))
    return lgs(r/n, g/n, b/n, (a or n)/n)
end
local lgg = love.graphics.getColor
love.graphics.gketColor = function()
    if type(r) == "table" then
     --   return love.graphics.getColor(r[1],r[2],r[3],r[4])
    end
    local r,g,b,a=lgg()
    local n =255 or  r>.9 and 1 or 255
    return r*n, g*n, b*n, (a or 1)*n
end

function love.load()
    f=ROT.Display(80, 24)
    maps={
        "Arena",
        "DividedMaze",
        "IceyMaze",
        "EllerMaze",
        "Cellular",
        "Digger",
        "Uniform",
        "Rogue",
        "Brogue",
    }
    doTheThing()
end
nii=255
function love.draw() f:draw() end
update=false
function love.update()
    if update then
        update=false
        doTheThing()
    end
end
function love.keypressed() update=true end
function love.keyreleased() end
function doTheThing()
    f:clear()
    mapData={}
    lightData={}
    -- Map type defaults to random or you can hard-code it here
    mapType="Brogue"--maps[ROT.RNG:random(1,#maps)]
    map= ROT.Map[mapType]:new(f:getWidth(), f:getHeight())
    if map.randomize then
        floorValue=1
        map:randomize(.5)
        for i=1,5 do
            map:create(mapCallback)
        end
    else
        floorValue=0
        map:create(mapCallback)
    end
    fov=ROT.FOV.Precise:new(lightPasses, {topology=4})
    lighting=ROT.Lighting(reflectivityCB, {range=12, passes=2})
    lighting:setFOV(fov)
    for i=1,10 do
        local point=getRandomFloor()
        f:write('*',tonumber(point[1]),tonumber(point[2]))
        lighting:setLight(tonumber(point[1]),tonumber(point[2]), getRandomColor())
    end
    lighting:compute(lightingCallback)
    local ambientLight={ 0, 0, 0, 255 }
    for k,_ in pairs(mapData) do
        local parts=k:split(',')
        local x    =tonumber(parts[1])
        local y    =tonumber(parts[2])
        local baseColor=mapData[k]==floorValue and { 125/nii, 125/nii, 125/nii, 255 } or { 50/nii, 50/nii, 50/nii, 255 }
        local light=ambientLight
        local char=f:getCharacter(x, y)
        if lightData[k] then log("adding ambient and main: "..inspect(light)..","..inspect(lightData[k]))
        local l = lightData[k]
            light=ROT.Color.add(light, lightData[k])
        end
        local finalColor=ROT.Color.multiply(baseColor, light)
        char=not lightData[k] and ' ' or char~=' ' and char or mapData[x..','..y]~=floorValue and '#' or ' ' --error(inspect(finalColor))

        f:write(char, x, y, light, finalColor)
    end
    mapData=nil
    lightData=nil
    map=nil
    lighting=nil
    fov=nil
end



function lightingCallback(x, y, color)
    local key=x..','..y
    lightData[x..','..y]=color
end

function getRandomColor() local nii= 1
    return { math.floor(ROT.RNG:random(11,125))/nii,
             math.floor(ROT.RNG:random(100,125))/nii,
             math.floor(ROT.RNG:random(50,125))/nii,
             255}
end

function getRandomFloor()
    local key=nil
    while true do
        key=ROT.RNG:random(1,f:getWidth())..','..ROT.RNG:random(1,f:getHeight())
        if mapData[key]==floorValue then
            return key:split(',')
        end
    end
end

function reflectivityCB(lighting, x, y)
    local key=x..','..y
    return mapData[key]==floorValue and .3 or 0
end

function lightPasses(fov, x, y)
    return mapData[x..','..y]==floorValue
end

function mapCallback(x, y, val)
    mapData[x..','..y]=val
end

--{
--]]
--[[local colss = require "toybox.libs.color"
cols={}
for x, i in pairs(colss) do cols[#cols+1] ={x,i} end

function love.draw()
    t = (t or 0)+1/60--/60
    
    local c = cols[cc or 1] --if not (c[2][3]) then error(tostring(c[1])) end
    love.graphics.setColor(c[2])
    love.graphics.rectangle("fill",100,100,100,100)
    love.graphics.print(c[1])--..","..c[2][1]..","..c[2][2]..","..c[2][3])
    if t>2 then
        cc = (cc or 1)+1
        t = 0
    end
end
    
]]

--[[
--error(love.graphics.getWidth().."_"..love.graphics.getHeight())
require('toybox.LGML')({
  entry = 'nest.game',
  debug = false
})
RELEASE = false
]]

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
--[[draw_rect = love.graphics.rectangle
draw_image = love.graphics.draw
local oss = love.graphics.setColor

function love.graphics.setColor(rr, gg, bb, aa)
    if type(rr) == "string" then
      rr = getColor(rr)--ooi.toRGBA(color)
    end
    
    local r,g,b,a = love.graphics.getColor()
    oss(rr,gg,bb,aa)
    return r,g,b,a
end

set_color = love.graphics.setColor
draw_line = love.graphics.drawLine


lume = require "toybox.libs.lume"
require "texty"

local sen = Sentence:new({w=1000,h=100,y=0,x=0,font=love.graphics.newFont(40)})
sen.highlight = {0,0,0,1}
tt = (require "toybox.libs.chrono")()
tt:tween(7,sen.highlight, {1,2,.3,1},"linear",function() end)
sen:newText("$Wait~ ??? \n@Maybe __ maybe ____ maybe ~we should _ ... #ahhhh ~ \ntoi ~#noooo _hu $nool ~ ")
function love.draw()
    draw_rect("fill", 100,100,500,500)
    sen:draw()
end

function love.update(dt)
    tt.update(tt, dt)
    sen:update(dt)
end]]
