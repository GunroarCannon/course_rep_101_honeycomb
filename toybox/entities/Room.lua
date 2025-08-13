-- Create class
local Room = class('Room')

-- Room:initialize
-- Room constructor
function Room:initialize(p)
  p = p or {}
  self.__created = true
  local old_room = toybox.room
  toybox.room = self
  -- Room creation
  self.objects = {}
  self.instances = {}
  self.viewports = {}
  self.viewport = false
  self.viewport_target = false
  self.width = W()--640
  self.height =H()-- 480
  
  self.physics_scale = 1
  self.gravity = 0
  self.world = bump.newWorld(16)
  
  self.timer = Chrono()
  self.controllers = {}
  
  self._must_draw = {}
  self._must_update = {}
  
  self.name = "room"
  self.total_steps = 0

  self:add_viewport('default', {})
  self:set_viewport('default')
  
  self.noRefresh = p.noRefresh
  self._instanceRoom = true
  
  self.freeze = p.freeze or .1
  
  self.ui_map = {}
  self.current_ui = nil
  self.current_ui_x = 0
  self.current_ui_y = 0
  self._lastMovedUI = 0
  
  self.cover_alpha = p.cover_alpha or p.alpha or 0
  
  
  self._tweening = {}
  self._squashing = {}
 
  function refreshUI()
       for ui, _ in pairs(self._tweening) do
           if ui.refresh then
               ui:refresh()
           end
           
           if ui.tweening <= 0 then
               self._tweening[ui] = nil
           end
       end
  end
  
  self._check_ui_tween = self.timer:every(1/20, refreshUI)
  
  -- Execute setup
  if type(self.setup) == 'function' then
    self:setup(p)
  end
  
  toybox.room = old_room or self
end

function Room:on_switch_ui(new, old)
    if old then
        old.bgColor = old.__toybox_oldBgColor 
    for i, n in ipairs(old.images) do
        n.__toybox_oldBgColor = n.color
        -- n.color = getColor("gold")
    end
    end
    
    new.__toybox_oldBgColor = new.bgColor
    -- new.bgColor = getColor("gold")
    
    for i, n in ipairs(new.images) do
        n.__toybox_oldBgColor = n.color
        -- n.color = getColor("gold")
    end

end

function Room:shake(...)
    if self.camera then
        return self.camera:shake(...)
    end
end


function Room:new_ui_map_data(umap)
    return {
        ui_map = umap or {},
        map_ui=self.map_ui,
        set_ui=self.set_ui
    }
end

function Room:load_ui_map_data(data)
    return self:load_ui_map(data, true)
end

function Room:load_ui_map(ui_map, is_data)
    if not ui_map then error("No ui Map") return end
    local old_ui = self.current_ui
    local old_ui_map_data = self.ui_map_data or {
        ui_map = self.ui_map,
        current_ui_x = self.current_ui_x,
        current_ui_y = self.current_ui_y,
        current_ui = self.current_ui,
        map_ui = self.map_ui,
        set_ui = self.set_ui
        
    }
    
    
    local data
    if is_data then
        data = ui_map
        ui_map = ui_map.ui_map
        self.current_ui = data.current_ui
        self.current_ui_x = data.current_ui_x
        self.current_ui_y = data.current_ui_y
        self.check_for_added_ui = data.check_for_added_ui
        data.old_ui_data = old_ui_map_data
    end
    
    self.ui_map = ui_map
    
    
    
    if not data then
        local umap = ui_map
        local x = #umap>0 and lume.min(umap,nil,true)
        local y = #umap>0 and #umap[x]>0 and (umap[x][1] and 1 or math.random(#umap[x]))
        self.current_ui_x = x or 0
        self.current_ui_y = y or 0
        self.current_ui = umap[x] and umap[x][y]
        if self.current_ui then
            self:on_switch_ui(self.current_ui, old_ui_map_data.current_ui)
        end
    end
    
    self.ui_map_data = data or {
        ui_map = self.ui_map,
        current_ui_x = self.current_ui_x,
        current_ui_y = self.current_ui_y,
        current_ui = self.current_ui,
        map_ui = self.map_ui,
        set_ui = self.set_ui,
        old_ui_data = old_ui_map_data,
        check_for_added_ui = nil,--self.check_for_added_ui
    }
    
    if data.current_ui then
        self:on_switch_ui(self.current_ui, old_ui)
    end
    
    return old_ui_map_data
end


function Room:map_ui(ui, x, y, ui_type)
    if type(ui) == "number" then
        local ou, ox, oy = ui, x, y
        x = ui
        ui = oy or ox
        y = oy and ox
    end
    
    local umap = self.ui_map
    local oo = y
    local yi = x
    local xi = oo
    ui.ui_type = ui_type or ui.ui_type
    
    local old
    
    if x and y then
        umap[x] = umap[x] or {}
        old = umap[x][y]
        umap[x][y] = ui
    
    elseif x then
        umap[x] = umap[x] or {}
        umap[x][#umap[x]+1] = ui
    
    elseif y then
        -- nope
    end
    
    if not self.current_ui then
        local x = lume.randomchoice(lume.keys(umap))
        local y = lume.randomchoice(lume.keys(umap[x]))
        self.current_ui_x = x
        self.current_ui_y = y
        self.current_ui = umap[x][y]
        if self.on_switch_ui then
            self.current_ui.selected_ui = true
            self:on_switch_ui(self.current_ui)
        end
    end
    
    return old

end

function Room:set_ui(ui, y)
    local x
    if type(ui) == "number" then
        x = ui
        local c = self.ui_map[x] and self.ui_map[x][y]
        if c then
            self.current_ui = c
            self.current_ui_x = x
            self.current_ui_y = y
            return true
        end
    end
    
    for _,y1 in lume.iter(self.ui_map) do
        for __,x1 in lume.iter(y1) do
            if x1 == ui then
                self.current_ui = x1
                self.current_ui_x = _
                self.current_ui_y = __
                return true
            end
        end
    end
end

local function reverseMap(map, x, y)
    local all = {}
    for x = lume.min(map, nil, true), lume.max(map, nil, true) do
        local pos = map[x]
        if pos then
            for y = lume.min(pos, nil, true), lume.max(pos, nil, true) do
                local obj = pos[y]
                if obj then
                    all[y] = all[y] or {}
                    all[y][x] = obj
                end
            end
        end
    end
    
    return all
end

function Room:move_ui(dx, dy)
    if dx == 0 and dy == 0 then return end
    if self._lastMovedUI > 0 then return end
    
    self._lastMovedUI = self.ui_move_cooldown or .25
    local x = self.current_ui_x+dx
    local y = self.current_ui_y+dy
    
        local cy = self.current_ui_y
        local cx = self.current_ui_x
        
    local ui = self.ui_map
    
    if self.check_for_added_ui then
    local uui = reverseMap(ui)
    local u = {}
    local um, umx = lume.min(ui, nil, true), lume.max(ui, nil, true)
    local umm, ummx = lume.min(uui, nil, true), lume.max(uui, nil, true)
    for x = um, umx do
        if ui[x] then
            for y = umm, ummx do
                if ui[x][y] and ui[x][y].added and ui[x][y].visible then
                    u[x] = u[x] or {}
                    u[x][y] = ui[x][y]
                end
            end
        end
    end
    
    ui = u
    end
                    
  --  error(inspect(ui,2))--..
    log("cx,cy = "..cx..","..cy.."::"..x..","..y.."|"..dx..","..dy)
  --  error(inspect(ui[x],2))
    if not ui[x] or (not ui[x][y] and dy == 0) then--#lume.keys(ui[x])==1 then
        local cx = self.current_ui_x
        local changed
        local newy,newx
        local um, umx = lume.min(ui, nil, true), lume.max(ui, nil, true)
        log(ui[x] and ui[x][y] and "yoh" or "noh")
        log("nn")
        --!!?? Moving around skips 1,1
        --[[
        ---x
        -x--
        o--- (1,1)
        x--- (2,1)
        (o is skipped)
        ]]
        
        local uui = reverseMap(ui)
        for nxx = dx == 0 and 0 or 1, dx == 0 and 0 or math.abs(um-umx) do
            local kx
            if nxx == 0 then
                kx = cx
            elseif dx > 0 then
                kx = cx + nxx
                if kx > umx then
                    kx = ((cx+nxx)-umx-1)+um
                end
            elseif dx < 0 then
                kx = cx - nxx
                if kx < um then
                    kx = ((cx-nxx)-um+1)+umx
                end
            end
            local br
            if ui[kx] and kx ~=ckx then
                log("x "..kx..">>>>>"..cx..","..cy..", mx,maxx"..um..","..umx)
                local umm, ummx = lume.min(uui, nil, true), lume.max(uui, nil, true)
                for _i = 0,math.abs(umm-ummx) do--lume.min(uui[kx], true), lume.max(uui[kx], true) do
                    ---start from current x
                    local _
                    if _i == 0 then
                        _ = cy
                    elseif dy > 0 then
                        _ = cy + _i
                        if _ > ummx then
                            _ = ((cy+_i)-ummx-1)+umm
                        end
                    elseif dy <= 0 then
                        _ = cy - _i
                        if _ < umm then
                            _ = ((cy-_i)-umm+1)+ummx
                        end
                    end
            
                    if ui[kx][_] and ui[kx][_]~=self.current_ui and ui[kx][_].added then
                        
                       log("....."..kx..",".._.." y is doing, my,maxy"..umm..","..ummx)
                        --nx = ui[kx]
                        newx = kx
                        newy = _
                        
                        changed = true
                        if _ == y or true then
                            br = true
                            break
                        end
                    end
                end
            end
            if changed and br then
                break
            end
        end
        
        for _, xx in ipairs({} or ui) do
            if true then
                for __, yy in ipairs(xx) do
                    if yy~=self.current_ui then
                    if changed and yy == self.old_ui then break end
                    newy = __
                    newx = _
                    changed = true
                    if __ == y and _ == x or 5 then
                        break
                    end
                    end
                end
            end
        end
        
        if changed then
            y = newy
            x = newx
            log("===done "..x..","..y.."===")
            
        elseif lume.size(ui) == 1 then
            x = self.current_ui_x
            y = y + dx
            
        
        elseif x > lume.max(ui, nil, true) then
            x = lume.min(ui, nil, true)
        
        elseif x < lume.min(ui, nil, true) then
            x = lume.max(ui, nil, true)
        end
        
        if not ui[x] then x = self.current_x end
        if not ui[x] then return end
    end
    
    local nx = ui[x]
    if not nx[y] or not nx[y].added then
        local cy = self.current_ui_y
        local cx = self.current_ui_x
        local changed
        local newx, newy
        local uui = reverseMap(ui)
        local um, umx = lume.min(uui, nil, true), lume.max(uui, nil, true)
        for nxx = dy == 0 and 0 or 1, dy == 0 and 0 or math.abs(um-umx) do
            local kx
            if dy > 0 then
                kx = cy + nxx
                if kx > umx then
                    kx = ((cy+nxx)-umx-1)+um
                end
            elseif dy < 0 then
                kx = cy - nxx
                if kx < um then
                    kx = ((cy-nxx)-um+1)+umx
                end
            end
            local br
            if uui[kx] and kx~=cy then
                log("["..cy.."]".."doing kx "..kx.."at min "..um..", max "..umx)
                local umm, ummx = lume.min(ui, nil, true), lume.max(ui, nil, true)
                for _i = 0,math.abs(umm-ummx) do--lume.min(uui[kx], true), lume.max(uui[kx], true) do
                    ---start from current x
                    local _
                    if _i == 0 then
                        _ = cx
                    elseif dx >= 0 then
                        _ = cx + _i
                        if _ > ummx then
                            _ = ((cx+_i)-ummx-1)+umm
                        end
                    elseif dx < 0 then
                        _ = cx - _i
                        if _ < umm then
                            _ = ((cx-_i)-umm+1)+ummx
                        end
                    end
            
                    if uui[kx][_] and uui[kx][_]~=self.current_ui and uui[kx][_].added then log(".    kx at "..kx..",".._)
                        nx = ui[_]
                        newx = _
                        newy = kx
                        
                        changed = true
                        if _ == x or true then
                            br = true
                            break
                        end
                    end
                end
            end
            if changed and br then
                break
            end
        end
        
        for _, xx in ipairs({} or ui) do
            if xx[y] then
                nx = xx
                newx = _
                changed = true
                if _ == x or true then
                    break
                end
            end
        end
        
        if changed then
            x = newx
            y = newy
            log("===done===")
        
        
        elseif lume.size(nx) == 1 then
            y = self.current_ui_y
            x = x + dy
            local ox = nx
            nx = ui[x]
            if not nx or not nx.added then
                nx = ox
                x = x - dy
            end
        
        elseif y > lume.max(nx, nil, true) then
            y = lume.min(nx, nil, true)
            
        elseif y < lume.min(nx, nil, true) then
            y = lume.max(nx, nil, true)
        end
    end
    
    if nx[y] then
        local old_ui = self.current_ui
        self.old_ui = old_ui
        if old_ui then
            old_ui.selected_ui = false
        end
        
        self.current_ui.selected_ui = true
        self.current_ui = nx[y]
        self.current_ui_x = x
        if not (self.current_ui.added) then warn(inspect(self.current_ui,1)) end
        if self.current_ui == self.removeCardButton then error(inspect(self.current_ui,2)) end
        self.current_ui_y = y
        self:on_switch_ui(self.current_ui, old_ui)
    end
end

function Room:play_sound(sound,pitch,vol)

    if type(sound) == "table" then
        if type(sound[2]) == "string" then
            sound = getValue(sound)
        else
            vol = getValue(sound.volume or sound.vol or sound[3])
            pitch = getValue(sound.pitch or sound[2])
            sound = getValue(sound.sound or sound.source or sound[1])
        end
    end
    
    pitch = ppo or self.pitch or pitch
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
        s:setPitch(pitch)
    end
    
    self.sound = sound
    self._sound = s
    local vgg = vol or game.get_volume and game:get_volume(sound) or 1
    if type(self.get_volume) == "function" then
        vgg = vol or self:get_volume()
    end
    s:setVolume(vgg)
    s:play()
    self.last_played_sound = s
    
    return s
end
    
local log= tostring
-- Room:update
-- Update instances accordingly its update method
function Room:__step(dt)

  if self.reportPerformance then
      ProFi:start()
  end
  
  if self.pre_update then
    self:pre_update(dt)
  end
  
  log("freeze?")
  if type(self.freeze) == "number" and self.freeze > 0 then
    self.freeze = self.freeze - dt
    return
  elseif self.freeze == true then
    
    if self.gooi_activated and self.alwaysUpdateGooi then
      gooi.update(dt)
    end
    
    return
  else
    self.freeze = nil
  end
  
  self._lastMovedUI = self._lastMovedUI - dt
  
  if self.slow_dt then
    dt = dt/self.slow_dt
  end
  
  if not self.pause_animation then
      animx.update(dt)
  end
  
  log("up step")
  self.total_steps = self.total_steps + 1
  
  self:__update_controllers(dt) log("con done")
  self:__update_viewport(dt) log("cam done")
  self:__update_instances(dt) log("ins done")
  
  self.timer:update(dt) log("timer done")

  self:__update_squashing()
  
  if type(self.step) == 'function' then
    self:step(dt)
  end
  
  if type(self.update) == 'function' then
    self:update(dt)
  end
  
  log("others")
  if self.gooi_activated then
    gooi.update(dt)
  end
  log("update steo done")
  
  
  if self.reportPerformance then
      ProFi:stop()
      ProFi:writeReport(string.format("step_report_on_Room_%s.txt", self.class.name))
      error("Report on updating written.")
  end
  
end
-- Room:draw
-- Update instances accordingly its draw method
function Room:__draw(dt)
  -- Room drawing
  
  if self.reportDrawPerformance then
      ProFi:start()
  end
  
  local shader
  if self.shader then
    shader = love.graphics.getShader() or true
    love.graphics.setShader(self.shader)
  end
  
  if self.background_color then
    love.graphics.setBackgroundColor(getColor(self.background_color))
  end
  
  
  if self.draw_before_gooi then
    self:draw_before_gooi(dt)
  end
 
  if self.gooi_activated and self.draw_gooi then
    if self.draw_gooi_with_camera then
      self.camera:attach()
    end
    
    gooi.draw(gooi.currentGroup)
    
    if self.draw_gooi_with_camera then
      self.camera:detach()
    end
  end
  
    if type(self.draw_before) == 'function' then
      self:draw_before(dt)
    end
    
  if self.viewport then
    self.viewport:attach()

    -- Draw inside viewport
    self:__draw_instances()

    if type(self.draw) == 'function' then
      self:draw(dt)
    end

    self.viewport:detach()

    -- Added for library features support
    self.viewport:draw()
    
    if self.gooi_after_draw then
        gooi.draw(gooi.currentGroup)
    end
    
  else
    -- Fallback
    self:__draw_instances()

    if type(self.draw) == 'function' then
      self:draw(dt)
    end
  end
  
  
  self:__draw_controllers()
  
  if type(self.draw_after) == 'function' then
    self:draw_after(dt)
  end
    
  if type(self.after_draw) == 'function' then
    self:after_draw(dt)
  end
    
    
  if self.gooi_activated and gooi.showingDialog then
    gooi.draw(nil, true)
  end
    
  if type(self.post_draw) == 'function' then
    self:post_draw(dt)
  end
  
  if self.cover_alpha or self.cover_alpha > 0 then
    local r,g,b,a = set_color(0,0,0,self.cover_alpha)
    draw_rect("fill", -W(), -H(), W()*4, H()*4)
    set_color(r,g,b,a)
  end
  
  if shader then
    love.graphics.setShader(shader~=true and shader or nil)
  end
  
  if self.reportDrawPerformance then
      ProFi:stop()
      ProFi:writeReport(string.format("draw_report_on_Room_%s.txt", self.class.name))
      error("Report on drawing written.")
  end
end

function Room:activate_gooi(noDraw)
  self.gooi_activated = true
  self.draw_gooi = not noDraw
end

function Room:deactivate_gooi()
  self.gooi_activated = false
end

-- Room:init
-- Start executing the room instances
function Room:init()
  if (not self.noRefresh) or not self._created then
   -- self:kill() -- Reset room
    self:set_viewport('default') -- Set default viewport
    self:__create_instances() -- create instances
    self._created = true
    if self.oninit then
      self:oninit()
    end
  end
end

function Room:tweenCoverAlpha(time, val, func, after)
    return self:tween(time, self, {cover_alpha = val}, func, after)
end

-- Room:kill
-- Reset room data
function Room:kill()
  self:__reset_viewport()
  self:__destroy_instances()
  
  self.controllers = {}
  
  local trash = self.onkill and self:onkill()
end

function Room:add_controller(c)
  c.id = lume.uuid()
  self.controllers[c.id] = c
end

function Room:remove_controller(c)
  self.controllers[c.id] = nil
end

function Room:tween(...)
  return self.timer:tween(...)
end

function Room:every(...)
  return self.timer:every(...)
end

function Room:after(...)
  return self.timer:after(...)
end

function Room:set_physics_scale(scale)
  self.physics_scale = scale
end

function Room:get_gravity()
    return self.gravity
end

function Room:get_height()
  return math.max(self.height, love.graphics.getHeight())
end

function Room:get_width()
  return math.max(self.width, love.graphics.getWidth())
end

-- Room:add_viewport
-- Add a viewport to the room viewport list
function Room:add_viewport(name, options)
  if not self.viewports[name] then
    self.viewports[name] = Camera(unpack(options))
  else
    print('[Room:add_viewport] Viewport already added: ', name)
  end
end

-- Room:__reset_viewport
-- Set viewport to its initial state
function Room:__reset_viewport()
  self.viewport = false
end

-- Room:set_viewport
-- set current app viewport
function Room:set_viewport(name)
  local viewport = self.viewports[name]

  if viewport then
    self.viewport = viewport
    self.camera   = viewport
    print('[Room:add_viewport] Viewport set: ' .. name)
  else
    self:__reset_viewport()
    print('[Room:add_viewport] Viewport not found: ' .. name)
  end
end

-- Room:getViewport
-- Exposes viewport
function Room:getViewport()
  return self.viewport
end

-- Room:getViewport
-- Exposes viewport
function Room:get_viewport()
  return self.viewport
end

-- Room:__update_viewport
-- Execute update method safely
function Room:__update_viewport()
  local dt = love.timer.getDelta()

  if self.viewport then
    self.viewport:update(dt)

    if self.viewport_target then
        -- Viewport target
      local xTarget = self.viewport_target.x
      local yTarget = self.viewport_target.y

      local roomWidth = self:get_width()
      local roomHeight = self:get_height()

      local halfScreenWidth = love.graphics.getWidth() / 2
      local halfScreenHeight = love.graphics.getHeight() / 2

      if xTarget < halfScreenWidth then
        xTarget = halfScreenWidth
      end

      if yTarget < halfScreenHeight then
        yTarget = halfScreenHeight
      end

      if xTarget > roomWidth - halfScreenWidth then
        xTarget = roomWidth - halfScreenWidth
      end

      if yTarget > roomHeight - halfScreenHeight then
        yTarget = roomHeight - halfScreenHeight
      end

      xTarget = math.round(xTarget)
      yTarget = math.round(yTarget)
        -- Viewport target
      local xTarget = self.viewport_target.x
      local yTarget = self.viewport_target.y

      self.viewport:follow(xTarget, yTarget)
      if self.cameraman then
        local vw = self.viewport
        local cm = self.cameraman
        vw.scale = cm.scale or vw.scale
        vw.angle = cm.angle or vw.angle
      end
    end
  end
end

-- Room:place_object
-- Place objects in room for giving coordinates
function Room:place_object(ObjDefinition, x, y)
  if ObjDefinition and ObjDefinition:isSubclassOf(Object) then
    table.insert(self.objects, { ObjDefinition, x, y, lume.uuid() })
  else
    print('Object is not instance of Object')
  end
end

-- Room:place_instance
-- Place already made instances
function Room:place_instance(instance, x, y)
  if x then
    instance:move_to(x,y)
    instance.x, instance.y = x,y
    
  end
  
  
  instance.room = self
  
  self:store_instance(instance)
end

-- Room:set_viewport_target
-- Set instance to be followed by viewport
function Room:set_viewport_target(instance)
  self.viewport_target = instance
end

-- Room:set_target
-- Set instance to be followed by viewport
function Room:set_target(instance)
  self.viewport_target = instance
end

function Room:set_cameraman(cameraman)
    self.cameraman = cameraman or {x=W()/2, y=H()/2, scale=1, angle=0}
    self:set_viewport_target(self.cameraman)
    
    self.cm = self.cameraman
    
    return self.cameraman
end

-- Room:create_instanceFromObject
-- Create single instance from object item from objects array
function Room:create_instance(ObjDefinition, x, y, id)
  if ObjDefinition and ObjDefinition:isSubclassOf(Object) then
    local ninstances = table.getn(self.instances)
    local id = id or lume.uuid()-- ninstances + 1000
    log("created")

    local instance = ObjDefinition:new({
      id = id,
      x = x,
      y = y,
      _created = true,
      room = self
    })
    
    
    instance._created = true

    self:store_instance(instance)
  end
end

function Room:store_instance(instance)
  instance.id = instance.id or lume.uuid()
  instance.destroyed = false
  instance.room = self
  self.instances[instance.id] = instance
  
  if instance.sprite and instance.sprite.animation.destroyed then
    return error("Sprite of instance "..instance.name.." is destroyed when storing the instance.\nThis could mean that instance was COMPLETELY destroyed instead of removed (e.g. the instance is 'dead' in the program but still trying to be accessed/used again). Set instance.fake_destroy = true to not permanently destroy, or give instance a new sprite.")
  end
end

function Room:has_instance(instance)
    instance.id = instance.id or lume.uuid()
    return self.instances[instance.id]
end

function Room:squash(obj, w, h, time, func, after, centered, center_only_y)
    local time = time or 1
    local timer = obj.timer or self.timer
    
    if type(after) == "table" then
        local n = after
        local w = type(n[1]) == "number" and n[1] or type(n[2]) == "number" and n[2] or n.w or 1
        local h = type(n[2]) == "number" and n[2] or type(n[3]) == "number" and n[3] or n.t or w
        local t = type(n[1]) == "string" and n[1] or type(n[2]) == "string" and n[2] or
            type(n[3]) == "string" and n[3] or n.func or n.f or "in-bounce"
        after = function()
            self[(center_only_y and "squash_centered_y" or centered and "squash_centered" or "squash")](self, obj, w, w, h, t)
        end
    end
    
    obj._sqow = obj._sqow or obj.w
    obj._sqoh = obj._sqoh or obj.h
    obj.squashing = (w+h)/2--obj.squashing or 0
    obj.doneSquash = (obj.doneSquash or 0)+1
    if obj.__sqtt then
        obj.__sqttTimer:cancel(obj.__sqtt)
    end
    
    local ow, oh = obj._sqow, obj._sqoh
    obj.__sqtt = timer:tween(time, obj, {
        w = ow*w,
        h = oh*h,
        doneSquash = obj.doneSquash-1,
        --squashing = (w+h)/2
    }, func or "out-quad", after)--,function()
    
    obj.__sqttTimer = timer
    
end

function Room:squashW(obj, w, time, func, after, tt,f2)
    if type(func)  == "number" then
        local ww = func
        tt = after
        f2 = tt
    end
    if type(after) == "number" then
        
        after = function()
            self:squashW(obj, 1/w, tt or after or time,f2)
        end
    end
    
    return self:squash(obj, w, 1/w, time, func, after)
end

function Room:squash_centered(obj, w, h, time, func, after)
    obj._sqox = obj._sqox or obj.x
    obj._sqoy = obj._sqoy or obj.y
    
    self:squash(obj, w, h, time, func, after, true)
    
    self._squashing[obj] = true
end

function Room:squash_centered_y(obj, w, h, time, func, after)
    --obj._sqox = obj._sqox or obj.x
    obj._sqoy = obj._sqoy or obj.y
    
    self:squash(obj, w, h, time, func, after, true, true)
    
    self._squashing[obj] = true
end

function Room:squash_ui(ui,w,h,t,f)
    local obj, centered = ui, true
    
    if ui.object then
        obj = ui.object
        centered = false
    end
    
    obj.doneSquash = obj.doneSquash or 0
    
    if ( obj.doneSquash ) <= .1 then
        self:squash_centered(obj, w or .5, h or 1.2, t or .3, f, {1,1})
    end
end

function Room:tween_in_ui(ui, time, func, after)
    if not (ui.ogx or ui.ogy) then
        return
    end
    
    if self._tweening[ui] then
        self.timer:cancel(self._tweening[ui])
    end
    
    ui.tweening = 1
    self._tweening[ui] = self:tween(
        time or 1,
        ui,
        {x=ui.ogx or ui.x, y=ui.ogy or ui.y, tweening=-.01},
        func or "in-bounce",
        after
    )
end

function Room:tween_out_ui(ui, time, func, after)
    if not (ui.outx or ui.outy) then
        return
    end
    
    if self._tweening[ui] then
        self.timer:cancel(self._tweening[ui])
    end
    
    ui.ogx = ui.ogx or ui.x
    ui.ogy = ui.ogy or ui.y
    ui.tweening = 1
    self._tweening[ui] = self:tween(
        time or 1,
        ui,
        {x=ui.outx or ui.x, y=ui.outy or ui.y, tweening=-.01},
        func or "out-quad",
        after
    )
end

function Room:__update_squashing(dt)
    for obj, _ in pairs(self._squashing) do
        if obj._sqox then
            obj.x = obj._sqox-(obj.w-obj._sqow)/2
        end
        
        obj.y = obj._sqoy-(obj.h-obj._sqoh)/2
        
        if obj.doneSquash <= 0 then
            self._squashing[obj] = nil
        end
    end
end

-- Room:__create_instances
-- Loop though all objects and instantiate them
function Room:__create_instances()
  for index, object in ipairs(self.objects) do
    self:create_instance(unpack(object))
  end

  print('[Room:createIntances] Creating instances for: ' .. Room.name)
end

-- Room:destroy instances
-- Reset instances table
function Room:__destroy_instances(all)
  for index in pairs(self.instances) do
    local item = self.instances[index]
    
    if item and (item._created or all) then
      self.world:remove(item)
      self.instances[item.id] = nil
    end
  end
end

function Room:destroy_instance(instance)
  self.instances[instance.id] = nil
  if self.world:hasItem(instance) then
    self.world:remove(instance)
  end
end

function Room:destroy_all_instances()
  return self:__destroy_instances(true)
end

function Room:must_update(obj, remove)
    self._must_update[tostring(obj)] = (not remove and obj) or nil
end

function Room:must_draw(obj, remove)
    self._must_draw[tostring(obj)] = (not remove and obj) or nil
end

-- Depth sorting method
function Room.depth_sorter(a, b)
  if not a.depth then error(inspect(a,1)) end
  if not b.depth then error(inspect(b,1)) end
  
  if b.depth == a.depth then
      b.time_alive = b.time_alive or 1
      a.time_alive = a.time_alive or 0
      return b.time_alive > a.time_alive
  end
  
  return b.depth > a.depth
end

-- Room:__draw_instances
-- loop though instances and draw them
function Room:__draw_instances()
  if mm1 then
  
    for x, i in ipairs(self.allTiles) do
      local xx, yy = self.camera:toCameraCoords(i.x,i.y)
      if xx<W() and yy<(H()) and yy>0 and xx>0 then--lume.distance(i.x,i.y,self.player.x,self.player.y)<W()/2 then
        self:draw_instance(i)
      end
    end
  
    for x, i in pairs(self.instances) do
      local xx, yy = self.camera:toCameraCoords(i.x,i.y)
      if xx<W() and yy<(H()) and yy>0 and xx>0 then
        self:draw_instance(i)
        assert(not i.isTile)
      end
    end
    return
  end
  
  local obj
  local x, y, w, h = self:get_viewport():getVisible()--Window()
  
  local visibleThings, len = self.world:queryRect(x,y,w,h)
    
  for x, i in pairs(self._must_draw) do
      visibleThings[len+1] = i
      len = len+1
  end
  
  if 1 then table.sort(visibleThings, self.depth_sorter) end
  
  if WEIGHT then
      -- useless drawing to hinder performance
      mm=0
      for i,m in pairs(self.instances) do
          mm=mm+1
      
         end
      --assert(len>0, mm.."?")
  end
  
  for i = 1, len do
    obj = visibleThings[i]
    local cam
    if obj.no_camera and self:get_viewport().attached then
        self:get_viewport():detach()
        cam = true
    end
    self:draw_instance(obj)
    if cam then
        self:get_viewport():attach()
    end
  end
end

function Room:draw_instance(obj)
    local sh
    if obj.shader then
        sh = love.graphics.getShader() or true
        love.graphics.setShader(obj.shader)
    end
    
    obj:__draw()
    
    if sh then
        love.graphics.setShader(sh~=true and sh or nil)
    end
end

-- Room:__update_instances
-- loop though instances and update them
function Room:__update_instances(dt)
  
  log("ins?")
  if self.classic then
    local obj
    local x, y, w, h = self:get_viewport():getVisible()--Window()
    
    --[[
    --x = math.floor(x) y = math.floor(y)
    if math.abs(x)>1.1e+13 then
      x = getDir(x)*99999
    end
    if math.abs(y)>1.1e+13 then
      y = getDir(y)*99999
    end]]
    
    local vw = (self.vw or w)*(self.multipleW or 1)
    local vh = (self.vh or h)*(self.multipleH or 1)
    local visibleThings, len = self.world:queryRect(x-(vw-w)/2,y-(vh-h)/2,
    vw,vh)

 
    --if 1 then table.sort(visibleThings, Room.depth_sorter) end
  
    for i = 1, len do
      obj = visibleThings[i]
      if not self._must_update[tostring(obj)] then
        self:__update_instance(obj, dt)
      end
    end
  
    for x, i in pairs(self._must_update) do
      self:__update_instance(i, dt)
    end
    
  else
  
    for index, instance in pairs(self.instances) do
      self:__update_instance(instance, dt)
    end
  end
end

function Room:__update_instance(instance,dt)
  instance:__step(dt)
end

function Room:__update_controllers(dt)
  for index, controller in pairs(self.controllers) do
    controller:__step(dt)
  end
end

function Room:__draw_controllers()
  for index, controller in pairs(self.controllers) do
    controller:__draw()
  end
end

function Room:__keypressed(key)
  if self.keypressed then
     self:keypressed(key)
  end

  if self.gooi_activated then
    gooi.keypressed(key)
  end
  
  for index, controller in pairs(self.controllers) do
    controller:__keypressed(key)
  end
end

function Room:__keyreleased(key)
  if self.keyreleased then
     self:keyreleased(key)
  end

  if self.gooi_activated then
    gooi.keyreleased(key)
  end
  
  for index, controller in pairs(self.controllers) do
    controller:__keyreleased(key)
  end
end

function Room:__textinput(text)
  if self.typed then return end
  --self.typed = true
  if self.gooi_activated then
    gooi.textinput(text)
  end
end

function Room:__mousepressed(x,y,button)
  if self.gooi_activated then
    gooi.pressed()
  end
  
  for index, controller in pairs(self.controllers) do
    controller:__mousepressed(x,y,button)
  end
  
  if self.mousepressed then
    return self:mousepressed(x,y,button)
  end
end

function Room:__mousereleased(x,y,button)
  if self.gooi_activated then
    gooi.released()
  end
  
  for index, controller in pairs(self.controllers) do
    controller:__mousereleased(dt)
  end
  
  if self.mousereleased then
    return self:mousereleased(x,y,button)
  end
end

function Room:__mousemoved(x,y)
  if self.gooi_activated then
    gooi.moved()
  end
  
  for index, controller in pairs(self.controllers) do
    controller:__mousemoved(x,y,button)
  end
  
  if self.mousemoved then
    return self:mousemoved(x,y,button)
  end
end

function Room:__touchpressed(id, x, y, dx, dy, pressure)
  for index, controller in pairs(self.controllers) do
    controller:touchpressed(id, x, y, dx, dy, pressure)
  end
  
  if self.touchpressed then
    return self:touchpressed(id,x,y,dx,dy,pressure)
  end
end

function Room:__touchreleased(id, x, y, dx, dy, pressure)
  for index, controller in pairs(self.controllers) do
    controller:touchreleased(id, x, y, dx, dy, pressure)
  end
  
  if self.touchreleased then
    return self:touchreleased(id,x,y,dx,dy,pressure)
  end
end

function Room:__touchmoved(id, x, y, dx, dy, pressure)
  for index, controller in pairs(self.controllers) do
    controller:touchmoved(id, x, y, dx, dy, pressure)
  end
  
  if self.touchmoved then
    return self:touchmoved(id,x,y,dx,dy,pressure)
  end
end

return Room