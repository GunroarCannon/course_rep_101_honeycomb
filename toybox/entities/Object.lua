local Object = class("Object")
-- Object:initialize
-- Object constructor
function Object:initialize(properties, ...)
  -- General variables
  local p = properties
  local kwargs = p
  
  self.time_alive = 0
  self.time_made = love.timer.getTime()
  
  self.id = lume.uuid()
  self.room = properties.room or toybox.room
  self.solid = (kwargs.solid==nil and true) or kwargs.solid
  self.visible = true
  self.static = kwargs.static
  
  self.depth = p.depth or self.time_made/1000000
  self.alarm = {}
  self.object_index = self.id
  self.id = self.object_index or self.id
  
  self.image_alpha = p.alpha or p.image_alpha or 1
  
  -- light_alpha, changes darkness of object but not opacity
  self.light_alpha = p.light_alpha or 1
  

  -- Built-in movements
  
  local pgravity = properties.gravity or
    (self.room and self.room.gravity)  
  local pgravity_direction = properties.gravity_direction or
    (self.room and self.room.gravity_direction)
  
  self.direction = 0
  self.friction = p.friction or 1
  self.bounce = p.bounce or 0
  self.doBounce = p.doBounce or 1
  self.bounces = 0
  self.mass = 1
  self.gravity = pgravity or 0  
  self.gravity_direction = pgravity_direction or 270
  self.vx = properties.vx or 0
  self.vy = properties.vy or 0
  self.va = properties.va or 0
  
  self.max_vx = p.max_vx or p.max_v or nil
  self.max_vy = p.max_vy or p.max_v or nil
  self.max_v  = p.max_v
  self.getVx  = p.getVx
  self.getVy  = p.getVy
  
  self.angle = 0
  self.speed = 0
  
  self.old_x = 0
  self.old_y = 0
  
  self.spritesBefore = {}
  self.sprites = {}
  self._spritesLen = 0
  self._spritesBeforeLen = 0
  
  self.ignores = {}
  self.collision_types = p.collision_types or {}
  self.type = "Object"
  self.get_collisions = p.get_collisions or false
  self.collision_type = p.collision_type or "slide"
  
  self.collided = {}
  
  
  self._to_ignore = {}
  
  self._created = properties._created
  
  self.x = properties.x or 0
  self.y = properties.y or 0
  self.offset_y = 0
  self.offset_x = 0
  self.axis_x = properties.axis_x
  self.axis_y = properties.axis_y
  self._w = 0
  self._h = 0
  self.flipX = properties.flipX or 1
  self.flipY = properties.flipY or 1
  
  self.flipX2 = properties.flipX2 or 1
  
  self.w = properties.w or 16
  self.h = properties.h or 16
  
  self.shake_x = 0
  self.shake_y = 0
  
  self.horizontal_shakes = {}
  self.vertical_shakes = {}

  self.last_horizontal_shake_amount = 0
  self.last_vertical_shake_amount = 0

  
  self.source = properties.source
  
  self.images = {}
  self._imagesLen = 0
  
  self.world = self.room.world

  -- Run create
  self:__create(properties, ...)
  
  if not self.rect then
    self:set_box()
  end
  
  if self.room and not self._created then
      self.room:place_instance(self)
  end
  
end

function Object:center(noRect)
    local x,y,w,h = self.x,self.y,self.w,self.h
    
    if not noRect and self.room.world:hasItem(self) then
        x,y,w,h = self.room.world:getRect(self)
    end
    
    self.offset_x = w/2
    self.offset_y = h/2
end

function Object:get_center()
    return self.x+(self.w/4+self.offset_x/4), self.y+(self.h/4+self.offset_y/4)
end

function Object:get_rect_center()
    return self.x+self.w/2, self.y+self.h/2
end

function Object.getAngle(from, too, x2, y2)
    if type(x2) == "number" and y2 then
        return -math.atan2(y2-too, x2-from)
    elseif type(too) == "number" then
        return -math.atan2(from, too)
    end
    
    return -math.atan2(too.y-from.y, too.x-from.x)
end

function Object:get_dir(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Object:getDir(...)
    return self:get_dir(...)
end

function Object:offset(x,y)
    self.offset_x = x or self.offset_x
    self.offset_y = y or self.offset_y
end

function Object:add_image(image, ox, oy, angle, w, h, fx, fy, color, alpha)
    local tb
    
    
    if type(image) == "table" then
        tb = image
        image = tb.source
    elseif type(ox) == "table" then
        tb = ox
        ox = nil
    end
    
    if tb then
        ox = tb.ox
        oy = tb.oy
        angle = tb.angle
        w = tb._w
        h = tb._h
        fx = tb.fx
        fy = tb.fy
        color = tb.color
        alpha = tb.alpha
    end
    
    local imgData = {
        source = image,
        offset_x = ox,
        offset_y = oy,
        angle = angle,
        color = color,
        alpha = alpha,
        _w = w,
        _h = h,
        fx = fx, fy = fy}
    self.images[self._imagesLen+1] = imgData
    self._imagesLen = #self.images
    
    return imgData
end

function Object:remove_image(imgData)
    local r = lume.remove(self.images, imgData)
    self._imagesLen = #self.images
    
    return r
end

function Object:project(angle,too,x2,y2,ac)
    local ac = ac
    
    if type(angle) == "table" and type(too)~="table" then
        ac = too
        too = angle
    end
    
    if too then
        local stop
        if type(too) == "table" then
            ac = x2
            x2 = nil
        elseif type(too) == "number" and not x2 then
            ac = too
            stop = true
        end
        if not stop then
            angle = self.getAngle(angle,too,x2,y2)
        end
    end
    
    ac = ac or self.room.physics_scale
    
    self.angleY = math.sin(angle)
    self.angleX = math.cos(angle)
    
    self.vx = ac*self.angleX
    self.vy = ac*-1*self.angleY
    
    
    self.thrown = .23
end

function Object:__create(properties, ...)
  if type(self.create) == 'function' then
    self:create(properties, ...)
  end
end

function Object:set_box(x,y,w,h)
  --if self.rect or
  if self.room.world:hasItem(self) then
    self.room.world:remove(self)
  end
  
  self.room.world:add(self,
      x or self.x, y or self.y,
      w or self.w, h or self.h
  )
  self.rect = true
end

function Object:boxes_intersect(other, extraW, extraH)
  local x,y,w,h = self:getRect()
  local x2,y2,w2,h2 = self.getRect(other)
  
  local vw = extraW or 0
  local vh = extraH or vw
  
  if x <= (x2+w2-vw) and (x+w) >= (x2+vw) and y <= (y2+h2-vh) and (y+h) >= (y2+vh) then
    return true
  else
    return false
  end
end

function Object:getRect()
  local x,y,w,h = self.x, self.y, self.w, self.h
  if self.world:hasItem(self) then
    x,y,w,h = self.world:getRect(self)
  end
    
  return x, y, w, h
end

function Object:get_rect(...)
    return self:getRect(...)
end

function Object:getY(y)
    return y or self.y
end

function Object:getX(x)
    return x or self.x
end

function Object:getVy(y)
    return y or self.vy
end

function Object:getVx(x)
    return x or self.vx
end

function Object:move_to(x,y)
  self.room.world:update(self,x,y)
  self.x, self.y = x,y
end

function Object:set_gravity(g)
  self.gravity = g
end

function Object:set_weight(w)
  self.weight = w
end

function Object:apply_impulse_x(n, limit)
  self.vx = self.vx+n
  if limit then
    local max = (type(limit) == "number" and  limit) or self:get_max_vx() or 500
    if math.abs(self.vx) > max then
      self.vx = self:getDir(self.vx) * max
    end
  end
end

function Object:apply_impulse_y(n, limit)
  self.vy = self.vy+n
  if limit then
    local max = (type(limit) == "number" and  limit) or self:get_max_vy() or 500
    if math.abs(self.vy) > max then
      self.vy = self:getDir(self.vy) * max
    end
  end
end

function Object:apply_impulse(n,nn,limit_x, limit_y)
  self:apply_impulse_x(n, limit_x)
  self:apply_impulse_y(nn, limit_y or limit_x)
end

function Object:get_max_vx()
  return self.max_vx or self.max_v
end

function Object:get_max_vy()
  return self.max_vy or self.max_v
end

function Object:set_speed(x,y)
  self.vx = x
  self.vy = y or self.vy
end

function Object:set_speed_x(x)
  self.vx = x
end

function Object:set_speed_y(y)
  self.vy = y
end

function Object:destroy(all)
  if self.destroyed then
      return
  end
  if self.sprite and not self.fake_destroy then
    self.sprite:destroy()
  end

  if self.id then
    self.room.instances[self.id] = nil
  end
  if self.on_destroy then self:on_destroy() end
  if self.rect and self.room.world:hasItem(self) then
    self.room.world:remove(self)
    self.rect = false
  end
  self.room:must_draw(self, true)
  self.room:must_update(self, true)
  self.destroyed = true
  if all then
    self.room.objects[self.id] = nil
  end
end

function Object:add_to_room(room, x, y)
  local room = room or toybox.room
  room:store_instance(self)
  self.world = room.world
  self.room = room
  self:set_box(x,y)
end
  
function Object:change_room(new, x, y)
  self.fake_destroy = true
  self:destroy(nil)
  self.fake_destroy = nil
  
  local new = new or toybox.room
  new:store_instance(self)
  self.room = new
  self.world = new.world
  self:set_box(x,y)
end

function Object:play_sound(sound,pitch,vol)

    if type(sound) == "table" then
        if type(sound[2]) == "string" then
            sound = getValue(sound)
        else
            vol = getValue(sound.volume or sound.vol or sound[3])
            pitch = getValue(sound.pitch or sound[2])
            sound = getValue(sound.sound or sound.source or sound[1])
        end
    end
    
    pitch = self.pitch or pitch
    local volumeg = nil
    if not media.sfx[sound] then warn(string.format("[Sound] %s does not exist",sound or "null")) end
    local s = media.sfx[sound].source:clone()
    if pitch == true then
        pitch = nil
        if self.sound == sound and self._sound:isPlaying() then
            return
        end
    end
    
    if pitch then
        s:setPitch(getValue(pitch))
    end
    
    self.sound = sound
    self._sound = s
    local vgg = vol or 1
    if type(self.get_volume) == "function" then
        vgg = vol or self:get_volume()
    end
    s:setVolume(vgg)
    s:play()
    self.last_played_sound = s
    
    return s
end

function Object:kill()
  return self:destroy(true)
end

function Object:ignore(instance, all)
  local item = instance
  
  if type(item) == "table" then
    self.ignores[item.id] = true
    if all then
      self.ignores[item.type] = true
      self.ignores[item.class_name] = true
    end
  else
    self.ignores[item] = true
  end
end

function Object:set_collision_type(instance, ttype, all)
  local item = instance
  
  if type(item) == "table" then
    self.collision_types[item.id] = ttype
    if all then
      self.collision_types[item.type] = ttype
      self.collision_types[item.class_name] = ttype
    end
  else
    self.collision_types[item] = ttype
  end
end

function Object:no_ignore(instance, all)
  local item = instance
  
  if type(item) == "table" then
    self.ignores[item.id] = nil
    if all then
      self.ignores[item.type] = nil
      self.ignores[item.class_name] = nil
    end
  else
    self.ignores[item] = nil
  end
end

function Object:ignore_for_now(item)
  self._to_ignore[item] = self.time_alive
end

function Object:add_sprite(sprite, frameDelay)
  sprite = sprite.isSprite and sprite or toybox.new_sprite(self,{
            animations = {
                {
                    name = "idle",
                    source = getValue(sprite),
                    useImages = true,
                    delay = frameDelay or .15,
                    mode = "loop"
                },
            
            }
        }):switch("idle")
        
  self._spritesLen = self._spritesLen + 1
  self.sprites[self._spritesLen] = sprite
  return sprite
end

function Object:addSprite(...)
    return self:add_sprite(...)
end

function Object:add_sprite_before(sprite)
  self._spritesBeforeLen = self._spritesBeforeLen + 1
  self.spritesBefore[self._spritesBeforeLen] = sprite
  return sprite
end

function Object:addSpriteBefore(...)
    return self:add_sprite_before(...)
end

function Object:attach_parent(parent)
  self.parent_object = parent
  self.px = parent.x-self.x
  self.py = parent.y-self.y
end

function Object:detach_parent(parent)
  self.parent_object = nil
  self.px = 0--parent.x-self.x
  self.py = 0--parent.y-self.y
end

function Object:get_angle_direction()
  return  math.deg(math.atan2(-(self.y-self.old_y),self.x-self.old_x))
end

function Object:__step(dt)

  for index, value in pairs(self.alarm) do
    if value >= 0 then
      self.alarm[index] = value - dt
    end

    if value < 0 and value ~= -1 then
      self.alarm[index] = -1

      if type(self['alarm'..index]) then
        self['alarm'..index](self)
      end
    end
  end
  
  self.dt = dt
  
  
  if self.timer then
      self.timer:update(dt)
  end


  if type(self.step) == 'function' then
    self:step(dt)
  end
  if type(self.update) == 'function' then
    self:update(dt)
  end
  
  if self.ignore_velocity and type(self.ignore_velocity) == "number" then
    
    if self.ignore_velocity <= 0 then
      self.ignore_velocity = nil
    else
      self.ignore_velocity = self.ignore_velocity - dt
    end
  end
  
  if self.ignore_velocity then
    self._ignored_vx = self._ignored_vx or self.vx
    self._ignored_vy = self._ignored_vy or self.vy
  end
  
  if not self.ignore_velocity then
    self._ignored_vx = nil
    self._ignored_vy = nil
  end
  
  
  
  if self.face_direction then
     self.angle = math.deg(math.atan2(-(self.y-self.old_y),self.x-self.old_x))+(type(self.face_direction)=="number" and self.face_direction or 0)
  end
  
  
  self.old_x = self.x
  self.old_y = self.y
  self.old_vx = self.vx
  self.old_vy = self.vy
  
    
  if self.thrown then
      --self.vx = 0
      --self.vy = 0
      if type(self.thrown) ~= "number" then
          --self.thrown = false
      else
          self.thrown = self.thrown-dt
          if self.thrown<=0 then
              self.thrown = true
          end
      end
  
  if (math.abs(self.vx)+math.abs(self.vy))<.3 then
      self.thrown = false
  end
  end
  
  self:check_shake(dt)
  self.angle = self.angle + self.va * dt
  if not self.static then
    self:__apply_velocities(dt)
  elseif self.world then
    --self:__move(self.x,self.y)
    self.y = self:getY(self.y)
    self.x = self:getX(self.x)
    if self.world:hasItem(self) then
        self.world:update(self,self.x,self.y)
    end
  end
  
  if self.parent_object then
    self.x = self.parent_object.x - self.px
    self.y = self.parent_object.y - self.py
    if self.world and self.world:hasItem(self) then
      self:move_to(self.x, self.y)
    end
  end
  
  

  for i = 1, self._spritesBeforeLen do
    self.spritesBefore[i]:update(dt)
  end
  
  if self.sprite then
    self.sprite:update(dt)
  end
  
  if self.sprite_2 then
    self.sprite_2:update(dt)
  end
  
  
  for i = 1, self._spritesLen do
    self.sprites[i]:update(dt)
  end
  
  if type(self.post_step) == 'function' then
    self:post_step(dt)
  end
  if type(self.post_update) == 'function' then
    self:post_update(dt)
  end

  -- update x previous and y previous
  self.xprevious = self.x
  self.yprevious = self.y
  
  
  self.time_alive = self.time_alive+dt

end

function Object:draw_sprites()
  for i = 1, self._spritesLen do
    self.sprites[i]:draw()
  end
end

function Object:draw_source_image()
  if self.source then
    local img = game:getSource(self.source)
    self._w, self._h = resizeImage(img, self.w, self.h)
    self:draw_image(img)
  end
end

function Object:draw_images()
  for i = 1, self._imagesLen do
    local data = self.images[i]

    
    self:draw_image_data(data)
  end
end

function Object:__draw()
  -- Skip draw event
  if not self.visible then
    return nil
  end
  
  local of = self.flipX
  self.flipX = self.flipX*self.flipX2

  local r, g, b, a = love.graphics.getColor()
  
  if type(self.draw_before) == 'function' then
    local dt = love.timer.getDelta()
    self:draw_before(dt)
  end
  
  local image_alpha
  
  if self.image_alpha < 1 or (self.room.image_alpha or 1) < 1 then
    image_alpha = (self.room.image_alpha or 1)-(1-(self.image_alpha or 1))
    love.graphics.setColor(r, g, b, image_alpha)
  end
  
  if self.color then
    love.graphics.setColor(toybox.getColor(self.color, image_alpha==1 and nil or image_alpha))
  end

  
  if self.color then
    love.graphics.setColor(toybox.getColor(self.color,image_alpha))
  end 
  
  if self.light_alpha ~= 1 then
    local r,g,b,a = lg.getColor()
    local l = self.light_alpha
    set_color(r*l, g*l, b*l, a*(l == 0 and 0 or 1))
  end

  local bl1, bl2 = love.graphics.getBlendMode()
  
  if self.blend then
    love.graphics.setBlendMode("alpha", "premultiplied")
  end
  
  for i = 1, self._spritesBeforeLen do
    self.spritesBefore[i]:draw()
  end

  -- Object drawing
  if self.sprite then
    self.sprite:draw()
  end
  
  self:draw_sprites()


  self:draw_source_image()
  self:draw_images()

  if self.sprite_2 then
    self.sprite_2:draw()
  end
  
  if type(self.draw) == 'function' then
    local dt = love.timer.getDelta()
    self:draw(dt)
  end

  if  LGML.__debug or LGML.debug or self.debug then
  
    local cx, cy = self:get_center()
    love.graphics.rectangle("fill", cx, cy, 10, 10)
  
    love.graphics.setColor(255, 0, 0, 1)
    love.graphics.line(self.x, self.y, self.x, self.y - 16)

    love.graphics.setColor(0, 255, 0, 1)
    love.graphics.line(self.x, self.y, self.x + 16, self.y)

    love.graphics.setColor(0, 0, 255, 1)
    love.graphics.line(self.x, self.y, self.x, self.y + 16)

    love.graphics.setColor(255, 255, 0, 1)
    love.graphics.line(self.x, self.y, self.x - 16, self.y)
    

    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
    
    if self.room.world:hasItem(self) then
        local x,y,w,h = self.room.world:getRect(self)
        love.graphics.setColor(0,1,1)
        love.graphics.rectangle("line",x,y,w,h)
    end
    
    
  end
  
  if self.name_tag then
    love.graphics.print(self.name_tag, self.x, self.y)
  end 
  
  if self.blend then
    love.graphics.setBlendMode(bl1, bl2)
  end

  love.graphics.setColor(r, g, b, a)
  
  
  if type(self.draw_after) == 'function' then
    self:draw_after()
  end
    
  if type(self.after_draw) == 'function' then
    self:after_draw()
  end
    
    
  if type(self.post_draw) == 'function' then
    self:post_draw()
  end
  
  self.flipX = of
end


function Object:redraw(x,y,angle,w,h,_w,_h)
    local of = self.flipX
    self.flipX = self.flipX*self.flipX2
    
    local ox, oy, oa, ow, oh = self.x,self.y,self.angle,self.w,self.h
    local oox, ooy = self.offset_x, self.offset_y
    
    self.x = x or ox
    self.y = y or oy
    self.angle = angle or oa
    self.w = w or ow
    self.h = h or oh
    self.offset_x = oox*(self.w/ow)
    self.offset_y = ooy*(self.h/oh)
    
    
    
    local s
    --add_sprit
    for x = 1, self._spritesLen+(self.sprite and 1 or 0) do
        s = self.sprites[x] or self.sprite
        
        s._ox, s._oy, s._ow, s._oh, s._ofx, s._ofy = s.x, s.y, s.w, s.h, s.offset_x, s.offset_y
        s.x = (self.x)--ox)
        s.y = (self.y)--oy)
        s.w = s.w*(self.w/ow)
        s.h = s.h*(self.h/oh)
        s.offset_x = s.offset_x*(self.offset_x/oox)
        s.offset_y = s.offset_y*(self.offset_y/ooy)-- error(s.offset_y..","..s._ofy)
        s:update(0)
    end
    
    for d = 1, self._imagesLen do
        local i = self.images[d]
        i._oh, i._ow, i._ofx, i._ofy = i._w, i._h, i.offset_x, i.offset_y
        if i._ofx then
            i.offset_x = i.offset_x*(self.offset_x/oox)
        end
        if i._ofy then
            i.offset_y = i.offset_y*(self.offset_y/ooy)
        end
        --local _nw, _nh = resizeImage(i._w, i._h, (type(i.source)=="string" and game:getAsset(i.source) or i.source):getDimensions())
        --error(i._w..","..i._h)
        if i._w then
            i._w = i._w*(self.w/ow)
        end
        if i._h then
            i._h = i._h*(self.h/oh)
        end
    end
    
    self:__draw()
    self.x, self.y, self.angle, self.w, self.h = ox, oy, oa, ow, oh
    self.offset_x, self.offset_y = oox, ooy
    
    for x = 1, self._spritesLen+(self.sprite and 1 or 0) do
        s = self.sprites[x] or self.sprite
        s.x, s.y, s.w, s.h, s.offset_x, s.offset_y = s._ox, s._oy, s._ow, s._oh, s._ofx, s._ofy
    end
    
    for d = 1, self._imagesLen do
        local i = self.images[d]
        i._w, i._h, i.offset_x, i.offset_y = i._oh, i._ow, i._ofx, i._ofy
    end
    
    self.flipX = of
end

  
function Object:draw_image_data(data)
    if not self.source then
      self._w, self._h = resizeImage(data.source, self.w, self.h)
    end
    
    assert(not (data.ox or data.oy), "Please use proper offset terminology for images (not 'ox'/'oy'.")
    
    return self:draw_image(
        data.source, data.offset_x, data.offset_y, data.angle, data._w, data._h, data.fx, data.fy, data.color, data.alpha
       ,data.ax, data.ay, data.w, data.h, data.ratio_w or data.rw, data.ratio_h or data.rh, data.light_alpha)
end

function Object:draw_image(img, resize, oy, angle, w, h, fx, fy, color, alpha, axis_x, axis_y, ww, hh, ratio_w, ratio_h, light_alpha)
    local r,g,b,a = love.graphics.getColor()
    
    local of = self.flipX
    self.flipX = self.flipX*self.flipX2
    
    if color then
        love.graphics.setColor(getColor(color))
    end
    
    if alpha then
        local r,g,b = love.graphics.getColor()
        love.graphics.setColor(r,g,b,alpha)
    end
    
    if light_alpha and light_alpha ~= 1 then
        local r,g,b,a = lg.getColor()
        local l = light_alpha
        set_color(r*l, g*l, b*l, a*(l == 0 and 0 or 1))
    end
  
    if type(img) == "string" then
        img = game:getSource(img)
    end
    local _w, _h = w or self._w, h or self._h
    local ox
    
    if resize and type(resize) ~= "number" then
        _w, _h = resizeImage(img, self.w,self.h)
    elseif resize then
        ox = resize
    end
    
    if ww or hh then
        _w, _h = resizeImage(img, ww or self.w, hh or self.h)
    end
    
    
    if ratio_w and not w then
        _w = resizeImage(img, (ww or self.w)*ratio_w)
    end
    
    if ratio_h and not h then
        local none
        none, _h = resizeImage(img, 0, (hh or self.h)*ratio_h)
    end
    
    local shake_x = self.shake_x
    local shake_y = self.shake_y
    
    love.graphics.draw(
        img, 
        self.x+(ox or self.offset_x)+shake_x+((self.flipX) == -1 and -self.w*0 or 0),
        self.y+(oy or self.offset_y)+shake_y+((self.flipY) == -1 and -self.h*0 or 0) ,
        math.rad(angle or self.angle)+(self.angle_2 and math.rad(self.angle_2) or 0),
        _w*(fx or self.flipX), _h*(fy or self.flipY),
        axis_x or self.axis_x or img:getWidth()/2,
        axis_y or self.axis_y or img:getHeight()/2,
        self.shearing_x,
        self.shearing_y
    )
    
    love.graphics.setColor(r,g,b,a)
    
    self.flipX = of
end

function Object:__check_collision_raw(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end

function Object:box_collides(x,y,w,h)
    if type(x) == "table" and x.getRect then
        x,y,w,h = x:getRect()
    end
    local x1,y1,w1,h1 = self:getRect()
    return self:__check_collision_raw(x1,y1,w1,h1,x,y,w,h)
end

function Object:place_free(x, y)
  local collision = false

  for index, instance in pairs(self.room.instances) do
    if instance.solid and instance.id ~=self.id then
      local has_collision = self:__check_collision_raw(
        x, y, self.w, self.h,
        instance.x, instance.y, instance.w, instance.h
      )

      if has_collision then
        collision = true
      end
    end
  end

  return not collision
end

function Object:__apply_gravity(dt)
  if self.noApplyGravity then return end
  
  local radians = math.rad(self.gravity_direction)
  local vacceleration = self.gravity * math.sin(radians);
  local hacceleration = self.gravity * math.cos(radians); 
  self.vy = self.vy - vacceleration*dt
  self.vx = self.vx + hacceleration*dt
  
  if self.weight then
    self.gravity = self.gravity + self.weight*dt
  end
end

function Object:__apply_speed()
  local radians = math.rad(self.direction)
  local vacceleration = self.speed * math.sin(radians);
  local hacceleration = self.speed * math.cos(radians);

  self.vy = self.vy - vacceleration
  self.vx = self.vx + hacceleration
end

function Object:__handle_collision()
  if self.room and self.solid == false then
    for index, instance in ipairs(self.room.instances) do
      if instance.id == self.id then
        return
      end

      local separation_x, separation_y = self:__calculate_separators(instance)

      if separation_x and separation_y then
        self:__resolve_collision(instance, separation_x, separation_y)
      end
    end
  end
end

function Object:move_to(x,y)
  self.x, self.y = x, y
  if self.room.world:hasItem(self) then
    self.room.world:update(self, x,y)
  end
end

function Object:__calculate_separators(instance)
  -- Calculate enter x and center y
  local sxx = self.x + (self.w / 2)
  local ixx = instance.x + (instance.w / 2)
  local syy = self.y + (self.h / 2)
  local iyy = instance.y + (instance.h / 2)

  -- distance between the rects
  local distanceX = sxx - ixx
  local distanceY = syy - iyy

  local abs_distance_x = math.abs(distanceX)
  local abs_distance_y = math.abs(distanceY)

  -- sum of the extents
  local sum_half_width = (self.w + instance.w) / 2
  local sum_half_height = (self.h + instance.h) / 2

  if abs_distance_x > sum_half_width or abs_distance_y > sum_half_height then
    -- no collision
    return
  end

  -- shortest separation
  local separation_x = sum_half_width - abs_distance_x
  local separation_y = sum_half_height - abs_distance_y

  if separation_x < separation_y then
    if separation_x > 0 then
      separation_y = 0
    end
  else
    if separation_y > 0 then
      separation_x = 0
    end
  end

  -- correct sign
  if distanceX < 0 then
    separation_x = -separation_x
  end

  if distanceY < 0 then
    separation_y = -separation_y
  end
  
  local physics_scale =self.room.physics_scale 

  return separation_x/physics_scale, separation_y/physics_scale
end

function Object:__resolve_collision(instance, separation_x, separation_y, collision)
  --collision is collision data gotten from kikito's bump.lua
  
  if collision and collision.normal.y ~=0 then
    
    if collision.normal.y == -1 and collision.type~="cross" then
      self.on_ground = true
    end
  end
  if collision and collision.normal.x ~= 0 then
      self.wall_on_side =true
  end
  
  
  local normalX, normalY = collision.normal.x, collision.normal.y
  local tangentX, tangentY = -normalX, normalY
  -- relative velocity
  local vx = self.vx - (instance.vx or 0)
  local vy = self.vy - (instance.vy or 0)
  
  if self.thrown then
      if type(self.thrown) ~= "number" then
          self.thrown = false
          self.uvx = 0
          self.vuy = 0
          self:__bounce(normalX, normalY,.7)
      elseif nil then--!!
          self.thrown = self.thrown-dt
          if self.thrown<=0 then
              self.thrown = false
          end
      end
  elseif self.bounce > 0 then--self.bounces<self.doBounce then
      if true then--self.doBounce>0 then
          self.bounces = self.bounces+1
          self:__bounce(normalX, normalY,self.bounce)
      end
  else
      self.bounces = 0
  end

  -- penetration speed
  local penetration_speed = vx * normalX + vy * normalY

  -- penetration component
  local penetration_x = normalX * penetration_speed
  local penetration_y = normalY * penetration_speed

  -- tangent component
  local tangent_x = vx - penetration_x 
  local tangent_y = vy - penetration_y

  -- restitution
  local restitution = 1 + math.max(self.bounce, instance.bounce or 0)

  -- friction
  local friction = 0--math.max(self.friction, instance.friction or 0)
  
  -- change the velocity of shape a
   
  --self.vx = vx - penetration_x * restitution + tangent_x * friction

  --self.vy = vy - penetration_y * restitution + tangent_y * friction
end

function Object:__bounce(nx, ny, b)
  local bounciness = lume.max(self.bounce,b or 0)
  
  if bounciness == 0 then
    return
  end

  local vx, vy = self.vx, self.vy

  if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
    vx = -vx * bounciness
    --self.bounced.x = true
  end
  
  if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
    vy = -vy * bounciness
    --self.bounced.y = true
  end
  
  if self.on_bounce then
      self:on_bounce(nx,ny,b)
  end
  
  self.vx, self.vy = vx, vy
end

function Object:__apply_velocities(dt)
  local dt = dt or love.timer.getDelta()
  assert(not accumulate)
  
  -- Apply forces that modify vy/vx
  self:__apply_gravity(dt)
 -- self:__apply_speed(dt)
  
  local physics_scale = self.room.physics_scale
  
  local max_vx = (self.thrown and (self.thrown_velocity or self.thrown_v)) or self.max_vx or self.max_v
  local max_vy = (self.thrown and (self.thrown_velocity or self.thrown_v)) or self.max_vy or self.max_v
  
  if max_vx and math.abs(self.vx)>max_vx then
      self.vx = self:get_dir(self.vx)*max_vx
  end
  
  if max_vy and math.abs(self.vy)>max_vy then
      self.vy = self:get_dir(self.vy)*max_vy
  end
  
  local vx = (self.ignore_velocity and self._ignored_vx) or self.vx
  local vy = (self.ignore_velocity and self._ignored_vy) or self.vy
  
  self.vx, self.vy = vx, vy
  
  local x = self:getX(self.x + self:getVx(vx) * physics_scale * (accumulate and error() and 1/60 or dt))
  local y = self:getY(self.y + self:getVy(vy) * physics_scale* (accumulate and error() and 1/60 or dt))
  
  
  if self.vx then  self.x, self.y = self:__move(x,y) end
end


function Object:__on_collide(collision)
  local other = collision.other
  if other.static and other.on_collide and not self.static then
    other:check_refresh_collided()
    
    collision.normalX = collision.normal.x*-1
    collision.normalY = collision.normal.y*-1
    collision.other = self
    
    local new_collision = lume.copy(collision)
    new_collision.normal = lume.copy(collision.normal)
    new_collision.normal.x = new_collision.normalX
    new_collision.normal.y = new_collision.normalY
    
    other:on_collide(new_collision)
    other:collide_with(new_collision)
    
    collision.normalX = collision.normal.x*-1
    collision.normalY = collision.normal.y*-1
    collision.other = other
  
  end
  
  self:collide_with(collision)
  
  if self.on_collide then
    return self:on_collide(collision)
  end
  
end

function Object:collide_with(col)
  if self.collided[col] then
    return
  end
  
  self.collided[col] = col
  self.collided[#self.collided+1] = col
end

function Object:check_to_ignore(other)
  if (self._to_ignore[other] or -10) >= self.time_alive then
    self._to_ignore[other] = self.time_alive+self.dt
    return true
  elseif self._to_ignore[other] then
    self._to_ignore[other] = nil
  end
end
  

function Object:__check_collision(other)
  if self:check_to_ignore(other) then
    return
  end
  
  if self.ignores[other.id] or self.ignores[other.team] then
    return
  end
  
  
  local type = self.collision_types[other.id] or self.collision_types[other.class_name] or other.team and self.collision_types[other.team]
  
  
  if not type and (self.ignores[other.type] or self.ignores[other.class_name]) then
    return
  end
  
  if not self.solid then return end
  
  
  local type = type or self.collision_types[other.type] or self.collision_types[other.name]
  if self.check_collision then
    return self:check_collision(other)
  end
  
  if type then
    return type
  end
  
  
  if not self.solid and not self.get_collisions then return end
  
  return other.solid and other.collision_type
end

function Object:check_refresh_collided()
  if self.col_steps ~= self.room.total_steps then
    self.col_steps = self.room.total_steps
    self:refresh_collided()
  end
end

function Object:refresh_collided()
  self.collided = {}
end

function Object:__move(x,y)
  if not self.room.world:hasItem(self) then
    return self.x, self.y
  end
  
  local dt = self.dt
  
  if type(self.pre_move) == "function" then
    self:pre_move(x, y, dt)
  end
  
  self.on_ground = false
  self.wall_on_side = false
  local actualX, actualY, collisions, len = self.room.world:move(self,x,y,
  self.__check_collision)
  local col
  for i = 1, len do
      col = collisions[i]
      if  self and col.type~="cross" then self:__resolve_collision(col.other,nil,nil,col) end
      local g= self:__on_collide(col)
      if g==false then break end--return g
      if self.destroyed then
          return actualX, actualY
      end
  end
  
  local nactualX, nactualY
  if type(self.on_move) == "function" then
    nactualX, nactualY = self:on_move(collisions, x, y, dt, actualX, actualY)
    
    if (nactualX and type(nactualX) ~= "number") or (nactualY and type(nactualY) ~= "number") then
        self.on_move()
        error("Improper movement positions at "..tostring(nactualX)..", "..tostring(nactualY))
    end
  end
  
  if self.no_movement then
    self:move_to(self.x, self.y)
    return self.x, self.y
  end
  return nactualX or actualX, nactualY or actualY
end

    
local function newShake(amplitude, duration, frequency)
    local self = {
        amplitude = amplitude or 0,
        duration = duration or 0,
        frequency = frequency or 60,
        samples = {},
        start_time = love.timer.getTime()*1000,
        t = 0,
        shaking = true,
    }

    local sample_count = (self.duration/1000)*self.frequency
    for i = 1, sample_count do self.samples[i] = 2*love.math.random()-1 end

    return self
end

function Object:shake(intensity, duration, frequency, axes)
    if not axes then axes = 'XY' end
    axes = string.upper(axes)

    if string.find(axes, 'X') then table.insert(self.horizontal_shakes, newShake(intensity, duration*1000, frequency)) end
    if string.find(axes, 'Y') then table.insert(self.vertical_shakes, newShake(intensity, duration*1000, frequency)) end
    
    return self
end
local function updateShake(self, dt)
    self.t = love.timer.getTime()*1000 - self.start_time
    if self.t > self.duration then self.shaking = false end
end

local function shakeNoise(self, s)
    if s >= #self.samples then return 0 end
    return self.samples[s] or 0
end

local function shakeDecay(self, t)
    if t > self.duration then return 0 end
    return (self.duration - t)/self.duration
end

local function move_shake(self, dx, dy)
    self.shake_x = self.shake_x + dx
    self.shake_y = self.shake_y + dy
end

local function getShakeAmplitude(self, t)
    if not t then
        if not self.shaking then return 0 end
        t = self.t
    end

    local s = (t/1000)*self.frequency
    local s0 = math.floor(s)
    local s1 = s0 + 1
    local k = shakeDecay(self, t)
    return self.amplitude*(shakeNoise(self, s0) + (s - s0)*(shakeNoise(self, s1) - shakeNoise(self, s0)))*k
end

local function check_shake(self, dt)
   -- Shake --
    local horizontal_shake_amount, vertical_shake_amount = 0, 0
    for i = #self.horizontal_shakes, 1, -1 do
        updateShake(self.horizontal_shakes[i], dt)
        horizontal_shake_amount = horizontal_shake_amount + getShakeAmplitude(self.horizontal_shakes[i])
        if not self.horizontal_shakes[i].shaking then table.remove(self.horizontal_shakes, i) end
    end
    for i = #self.vertical_shakes, 1, -1 do
        updateShake(self.vertical_shakes[i], dt)
        vertical_shake_amount = vertical_shake_amount + getShakeAmplitude(self.vertical_shakes[i])
        if not self.vertical_shakes[i].shaking then table.remove(self.vertical_shakes, i) end
    end
    self.shake_x, self.shake_y = self.shake_x - self.last_horizontal_shake_amount, self.shake_y - self.last_vertical_shake_amount
    move_shake(self, horizontal_shake_amount, vertical_shake_amount)
    self.last_horizontal_shake_amount, self.last_vertical_shake_amount = horizontal_shake_amount, vertical_shake_amount
    
end

function Object:stop_shake()
    self.horizontal_shakes = {}
    self.vertical_shakes = {}
    
    self.last_horizontal_shake_amount = 0
    self.last_vertical_shake_amount = 0
    
    self.shake_x = 0
    self.shake_y = 0
end


Object.update_shake = updateShake
Object.check_shake = check_shake


return Object