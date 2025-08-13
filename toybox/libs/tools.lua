--This module squirts some useful functions and variables
--into the global namespace.

zoom = function(v,f) 
    local self = self or game.map
    self.fogOfWar = f or false
    self.cameraMan.scale=v or 1 
end

_can_reload = {}
require_and_sign = function(path)
    local module = require(path)
    if type(module)=="table" then--and module.class then
        _can_reload[module] = path
    end
    oldmod = module
    return module
end

color = require 'toybox.libs.color'
class = require "toybox.libs.middleclass"
colors = color
COLOR = color
COLORS = color

Simplex = require 'toybox.libs.simplex'

_noise = Simplex()
function noise(x,y)
    return _noise:get(x,y)
end

function getColor(col,alpha)
    if type(col) == "table" then
        if true or alpha then
            col = {col[1],col[2],col[3]}
            col[4] = alpha or col[4]
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

function addColors(c1, c2)
    local color1 = getColor(c1)
    local color2 = getColor(c2)
    local result = {
        color1[1]+color2[1],
        color1[2]+color2[2],
        color1[3]+color2[3],
        (color1[4] or 1)+(color2[4] or 1)
    }
    return result
end

function subtractColors(c1, c2)
    local color1 = getColor(c1)
    local color2 = getColor(c2)
    local result = {
        color1[1]-color2[1],
        color1[2]-color2[2],
        color1[3]-color2[3],
        (color1[4] or 1)-(color2[4] or 1)
    }
    return result
end

NULL = function() end
null2 = function(t) return t end
null = NULL
Null = null

function resetAll()
    for u,i in pairs(_G) do
        if u ~= "love" and not u~="_g" and not _g[u] and u~="gooi" and u~="component" and u~="genId"
        and u~="changeBrig" and u~="split"
        and u~="table" and u~="ser" and u ~="_LOG_FILE" and u~="string" and u~="tostring" and u~="clog"
        and u~= "_G" and u~="astar" and u~= "log" and u~="lume"  and u~="warn"
        then -- log(u)
            _G[u] = nil
        end
    end

    love.load()
end

_tmpG = {}
function observeGlobals()
    _tmpG = {}
    for x,i in pairs(_G) do
        _tmpG[x] = 1
    end
end

function seekNewGlobals(callback)
    local callback = callback or null
    local new = {}
    for x,i in pairs(_G) do
        if not _tmpG[x] then
            new[#new+1] = x
        end
    end
    if #new>0 then
        callback(inspect(new))
    end
end


_LOG_FILE = love.filesystem.newFile("game_log.txt","w")
_WARN_FILE = love.filesystem.newFile("game_warning.txt","w")


WARNING_COLOR = "red"

function clog(_str,cond,file,depth)
    local inspect = inspect or null2
    if not cond then
        return false
    end
    local file = file or _LOG_FILE
    local str = lume.wordwrap(inspect(_str,depth or 1),90)
    assert(str~="dirt.png" and str~="turret.png")
    file:write(string.format("%s%s",str,"\n"))
    if game and game.debugLabel and doDebug then
        game.debugLabel:setText(str)
    end
    return true
end

function cwlog(str,cond)
    if doDebug == false then
        return
    end
    
    TMP_WARNING_COLOR = WARNING_COLOR
    if type(cond) == 'string' and getColor(cond) then
        WARNING_COLOR = cond
    end
    
    local log = clog(str,cond) and clog(str,cond,_WARN_FILE)
    if not log then
        return log
    end
    local current = toybox and toybox.room or GS and GS.current()
    if not current then
        return log
    end
    local cam = current.camera or current.viewport or (current.parent and current.parent.camera)
    local trash = cam and cam:flash(.05,getColor(WARNING_COLOR,.5))
    WARNING_COLOR = TMP_WARNING_COLOR
    return log
end

function wlog(str,cond)
    return cwlog(str,cond or true)
end

warn = wlog
_warn = warn
cwarn = cwlog

function log(str,depth)
    return clog(str,true,nil,depth)
end

function getCamera()
    local current = GS and GS.current()
    if not current or not current.camera then
        if game.map then
            return game.map.camera
        end
        return Camera()
    end
    return current.camera or 
           (current.parent and current.parent.camera) or
               (current.map and current.map.camera)
end

Graphics = love.graphics
Physics = love.physics
lg = Graphics

lg._getHeight =  lg.getHeight
lg._getWidth = lg.getWidth
lg._getDimensions = function()
    return lg._getWidth(), lg._getHeight()
end

_W = _W or 1280
_H = _H or 800

lg._getHeigooht = function() return 1280 end
lg._getWihggdth = function() return 800 end
lg.getHeight = function() return _H end
lg.getWidth = function() return _W end
lg.getDimensions = function()
    return lg.getWidth(), lg.getHeight()
end
function fixSize(size, r) return (r and (r/size)) or 1 end
function width(r) return lg.getWidth()*fixSize(_W,r) end
function height(r) return lg.getHeight()*fixSize(_H,r) end
function W(...) return width(...) end
function H(...) return height(...) end
function getRatio() return (_H/H())/(_W/W()) end


function ser(val)
    return lume.serialize(val)
end

local __ids = {}
local __idCount = 0
function getAnID(item)
    __idCount = __idCount + 1
    if not __ids[__idCount] then
        __ids[__idCount] = item or 1
        return __idCount
    else
        return getAnID(item)
    end
end

function getCustomID(...)
    return getAnID(...)
end

local generator = love.math.newRandomGenerator(os.time())
function UUID()
    local fn = function(x)
        local r = generator:random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
end

function isDown(key)
    return paddy.isDown(key)
end

function tableIsEmpty(t)
    local em = true
    for x, i in pairs(t) do
        em = false
        break
    end
    return #t==0 and em
end

function getValue(amount)
    local amount = amount
    if type(amount) == "table" then
        if #amount == 2 and type(amount[1]) == "number" then
            amount = math.random(amount[1], amount[2])
        else
            amount = lume.randomchoice(amount)
        end
    end
    return amount
end

SETTINGS_FILE = "settings.dat"

function getSettingsToLoad()
    if love.filesystem.isFile(SETTINGS_FILE) then
        return love.filesystem.load(SETTINGS_FILE, "r")()
    end
end

function getSettingsToSave(data)
    local tmp = love.filesystem.newFile(string.format("%s_TMP",SETTINGS_FILE),"w")
    tmp:write(data)
    local value = love.filesystem.load(string.format("%s_TMP",SETTINGS_FILE), "r")()
    if type(value) == "table" then
        local file = love.filesystem.newFile(SETTINGS_FILE, "w")
        file:write(data)
        return true
    elseif game then--.map then
        GTimer:after(3,function() gooi.alert({
            text = "No space to save data!"
        })
        end)
    end
    
end

FakeButton = class:extend("FakeButton")

function FakeButton:__init__(kwargs)
    self.data = kwargs.data or 1
    self.source = kwargs.source or ""
    self.ref = self
end

function FakeButton:setText(t)
    self.text = t
end

function FakeButton:getText()
    return self.text
end

function FakeButton:getSource()
    return self.source
end

function FakeButton:setSource(s)
    self.source = s
end

function FakeButton:setStyle()
end

--CLOCK--??
    Clock = class:extend("Clock")
    Clock.updates = {}
    function Clock.schedule_interval(item,func,interval)
        --Who cares bout the interval for now
        table.insert(Clock.updates,{func,item})
        return _Checker(func)
    end
    function Clock.update(dt)
        for _,func in ipairs(Clock.updates) do
            func[1](func[2],dt)
        end
    end
    _Checker = class:extend("Checker")
    function _Checker:__init__(func)
        self.func = func
    end
    function _Checker:cancel()
        lume.remove(Clock.updates,self.func)
        self = nil --?
    end
--CLASS--
    
--TOGGLE--
    Toggle = class:extend("Toggle")
    function Toggle:__init__(data)
        self._data = data
        self.current = 1
        self.data = self._data[1]
        self._func = function() end
    end

    function Toggle:toggle(_data)
        local _data = _data or "nothing can REALLY be eqal to this, can it?"
        self.current = lume.find(self._data,self.data)
        self.current = self.current + 1
        if self.current > #self._data then
            self.current = 1
        end
        self.data = self._data[self.current]
        if self.data == _data then
            local s = self:toggle()
            assert(s~=data,"toggle failed!")
            return s
        end
        self._func(self.data,_data)
        return self._data[self.current]
    end
    
    function Toggle:onToggle(t)
        self._func = t
        return self
    end
--CLASS--

function eliminate(list)
    local f = lume.randomchoice(list)
    lume.remove(list,f)
    return f
end

function scale(noise)
    -- Rescale from -1.0:+1.0 to 0.0:1.0
    return noise/2.0+0.5
end

function positive(n) if n<0 then return n*-1 end return n end
function get_bearing(n) if n<0 then return -1 elseif n>0 then return 1 end return 0 end

function getRound(r)
    local t = {}
    for i = 0,r do
        for y = 0,r do
            --if i ~= 0 and y ~= 0 then
                table.insert(t,{i,y,x=i,y=y})
                if y ~= 0 then
                    table.insert(t,{i,y*-1,x=i,y=y*-1})
                    if i ~= 0 then
                        table.insert(t,{i*-1,y,x=i*-1,y=y})
                        table.insert(t,{i*-1,y*-1,x=i*-1,y=y*-1})
                    end
                end
            --rnd
                
            if y==0 and i~= 0 then
                table.insert(t,{i*-1,y,x=i*-1,y=y})
            end
        end
    end
    return t
end

function getPlayerColor()
    return getColor("blue")--game.player and game.player.color or game.settings.color)
end

local lgetColor = love.graphics.getColor
local lsetColor = love.graphics.setColor
local function drawAroundTile(x,y,w,h,color,data)
    local r,g,b,a = lgetColor()
    lsetColor(color)
    local drawline = love.graphics.line
    local linew = 0
    local x2, y2 = x+w-linew, y+h-linew
    
    local old = love.graphics.getLineWidth()
    love.graphics.setPointSize(10)--
    love.graphics.setLineWidth(Linew or 1.5)--3)
    if data.up then
        drawline(x,y,x2,y)
    end
    
    if data.down then
        drawline(x,y2,x2,y2)
    end
    
    if data.left then
        drawline(x,y,x,y2)
    end
    
    if data.right then
        drawline(x2,y,x2,y2)
    end
    
    lsetColor(r,g,b,a)
    love.graphics.setLineWidth(old)
end

function getDir(n)
    if n<0 then return -1 end
    if n>0 then return 1 end
    return 0
end

local black = getColor("black")
local dirs = { {1,0}, {-1,0}, {0,1}, {0,-1} }
local vals = { 
    [-1] = {[0]="left"},
    [1]  = {[0]="right"},
    [0]  = {
        [1]="down",
        [-1]="up"
    }
}

function highlightTile(x,y,w,h,color,map)
    local tx, ty = x/w, y/h
    local grid = (map or game.map).grid
    local tile
    local data = {}
    local d, dd, t, dx, dy
    
    for d = 1, 4 do
        dd = dirs[d]
        dx, dy = dd[1], dd[2]
        t = grid[tx+dx] and grid[tx+dx][ty+dy]
        if t and (t.isBackground or t.barrier) then
            data[vals[dx][dy]] = true
            data.used = true
        end
    end
    
    if data.used then
        drawAroundTile(x,y,w,h,color or black,data)
    end
    data = nil
    grid = nil

end

function collided(t, o)
    tr = t.x+(t.width or t.w)
    tl = t.x
    ttop = t.y
    tbot = t.y + (t.height or t.h)
    
    orr = o.x+(o.width or o.w)
    ol = o.x
    otop = o.y
    obot = o.y + (o.height or o.h)
    
    if tr>ol and tl<orr
    and tbot>otop and ttop<obot then
        return true
    end
    return false
end


function circleCollision(cx, cy, r, sx, sy, sh, sw)
    if type(sx) == "table" then
        local obj = sx
        sx = obj._x or obj.x
        sy = obj._y or obj.y
        sh = obi.h
        sw = obj.w
    end
    
    local testX, testY = cx, cy
    
    if cx<sx then
        testX = sx
    elseif cx>sx+sw then
        testX = sx+sw
    end
    if cy<sy then
        testY = sy
    elseif cx>sy+sh then
        testX = sy+sh
    end
    
    local dist = lume.distance(cx, cy, testX, testY)
    
    if dist<=r then
       return true
    end
    
    return false
end

function drawScaledImage(img,x,y,nW,nH,draw)
    if draw == nil then draw = true end
    local cw, ch  = img:getDimensions()
    cw = nW/cw
    ch = nH/ch
    if draw then
        Graphics.draw(img,x,y,0,ch,cw)
    end
    return cw,ch
end

function resizeImage(img, nW, nH, extra)

    local cw, ch
    if type(img) == "string" then
        img = game:getSource(img)
    end
    if type(img) == "number" then
        cw, ch = img, nW
        nW, nH = nH, extra
    else
        cw, ch  = img:getDimensions()
    end
    
    cw = nW/cw
    ch = nH/ch
    return cw,ch
end


util = {}

util.drawFilledRectangle = function(l,t,w,h, r,g,b,op,op2)
  local rr,gg,bb,a = love.graphics.getColor()
  love.graphics.setColor(r,g,b,op)
  love.graphics.rectangle('fill', l,t,w,h)
  love.graphics.setColor(r,g,b,op2)
  love.graphics.rectangle('line', l,t,w,h)
  love.graphics.setColor(rr,gg,bb,a)
end

util.drawFilledCircle = function(l,t,w,h, r,g,b,op,op2)
  local rr,gg,bb,a = love.graphics.getColor()
  love.graphics.setColor(r,g,b,op)
  love.graphics.circle('fill', l,t,w/2)
  love.graphics.setColor(r,g,b,op2)
  love.graphics.circle('line', l,t,w/2)
  love.graphics.setColor(rr,gg,bb,a)
end

local function _get(item,name,_global)
    return item[name]
    --edit later
end

OPERATORS = {
    ["=="] = 1,
    ["!="] = 2,
    ["~="] = 2.5,
    ["in"] = 3,
    [">"] = 4,
    ["<"] = 5,
    [">="] = 6,
    ["<="] = 7,
    ["and"] = 8,
    ["or"] = 9,
    
    ["="] = 10,
    ["+"] = 11,
    ["-"] = 12,
    ["/"] = 13,
    [""] = 14,
    ["*"] = 15,
    ["**"] = 16,
    ["^"] = 16.5,
    ["%"] = 17,
    ["#"] = 18,
}
function operate(main,op,val)

    --comparers
    if op == "==" then return main == val
    elseif op == "!=" then return main ~= val
    elseif op == "~=" then return main ~= val
    elseif op == "in" then return main[val]
    elseif op == ">" then return main>val
    elseif op == "<" then return main<val
    elseif op == ">=" then return main>=val
    elseif op == "<=" then return main<=val
    elseif op == "and" then return main and val
    elseif op == "or" then return main or val
    
    --changers
    elseif op == "=" then return val
    elseif op == "+" then return main+val
    elseif op == "-" then return main-val
    elseif op == "/" then return main/val
    elseif op == "*" then return main*val
    elseif op == "**" then return main^val
    elseif op == "^" then return main^val
    elseif op == "%" then return main%val
    elseif op == "#" then return #val
    
    end
    return nil
    
end
    
function decodeData(item, data, _globals)
    local _globals = _globals or {}
    local op = operate
    local terminate = false
    if data._if ~= nil then
        for name,val in ipairs(data._if) do
            o = op(get(item,name,_globals),val[1],val[2])
            table.insert(ifs,o)
            if not o then terminate = true end
        end
    end
    if not terminate then
        for name,val in ipairs(data) do
            if name ~= "_if" then
                local v1 = get(item,name,_globals)
                local v3 = get(item,val[2],_globals)
                local result = op(v1,val[1],v3)
                item[name] = result
                --change so you can call other value later
            end
        end
    end
end

function createDigitalControllor(move,x,y,w,h,gooii)
    local gooi = gooii or gooi
    panel =gooi.newPanel({x =x or 0, y = y or H()-(h or 250), w =w or 250, 
    h = h or 250, layout = "grid 3x3"})

    panel
    :add(
      gooi.newButton({text = ""}):left(),
      gooi.newButton({text = "^"}):center()
      :onRelease(function()
            move(0,-1)
        end
        ),
      gooi.newButton({text=""}):right(),
      gooi.newButton({text = "<"}):left()
      :onRelease(function()
            self:move(-1,0)
        end
        ),
      gooi.newButton({text = "0"}):center()
      :onRelease(function()
        end
        ),
      gooi.newButton({text = ">"}):right()
      :onRelease(function()
            move(1,0)
        end
        ),
      gooi.newButton({text = ""}):left(),
      gooi.newButton({text = "v"}):center():secondary()
      :onRelease(function()
            move(0,1)
        end
        ),
      gooi.newButton({text=""}):right()
    )                
            
    return panel
end

function createJoystick(x,y,w,group)
    return gooi.newJoy({group=group,x=x or 0, y=y or 0 ,size = w or 60}):
       setStyle({showBorder = true})--:make3d()
end


function traceObject(target,ignore,start)
    local isarray = function(x)
        return type(x) == "table" and x[1] ~= nil
    end

    local getiter = function(x)
        if isarray(x) then
            return ipairs
        elseif type(x) == "table" then
            return pairs
        end
        error("expected table", 3)
    end

    local function remove(t, x)
        local iter = getiter(t)
       for i, v in ipairs(t) do
            if v == x then
                --if isarray(t) then
                    table.remove(t, i)
                    --return true
                --else
                    --t[i] = nil
                    --return true
                --end
            end
        end
       for i, v in pairs(t) do
            if v == x then
            
                    t[i] = nil
                    return true
                
            end
        end
        return false
    end

    local done = {}
    local data = ""
    local count = 0
    local refs = {}
    local inspect = inspect or tostring
    local gotten = {}
    local printed = {}
    local _inspect = function(n) return inspect(n,1) end
    if type(ignore)=="string" then
        ignore = {_G, ignore}
    else
        ignore = {}
    end
    local ii=0

    local function _traceObject(m,name,donemove)
        done[tostring(m)] = true 
        --log("tracing "..tostring(m)..(name and tostring(m[name]) or "")..inspect((name or "none"),1))
        --local donemove = donemove or {}
        local _printed = {}
        local function check(x,i)
        
            if i==target and not (x==ignore[2] and m==ignore[1]) then
                if not gotten[tostring(m)..x] then
                    local sp = " "
                    gotten[tostring(m)..x] = 1
                    table.insert(refs,{name or "_G",m})
        
                    if not printed[tostring(m)] then
                        for cc = 1,#refs do
                            local r = refs[cc]
                            local name, value = tostring(r[1]),r[2]
                            if not _printed[tostring(value)..name] then
                                data = string.format("%s\n%sMoving to index %s (name: %s): ",data,sp,name,(type(r[2]) == "table" and (r[2].name or r[2]._id or r[2].id)) or "<?>")
                                sp = string.format("%s    ",sp)
                                _printed[tostring(value)..name] = 1
                            end
                        end
                        printed[tostring(m)] = sp
                    end
                    sp = printed[tostring(m)]
                    data = string.format("%s\n%sFound target at index `%s`.",data,sp,x)
                    --return data
                    refs[#refs] = nil
                    for x, i in pairs(refs) do
                    --    refs = {}--[i] = nil--donemove[x] = nil
                    end
                end
            
            elseif type(i)=="table" and not done[tostring(i)] then
                local tt = {name or "_G",m}
                local name = name or "_G"
                
                table.insert(refs,tt)
                _traceObject(i,x)
                remove(refs,tt)
            else
                --log("==stopped "..tostring(i))
               
            end
        end
        
        for x,i in pairs(m) do
            check(x,i)
        end
        for x,i in ipairs(m) do
            check(x,i)
        end
        return data
    end
    local data = _traceObject(start or _G)
    if data=="" then
        data = "Not Found!"
    end
    return data
end
--[[
Use:
    traceObject(table object[, table/string ignore])
        table object: object(mostly table, can be other) that should be traced
        table ignore: {table parent, string name}, ignore entries of key 'name' in parent
        string ignore: ignores global variable put in ignore
        returns: string representing trace

    
--example
t = {"hey"}
gotcha = {["that"]=t}
gotcha.forge = {hey={7,8,9,k={0,["that"]=t,["y"]={"can",t},nu={7,7,t}},t,t}}


--print traces ignoring key "that" at table gotcha
print(traceObject(gotcha.that,{gotcha,"that"}))

--print traces ignoring key "t" at global table
print(traceObject(gotcha.that,"t"))

--print all traces
print(traceObject(gotcha.that))

--print all traces of string "can"
print(traceObject("can,"t"))
  ]]