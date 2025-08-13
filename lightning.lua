
local Lightning = {}
Lightning.__index = Lightning

local function bang()
    media.sfx.bang:play()
end

local function init(self)
    self.vy = -70
    self.vx = 0
    self.depth = DEPTHS.EFFECTS
    
    self.dead = .3
    
    self.id = lume.uuid()
    toybox.room:store_instance(self)
    self.room = toybox.room
    self.room:must_draw(self)
    self.room:must_update(self)
    
    self.ocolor = getColor(self.color)
    self.color = {1,1,1,1}
    
    self.x, self.y = self.source.x, self.source.y
    
    local timer = self.room.player and self.room.player.timer or self.room.timer
    timer:tween(.3,self.color,getColor(self.ocolor))
    --timer:after(.4, bang)
    --media.sfx.zap:play()
end

function Lightning:new(k)
    local source ={x=k.x, y=k.y}
    local target ={x=k.gx or k.goalX or k.x , y=k.gy or k.goalY or love.graphics.getHeight()}

    local t= {
        ox = k.ox, oy = k.oy,
        source=source,
        target=target,time=0,
        delay = k.delay or .1,
        mainLine={source, target},
        color = k.color or "yellow",
        thickness = k.thickness or 3/2,
        user = k.user or k.source,
        offset = k.offset,
        life = k.life
    }   
    init(t)
    return setmetatable(t, Lightning)

end

local dv =.1

function  Lightning:addPoint (lightning, index) -- 
index = math.random(#lightning.mainLine -1)
  local x1=lightning.mainLine[index].x
  local y1=lightning.mainLine[index].y
  local x2=lightning.mainLine[index+1].x
  local y2=lightning.mainLine[index+1].y
  local t = dv + 0.5*math.random()
  local x = x1+ t*(x2 - x1)
  local y = y1+ t*(y2 - y1)
  x = x + dv*(y2 - y1)* (math.random()-1) *-1
  y = y + dv*(x2 - x1)* (math.random()-1) *-1
  table.insert (lightning.mainLine, index+1, {x=x,y=y})
end

function Lightning :reload( )
    local u = self.user
    local x,y,w,h = u and u.getRect and u:getRect()
    if not w and u then
        x,y,w,h = u.x,u.y,u.w,u.h
    end
    
    local o = self.offset
    local oox, ooy = 0,0
    if o then
        self.ogx, self.ogy = self.ogx or self.x, self.ogy or self.y
        self.oox = o.x - self.ogx + self.ox
        self.ooy = o.y - self.ogy + self.oy
        --self.x = self.ogx + ox
        --self.y = self.ogy + oy
    end
    
    
    local oox, ooy = self.oox or 0, self.ooy or 0
    
    local s = self.user and {x=u.x,y=u.y} or {x = self.ogx or self.x, y = self.ogy or self.y}  or self.mainLine[1]
    local g = self.mainLine[#self.mainLine]
    self.oggx = self.oggx or g.x
    self.oggy = self.oggy or g.y
    self.mainLine = {
      {x = s.x+oox, y = s.y+ooy},
      {x = self.oggx+oox, y = self.oggy+ooy}
    }

    for x = 1 , math.random(50,80) do--or 10,18 or anything
        self:addPoint(self)
    end
end



function Lightning:destroy()
    self.room.instances[self.id] = nil
    self.room:must_draw(self,true)
end

function Lightning.__step(self, dt)
    if self.life then
        self.life = self.life - dt
        if self.life <= 0 then
            self:destroy()
            return
        end
    end
    
    self.time = self.time - dt
    self.source.x = self.x or self.source.x
    self.source.y = self.y or self.source.y
    if self .time <= 0 then
        self.time = self.delay
        self:reload()
    end
end    

function Lightning.__draw(self)
    local o = self.offset
    local oox, ooy = 0,0
    if o then
        self.ogx, self.ogy = self.ogx or self.x, self.ogy or self.y
        self.oox = o.x - self.ogx
        self.ooy = o.y - self.ogy
        --self.x = self.ogx + ox
        --self.y = self.ogy + oy
    end
    
    local g = lg.getLineWidth()
    lg.setLineWidth(g*2)
    
    for xx, ii in ipairs(self.mainLine) do
        local o = self.mainLine[xx-1]
        local ox = o and o.x or ii.x
        local oy = o and o.y or ii.y
        
        ox = ox + oox
        oy = oy + ooy
        
        local r,g,b,a = love.graphics.getColor()
        if self.color then
            love.graphics.setColor(getColor(self.color))
        end
        local p = love.graphics.getLineWidth()
        local pp = self.thickness or p
        love.graphics.setLineWidth(pp/2)
        set_color(1,1,1)
        --love.graphics.line(ox,oy+pp,ii.x,ii.y+pp)
        love.graphics.setLineWidth(pp)
        
        self.totalLife = self.totalLife or self.life
        if self.color or true then
            love.graphics.setColor(getColor(self.color or "white",self.life/self.totalLife))
        end
        love.graphics.line(ox,oy,ii.x,ii.y)
        set_color(1,1,1)
        love.graphics.setLineWidth(pp/2)
       -- love.graphics.line(ox,oy-pp,ii.x,ii.y-pp)
        love.graphics.setLineWidth(p)
        love.graphics.setColor(r,g,b,a)

    end
    
    lg.setLineWidth(g)
end

return  Lightning
--[[local getColor = _G.getColor or function(n,b,aa,a) return n,b,aa,a end

local function choose(t)
    return t[math.random(#t)]
end

local function point_distance(x,y,xx,yy)
    return math.sqrt(((x-xx)^2)+(y-yy)^2)
end

local function point_direction(x,y,xx,yy)
    return -math.atan2(yy-y, xx-x)
end

local random_range  = function(x,y)
    return math.random((y and x or -x), y or x)
end

local array_length = function(t)
    return #t
end


local function lengthdir_x(spd, ang)
    return spd*math.cos(ang)
end

local function lengthdir_y(spd, ang)
    return spd*-math.sin(ang)
end

local function draw_set_alpha(a)
    local r,g,b = love.graphics.getColor()
    love.graphics.setColor(r,g,b,a)
end


local function set_color(rr,gg,bb,aa)
    
    local r,g,b,a = love.graphics.getColor()
    
    if not rr then
        return r, g, b, a
    end
    
    love.graphics.setColor(rr,gg,bb,aa)
    return r,g,b,a,rr,gg,bb,aa
end

local function draw_line_width_colour(self, x1, y1, x2, y2,size,color1,color2)
    local r,g,b,a,rr,gg,bb,aa = set_color(color1)
    local p = love.graphics.getLineWidth()
    love.graphics.setLineWidth(size or p)
    self:drawLine(x1,y1,x2,y2,size or p,rr, gg ,bb,aa)
    set_color(r,g,b,a)
    love.graphics.setLineWidth(p)
end



local function draw_circle_colour(self, x,y,ra,c1,c2)
    local r,g,b,a,rr,gg,bb,aa = set_color(c1)
    self:drawCircle("fill",x,y,ra,rr,gg,bb,aa)
    set_color(r,g,b,a)
end

local c_white = {1,1,1}
function draw_lightning(self, x1, y1, x2, y2, branches, size, color)
    --draw_lightning(x, y, x2, y2, branches, size, colour)
    --
    --draws a lightning bolt from the given starting location to the given end location
    --
    --x = x of the bolt's start
    --y = y of the bolt's start
    --x2 = x of the bolt's end
    --y2 = y of the bolt's end
    --branches = true or false, if the lightning bolt branches into multiple smaller ones
    --size = pixel width of the lightning
    --colour = colour of the glow
    --
    --amusudan 23/5/2016
    --
    --feel free to use this in your project!
    --
    local dir = point_direction(x1,y1,x2,y2)
    local length = point_distance(x1,y1,x2,y2) --error(length)
    local colour = color;
    local _size = size;
    --make different segments
    local point = {};
    point[1] = 0;
    local i2 = 2;
    for i = 1, length do
        if (math.random() < .06) then
            point[i2] = i;
            i2 = i2+1;
        end
    end
    point[i2] = length;-- error(point[#point-0])
    local points = array_length(point);
    --draw segments
    local i2 = 2
    local difx = 0;
    local difx2 = 0;
    local dify = 0;
    local ii =0
    local dify2 = 0;    --error(points)
    local dis = 7
    for i2 = 2, points do
        local i2 = i2+ii
        difx = random_range(dis)
        dify = random_range(dis)
        local xx = x1 + lengthdir_x(point[i2 - 1],dir);
        local yy = y1 + lengthdir_y(point[i2 - 1],dir);
        local xx2 = x1 + lengthdir_x(point[i2],dir);
        local yy2 = y1 + lengthdir_y(point[i2],dir); --error(xx2..","..x1..",y2:"..yy2..","..y1..","..dir..","..point[i2])
        --create a branch
        if (math.random() < .15 and branches) then
            local bdir = dir + choose({random_range(-45,-25),random_range(45,25)});
            local blength = random_range(5,30);
            draw_lightning(self, xx + difx2, yy + dify2, xx + difx2 + lengthdir_x(blength,bdir), yy + dify2 + lengthdir_y(blength,bdir), false, _size, colour)
        end
        --draw the glow of the lightning
        set_color(1,1,1,.1)
        
        draw_line_width_colour(self, xx + difx2,yy + dify2,xx2 + difx,yy2 + dify, size*1.5,colour,colour);
        draw_line_width_colour(self, xx + difx2,yy + dify2,xx2 + difx,yy2 + dify, size*1.2,c_white,c_white);
        draw_line_width_colour(self,xx + difx2,yy + dify2,xx2 + difx,yy2 + dify, size*1.1,c_white,c_white);
        draw_set_alpha(1)
        --draw the white center of the lightning
        draw_line_width_colour(self,xx + difx2,yy + dify2,xx2 + difx,yy2 + dify, size,c_white,c_white);
        --ii = ii+1;
        difx2 = difx;
        dify2 = dify;
    end
    --draw a glowing circle
    if (nil or branches) then
        draw_set_alpha(.91);
        draw_circle_colour(self, x1,y1,size * 2.5,colour,colour,false);
        draw_circle_colour(self, x1,y1,size *1.5,colour,colour,false);
        draw_circle_colour(self, x1,y1,size * .5,colour,colour,false);
        draw_set_alpha(1);
        draw_circle_colour(self, x1,y1,size,c_white,c_white,false);
    end
end



local Lightning = {}
Lightning.__index = Lightning

function Lightning:new(k)
    local t = {
        lines = {},
        circles = {},
        getColor = k.getColor,
        color = k.color or c_white,
        life = k.life or .5,
        count = 0,
        interval = k.interval or .1,
        branches = k.branches or false,
        
        size = k.size or w or .3,
        x = k.x or error("Need x position"),
        y = k.y or error("Need y position"),
        goalX = k.gx or k.goalX or (k.x+math.random(k.h or k.size or k.w or 9)),
        goalY = k.gy or k.goalY or (k.y+math.random(k.h or k.size or k.w or 9))
    }   
   
    return setmetatable(t, Lightning)
end

function Lightning:getColor(r,g,b,a,line)
    return r,g,b,a,line
end

function Lightning:update(dt)
    self.count = self.count - dt
    if self.count <= 0 then
        self.count = self.interval
        self.lines = {}
        self.circles = {}
        self:getLines()
    end
    
end

function Lightning:getLines()
    return draw_lightning(self, self.x, self.y, self.goalX, self.goalY, self.branches, self.size, getColor(self.color))
end

function Lightning:drawLine(x1,y1,x2,y2,p,r,g,b,a)
    self.lines[#self.lines+1] = {
        x = x1, y = y1,
        x2 = x2, y2 = y2,
        r = r, g = g,
        b = b, a = a,
        width = p
    }
end

function Lightning:drawCircle(type, x, y, radius, r, g, b, a)

    self.circles[#self.circles+1] = {
        x = x, y = y,
        r = r, g = g,
        b = b, a = a,
        radius = radius,
        type   = type
    }
end

function Lightning:draw(dt)
    local rr, gg, bb, aa = love.graphics.getColor()
    local pw = love.grajphics.getLineWidth()
    for x = 1, #self.lines do
        local l = self.lines[x]
        local r,g,b,a,x,y,x2,y2,p = 
          l.r, l.g, l.b, l.a, l.x, l.y,
          l.x2, l.y2, l.width
        love.graphics.setColor(self:getColor(r,g,b,a,l))
        love.graphics.setLineWidth(p/2)
        
        set_color(1,1,1)
        love.graphics.line(x,y+p/2,x2,y2+p/2)
        
        love.graphics.setColor(self:getColor(r,g,b,a,l))
        love.graphics.line(x,y,x2,y2)
        
        set_color(1,1,1)
        love.graphics.line(x,y+p/2,x2,y2+p/2)
        
    end
    
    love.graphics.setLineWidth(pw)

    for x = 1, #self.circles do
        local l = self.circles[x]
        local r,g,b,a,x,y,radius,type = 
          l.r, l.g, l.b, l.a, l.x, l.y,
          l.radius, l.type
        love.graphics.setColor(self:getColor(r,g,b,a,l))
        
        love.graphics.circle(type,x,y,radius)
    end
    love.graphics.setColor(rr,gg,bb,aa)

end

return Lightning]]