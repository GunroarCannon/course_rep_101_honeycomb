local Controller = class:extend("Controller")

local DESKTOP =   love.system.getOS()~= "Android" and
love.system.getOS()~= "IOS"
function Controller:__init__(kwargs)
    kwargs = kwargs or {}
    
    self.paddy = Paddy:new({Rjoystick=not kwargs.noRjoystick and true or false,Ljoystick=not DESKTOP and not kwargs.noLjoystick,ly=kwargs.ly,lx=kwargs.lx})--DESKTOP_CONTROLS})
    self.index = kwargs.index or 1
    
    if DESKTOP then
        self.paddy.draw = tostring
        self.paddy.update = tostring
        self.paddy.isDown = function() return false end
    end
    
    self.room = kwargs.room or toybox.room
    self.room:add_controller(self)
    
    self.object = kwargs.object

    self.Ljoystick = self.paddy.Ljoystick
    self.Rjoystick = self.paddy.Rjoystick
    
    local paddy = self.paddy
    
    local joysticks = love.joystick.getJoysticks()
    local joy = joysticks[self.index]
    
    if joy and joy:isGamepad() and false then--!!??
        self.hardJoystick = joy
    else
        joy, joysticks = nil,{}
    end
    
    
    self.Ljoystick = self.Ljoystick or {
        parent = self,
        getXDir = function(self)
            if self.dx then
                local dx = self.dx
                if self.release then
                    self.dx = nil
                end
                return dx
            end
            
            local dz = IM.deadzone
            
            local hardJoystick = self.parent.hardJoystick
            
            if (self.hardJoystick and
                math.abs(self.hardJoystick:getGamepadAxis(IM.joyMove.x))>0) then
                return self.hardJoystick:getGamepadAxis(IM.joyMove.x)
            end
            
            if self.parent.baton and (DESKTOP or self.parent.baton.config.joystick) then
                local baton = self.parent.baton
                local x, y = baton:get("move")
                return x
            end
            
            if (IM.active and (IM:isDown("JumpRight") or IM:isDown("Right"))) then
                return 1
            end

            if IM.active and IM:isDown("JumpLeft") or IM:isDown("Left") then
                return -1
            end
            
            if paddy:isDown("m_right","m_upright","m_downright") then
                return 1
            elseif paddy:isDown("m_left","m_downleft","m_upleft") then
                return -1
            else
                return 0
            end
        end,
        
        getYDir = function(self)
            if self.dy then
                local dy = self.dy
                if self.release then
                    self.dy = nil
                end
                return dy
            end
            
            local hardJoystick = self.parent.hardJoystick
            
            
            if self.hardJoystick and
                math.abs(self.hardJoystick:getGamepadAxis(IM.joyMove.y))>IM.deadzone then
                return self.hardJoystick:getGamepadAxis(IM.joyMove.y)
            end
            
            
            
            if self.parent.baton and (DESKTOP or self.parent.baton.config.joystick) then
                local baton = self.parent.baton
                local x, y = baton:get("move")
                return y
            end
            
            if IM.active and IM:isDown("JumpRight") then
                return -1
            end
            
            if IM.active and IM:isDown("JumpLeft") then
                return -1
            end
            
            
            if IM.active and IM:isDown("Jump") then
                return -1
            end
            
            if IM.active and IM:isDown("Down") then
                return 1
            end
            
            
            
            if paddy:isDown("m_down","m_downleft","m_downright") then
                return 1
            elseif paddy:isDown("m_up","m_upleft","m_upright") then
                return -1
            else
                return 0
            end
        end,
        
        getPos = function(self)
            return self:getXDir(), self:getYDir()
        end,
        
        releaseStick = function(self)
            self.dx, self.dy = nil, nil
        end
    }
    
    if DESKTOP_CONTROLS then
        self.Ljoystick.getX = self.Ljoystick.getXDir
        self.Ljoystick.getY = self.Ljoystick.getYDir
    end
end

function Controller:attach(obj)
    self.object = obj
    return self
end

function Controller:destroy()
    self.room:remove_controller(self)
end

function Controller:__step(dt)
    self.paddy:update(dt)
    
    if self.baton then
        self.baton:update(dt)
    end
    
    self.dx = self.Ljoystick.dx
    self.dy = self.Ljoystick.dy
    
    if self.step then
      self:step(dt)
    end
    
    if self.update then
      self:update(dt)
    end
end

function Controller:__draw()
    self.paddy:draw()
    if self.draw then
      self:draw()
    end
end

function Controller:__mousepressed(x,y,button)
  if self.mousepressed then
    return self:mousepressed(x,y,button)
  end
end

function Controller:__mousereleased(x,y,button)
  if self.mousereleased then
    return self:mousereleased(x,y,button)
  end
end

function Controller:__mousemoved(x,y)
  if self.mousemoved then
    return self:mousemoved(x,y)
  end
end


function Controller:__keypressed(x,y,button)
  if self.keypressed then
    return self:keypressed(x,y,button)
  end
end

function Controller:__keyreleased(x,y,button)
  if self.keyreleased then
    return self:keyreleased(x,y,button)
  end
end

function Controller:touchreleased(id, x, y, dx, dy, pressure)
    return self.paddy:touchreleased(id, x, y, dx, dy, pressure)
end

function Controller:touchpressed(id, x, y, dx, dy, pressure)
    return self.paddy:touchpressed(id, x, y, dx, dy, pressure)
end

function Controller:touchmoved(id, x, y, dx, dy, pressure)
    return self.paddy:touchmoved(id, x, y, dx, dy, pressure)
end

return Controller