local Projectile = toybox.Object("Projectile")

function Projectile.getAngle(from, too, x2, y2)
    if x2 then
        return -math.atan2(from, too, x2, y2)
    end
    
    return -math.atan2(too.y-from.y, too.x-from.y)
end

Projectile.__step2 = Projectile.__step

function Projectile:create(kwargs)
    self.w, self.h = kwargs.w or 40, kwargs.h or 40
    
    local p = kwargs.parent or kwargs.from
    self.parent = p
    
    local px, py, pw, ph = p:getRect()
    self.x = kwargs.x or p.x+pw-self.w/2
    self.y = kwargs.y or p.y+ph/2-self.h/2
    
    self.gravity = kwargs.gravity or 0
    self.type = "Bullet"
    
    self.angle = kwargs.angle or (kwargs.too and self.getAngle(kwargs.parent or kwargs.from, kwargs.too)) or 0
    
    self.angleY = math.sin(self.angle)
    self.angleX = math.cos(self.angle)
    
    if kwargs.passive then
        self:passiveDestroy()
        return self
    end
    
    self.hits = kwargs.hits or 1
    
    self.ac = kwargs.speed or kwargs.ac or 5
    
    --how many seconds bullet lasts
    self.life = kwargs.life or 1
    self.totalLife = self.life
    self.attack = (kwargs.attack or 1)--+(self.parent.attack or 0)
    self.on_hit = kwargs.on_hit or kwargs.onHit
    
    self.vx = 1*self.angleX
    self.vy = 1*-1*self.angleY
    
    self.vox = self.vx
    self.voy = self.vy
    
    self.mainAc = kwargs.ac
    self.startAc = kwargs.startAc or self.mainAc/10
    self.ac = self.startAc
    self.buildUp = kwargs.buildUp or .001
    
    self.range = kwargs.range
    if self.range then
        self.startTile = {x = self.x, y = self.y}
        self.maxDis = self.room.allTiles[1].w*self.range -- (self.x, self.y)
    end
 
    self.collision_type = "cross"
    if kwargs.jignoreParent then
        self:ignore(self.parent)
    else
        self:ignore(self.parent)
        local function undo()
            self:no_ignore(self.parent)
        end
        self.room.timer:after(kwargs.unignoreTime or .3, undo)
    end
    
    self:set_box()
    
    self.free_velocity = kwargs.free_velocity or kwargs.free
    
    self.timer = Chrono()
    
    if self.buildUp > 0.001 then
        self.timer:tween(self.buildUp, self, {ac = (self.mainAc)*1},"linear")
    else
        self.ac = self.mainAc
    end
    
    self.vx = self.vx*self.ac
    self.vy = self.vy*self.ac
    
    self.bounceOn = kwargs.bounceOn
    
    --self.gravity = 50
    self.grav = self.gravity
    self.gravity = 0
    self.room.timer:after(.1,function() self.free_velocity=true end)
end

function Projectile:__step(dt)
    self.life = self.life-dt
    
    if self.range then
        local dis = lume.distance(self.startTile.x, self.startTile.y, self.x, self.y)
        local d = self.maxDis-dis
        self.life = d
        self.totalLife = self.maxDis log(d) log(self.maxDis.."!! dis")
    end
    
    if self.totalLife/2>=self.life then
        self.image_alpha = self.life/(self.totalLife/2)
    end
    
    if not self.fre8e_velocity then
        local ac = self.ac
        self.vx = self.vx+ac*dt*self.vox--self.vox*self.ac
        self.vy = self.vy+(ac*self.voy+self.grav)*dt--voy*self.ac
    end

    
    if self.life <= 0 then
        self:destroy()
        return
    end
    
    self.tag = self.source
    self:__step2(dt)
end


--[[
Bounce variables:

    deflection = {0,1},
    attackAllOnBounce = (num)false,
    bounceOffset = 50,
    bounceOn = "isTile",
    maxBounce = (num)-1,
    hitAmount = (num)-1,
    mustBounce = false,
    hitOnBounce = (num)false,
    noCheckBounce = false,
    checkForMaxVelocity = true,
    checkForMinVelocity = false
]]

local function canBounce(bounceOn, other)
    local o = bounceOn
    
    if not o then
        return false
    elseif type(o) == "string" then
        return other[o]
    else
        for i, val in ipairs(o) do
            if canBounce(val, other) then
                return true
            end
        end
    end
    
    return false
end


function Projectile:on_collide(col)
    if self.onHit then
        self:onHit(col.other, col)
    end
    
    if self.attack > 0 and col.other.takeDamage then
        local a = self.attack
        local maxHits = self.hitAmount ~= -1 and self.hitAmount or self.hits
        while self.hits > 0 and maxHits>0 do
            self.hits = self.hits - 1
            maxHits = maxHits - 1
            col.other:takeDamage(self)
            if (col.other.stats and col.other.stats.health or col.other.health or col.other.life) <= 0 then
                break
            end
            break
        end
    end

    self.tbounced = self.tbounced or 0
    self.maxBounce = (not self.onBounce and 0) or self.maxBounce or -1
    local forceBounce
    
    if self.mustBounce and self.tbounced <= 0 then
        self.hits = (self.hits == 0 and 1 or self.hits)
        forceBounce = true
    end
    
    if (self.hits <= 0) and not forceBounce then
        self:destroy()
        
    elseif canBounce(self.bounceOn, col.other) then
        local bounceOffset = self.bounceOffset
        if type(self.bounceOffset) == "number" then
            bounceOffset = math.random(-self.bounceOffset,self.bounceOffset)
        end
        
        local v = self.vx
        
        local dfx = getValue(self.deflection or 1)
        local dfy = getValue(self.deflection or 1)
        if dfx == 0 and dfy == 0 then dfy = 1 end
        
        self.vx, self.vy = self.vx*-dfx+getValue(bounceOffset), self.vy*-dfy+getValue(bounceOffset)
        
        self.free_velocity = true
        --self.ac = 0
        self.tbounced = self.tbounced + 1
        

        if not self.noCheckBounce then
        
            self.vx = (self.vx+self.vy) == 0 and v*-1 or self.vx

            if self.checkForMaxVelocity then
                local nn = .7
                if math.abs(self.vy)>self.mainAc*nn then
                    self.vy = getDir(self.vy)*self.mainAc*nn
                end
                if math.abs(self.vx)>self.mainAc*nn then
                    self.vx = getDir(self.vx)*self.mainAc*nn
                end
            end
            if self.checkForMinVelocity then
                local nn = .7
                if math.abs(self.vy)<self.mainAc*nn then
                    self.vy = getDir(self.vy)*self.mainAc*nn
                end
                if math.abs(self.vx)<self.mainAc*nn then
                    self.vx = getDir(self.vx)*self.mainAc*nn
                end
            end
            
            
        end
        
        if self.hitOnBounce then
            local h = type(self.hitOnBounce) == "number" and self.hitOnBounce or 1
            if self.tbounced >= h then
                self.hits = self.hits - 1
            end
        end
        
        local attackAll = self.attackAllOnBounce
        if attackAll then
            attackAll = type(attackAll) == "number" and attackAll or 1
            if self.tbounced >= attackAll then
                self:no_ignore(self.parent)--self.team = self.id
            end
        end
        
        
        self.angle = math.deg(-math.atan2(self.vy, self.vx))
    
    elseif (col.other.isTile and self.tbounced>=(self.maxBounce ~= -1 and self.maxBounce or self.tbounced+1)) then
        self:destroy()
    end
end


return Projectile