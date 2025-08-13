local BaseController = class:extend("BaseController")

function BaseController:__init__(kwargs) 
    
    self.room = kwargs.room
    self.room:add_controller(self)
    
    self.object = kwargs.object 
end

function BaseController:attach(obj)
    self.object = obj
    return self
end

function BaseController:destroy()
    self.room:remove_controller(self)
end

function BaseController:__step(dt) 
    
    if self.baton then
        self.baton:update(dt)
    end
    
    if self.step then
      self:step(dt)
    end
end

function BaseController:__draw() 
    if self.draw then
      self:draw()
    end
end

function BaseController:__keypressed(x,y,button)
  if self.keypressed then
    return self:keypressed(x,y,button)
  end
end

function BaseController:__keyreleased(x,y,button)
  if self.keyreleased then
    return self:keyreleased(x,y,button)
  end
end

function BaseController:__mousepressed(x,y,button)
  if self.mousepressed then
    return self:mousepressed(x,y,button)
  end
end

function BaseController:__mousereleased(x,y,button)
  if self.mousereleased then
    return self:mousereleased(x,y,button)
  end
end

function BaseController:__mousemoved(x,y)
  if self.mousemoved then
    return self:mousemoved(x,y)
  end
end

function BaseController:touchreleased(id, x, y, dx, dy, pressure) 
end

function BaseController:touchpressed(id, x, y, dx, dy, pressure) 
end

function BaseController:touchmoved(id, x, y, dx, dy, pressure) 
end

return BaseController