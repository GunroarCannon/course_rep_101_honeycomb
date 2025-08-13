-- First thing's first...
-- Good old monkey-patching
-- :)

local km = love.keyboard.isDown
--[[L_KEYS = {}
function love.keyboard.isDown(k)
    return L_KEYS[k]
end]]


draw_rect = love.graphics.rectangle
local _draw = love.graphics.draw
love.graphics.draw = function(s, ...)
    return _draw(type(s)=="string" and game:getAsset(s) or s,...)
end
draw_image = love.graphics.draw

local oss = love.graphics.setColor

function love.graphics.setColor(rr, gg, bb, aa) if type(rr)=="boolean" then return love.graphics.getColor() end
    if type(rr) == "string" then
      rr = getColor(rr)--ooi.toRGBA(color)
    end
    
    local r,g,b,a = love.graphics.getColor()
    oss(rr,gg,bb,aa)
    return r,g,b,a
end

set_color = love.graphics.setColor
draw_line = love.graphics.drawLine

local old_sort = table.sort
function table.sort(table, method, ...)
    old_sort(table, method, ...)
    return table
end

function change_brightness(color, amount)
  if type(color) == "string" then
    color = getColor(color)--ooi.toRGBA(color)
  end
  
  --color = getColor(color)

  local r, g, b, a = color[1], color[2], color[3], color[4] or 1

  r = r + amount
  g = g + amount
  b = b + amount
  --a = a + amount

  if r < 0 then r = 0 end
  if r > 1 then r = 1 end

  if g < 0 then g = 0 end
  if g > 1 then g = 1 end

  if b < 0 then b = 0 end
  if b > 1 then b = 1 end

  --if a < 0 then a = 0 end
  --if a > 1 then a = 1 end

  return {r, g, b, a}
end

require('toybox.utils.rgba')
require('toybox.utils.round')
require('toybox.utils.sign')
require('toybox.utils.spairs')

LGML = setmetatable({}, {
  __call = function (t, options)
    t.__entry = require(options.entry)
    t.__debug = options.debug or false
  end
})

toybox = LGML


class = require "toybox.libs.middleclass"

Andralog = require "toybox.libs.andralog"

Paddy = require "toybox.libs.paddy"
Chrono = require "toybox.libs.chrono"
Camera = require "toybox.libs.camera"

lume = require "toybox.libs.lume"
inspect = require "toybox.libs.inspect"
require  "toybox.libs.tools"
aspect = require "toybox.libs.aspect"
bump = require "toybox.libs.bump"
animx = require "toybox.libs.animx"
baton = require "toybox.libs.baton.baton"

ProFi = require "toybox.libs.ProFi"

JumperGrid = require "toybox.libs.jumper.grid"
PathFinder = require "toybox.libs.jumper.pathfinder"
--[[lure = require "toybox.libs.lure.build.lua.lure"
local obj = "toybox.libs.lure.src.__legacy__"
lure.lib = {}
lure.dom = {}
lure.lib.upperclass = require(string.format("%s.lib.upperclass", obj))

XMLHttpRequest = require "toybox.libs.lure.src.__legacy__.dom.XMLHttpRequest"
require( string.format("%s%s",obj,".dom.__legacy__.objects.lure_dom_XMLHttpRequest.XMLHttpRequest"))]]
local oor = require



old_require = oor
old_requiren = function(n)
    return oor(string.format("libs.steering%s",n))
end

require = function(n)
    return oor(string.format("toybox.libs.steering.%s",n))
end

SteeringAgent = require "src.agent.steeringAgent"

require = old_require

luastar = require_and_sign "toybox.libs.luastar"

colors = require_and_sign "toybox.libs.color"

--basic online scoreboard, and json parser
dreamlo = require_and_sign "toybox.libs.dreamlo"
lootlocker = require_and_sign "toybox.libs.lootlocker"

aspect = require_and_sign 'toybox.libs.aspect'
saveTable = require "toybox.libs.saveTable"
bitser = require "toybox.libs.bitser"
binser = require "toybox.libs.binser"
binser = lume

bibhand = require "toybox.libs.bibhandgemalt"

require "toybox.libs.gooi"

toybox.make_grid = require "toybox.utils.grid"
toybox.make_boid = require "toybox.utils.boid"

toybox.bars = require "toybox.extra.bars"

print = log

InputManager = require "toybox.managers.InputManager"
AudioManager = require_and_sign "toybox.managers.AudioManager"
media = require_and_sign "toybox.utils.media"

function getRandom(r)
    if type(r) == "table" then
        if type(r[1])=="number" and #r==2 then
            return math.random(r[1], r[2])
        end
        return lume.randomchoice(r)
    end
    if type(r) == "function" then
        return r()
    end
    
    return r
end

getValue = getRandom
toybox.getRandom = getRandom
toybox.getValue = getRandom

aspect.setGame(_W,_H)

res = {}
res.beginRendering = function()
    aspect.start()--push:apply("start")
end
    
res.endRendering = function()
    aspect.stop()--push:apply("end")
end
    
function res.update(dt)
    aspect.update(dt)
end

lmx = love.mouse.getX
lmy = love.mouse.getY
    
res.getMousePosition = function(w,h,x,y)
    local x,y = x or w or lmx(), y or h or lmy()
    return aspect.toGame(x,y)
end
    
love.mouse.getX = function()
    local x,y = res.getMousePosition()
    return x
end
    
love.mouse.getY = function()
    local x,y = res.getMousePosition()
    return y
end

local luu = love.update
function love.update(dt)
    if lui then luu(dt) end
    --animx.update(dt)
    res.update(dt)
end
lu=love.update
Object = require "toybox.entities.Object"
Room = require "toybox.entities.Room"
Sprite = require "toybox.entities.Sprite"
Controller = require "toybox.entities.Controller"
Game = require "toybox.entities.Game"

    
    IM = InputManager:new()
    input = IM
    inputManager = IM
    IM.active = true


local SETTINGS_FILE = "settings.dat"
useLumeSer = true
local function getSettingsToLoad() log("load")
    local fileDat = love.filesystem.getInfo(SETTINGS_FILE)
    if fileDat and (fileDat.size or 0) > 0 then
        -- love.filesystem.load(SETTINGS_FILE,"r")()--
        local d = (useLumeSer and binser.deserialize(love.filesystem.newFile(SETTINGS_FILE,"r"):read()) or
        bitser.loadLoveFile(SETTINGS_FILE, "r") )
        if type(d) == "table" then
            return d
        end
    end log("non"..inspect(love.filesystem))
    return {}
end

local function getSettingsToSave(data)
    local tmp = love.filesystem.newFile(string.format("%s_TMP",SETTINGS_FILE),"w") --warn()
    tmp:write(data)
    local value = useLumeSer and binser.deserialize(
    love.filesystem.newFile(string.format("%s_TMP",SETTINGS_FILE), "r"):read()) or
    bitser.loadLoveFile(string.format("%s_TMP",SETTINGS_FILE), "r")
    
    if type(value) == "table" then--cwarn("..","blue")
        local file = love.filesystem.newFile(SETTINGS_FILE, "w")
        file:write(data)
        return true
    elseif nil then--game then--.map then
        GTimer:after(3,function() gooi.alert({
            text = "No space to save data!"
        })
        end)
    end
    
end

LGML.getColor = function(col,alpha)
    if type(col) == "table" then 
        if alpha then
            col = {col[1],col[2],col[3]}
            col[4] = alpha
        end
        return col
    end
    local col = colors[col] or colors.red
    col = {col[1],col[2],col[3],col[4]}
    if alpha then
        col[4] = alpha
    end
    return col
end

LGML._data = {}
LGML.getData = function(name)
    SETTINGS_FILE = name or "settings.dat"
    local d = LGML._data[name] or getSettingsToLoad() or {}
    LGML._data[name] = d
    return d
end

function LGML.saveData(name)
    SETTINGS_FILE = name or "settings.dat"
    getSettingsToSave(useLumeSer and binser.serialize(LGML._data[name]) or
        bitser.dumps(LGML._data[name]))--saveTable(LGML._data[name] or getSettingsToLoad()))
end


LGML.deactivate_gooi = function()
    gooi_activated = false
end


LGML.rot = function ()
  return require('toybox.libs.src.rot')
end

LGML.Game = function (name)
  return require('toybox.entities.Game'):subclass(name)
end

LGML.Room   = function (name) 
  return require('toybox.entities.Room'):subclass(name)
end

LGML.Object = function (name)
  return require('toybox.entities.Object'):subclass(name)
end

LGML.Sprite = function (name)
  return require('toybox.entities.Sprite'):subclass(name)
end

LGML.new_sprite = function (...)
  return require('toybox.entities.Sprite'):new(...)--subclass(name)
end

LGML.Controller = function (name)
  return require('toybox.entities.Controller'):subclass(name)
end

LGML.BaseController = function (name)
  return require('toybox.entities.BaseController'):subclass(name)
end

LGML.BaseObject = function (...)
  return require('toybox.extra.BaseObject'):subclass(...)
end

LGML.NewBaseObject = function (...)
  return require('toybox.extra.BaseObject'):new(...)
end

LGML.Projectile = function (name)
  return require('toybox.extra.Projectile'):subclass(name)
end

LGML.NewProjectile = function (...)
  return require('toybox.extra.Projectile'):new(...)
end

LGML.LifeBar = function(parent, kwargs)
    if kwargs and parent then
        kwargs.parent = parent
    end
    
    kwargs = kwargs or parent
    
    return toybox.bars.LifeBar:new(kwargs)
end

LGML.ProgressBar = function(parent, kwargs)
    if kwargs and parent then
        kwargs.parent = parent
    end
    
    kwargs = kwargs or parent
    
    return toybox.bars.ProgressionBar:new(kwargs)
end

function love.load()
  LGML.__instance = LGML.__entry:new()
  _G.game = LGML.__instance
end

function love.update(dt)
  if L_KEYS then
    for k, i in pairs(L_KEYS) do
      L_KEYS[k] = i-dt
      if L_KEYS[k] <= 0 then
        L_KEYS[k] = nil
      end
    end
  end
  
  lu(dt)
  LGML.__instance:__step(dt)
end

function love.draw()
  LGML.__instance:__draw(love.timer.getDelta())
end

function love.mousepressed(...)
  LGML.__instance:mousepressed(...)
end

function love.mousereleased(...)
  LGML.__instance:mousereleased(...)
end

function love.mousemoved(...)
  LGML.__instance:mousemoved(...)
end

function love.keypressed(k, ...)
  if L_KEYS then
    L_KEYS[k] = .3
  end
  
  LGML.__instance:keypressed(k, ...)
end

function love.keyreleased(k, ...)
  
  LGML.__instance:keyreleased(k, ...)
end

function love.textinput(...)
  LGML.__instance:textinput(...)
end

function love.touchpressed(...)
  LGML.__instance:touchpressed(...)
end

function love.touchreleased(...)
  LGML.__instance:touchreleased(...)
end

function love.touchmoved(...)
  LGML.__instance:touchmoved(...)
end
    
function love.focus(focus)
    if not LGML.__instance then return end
    
    local game = LGML.__instance
    
    if game.room and game.room._focus then
        game.room:_focus(focus)
    end
    
    if not focus then
        if game.__step ~= null then
           game.__toyboxOldStep = game.__step 
        end
        game.__step = null
        game.stopped_focus = true
        if media.music then
            media.music:pause()
        end
    elseif game.stopped_focus then
        game.stopped_focus = false
        game.__step = game.__toyboxOldStep or game.__step
        if media.music then
            media.music:play()
        end
    end
end

return LGML