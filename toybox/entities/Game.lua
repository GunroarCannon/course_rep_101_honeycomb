
local Game  = class('entities.Game')

-- Game constructor
function Game:initialize()
  self.rooms = {}
  self.room = false
  self._sources = {}
  self._images = {}
  self.timer = Chrono()
  
  self.sourcie = "assets/%s"
  _G.game = self
  
  -- Execute setup
  if type(self.setup) == 'function' then
    self:setup()
  end
end


function Game:setSource(s)
    self.sourcie = s
    assert(s)
end

function Game:getSource(source, new)
    if type(source) ~= "string" then return source end
    
    self._sources=self._sources or {}
    assert(source)
    --log(source)
    

    if self._sources[source] == nil or new==true then
        log(string.format("[GAME] Creating New Asset <%s>", source))
        
        self._sources[source] = Graphics.newImage(string.format(self.sourcie,source))
        self._images[self._sources[source]] = source
        if self.set_image_filter then
            self._sources[source]:setFilter(self.set_image_filter, self.set_image_filter)
        end
    elseif self.sejt_image_filter then
    
        local s = self._sources[source]
        local df, g = s:grtDefaultFilter()
        error(df..","..tostring(g))
        self.filters[source] = df
        s:setDefaultFilter(self.set_image_filter, self.set_image_filter)
    elseif nil then
    end
    return self._sources[source]
end

function Game:getAsset(...)
    return self:getSource(...)
end

function Game:getAssetName(asset)
    for x, a in pairs(self._sources) do
        if asset == a then
            return x
        end
    end
end

function Game:getSourceName(...)
    return self:getAssetName(...)
end

function Game:getImageSource(img)
    return self._images[img] or nil
end


function Game:getSourceFromPath(source, new)
    self._sources=self._sources or {}
    if self._sources[source] == nil or new==true then
        self._sources[source] = Graphics.newImage(source)
    end
    return self._sources[source]
end



function Game:getAssetFromPath(...)
    return self:getSourceFromPath(...)
end

-- Game:update:
function Game:__step(dt)
  if toybox.check_update then
    ProFi:start()
    toybox.startedP = true
  end
  media.cleanup(dt)
  self.timer:update(dt)
  
  if type(self.step) == "function" then self:step(dt) end
  if self.update then self:update(dt) end
  
  if self.room then--and self.room:isInstanceOf(Room) then
    self.room:__step(dt)
  end
  
  if self.post_update then
    self:post_update(dt)
  end
  
  IM:update(dt)
  
  if toybox.check_update and toybox.startedP then
    ProFi:stop()
    ProFi:writeReport("toybox_update.txt")
    error("ProFi wrote update report")
  end
end

-- Game:draw:
-- Call current room draw method
function Game:__draw(dt)
  res.beginRendering()
  
  if self.draw_before then
    self:draw_before(dt)
  end
  
  if self.room then--and self.room:isInstanceOf(Room) then
    self.room:__draw(dt)
  end
  
  if type(self.draw) == "function" then
    self:draw(dt)
  end
  
  res.endRendering()
end

function Game:add_room(room,isInstance)
  print('[App:add_room] Added new room: ' .. room.name)
  self.rooms[room.name] = isInstance and room or room:new()

  -- Set initial room
  if not self.room then
    self:set_room(room.name)
  end
end

-- Game:set_room:
-- Changes current room based on its name
function Game:set_room(roomName)
  self.old_room = toybox.room or self
  
  local nextRoom = type(roomName) == "table" and roomName or self.rooms[roomName]
  
  if not nextRoom.__created then
    nextRoom = nextRoom:new({})
  end
  
  assert(nextRoom, string.format("No room with the name %s", roomName or "null"))
  
  roomName = nextRoom.name
  
  if self.rooms[roomName] and self.rooms[roomName] ~= nextRoom then
    log("[WARNING] Displacing room "..roomName)
  end
  
  self.rooms[roomName] = nextRoom

  if self.room and self.room.noRefresh then
    self.room:kill()
  end

  if nextRoom then
    print('[Game:set_room] Running room: ' .. roomName)
    self.room = nextRoom
    toybox.room = self.room
    if self.room.onSwitch then
      self.room:onSwitch()
    end
    self.room:init()
  else
    print('[Game:set_room] Failed running room: ' .. roomName)
    self.room = false
  end
  
  return self.room
end

function Game:get_room(name)
  return self.rooms[name]
end

function Game:keypressed(key)
  IM:keyPressed(key)
  
  if self.doKeyPress then
    self:doKeyPress(key)
  end

  if self.room then
    self.room:__keypressed(key)
  end
end

function Game:keyreleased(key)
  IM:keyReleased(key)
  
  if self.room then
    self.room:__keyreleased(key)
  end
  
  if key == 'escape' then
    -- love.event.quit()
  end
end

function Game:textinput(text)
  if self.room then
    self.room:__textinput(text)
  end
end

function Game:mousepressed(x,y,button)
  local x, y = res.getMousePosition(_W,_H,x,y)
  
  if self.room then
    self.room:__mousepressed(x,y,button)
  end
end

function Game:mousereleased(x,y,button)
  local x, y = res.getMousePosition(_W,_H,x,y)
  
  if self.room then
    self.room:__mousereleased(x,y,button)
  end
end

function Game:mousemoved(x,y)
  local x, y = res.getMousePosition(_W,_H,x,y)
  
  if self.room then
    self.room:__mousemoved(x,y,button)
  end
end

function Game:touchpressed(id, x, y, dx, dy, pressure)
  local x, y = res.getMousePosition(_W,_H,x,y)
  
  if self.room then
    self.room:__touchpressed(id, x, y, dx, dy, pressure)
  end
end

function Game:touchreleased(id, x, y, dx, dy, pressure)
  local x, y = res.getMousePosition(_W,_H,x,y)
  
  if self.room then
    self.room:__touchreleased(id, x, y, dx, dy, pressure)
  end
end

function Game:touchmoved(id, x, y, dx, dy, pressure)
  local x, y = res.getMousePosition(_W,_H,x,y)
  
  if self.room then
    self.room:__touchmoved(id, x, y, dx, dy, pressure)
  end
end

return Game