local Boid = {}

-- Agent agent
--- [pos vector] agent.target
--- [bool] agent.noPath
--- [string] agent.steer
--- [number] agent.speed -- speed increment


--[[
  seek
  flee
  arrive
  pursuit
  wander
  evade
  arrive
]]


local function newBoid(obj)
    obj._old_move_before_boid = obj.on_move or null
    obj._old_update_before_boid = obj.__step
    obj._old_pre_move_before_boid = obj.pre_move or null
    
    for name, func in pairs(Boid) do
        obj[name] = func
    end
    
    obj:_init_boid()
    return obj
end

function Boid:_init_boid(kwargs)

    self.sight = 10

    self.maxForce = 1
    self.isBoid = 1

    self.agent = SteeringAgent:new(self.x,self.y)
    self.agent.vel.x = 10
    self.agent.speed = 1
end

function Boid:setAgentVelocity(vx, vy)
    self.vx = vx or self.vx
    self.vy = vy or self.vy
    self.agent.vel.x = self.vx
    self.agent.vel.y = self.vy
end

function Boid:checkMaxAgentVelocity(x,y)
    y = y or x
    self.vx, self.vy = self.agent.vel.x, self.agent.vel.y
    
    if math.abs(self.vx) > x then
        self.vx = x*self:getDir(self.vx)
    end
    
    if math.abs(self.vy) > y then
        self.vy = y*self:getDir(self.vy)
    end
    
    self:setAgentVelocity()
end

function Boid:checkMinAgentVelocity(x,y)
    y = y or x
    self.vx, self.vy = self.agent.vel.x, self.agent.vel.y
    if math.abs(self.vx) < x then
        self.vx = x*self:getDir(self.vx)
    end
    
    if math.abs(self.vy) < y then
        self.vy = y*self:getDir(self.vy)
    end
    
    self:setAgentVelocity()
end

function Boid:updateAgentVelocity(dt)
    local oldvy = self.vy
    local speed = self.agent.speed
    
    self.vx, self.vy = self.agent.vel.x*speed, self.agent.vel.y*speed
end

function Boid:updateAgentPos(dt)
   -- self.x, self.y = self:move(self.x+self.vx*dt, self.y+self.vy*dt,dt)
    self.agent.pos.x = self.x
    self.agent.pos.y = self.y
end

function Boid:updateBoid(dt,field)
    self.agent.dt = dt
            
    self.agent.checkMinV = (self.agent.checkMinV or 1)-dt
    if self.agent.checkMinV <= 0 then --nope! What if vx is supposed to be zero
        --self:checkMinAgentVelocity(self.min_vx or self.min_v or 0, self.min_vy or self.min_v or 0)
        self.agent.checkMinV = .5
    end
    
    self:checkMaxAgentVelocity(self.max_vx or self.max_v or 100, self.max_vy or self.max_v or self.maxVy)
    if self.agent.target and self.agent.target.x and (self.agent.noPath or self.agent.path) then
        self.agent:updateSteer((not self.agent.path and self.agent.steer) or "seek",self.agent.target, self.agent.panicDistance or self.agent.decelerationSpeed)
        

    end
    self.name_tag = tostring(self.agent.target)
    self:checkPath()
end

function Boid:__step(dt)
    --self:setAgentVelocity()
    
    self:_old_update_before_boid(dt)
    
    self:updateBoid(dt)
    self:updateAgentVelocity(dt)
    self:setAgentVelocity()
    self:updateAgentPos(dt)
end

function Boid:checkPath()

    local size = self.room and (self.room.tileW or self.room.tW) or (self.tile and self.tile.w) or
        self.tw or self.tW or self.w
    
    local cursor
    local w, h = self.w, self.h
    if self.world:hasItem(self) then
        x,y,w,h = self.world:getRect(self)
    end
    
    if self.agent.path then
            cursor = self.agent.path[self.agent.currentPosInPath]
            
            if not cursor then
                self.agent.path = nil
                self.agent.target = nil
                return
                
            elseif not cursor.converted then
                cursor.x=(cursor.x)*size+w/2
                cursor.y =(cursor.y)*size+h/2
                cursor.converted = 1
            end
            
                cursor.tile.rr = 1
            if cursor and lume.distance(cursor.x,cursor.y,self.x, self.y)<=(self.pathDistance or 5) then
                self.agent.currentPosInPath = self.agent.currentPosInPath+1
                self.vx, self.vy=0,0
                self:setAgentVelocity()
                local dst = self.agent.path[self.agent.currentPosInPath]
                --cursor.tile.color = "purple"
                if dst and self.agent.currentPosInPath~=1 then
                    if not dst.converted then
                        dst.x = dst.x*size+size/2
                        dst.y = dst.y*size+size/2
                        dst.converted = 1
                    end
                    disst = lume.distance(dst.x,dst.y,self.x,self.y)
                --self.angle = math.atan2(dst.y-self.y,dst.x-self.x)
                end
            end
               
        
        local cursor_angle = math.atan2(cursor.y-self.y,cursor.x-self.x)
        if 1 then 
            self.agent.target = cursor
            --self:adjustAngle(cursor_angle,dt,2,cursor)
            --self.doneP=self.currentPosInPath
        end

    end
        
end

local function getCenter(obj)
    local x = obj.x+obj.w/2
    local y = obj.y+(obj.h or obj.w)/2
    return {x=x,y=y}
end


local function getdir(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Boid:pre_move(x,y,dt)
    self:_old_pre_move_before_boid(x,y,dt)
    self:updateAgentVelocity(dt)
end

function Boid:poust_update(x,y,dt)
    self:_old_post_update_before_boid(dt)
    self:updateAgentPos()
end

function Boid:on_move(collisions,x,y,dt,actualX, actualY)

    local actX, actY = self:_old_move_before_boid(collisions, x, y, dt, actualX, actualY)
    actualX = actX or actualX
    actualY = actY or actualY
    
    local cc = collisions[1]
    
    if cc then
        local sp = self.agent.bounce or self.w--50
        local ccx = cc.normal.x~=0 and cc.normal.x or math.random(-1,1)==1 and 1 or -1
        local ccy = cc.normal.y~=0 and cc.normal.y or math.random(-1,1)==1 and 1 or -1
        self.vx = self.vx+ccx*math.random(10,15)/10*sp*self.w*dt
        self.vy = self.vy+ccy*math.random(10,15)/10*sp*self.h*dt
        self:setAgentVelocity()
     end
    log(tostring(actualX)..","..tostring(actualY).."??")
    return actualX, actualY
end
    
function Boid:findPathTo(x,y,converted)
    if type(x)=="table" then
        converted = y or x._x
        y=x._y or x.y
        x=x._x or x.x
    end
    
    local pathfinder = self.pathfinder or self.room.pathfinder or error("NO PATHFINDER FOR BOID, DUMDUM!")
    
    --self:setVelocity(0,0)
    local angle = math.atan2(y-self.y, x-self.x)
    local size = tw or self.room and (self.room.tileW or self.room.tW) or (self.tile and self.tile.w) or
        self.tw or self.tW or self.w
    local tt = {
        x = self._x or math.floor(self.x/size),
        y = self._y or math.floor(self.y/size)
    }
    
    local t = {x=converted and x or math.floor(x/size),y=converted and y or math.floor(y/size)}
    
    self.agent.goal = t
    
    path = pathfinder:getPath(tt.x,tt.y,t.x,t.y)--,self.isOpen)
    
    self.agent.currentPosInPath = 1
    
    _path = {}
    
    local ox, oy, pre
    
    if path then
        for x,c in path:nodes() do 
            x.x = x:getX()
            x.y = x:getY()
            x.converted = false
            
            x.tile = self.room:getTile(x.x,x.y)
            x.tile.color="blue"
            if strict then
                table.insert(_path, x)
            elseif (x.x==ox or x.y==oy) then
            else
                ox = x.x
                oy = x.y
                table.insert(_path,pre or x)
           --     table.insert(_path,x)
            end
            
            pre = x
            
        end
        
        if not strict then
            table.insert(_path,pre)
        end
    end
    
    self.agent.path= _path
    return self.agent.path
end


function Boid:drawDebug()
    love.graphics.setColor(255/255,255/255*(20-self.crowded)/20,255/255*(20-self.crowded)/20)
    local x1,y1 = self.x+math.cos(self.angle)*5,self.y+math.sin(self.angle)*5
    local x2,y2 = self.x+math.cos(self.angle+math.pi*0.8)*5,self.y+math.sin(self.angle+math.pi*0.8)*5
    local x3,y3 = self.x+math.cos(self.angle-math.pi*0.8)*5,self.y+math.sin(self.angle-math.pi*0.8)*5
    love.graphics.polygon("line",x1,y1,x2,y2,x3,y3)
    love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
    
    if self.target then
       -- love.graphics.line(self.x,self.y,self.target.x,self.target.y)
    end
end



function Boid:adjustAngle(target_angle,dt,power)
    local power = power or 1
    local target_angle = target_angle
    local angle_diff = target_angle - self.angle
    if math.abs(angle_diff) > math.pi then
        if angle_diff > 0 then
            angle_diff = -(2*math.pi-target_angle+self.angle)
        else
            angle_diff = 2*math.pi-self.angle+target_angle
        end
    end
    if angle_diff > 0 then
        self.angle = self.angle + power*dt
    else
        self.angle = self.angle - power*dt
    end
end

return newBoid