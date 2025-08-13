function newAnalog(Ax, Ay, Ar, Br, Bd)
    local self = {}
    local ww, hh = love.window.getMode()

    if type(Ax) == "table" then
        local kwargs = Ax
        Ax = kwargs.x or 200
        Ay = kwargs.y or hh-200
        Ar = kwargs.r or 100
        Br = kwargs.br or W(50)
        Bd = kwargs.bd or 20/100
    end
    
    self.cx = Ax or 200
    self.cy = Ay or hh - 200
    self.deadzone = Bd or 20/100 --Range from 0 to 1
    self.button = Br or 50
    self.size = Ar or 100
    self.angle = 0
    self.d = 0 --Range from 0 to 1
    
    self.dx = 0 --Range from 0 to 1
    self.dy = 0 --Range from 0 to 1
    
    self.held = false
    self.releasePos = 0
    self.releaseTimer = 0
    self.releaseSpeed = .2
    
    
    --Configurable settings
    self.spring = true
    self.reclick = true
    self.limitedRange = false
    self.rangeRelease = false
    self.pressure = .5
    
    self.digitalH = ""
    self.digitalV = ""
    
   -- self.player = game.player assert(self.player)
    
    self.getAngle = function(self)
        
        if 1 then
            return self.angle
        end
    end
    
    self._getAngle = function(self, cx, cy, x, y)
        local a = math.atan2(y-cy, x-cx)
        a = -a
        while a < 0 do
            a = a + math.pi*2
        end
        while a >= math.pi*2 do
            a = a - math.pi*2
        end
        
        return a
    end

    self.fade = function(self, currenttime, maxtime, c1, c2)
        local tp = currenttime/maxtime
        local ret = {} --return color

        for i = 1, #c1 do
            ret[i] = c1[i]+(c2[i]-c1[i])*tp
            ret[i] = math.max(ret[i], 0)
            ret[i] = 1*(math.min(ret[i], 255/255))
            
        end

        return unpack(ret)
    end
    
    self.distance = function(self, cx, cy, x, y)
        return math.sqrt( math.abs(x-cx)^2 + math.abs(y-cy)^2 )
    end
    
    self.renderGradient = function(self, size, c1, c2)
        local i = love.image.newImageData(size*2, size*2)
        for x = 0, size*2-1 do
            for y = 0, size*2-1 do
                local d = self:distance(size, size, x+1, y+1)
                local f = d/size
                f = math.max(0, f)
                i:setPixel(x, y, self:fade(f, 1, c1, c2))
            end
        end
        return love.graphics.newImage(i)
    end

    self.pokedStencil = function(self, cx, cy, d1, d2, s)
        for a = 0, s-1 do
            local p1x = math.cos(a/s*(math.pi*2))*d2
            local p1y = -math.sin(a/s*(math.pi*2))*d2
            
            local p2x = math.cos(a/s*(math.pi*2))*d1
            local p2y = -math.sin(a/s*(math.pi*2))*d1
            
            local p3x = math.cos((a+1)/s*(math.pi*2))*d1
            local p3y = -math.sin((a+1)/s*(math.pi*2))*d1
            
            local p4x = math.cos((a+1)/s*(math.pi*2))*d2
            local p4y = -math.sin((a+1)/s*(math.pi*2))*d2
            
            love.graphics.polygon("fill", cx+p1x, cy+p1y, cx+p2x, cy+p2y, cx+p3x, cy+p3y, cx+p4x, cy+p4y)
        end
    end
    
    local p = getPlayerColor()
    self.mist_gradientImage = mist or self:renderGradient(self.size, {--p[1],p[2],p[3],155/255},{1,1,1,55/254})
    0, 205/255, 255/255, 1*(155/255)}, {255, 255, 255, 1*(55/255)})
    
    mist= self.mist_gradientImage
    
    local p = getColor("red")
    self.blood_gradientImage = bg or self:renderGradient(self.size, {p[1],p[2],p[3],155/255},{p[1],p[2],p[3],55/254})
   -- 0, 205/255, 255/255, 1*(155/255)}, {p[1], 1*(55/255)})
    bg = self.blood_gradientImage
   
    
    
    self.setDigital = function(self,con)
        if con then
            self.digital = "8"
        else
            self.digital = false
        end
        return self
    end
    
    self.draw = function(self)
        --self screen
        local t = self
        
        love.graphics.setColor(255, 255, 255, 1*(155/255))
        love.graphics.circle("line", t.cx, t.cy, t.size, 32)
        love.graphics.circle("line", t.cx, t.cy, t.deadzone*t.size, 32)
        
        local ax, ay = t.cx + math.cos(t.angle)*t.d*t.size, t.cy - math.sin(t.angle)*t.d*t.size
        love.graphics.stencil( function() love.graphics.circle("fill", ax, ay, t.button, 32) end )
        love.graphics.setStencilTest( "equal", 0 )
        local l = love.graphics.getLineWidth()
        love.graphics.setLineWidth(12)
        love.graphics.setColor(0, 105/255, 155/255, 255)
        if self.digital then
            ax,ay = self:computeDigital()
        end
        
        love.graphics.line(ax, ay, t.cx, t.cy)
        love.graphics.circle("fill", t.cx, t.cy, 12/2, 32)
        love.graphics.setLineWidth(l)
        love.graphics.setStencilTest()
        
        local p = getColor("blue")
        love.graphics.setColor(p[1],p[2],p[3],1)--55/255)--0, 205/255, 255/255, 1*(155/255))
        love.graphics.circle("fill", ax, ay, t.button, 32)
        love.graphics.setColor(p[1],p[2],p[3],1)--0, 205/255, 255/255, 1)
        love.graphics.circle("line", ax, ay, t.button, 32)
        love.graphics.setColor(255/255, 255/255, 255/255, 1)
    end
    
    
      
    self.computeDigital = function(self)
        -- horizontal directions:
        local xv = self:getX(true)
        local yv = self:getY(true)

        local rStick = -self.button*2
        local w = 0--self.button
        local h = w
        local x, y = self.cx, self.cy
        
        if self.digital == "8" then
            -- horizontal direction:
            if xv < -0.5 then
                self.digitalH = "l"
                x = x + rStick
            elseif xv > 0.5 then
                self.digitalH = "r"
                x = x + w - rStick
            else
               self.digitalH = ""
               x = x + w / 2
            end
            --vertical:
            if yv < -0.5 then
                self.digitalV = "t"
                y = y + rStick
            elseif yv > 0.5 then
                self.digitalV = "b"
                y = y + h - rStick
            else
               self.digitalV = ""
               y = y + h / 2
            end
        elseif self.digital == "4" then-- 4 directions joystick:
            --ToDo
        end

        return x, y
    end

    self.direction = function(self)
        if self.digital then
            return self.digitalV..self.digitalH
         else
            return ""
        end
    end
  
    self.update = function(self,dt)
        --Actual code
        
        --Restore self to center if not being held
        if self.releaseTimer > 0 then
            self.releaseTimer = math.max(0, self.releaseTimer-dt)
        end
        if self.held == false and self.spring == true then
            self.d = math.max(0, self.releasePos*(self.releaseTimer/self.releaseSpeed) )
        end
        if self.d==0 then self.angle=0 end
        if self.spring and self.held == false and self.releaseTimer == 0 and not (self.dx == 0 and self.dy == 0) then
            self.releaseTimer = self.releaseSpeed
            self.releasePos = self.d
            self.dx = 0
            self.dy = 0
        end
    end

    self.touchPressed = function(self, id, x, y, dx, dy, pressure)
        if pressure > self.pressure then
            local d = self:distance(x, y, self.cx + math.cos(self.angle)*self.d*self.size, self.cy - math.sin(self.angle)*self.d*self.size)
            local e = self.notTouch and math.huge or self:distance(x, y, self.cx, self.cy)
            if not (self.reclick == false and self.d > 0 and self.spring == true) then
                if d <= self.button or e<=self.size then
                    self.held = id
                    self:touchMoved(id, x, y, dx, dy, pressure)
                    return true
                end
            end
        end
        local d = self:distance(x, y, self.cx + self.size, self.cy - self.size)
        --if not (self.reclick == false and self.d > 0 and self.spring == true) then
            if d <= self.button then
                return true
            end
     --   end
    end

    self.touchReleased = function(self,id, x, y, dx, dy, pressure)
        --local x, y = x*love.window.getWidth(), y*love.window.getHeight()
        --if pressure > self.pressure then
            if self.held == id then
                self:releaseStick()
                return true
            end
        --end
    end
    
    self.touchMoved = function(self,id, x, y, dx, dy, pressure)
        if pressure > self.pressure then
            if self.held == id then
                local d = self:distance(x, y, self.cx, self.cy)
                self.d = math.min(1, d/self.size)
                if not (self.limitedRange and d > self.size) then
                    self.angle = self:_getAngle(self.cx, self.cy, x, y)
                end
                if self.d >= self.deadzone then
                    if not (self.limitedRange and d > self.size) then
                        self.dx = math.cos(self.angle) * (self.d-self.deadzone)/(1-self.deadzone)
                        self.dy = -math.sin(self.angle) * (self.d-self.deadzone)/(1-self.deadzone)
                    end
                    
                    if self.rangeRelease and d > self.size then
                        self:releaseStick()
                    end
                else
                    self.dx = 0
                    self.dy = 0
                end
            end
            
        elseif self.held == id then
            self:releaseStick()
        end
    end
    
    self.releaseStick = function(self)
        self.held = false
        if not (self.spring == false and self.d > self.deadzone) then
            self.releaseTimer = self.releaseSpeed
            self.releasePos = self.d
            self.dx = 0
            self.dy = 0
        end
    end
    
    self.getX = function(self, sk)
        if self.digital and not sk then
            if self.digitalH=="" then
                return 0
            elseif self.digitalH == "r" then
                return 1
            elseif self.digitalH == "l" then
                return -1
            end
            error("Problem in digital x"..inspect(self.digitalH))
        end
        return self.dx
    end

    self.getY = function(self, sk)
        if self.digital and not sk then
            if self.digitalV=="" then
                return 0
            elseif self.digitalV == "b" then
                return 1
            elseif self.digitalV == "t" then
                return -1
            end
            error("Problem in digital y")
        end
        return self.dy
    end
    
    self._getDir = function(self, r) 
        r = math.floor(r*10)
        if r > 0 then
            return 1
        elseif r < 0 then
            return -1
        else
            return 0
        end
    end
    
    self.getPos = function(self)
        return self:getX(), self:getY()
    end
    
    function self:getXDir()
        return self:_getDir(self:getX())
    end
    
    function self:getYDir()
        return self:_getDir(self:getY())
    end
    
    function self:getDir()
        return self:getXDir(), self:getYDir()
    end
    
    self.isHeld = function(self)
        return self.held
    end
    
    return self
end

return newAnalog