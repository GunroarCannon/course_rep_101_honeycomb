----------------------------------------------------------------------------
--------------------------   Button creator  -------------------------------
----------------------------------------------------------------------------

function gooi.newButton(params)
  params = params or {}
  local b = {}
  local defaultText = gooi.defaultText or "new button"
  local theH = gooi.getFont():getHeight()

  local x, y, w, h = gooi.checkBounds(
    params.text or defaultText,
    params.x or 10,
    params.y or 10,
    params.w or gooi.getFont():getWidth(params.text or defaultText) + theH * 2,
    params.h or theH * 2,
    "button"
  )
  
  local yLocal = params.yLocal or 0
  
  b = component.new("button", x, y, w, h, params.group)
  b = gooi.setStyleComp(b)
  b.text = params.text or b.img and "" or defaultText
  b.icon = params.icon
  b.info = params.info
  b.block = params.block
  b.img =  params.img
  b.isImageButton = b.image or b.isImageButton
  
  b.noSquash = params.squash == false
  b.squash = params.squash or b.squash
  
  b.font = params.font or b.font or gooi.font
  
  if b.icon then
    if type(b.icon) == "string" then
      b.icon = game:getAsset(b.icon)--love.graphics.newImage(b.icon)
    end
    if b.text:len() > 0 then
      b.w = b.w + b.icon:getWidth()
    end
  end

  b.textParts = split(b.text, "\n")

  function b:rebuild()
    --self:generateBorder()
  end

  function b:setText(value)
    if not value then value = "" end
    self.text = tostring(value)
    self.textParts = split(self.text, "\n")
    return self
  end

  b:rebuild()

  function b:largerLine()
    local line = self.textParts[1] or ""

    for i = 2, #self.textParts do
      if #self.textParts[i] > #line then
        line = self.textParts[i]
      end
    end
    
    return line
  end
  function b:drawSpecifics(fg)
    -- Center text:
    local t = self:largerLine(self.textParts)
    local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
    local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)

    if self.align == gooi.l then
      x = self.x + self.h / 2

      if self.icon then
        x = x + self.h / 2
      end
    elseif self.align == gooi.r then
      x = self.x + self.w - self.h / 2 - gooi.getFont(self):getWidth(self.text)
    end
    self.icon = self.icon or self.source
    if type(self.icon) == "string" then
      self.icon = game:getSource(self.icon)
    end
    if self.icon then
      local _w, _h = self.iw or 1, self.ih or 1
      self.source = self.icon
      local xImg = math.floor(self.x + self.h / 2)

      if t:len() == 0 or self.isImgButton or self.ignoreImage then
        if not self.img then
          xImg = math.floor(self.x + self.w / 2)
          _w,_h = resizeImage(self.icon,self.w/2,self.h/2)
        else
          xImg = math.floor(self.x+self.w/2)
          _w,_h = resizeImage(self.icon,self.w,self.h)
        end
      end
      love.graphics.setColor(1, 1, 1)

      if not self.enabled then love.graphics.setColor(1/4, 1/4, 1/4) end
      
      if self.imgColor then
        love.graphics.setColor(type(self.imgColor)=="table" and self.imgColor or getColor(self.imgColor))
      end

      love.graphics.draw(self.icon, xImg, math.floor(self.y + self.h / 2), 0, _w*2 ,_h*2,
        math.floor(self.icon:getWidth() / 2),
        math.floor(self.icon:getHeight() / 2))
        
      if self.img2Color then
        love.graphics.setColor(self.img2Color)
      end
      
      if self.img2 then
       local icon = game:getAsset(self.img2)
       love.graphics.draw(icon, xImg, math.floor(self.y + self.h / 2), 0, _w*2 ,_h*2,
        math.floor(self.icon:getWidth() / 2),
        math.floor(self.icon:getHeight() / 2))
      end
      
      love.graphics.setColor(1, 1, 1)

      if not self.enabled then love.graphics.setColor(1/4, 1/4, 1/4) end
      
      if self.isImgButton and not self.drawtext then
        return
      end
    end

    love.graphics.setColor(fg)

    local yLine = yLocal + self.y + (self.yOffset or self.h / 2)
    yLine = yLine + (
        self.yOffset and 0 or
        (self.yOffset and 1 or -1) *(gooi.getFont(self):getHeight()) * #self.textParts / 2
    
    )
    
    for i = 1, #self.textParts do
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
        math.floor(xLine)-(math.floor(xLine)-self.x)*(1-(self.w/(self._sqow or self.w)))
        +((1-(self.w/(self._sqow or self.w)))*gooi.getFont(self):getWidth(part)/4)-
        0*((self.x)+(self._sqox or self.x))/4-0*((self._sqow or self.w)-self.w)/2,
        math.floor(yLine)-0*((self.y)+(self._sqoy or self.y))/4-0*((self._sqoh or self.h)-self.h)/2,
        0,self.w/(self._sqow or self.w),self.h/(self._sqoh or self.h))

      yLine = yLine + (gooi.getFont(self):getHeight()) + (self.ySpacing or 0)
    end
  end
  function b:getFontDimensions()
    local yLine = yLocal + self.y + (self.yOffset or self.h / 2)
    yLine = yLine + (
        self.yOffset and 0 or
        (self.yOffset and 1 or -1) *(gooi.getFont(self):getHeight()) * #self.textParts / 2
    
    )
    local f = gooi.getFont(self)
    local h, w = f:getHeight()
    local x, y
    
    for i = 1, #self.textParts do
      local part = self.textParts[i]
      
      w = gooi.getFont(self):getWidth(part)

      local xLine = self.x + self.w - w - self.h / 2
      if self.align == gooi.l then
        xLine = self.x + (self.xOffset or self.yOffset or self.h / 2)
        
        if self.icon then
          xLine = xLine + self.h /2
        end
      elseif self.align == "center" then
        xLine = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(part) / 2)
      end
      
      x = math.floor(xLine)-(math.floor(xLine)-self.x)*(1-(self.w/(self._sqow or self.w)))
        +((1-(self.w/(self._sqow or self.w)))*gooi.getFont(self):getWidth(part)/4)-
        0*((self.x)+(self._sqox or self.x))/4-0*((self._sqow or self.w)-self.w)/2
      y = math.floor(yLine)-0*((self.y)+(self._sqoy or self.y))/4-0*((self._sqoh or self.h)-self.h)/2
      break
    end
    
    local n = 1.2
    
    return x-w*n*.5, y-h*n*.5, w*n, h*n
  end

  function b:setFontDimensions()
    self:setBounds(self:getFontDimensions())
  end
      
  function b:left()
    self.align = gooi.l
    return self
  end
  function b:center()
    self.align = "center"
    return self
  end
  function b:right()
    self.align = gooi.r
    return self
  end

  b:center()
  
  function b:setSource(source)
    return b:setIcon(game:getSource(source))
  end
  
  function b:setIcon(icon)
    if type(icon) == "string" then
      icon = game:getSource(icon)--love.graphics.newImage(icon)
    end

    self.icon = icon
    return self
  end
  return gooi.storeComponent(b, id)
end

function gooi.newImageButton(kwargs)
    kwargs.icon = game:getSource(kwargs.source or "none.png")
    kwargs.text = kwargs.text or ""
    local b = gooi.newButton(kwargs)
    b.source = kwargs.source
    b.drawtext = kwargs.drawtext
    b.text = kwargs.text or ""
    b:setText(b.text)
    b.isImgButton = true
    b.img2 = kwargs.source2 or kwargs.img2
    b.data = kwargs.data
    return b
end
    
