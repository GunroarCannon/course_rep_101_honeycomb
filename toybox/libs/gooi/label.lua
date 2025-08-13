----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Label creator  --------------------------------
----------------------------------------------------------------------------
function gooi.newLabel(params)
  params = params or {}
  local l = {}
  defaultText = "new label"

  
  local yLocal = params.yLocal or 0
  
  local x, y, w, h = gooi.checkBounds(
    params.text or defaultText,
    params.x or 10,
    params.y or 10,
    params.w or gooi.getFont():getWidth(params.text or defaultText),
    params.h or gooi.getFont():getHeight() * 2,
    "label"
  )

  l = component.new("label", x, y, w, h, params.group)
  l = gooi.setStyleComp(l)
  l.opaque = false
  l.text = params.text or defaultText
  l.font = params.font or l.font or gooi.font
  
  local self = l
  self.texty = texty:new({
    w=self.w,
    h=self.h,
    y=self.y,
    x=self.x,
    font=self.font or nil and gooi.getFont(self),
    instant=not params.slow and params.instant ~= false and true,
    pause=params.pause or params.textDelay
  })
  
  assert(self.texty.words)
  
  l.icon = params.icon
  l.img = params.img

  if l.icon then
    if type(l.icon) == "string" then
      l.icon = love.graphics.newImage(l.icon)
    end
    if l.text:len() > 0 then
      l.w = l.w + l.icon:getWidth()
    end
  end

  l.textParts = split(l.text, "\n")

  function l:rebuild()
    --self:generateBorder()
  end
  l:rebuild()
  function l:setText(value)
    if not value then value = "" end
    self.texty.color = self.fgColor or self.style.fgColor
    self.text = tostring(value)
    self.textParts = split(self.text, "\n") assert(self.texty.words)
    self.texty.w = self.w
    self.texty:newText(self.text)
    
    return self
  end
  
  l:setText(l.text)
  
  --[[for x = 1,3 do
  l.texty:update(1/60) end
  l:setText(l.text.."hello there, you!! !")
  toybox.room:after(3,function() l.setText = function(self) self.texty.font=font13 ft=fft local old = lume.copy(self.texty.words[1]) self.texty:newText(self.text)
  local c={}
  for x, i in pairs(self.texty.words[1]) do
      if old[x] ~= i or x=="shortText" then--~="words" then
          c[x.."1"] = inspect(i, 2)
          c[x.."2"] = inspect(old[x],2)
          self.texty[x] = old[x]
      end
  end  log(ft==fft) log(inspect(c)) return l end end)
  ]]
  
  function l:largerLine()
    local line = self.textParts[1] or ""

    for i = 2, #self.textParts do
      if #self.textParts[i] > #line then
        line = self.textParts[i]
      end
    end

    return line
  end
  function l:drawSpecifics(fg)
    local tex = self.texty
    tex.w = self.w
    
    -- done in main gooi update loop
    --tex:update(love.timer.getDelta())
    
    tex.w = self.w
    tex.h = self.h
    tex.y = self.y
    tex.x = self.x+(self.xOffset or 0)
    --tex.font = gooi.getFont(self)
    

    local t = self:largerLine() or ""
    -- Right by default:
    local x = self.x + self.w - gooi.getFont(self):getWidth(t) - self.h / 2
    local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
    if self.align == gooi.l then
      x = self.x + self.h / 2
      if self.icon then
        x = x + self.h / 2
      end
    elseif self.align == "center" then
      x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
    end
    if self.icon then
      local fw = gooi.getFont(self):getWidth(self.text)/(iconFontWidth or 4)
      local xImg = math.floor(self.x + self.h / 2)
      local w,h
      love.graphics.setColor(1, 1, 1)
      if not self.enabled then love.graphics.setColor(1/4, 1/4, 1/4) end
      if t:len() == 0 then
        if not self.img then
          xImg = math.floor(self.x + self.w / 2)
          w,h = resizeImage(self.icon,self.w/2,self.h/2)
        else
          xImg = math.floor(self.x+self.w/2)
          w,h = resizeImage(self.icon,self.w,self.h)
        end
      else
        w, h = resizeImage(self.icon, xImg-self.x,self.h/2)
      end
      
      local xImg = math.floor(self.x + self.h / 2) - fw
      love.graphics.draw(self.icon, xImg, math.floor(self.y + self.h / 2), 0, w, h,
        math.floor(self.icon:getWidth() / 2),
        math.floor(self.icon:getHeight() / 2))
    end
    love.graphics.setColor(fg)

    local yLine = yLocal + self.y + (self.yOffset or self.h / 2)
    yLine = yLine + (
        self.yOffset and 0 or
        (self.yOffset and 1 or -1) *(gooi.getFont(self):getHeight()) * #self.textParts / 2
    
    )
    
    for i = 1, 0 or #self.textParts do
      local part = self.textParts[i]

      local xLine = self.x + self.w - gooi.getFont(self):getWidth(part) - self.h / 2
      if self.align == gooi.l then
        xLine = self.x + (self.xOffset or self.yOffset or self.h / 2)
        if self.icon then
          xLine = xLine + self.h /2
        end
      elseif self.align == "center" then
        xLine = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(part) / 2)
      end
      love.graphics.print(part,
        math.floor(xLine),
        math.floor(yLine))

      yLine = yLine + (gooi.getFont(self):getHeight())
    end
    
    self.texty.centered = self.align == "center"
    
    if self.fgColor and self.fgColor[4] then
        tex.alpha = self.fgColor[4]
    end
    
    tex.y = yLine
    tex:draw()
  end
  function l:left(yOffset)
    self.align = gooi.l
    
    if yOffset then
        self.yOffset = yOffset
    end
    
    return self
  end
  function l:center()
    self.align = "center"
    return self
  end
  function l:right()
    self.align = gooi.r
    return self
  end

  l:center()

  function l:setIcon(icon)
    if type(icon) == "string" then
      icon = game:getAsset(icon)--love.graphics.newImage(icon)
    end
    self.icon = icon
    return self
  end
  return gooi.storeComponent(l, id)
end
