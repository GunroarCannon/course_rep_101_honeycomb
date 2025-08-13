local BaseObject = toybox.Object("BaseObject")

BaseObject.__step2 = BaseObject.__step

function BaseObject:create(p)
    self._parent = p.parent or {}
    p = p or {}
    
    self.x       = p.x or self.x
    self.y       = p.y or self.y
    self.h       = p.h or self.h
    self.w       = p.w or self.w
    
    self.vx      = p.vx or self.vx
    self.vy      = p.vy or self.vy
    
    -- Base objects need to be manually added to room
    -- idk why though XD
    -- self._created = true
    
    self.source = p.source or self.source
    self.static  = p.static
    self.solid   = p.solid--~=nil and not p.isBackground or p.solid
    self.isBackground = not self.solid
    self.depth = p.depth or self.depth
    
    self._parent._object = self
    
    if p.center then
        self:center()
    end
    
    self:set_box()
   
end

function BaseObject:__step(dt)
    self:__step2(dt)
    
    local p = self
    
    --self.soflid = not p.isBackground
    
    self.isBackground = p.isBackground
    self.type = self.isBackground and "background" or "solid"
    
    p.x = self.x
    p.y = self.y
    p.vx = self.vx
    p.vy = self.vy
end


return BaseObject