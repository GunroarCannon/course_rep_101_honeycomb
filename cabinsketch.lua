game = toybox.Game("game")

local obj = toybox.Object("obj")

local s = 1550
obj.update = function(self,dt)
    if self.vx>0 then
        self.vx = self.vx-dt*s
    else
        self.vx = 0
    end
    self.source = "monsters/slime.png"
 
 end   

obj.draw = function(self)
    love.graphics.rectangle("line",self.x - (self.w-self.ogw)/2 ,self.y- (self.h-self.ogh)/1 ,self.w ,self.h)
end

function obj:create(p)
    self.w, self.h = p.w or 100, p.h or 100
    self:set_box(self.x,self.y,self.w/2,self.h/2)
    self:center()
    self.ogw = self.w
    self.ogh = self.h
end


local R = toybox.Room("R")

function R:setup() 
    self.o = obj:new({x=100,y=100})
    self:place_instance(obj:new({x=-100,y=400,w=1000,h=50,static=true,color="grey"}))
    self.o.draw=null
    self.o.gravity=15
    self.gravity = 15
    local o = self.o
    self:set_target(o)
    self:place_instance(o)
    
   -- self.timer:after(1,

end

function R:squash(obj, w, h, time, func)
    local time = time or 1
    
    obj._sqow = obj._sqow or obj.w
    obj._sqoh = obj._sqoh or obj.h
    obj.squashing = (w+h)/2--obj.squashing or 0
    obj.doneSquash = (obj.doneSquash or 0)+1
    local ow, oh = obj._sqow, obj._sqoh
    self:tween(time, obj, {
        w = ow*w,
        h = oh*h,
        doneSquash = obj.doneSquash-1,
        --squashing = (w+h)/2
    }, func or "out-quad")--,function()
end

function R:squashW(obj, w, time, func, tt,f2)
    if type(func)  == "number" then
        local ww = func
        func = function()
            self:squashW(obj, ww, tt or time,f2)
        end
    end
    
    return self:squash(obj, w, 1/w, time, func)
end

R.mousepressed=function(self)
    local o = self.o

    --if o.vx~= 0 then return end
 
    local t = self.timer
    local anim = .15
    o:apply_impulse(0,-500)
    
    self:squashW(o, 1/1.2, anim)
    o.jsquashed = false
    --self:after(anim,
    function --
    o:on_collide()
        local self = o
        if not self.jsquashed then
          --  if self.squashing ~= 1 then
            self.room:squashW(o, .2+1.2, anim*.5, "in-bounce")
            self:apply_impulse(0,-self.gravity*20)
            self.jsquashed = true
            self.room:after(anim*.5,function()
            self.room:squashW(o, 1, anim*.5,"out-quad")
               end)  
            self.jsquashed = true
        end
    end--)
    
    
    
end

function game:setup()
    self:setSource("hunt/assets/%s")
    self:add_room(R:new({}),true)
end

return game