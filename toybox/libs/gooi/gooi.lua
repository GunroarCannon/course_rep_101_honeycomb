gooi = {}
gooi.__index = gooi
gooi.components = {}
gooi.dialogFOK = function() end
gooi.showingDialog = false
gooi.desktop = false
gooi.vibration = false
gooi.delayVibration = 0
gooi.dialogMsg = ""
gooi.dialogH = 0
gooi.dialogW = 0
gooi.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
gooi.sx = 1
gooi.sy = 1
gooi.defaultFont = love.graphics.newFont(love.window.toPixels(13))
gooi.font = defaultFont
gooi.unit = 25
gooi.bs = "backspace"
gooi.del = "delete"
gooi.r = "right"
gooi.l = "left"
gooi.lineStyle = "smooth"
gooi.delayKey = 0.05
gooi.delayCursorBlink = 0.4
gooi.delayCanRepeat = 0.45
gooi.class = "gooi"


function gooi.desktopMode()
  gooi.desktop = true
end

function gooi.roughShapes()
  gooi.lineStyle = "rough"
end

function gooi.vibrate(s)
  gooi.vibration = true
  gooi.delayVibration = s or 0.035
end

gooi.smallerSide = function()
  local smallerSide = love.graphics.getWidth()

  if love.graphics.getHeight() < smallerSide then
    smallerSide = love.graphics.getHeight()
  end
  return smallerSide
end

circleRes = 30 -- for rounded shapes

--*********************************************
--*********************************************
--      Special dialog widgets:
--*********************************************
--*********************************************

--function gooi.alert(msg, fOK)
function gooi.alert(params)
  return gooi.dialog(params, "alert")
end

--function gooi.alert(msg)
function gooi.palert(params)
  gooi.dialog(params, "alert", true)
end

--function gooi.confirm(msg, fYes, fNo)
function gooi.confirm(params)
  return gooi.dialog(params, "confirm")
end

--function gooi.dialog(msg, fPositive, fNegative, kind, group)
function gooi.dialog(params, kind)
  if not (gooi.showingDialog or gooi.panelDialog) then
    gooi.showingDialog = true
    local positiveBtnTxt = "OK"
    local negativeBtnTxt = "Cancel"

    gooi.dialogMsg = params.text or "message"
    fPositive = params.ok
    gooi.fPositive = fPositive
    fNegative = params.cancel
    gooi.fNegative = fNegative
    fMaybe    = params.maybe
    
    local group = params.group
    
    positiveBtnTxt = params.okText or positiveBtnTxt
    negativeBtnTxt = params.cancelText or negativeBtnTxt
    maybeTxt = params.maybeText or "Maybe?"

    local w, h = love.graphics.getWidth() / gooi.sx, love.graphics.getHeight() / gooi.sy

    local smaller = gooi.smallerSide()
    local divide = params.divide or 2
    if params.big then divide = 1 end

    gooi.dialogW = params.w or math.floor(smaller / divide)
    gooi.dialogH = params.h or math.floor(gooi.dialogW * (1.2/2))

    gooi.panelDialog = gooi.newPanel({
      x = math.floor(w / 2 - gooi.dialogW / 2 / gooi.sx),
      y = math.floor(h / 2 - gooi.dialogH / 2 / gooi.sy),
      w = math.floor(gooi.dialogW / gooi.sx),
      h = math.floor(gooi.dialogH / gooi.sy),
      group = group,
      layout = "grid 4x3",padding=params.padding}
    ):setOpaque(true)

    gooi.panelDialog.layout.padding = params.padding or 7-- Default = 3
    gooi.panelDialog.layout:init(gooi.panelDialog)

    gooi.panelDialog:setColspan(1, 1, 3)-- For the msg:
    gooi.panelDialog:setRowspan(1, 1, 3)

    gooi.lblDialog = gooi.newLabel({text = gooi.dialogMsg, instant = params.instant, textDelay = params.pause or params.textDelay}):center()
      :setOpaque(false)
    gooi.lblDialog.lblFlag = true
    gooi.lblDialog.font = gooi.dialogFont or gooi.lblDialog.font
    gooi.panelDialog:add(gooi.lblDialog, "1,1")

    if kind == "alert" then
      gooi.okButton  = gooi.newButton({text = positiveBtnTxt,group = group,squash = params.squash}):onRelease(function()
        gooi.closeDialog()
        if fPositive then
          fPositive()
        end
      end)
      gooi.okButton.okFlag = true
      gooi.okButton.font = gooi.dialogFont or gooi.okButton.font
      gooi.panelDialog:add(gooi.okButton,  "4,2")
      if params.big then
        local okb = gooi.okButton
        okb.h = okb.h/2
      end
      gooi.radCorner = gooi.okButton.style.radius
    else
      gooi.noButton  = gooi.newButton({text = negativeBtnTxt, group = group, squash = params.squash}):onRelease(function()
        gooi.closeDialog()
        if fNegative then
          fNegative()
        end
      end)
      gooi.yesButton = gooi.newButton({text = positiveBtnTxt, group = group, squash = params.squash}):onRelease(function()
        gooi.closeDialog()
        if fPositive then
          fPositive()
        end
      end)
      gooi.noButton.noFlag   = true
      gooi.yesButton.yesFlag = true
      gooi.panelDialog:add(gooi.noButton,  "4,1")
      gooi.panelDialog:add(gooi.yesButton, "4,3")
      gooi.yesButton.font = gooi.dialogFont or gooi.yesButton.font
      gooi.noButton.font = gooi.dialogFont or gooi.noButton.font
      gooi.radCorner = gooi.noButton.style.radius
    end
    if params.maybe and gooi.noButton then
      gooi.maybeButton = gooi.newButton({text = maybeTxt, group = group, squash = params.squash}):onRelease(function()
        gooi.closeDialog()
        if fMaybe then
          fMaybe()
        end
      end)
      gooi.maybeButton.maybeFlag = true
      gooi.panelDialog:add(gooi.maybeButton, "4,2")
      gooi.maybeButton.font = gooi.dialogFont or gooi.maybeButton.font
    end
    gooi.panelDialog:getUIMap()
    gooi.removeComponent(gooi.panelDialog)
    gooi.addComponent(gooi.panelDialog)
    toybox.room:on_switch_ui(toybox.room.current_ui)
    gooi.panelDialog.isDialog = true
    
  local r = toybox.room
    
  if r or error() then
      local p = gooi.panelDialog
      for x = 1, #p.sons+1 do
          local f = p.sons[x] and p.sons[x].ref or p
          local oi, fi = f.bgColor, f.fgColor
          local oa = f.alpha
          f.alpha = 0
          r:tween(.5, f, {alpha=1}, "in-quad")
      end
  end
  
    return gooi.panelDialog
  end
  
  
end

function gooi.closeDialog()
  --print(#gooi.components)
  gooi.removeComponent(gooi.panelDialog)
  gooi.panelDialog = nil
  gooi.showingDialog = false
  gooi.dialogImportant = nil
  gooi.dialogIsTalkies = nil
  gooi.allowAction = nil
  gooi.okButton = nil
  gooi.yesButton = nil
  gooi.noButton = nil
end













--**************************************************************************
--**************************************************************************

-- gooi functions:

--**************************************************************************
--**************************************************************************


function gooi.storeComponent(c, id)
  if not c then return false end
  c.events = c.events or {}
  c.events.r = c.r or c.events.r
  c.enabled = true
  c.added = true
  table.insert(gooi.components, c)
  return c
end

function gooi.setCanvas(c)
  gooi.canvas = c
  gooi.sx = love.graphics.getWidth() / gooi.canvas:getWidth()
  gooi.sy = love.graphics.getHeight() / gooi.canvas:getHeight()
end

function gooi.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function gooi.removeComponent(comp, keepEnabled)
  local removed = false
  if not comp then
    return
  end
  if not comp.enabled then
    -- return
  end
  comp.enabled = keepEnabled or nil
  comp.added = false
  comp.events = comp.events or {}
  comp.events.r = comp.r or comp.events.r
  if comp.ui_map_data and toybox.room and comp.ui_map_data == toybox.room.ui_map_data then
    toybox.room:load_ui_map(comp.ui_map_data.old_ui_data,true)
  end
  
  if comp.bLabel then
    gooi.removeComponent(comp.bLabel)
  end
  
  for k, v in pairs(gooi.components) do
    local c = gooi.components[k]
    c._val = k
    if c == comp then 
      --print("id father: "..c.id)
      if c.sons then
        for k2, v2 in pairs(c.sons) do
          --print("text sons: "..(c.sons[k2].text or "(nil)"))
          gooi.removeComponent(c.sons[k2].ref, keepEnabled)
         -- c.sons[k2] = nil
        end
       -- c.sons = nil
      end
      v.enabled = keepEnabled or false
      gooi.components[k] = nil
      removed = true
      --return removed
    end
  end
  
  return removed
end

function gooi.addComponent(c)
    local comp = c
    
    if (comp.ui_map_data or comp.ui_map) and toybox.room then
      toybox.room:load_ui_map(comp.ui_map or comp.ui_map_data, not comp.ui_map)
      comp.ui_map_data = toybox.room.ui_map_data
    end
  
    gooi.storeComponent(c)
    
    if c.sons then
      for x,y in pairs(c.sons) do
        gooi.addComponent(y.ref)
      end
    end
    
    return c
end

function gooi.processStyle(style)
  if style.bgColor and type(style.bgColor) == "string" then
    style.bgColor = gooi.toRGBA(style.bgColor)
  end
  if style.fgColor and type(style.fgColor) == "string" then
    style.fgColor = gooi.toRGBA(style.fgColor)
  end
  if style.borderColor and type(style.borderColor) == "string" then
    style.borderColor = gooi.toRGBA(style.borderColor)
  end
  style.bgColor = style.bgColor or component.style.bgColor
  style.fgColor = style.fgColor or component.style.fgColor
  style.tooltipFont = style.tooltipFont or component.style.tooltipFont
  style.radius = style.radius or component.style.radius
  style.innerRadius = style.innerRadius or component.style.innerRadius
  style.showBorder = style.showBorder or false
  style.borderColor = style.borderColor or component.style.borderColor
  style.borderStyle = style.borderStyle or component.style.borderStyle
  style.borderWidth = style.borderWidth or component.style.borderWidth
  style.font = style.font or component.style.font

  return style
end

function gooi.deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[gooi.deepcopy(orig_key)] = gooi.deepcopy(orig_value)
    end
    setmetatable(copy, gooi.deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function gooi.setStyleComp(c)
  function c:setStyle(s)
    local style = gooi.processStyle(s)
    c.style = style

    if not (c.ongrid or c.ongame) then-- Ignore components in a grid layout:
      local s = c.style
      if c.type == "button" or c.type == "label" or c.type == "label" then
        c.w = s.font:getWidth(c.text) + s.font:getHeight() * 2
        c.h = s.font:getHeight() * 2
      end
      if c.type == "checkbox" or c.type == "radio" then
        c.w = s.font:getWidth(c.text) + s.font:getHeight() * 3
        c.h = s.font:getHeight() * 2
      end
      if c.type == "spinner" then
        c.w = s.font:getWidth(c.max) + s.font:getHeight() * 4
        c.h = s.font:getHeight() * 2
      end
      if c.type == "text" then
        c.w = s.font:getWidth(c.text) + s.font:getHeight() * 1.5
        c.h = s.font:getHeight() * 2
      end
    end

    if c.sons then
      for i = 1, #c.sons do
        if not c.sons[i].ref.setStyle then--??
          gooi.setStyleComp(c.sons[i].ref)
        end
        c.sons[i].ref:setStyle(style)
        
      end
    end

    return c
  end

  return c
end

function gooi.setStyle(style)
  local s = gooi.processStyle(style)
  component.style = s
  gooi.font = s.font
end

-- Update what needs to be updated:
local timerBackspaceText = 0
local timerStepChar = 0
function gooi.update(dt)

  for k, c in pairs(gooi.components) do
    c:checkShake(dt)
    
    if c.texty then
      c.texty:update(dt)
    end
    
    if c.type == "progressbar" and c.visible then
      if c.changing and c.enabled then
        c.value = c.value + c.speed * c.changing * dt
        if c.value > 1 then c.value = 1 end
        if c.value < 0 then c.value = 0 end
      end
    end
    if c.type == "text" and c.hasFocus then
      local key = c.keyToRepeat
      c:updateCursor(key, dt)
    end
    if c.enabled and c.visible and (c.pressed or c.touch) then
      if c.type == "slider" then
        local t = c.touch
        if t then
          c:updateGUI()
        else
          c:updateGUI()
        end
      elseif c.type == "joystick" then
        c:move()
      elseif c.type == "spinner" then
        c:update(dt)
      elseif c.type == "knob" then
        c:turn()
      end
    end
  end
end

function gooi.mode3d()
  component.mode3d = true
  component.shadow = false
  component.glass = false
end

function gooi.glass()
  component.mode3d = false
  component.glass = true
  component.shadow = false
end

function gooi.shadow()
  component.mode3d = false
  component.glass = false
  component.shadow = true
end

local function fakeSetColor(r, g, b, a)
  if type(r) == "table" then
    gooi.setColor(r[1], r[2], r[3], gooi.alpha)
  else
    gooi.setColor(r, g, b, gooi.alpha)
  end
end

-- Draw the stuff:
function gooi.draw(group, onlyDialog, alpha)

  local r,g,b,a
  
  local oldAlpha = gooi.alpha
  if alpha then
     gooi.alpha = alpha
  end
  
  if gooi.alpha then
    gooi.setColor = gooi.setColor or love.graphics.setColor
    love.graphics.setColor = fakeSetColor
    r,g,b,a = love.graphics.getColor()
    fakeSetColor(r,g,b)
  end
  
  NO_DOUBLE_TEXT = true
  --love.graphics.origin() --to take in account scale,translate,rotate
  local actualGroup = group or "default"

  local prevFont  = love.graphics.getFont()
  local prevLineW = love.graphics.getLineWidth()
  local prevLineS = love.graphics.getLineStyle()
  local prevR, prevG, prevB, prevA = love.graphics.getColor()

  local noButton, okButton, yesButton, maybeButton, msgLbl = nil, nil, nil, nil

  local compWithTooltip = nil -- Just for desktop.

  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle(gooi.lineStyle)

  gooi.backButton = nil
  
  local os = love.system.getOS()
  
  if onlyDialog then
    --goto dialog
  end
  
  for k, comp in pairs(gooi.components) do
  
    if (comp.text == "Back" or comp.text == "Back") and comp.events and comp.events.r then
      gooi.backButton = comp
    end

    if comp.noFlag then
      noButton = comp
    end
    
    if comp.maybeFlag then
      maybeButton = comp
    end
    
    if comp.okFlag then
      okButton = comp
    end

    if comp.yesFlag then
      yesButton = comp
    end

    if comp.lblFlag then
      msgLbl = comp
    end

    if not comp.noFlag and not comp.okFlag and not comp.yesFlag
    and not comp.lblFlag and not comp.maybeFlag and not onlyDialog then
      if actualGroup == comp.group and comp.visible then
          gooi.drawComponent(comp, nil, true, true)
      end

      if comp.showTooltip then
        compWithTooltip = comp
      end 

    end
  end

  -- Check if a tooltip was generated (just for desktop):
  
  if compWithTooltip and os ~= "Android" and os ~= "iOS" and gooi.desktop then
    local ttf = compWithTooltip.style.tooltipFont
    local httf = ttf:getHeight()
    local text = compWithTooltip.tooltip
    local xTT = math.floor(love.mouse.getX() / gooi.sx)

    if ((love.mouse.getX() / gooi.sx) + ttf:getWidth(text)) >= gooi.canvas:getWidth() then
      xTT = xTT - ttf:getWidth(text)
    end

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill",
      xTT - httf,
      math.floor((love.mouse.getY() / gooi.sy) - httf * 1.5),
      ttf:getWidth(text) + httf * 2,
      httf * 2)

    love.graphics.setColor(component.style.fgColor)
    love.graphics.setFont(ttf)
    love.graphics.print(text,
      xTT,
      math.floor((love.mouse.getY() / gooi.sy) - httf))
  end
  ::dialog::

  if gooi.showingDialog and msgLbl then
    love.graphics.setFont(gooi.getFont(msgLbl))-- Specific or a common font.
    local w, h = gooi.canvas:getWidth(), gooi.canvas:getHeight()

    --[[love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0-100, 0-100,
      W()+200,--love.graphics.getWidth(),
      H()+200)--ove.graphics.getHeight())

    love.graphics.setColor(getColor(component.style.bgColor, component.alpha))
    love.graphics.rectangle("fill",
      gooi.panelDialog.x,
      gooi.panelDialog.y,
      gooi.panelDialog.w,
      gooi.panelDialog.h,
      gooi.radCorner,
      gooi.radCorner
    )

    if component.style.showBorder then
      love.graphics.setColor(getColor(component.style.borderColor, component.alpha))
      love.graphics.rectangle("line",
        gooi.panelDialog.x,
        gooi.panelDialog.y,
        gooi.panelDialog.w,
        gooi.panelDialog.h,
        gooi.radCorner,
        gooi.radCorner
      )
      love.graphics.setColor(getColor(component.style.bgColor, component.alpha))
    end

    msgLbl:draw()
    msgLbl:drawSpecifics(msgLbl.style.fgColor)]]
    
    gooi.drawComponent(gooi.panelDialog)--.opaque = 
    gooi.drawComponent(msgLbl)
    
    love.graphics.setFont(gooi.getFont(self))
    local gfont = love.graphics.getFont()
    
    if okButton then
      love.graphics.setFont(okButton.font or gfont)
      -- okButton:draw()
      -- okButton:drawSpecifics(okButton.style.fgColor)
      gooi.drawComponent(okButton)
    elseif noButton then
      love.graphics.setFont(noButton.font or gfont)
      -- noButton:draw()
      -- noButton:drawSpecifics(noButton.style.fgColor)

      -- yesButton:draw()
      -- yesButton:drawSpecifics(yesButton.style.fgColor)
      
      gooi.drawComponent(noButton)
      gooi.drawComponent(yesButton)
      
      if maybeButton then
          love.graphics.setFont(maybeButton.font or gfont)
          -- maybeButton:draw()
          -- maybeButton:drawSpecifics(maybeButton.style.fgColor)
          gooi.drawComponent(maybeButton)
      end
    else
      -- gooi.panelDialog:draw()
      -- gooi.panelDialog:drawSpecifics(gooi.panelDialog.style.fgColor)
      gooi.drawComponent(gooi.panelDialog)
    end

  end

  love.graphics.setFont(prevFont)
  love.graphics.setLineWidth(prevLineW)
  love.graphics.setLineStyle(prevLineS)
  love.graphics.setColor(prevR, prevG, prevB, prevA)
  
  NO_DOUBLE_TEXT = false
  
  if gooi.alpha then
    love.graphics.setColor = gooi.setColor
    love.graphics.setColor(prevR, prevG, prevB, a)
  end
  
  gooi.alpha = oldAlpha
end


gooi_transform = love.math.newTransform()
local gtran = gooi_transform
    
    
function gooi.drawComponent(comp, drawChildren, noReset, checkedAlpha)

    local r,g,b,a
    
    if comp.preDraw then
        comp:preDraw()
    end
    
    local oldAlpha = gooi.alpha
    if comp.alpha then
        gooi.alpha = comp.alpha
    end
  
    if gooi.alpha and not checkedAlpha then
      gooi.setColor = gooi.setColor or love.graphics.setColor
      love.graphics.setColor = fakeSetColor
      r,g,b,a = love.graphics.getColor()
      fakeSetColor(r,g,b)
    end

    NO_DOUBLE_TEXT = true
    
    local prevFont  = love.graphics.getFont()
    local prevLineW = love.graphics.getLineWidth()
    local prevLineS = love.graphics.getLineStyle()
    local prevR, prevG, prevB, prevA = love.graphics.getColor()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle(gooi.lineStyle)
  
    if true then
        comp.x = comp.x + comp.shake_x
        comp.y = comp.y + comp.shake_y
        
        
        local self = comp
        gtran:reset()
        lg.push()
        local rx = self.w/6
        local ry = self.h/6
        
        local tr = self.transformParent or self
        local rrx,rry = (tr.x+tr.w/2), (tr.y+tr.h/2)
        Graphics.translate(rrx,rry)
        Graphics.rotate(math.rad(tr.angle or 0))
        love.graphics.applyTransform(gtran)
        Graphics.translate(-rrx, -rry)
    
        comp:draw()-- Draw the base.

        love.graphics.setFont(gooi.getFont(comp))-- Specific or a common font.

        local fg = comp.fgColor or comp.style.fgColor
        if not comp.enabled then
          fg = {0.12, 0.12, 0.12}
        end

        ------------------------------------------------------------
        ------------------------------------------------------------
        ------------------------------------------------------------


        comp:drawSpecifics(fg)
        comp:drawShadowPressed()
        
        if drawChildren then
            for x, son in ipairs(comp.sons or {}) do
                gooi.drawComponent(son.ref, drawChildren, noReset)
            end
        end
        
          
        if comp.postDraw then
            comp:postDraw()
        end


        ------------------------------------------------------------
        ------------------------------------------------------------
        ------------------------------------------------------------
        
        if not noReset then
            love.graphics.setFont(prevFont)
            love.graphics.setLineWidth(prevLineW)
            love.graphics.setLineStyle(prevLineS)
            love.graphics.setColor(prevR, prevG, prevB, prevA)
        end
        
        comp.x = comp.x - comp.shake_x
        comp.y = comp.y - comp.shake_y
        lg.pop()
        
        
        if comp.postPostDraw then
            comp:postPostDraw()
        end
    end
    
    NO_DOUBLE_TEXT = false
    
    
  if gooi.alpha and not checkedAlpha then
    love.graphics.setColor = gooi.setColor
    love.graphics.setColor(prevR, prevG, prevB, a)
  end
  
  gooi.alpha = oldAlpha
end

function gooi.drawInnerShape(c, mode, mC, side)
  love.graphics.rectangle(mode,
    (c.x + mC),
    (c.y + mC),
    (side),
    (side),
    c.style.innerRadius,
    c.style.innerRadius,
    circleRes
  )
end

function gooi.toRGBA(hex)
  hex = hex:gsub("#","")
  color = {tonumber("0x"..hex:sub(1,2)),
       tonumber("0x"..hex:sub(3,4)),
       tonumber("0x"..hex:sub(5,6))}
  if string.len(hex) >= 8 then
    table.insert(color, tonumber("0x"..hex:sub(7, 8)))
  end
  return color
end

function gooi.getByType(theType)
  g = {}-- Group.
  for k, c in pairs(gooi.components) do
    if c.type == theType then
      table.insert(g, c)
    end
  end
  return g
end

-- Get any component by its id:
function gooi.get(id)
  if not gooi.components[id] then
    error("Component '"..id.."' does not exist!")
  end
  return gooi.components[id]
end

function gooi.setGroupVisible(group, b)
  for k, c in pairs(gooi.components) do
    if c.group == group then
      c:setVisible(b)
    end
  end
end

function gooi.setGroupEnabled(group, b)
  for k, c in pairs(gooi.components) do
    if c.group == group then
      c:setEnabled(b)
    end
  end
end

function gooi.getByGroup(group)
  g = {}-- Group.
  for k, c in pairs(gooi.components) do
    if c.group == group then
      table.insert(g, c)
    end
  end
  return g
end

function gooi.getByGroupAndType(group, theType)
  g = {}-- Group.
  for k, c in pairs(gooi.components) do
    if c.group == group and c.type == theType then
      table.insert(g, c)
    end
  end
  return g
end

function gooi.deselectOtherRadios(group, id)
  local radios = gooi.getByType("radio")-- Type.
  for i=1, #radios do
    if  radios[i].radioGroup == group then
      radios[i].selected = false
    end
  end
end

---------------------------------------------------------------------------------------------
function gooi.pressed(id, xt, yt)
  local x = xt or love.mouse.getX()
  local y = yt or love.mouse.getY()
  x = x / gooi.sx
  y = y / gooi.sy
  
  local camera = gooi.use_camera or gooi.camera
  if camera then
    x, y = camera:toWorldCoords(x, y)
    -- game.timer:after(.1, function() gooi.newButton({x=x, y=y,w=10,h=10,text=""}) end)
  end
  
  gooi.focused = nil
  
  if game then
    game.buttonPressed = nil
  end
  
  if toybox and toybox.room then
    toybox.room.buttonPressed = nil
  end
  
  local pressed
  for k, c in pairs(gooi.components) do
    if gooi.currentGroup and c.group ~= gooi.currentGroup then
    assert(not c.maybeFlag)
        --goto skip
    end
    c:setTooltip(nil, true)-- remove tooltips when something is clicked
    if c.enabled and (c.visible or c.alwaysPress) then
      if c.type == "joystick" then
        if c:overIt(x, y) then
          gooi.focused = c
          if c.anyP then
            c.stickPressed = true
            c.dx = 0
            c.dy = 0
          elseif c:overStick(x, y) then
            c.stickPressed = true
            c.dx = c.xStick - x
            c.dy = c.yStick - y
          end
        end
      elseif c.type == "spinner" then
        if c:overMinus(x, y) then
          c:changeValue(-1)
          c.minPressed = true
          c.plusPressed = false
        elseif c:overPlus(x, y) then
          c:changeValue(1)
          c.minPressed = false
          c.plusPressed = true
        end
      elseif c.type == "knob" then
        c.pivotY = (y or love.mouse.getY())
      end
      if c:overIt(x, y) then
      
        if game and game then
            game.buttonPressed = c
        end
        if toybox and toybox.room then
            toybox.room.buttonPressed = c
        end
        
        pressed = pressed or true
        if c.text=="Back" or c.text=="BACK" then
            pressed = 1
        end
        gooi.focused = c
        if id and x and y then
          c.touch = {
            id = id,
            x = x,
            y = y
          }-- Touch used on touchscreens only.
        else
          c.pressed = true-- Pressed just on PC (one pressed at once).
        end
        if not ignoreGooi and c.events.p then
          c.events.p(c)-- onPress event.
        end
      end
    end
    ::skip::
  end
  if pressed then
      if pressed == nil1 then
        media.sfx.laser:play()
        if #mainMenu.oldCurrents>0 then
            mainMenu.current = table.remove(mainMenu.oldCurrents,#mainMenu.oldCurrents)
            mainMenu.ignoreOld = true
        end
      else
        --media.sfx[(string.format("single_shot%s",math.random(1,2)))]:play()
      end
  end
end
---------------------------------------------------------------------------------------------
function gooi.moved(id, xt, yt)
  local x = xt or love.mouse.getX()
  local y = yt or love.mouse.getY()
  x = x / gooi.sx
  y = y / gooi.sy
  
  local camera = gooi.use_camera or gooi.camera
  if camera then
    x, y = camera:toWorldCoords(x, y)
    -- game.timer:after(.1, function() gooi.newButton({x=x, y=y,w=10,h=10,text=""}) end)
  end
  
  
  local cg = {}
  for k, c in pairs(gooi.components) do
    table.insert(cg,c)
  end
  
  local mcomp
  
  for k = #cg,1,-1 do
    local comp = cg[k] or {}
    

  --for k, comp in pairs(gooi.components) do
  -- local comp = gooi.getCompWithTouch(id)
  if comp and comp:overIt(x, y) then--comp.touch then-- Update touch for every component which has it.
  
    if gooi.currentGroup and comp.group ~= gooi.currentGroup then
        --return
    end
    if comp.touch then
    comp.touch.x = xt / gooi.sx
    comp.touch.y = yt / gooi.sy
    end
    if comp.events.m then
      comp.events.m(comp)-- Moven event.
    end
    gooi.oldCompMove = comp
    mcomp = comp
    break
  end
  end
  
  local old = gooi.oldCompMove
  if old and (not mcomp or mcomp ~= old) then
      gooi.oldCompMove = nil
      if old.events.mr then
        old.events.mr(old)
      end
  end
  
  for k, comp in pairs({} or gooi.components) do
    comp:setTooltip(nil, true)
  end
  
end
---------------------------------------------------------------------------------------------
function gooi.released(id, xt, yt) log("rel")
  local c = gooi.getCompWithTouch(id)
  --for x, i in pairs(c) do
    gooi._released(c, xt, yt)
  --end
end

function gooi._released(c, xt, yt)
  gooi.updateFocus()
  if c then
    if gooi.currentGroup and c.group ~= gooi.currentGroup then
        --return
    end
    if c.type == "joystick" then
    end
    if c.type == "knob" then
      c.pivotY = c.yKnob
      c.pivotValue = c.changedValue
    end
    if c:wasReleased() then log("yeah")
      if c.type == "radio" then
        c:select()
      elseif c.type == "checkbox" then
        c:change()
      elseif c.type == "spinner" then
        if c.minPressed then c.minPressed = false end
        if c.plusPressed then c.plusPressed = false end
        c.timerChange, c.timerPreChange, c.amountChange = 0, 0, .1
      end
      if not ignoreGooi and c.events.r then -- and (c.type == "button" or c.squash or c.type=="label") then
        if toybox.room and (not (c.noSquish or c.noSquash) and game.squash) or (c.squash or c.doSquash) then
            toybox.room:squash_ui(c)
            
            if c.events.sq then
                assert(c.ogOnSquash == c.onSquash, "Squash function is bad?")
                c.events.sq(c)
            end
            
            local func = function()
                c.events.r(c)-- onRelease event.
            end
            game.timer:after(1.0,func)
        else
            c.events.r(c)
        end
        
        if gooi.onReleaseUI then
            gooi.onReleaseUI()
        end
      end else log("NOOOO!!")
    end
    c.pressed = false
    c.touch = nil
  end
end
---------------------------------------------------------------------------------------------
function gooi.oldgetCompWithTouch(id)
  local comp = nil
  for k, c in pairs(gooi.components) do
    if c.touch then
      if c.touch.id == id then
        comp = c
        break
      end
    else
      if c.pressed then comp = c ; break; end
    end
  end
  return comp
end

function gooi.getCompWithTouch(id)
  local comp = nil
  local cg = {}
  for k, c in pairs(gooi.components) do
    table.insert(cg,c)
  end
  
  for k = #cg,1,-1 do
    local c = cg[k] or {}
  
    if c.touch then
      if c.touch.id == id then
        comp = c
        break
      end
    else
      if c.pressed then comp = c ; break; end
    end
  end

  return comp
end

function gooi.oldnewgetCompWithTouch(id)
  local comp = nil
  for k = #gooi.components,1,-1 do
    local c = gooi.components[k] or {}
    if c.touch then
      if c.touch.id == id then
        comp = c
        break
      end
    else
      if c.pressed then comp = c ; break; end
    end
  end
  return comp
end

function gooi.getCompsWithTouch(id)
  local comps = {}
  for k, c in pairs(gooi.components) do
    if c.touch then
      if c.touch.id == id then
        table.insert(comps,c)
        break
      end
    else
      if c.pressed then table.insert(comps,c) ; end
    end
  end
  return comps
end

function gooi.updateFocus()
  local comp = nil
  for k, c in pairs(gooi.components) do
    if c:overIt() and (c.pressed or c.touch) then
      c.hasFocus = true
      comp = c
      break
    end
  end

  for k, c in pairs(gooi.components) do
    if c ~= comp then
      c.hasFocus = false
      if c.type == "text" then
        c.timerCursor = 0
        c.showingCursor = true
      end
    end
  end

  local tf = gooi.getByType("text")
  local b = false
  for i = 1, #tf do
    if tf[i].hasFocus then b = true end
  end
  if not b then love.keyboard.setTextInput(false) end
end

function gooi.changeFont(font)-- Update font of every component:
  for k, c in pairs(gooi.components) do
    c.font = font
  end
end

function gooi.keypressed(key, scancode, isrepeat)
  if gooi.showingDialog then
    if key == "enter" then
        if gooi.fPositive then
            gooi.fPositive()
        end
        gooi.closeDialog()
    elseif key == "escape" and gooi.noButton then
        if gooi.fNegative then
            gooi.fNegative()
        end
        gooi.closeDialog()
    end
  end

  local fields = gooi.getByType("text")
  for i = 1, #fields do
    local f = fields[i]
    if gooi.currentGroup and f.group ~= gooi.currentGroup then
        --goto skip
    end
    if f == gooi.focused then
      f:typeCode(key)
      f:setToRepeat(key)
    end
    ::skip::
  end
end

function gooi.keyreleased(key, scancode)
  local fields = gooi.getByType("text")
  for i = 1, #fields do
    local f = fields[i]
    if gooi.currentGroup and f.group ~= gooi.currentGroup then
        --goto skip
    end
    f.keyToRepeat = nil
    f.timerRepeatKey = 0
    f.timerCanRepeat = 0
    ::skip::
  end
end

function gooi.textinput(text)
  local fields = gooi.getByType("text")
  for i = 1, #fields do
    local f = fields[i]
    if f == gooi.focused then
      f:typeText(text)
      if f:specialKey(text) then
        f:setToRepeat(key)
      end
    end
  end
end

-- Get the focused component (for non touchscreens):
function gooi.getFocused()
  local comp = nil
  for k, c in pairs(gooi.components) do
    if c.hasFocus then
      comp = c
      break
    end
  end
  return comp
end

function gooi.checkBounds(text, x, y, w, h, t)
  local newX, newY, newW, newH = x, y, w, h
  if not (w and h) then
    newW = gooi.getFont(self):getWidth(text) + gooi.getFont(self):getHeight()
    newH = gooi.getFont(self):getHeight() * 2
    if t == "check" or t == "text" or t == "radio" then
      newW = newH
    end
    if t == "spinner" then
      newW = gooi.getFont(self):getWidth(text)
      newW = newW + newH * 2.5
    end
    if not (x and y) then
      newX, newY = 10, 10
    end
  end
  return newX, newY, newW, newH
end

function gooi.getFont(comp)
  if comp and comp.font then
    return comp.font
  end
  if comp and comp.style and comp.style.font then
    return comp.style.font
  end
  return gooi.font or gooi.defaultFont
end


-----------------------

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function invert(color)
  local r, g, b, a = color[1], color[2], color[3], color[4] or 1
  return {1 - r, 1 - g, 1 - b, a}
end
