----------------------------------------------------------------------------
--------------------------   Spinner creator   -----------------------------
----------------------------------------------------------------------------

function gooi.newChooser(params)
  params = params or {}
  local s = {}

  local x, y, w, h = gooi.checkBounds(
    "..........",
    params.x or 10,
    params.y or 10,
    params.w or gooi.unit * 5,
    params.h or gooi.getFont():getHeight() * 2,
    "spinner"
  )

  local v = params.value or 5
  local maxv = params.max or 10
  s = component.new("spinner", x, y, w, h, params.group)
  s = gooi.setStyleComp(s)
  s.items = params.items or {"None"}
  s.drawNumber = params.drawNumber
  s.drawValue = params.drawValue
  s.currentPlace = 1
  
  s.value = v
  s.realValue = s.value
  s.max = maxv
  s.min = params.min or 0
  s.minPressed, s.plusPressed = false, false
  s.amountChange = .1
  s.timerChange = 0
  s.timerPreChange = 0
  s.sense = params.sense or 1
  s.r = function() end
  if s.value > s.max or s.value < s.min then
    error("Error in gooi.newSpinner(), value out of range.")
  end
  if s.min > s.max then
    error("Error in gooi.newSpinner(), min value it's greater than max value")
  end
  function s:rebuild()
    -- Coords for minus and plus buttons:
    self.step = step or 1
    self.xMin = self.x + self.h / 2
    self.yMin = self.y + self.h / 2
    self.xPlus = self.x + self.w - self.h / 2
    self.yPlus = self.y + self.h / 2
    self.radCirc = self.h * .4
    -- Correct bounds:
    if self.h >= self.w then self.w = self.h * 1.1 end
  end
  s:rebuild()
  function s:drawSpecifics(fg)
    local value = self.items[self.currentPlace]
    local mC = self.h / 6 -- Margin corner.
    local side = self.h - mC * 2
    local modes = {"fill", "line"}

 --   for i = 1, 2 do
      love.graphics.setColor(fg)
      love.graphics.print("<",
        math.floor(self.x + mC + side / 4),
        (self.y + mC + side / 4)
      )
      love.graphics.print(">",
        math.floor(self.x + self.w - mC - side),
        (self.y + mC + side / 4)
      )
 --   end

    if not self.enabled then
      love.graphics.setColor(0, 0, 0)
    end
    local t = value
    if self.drawNumber then
        t = self.currentPlace
    elseif self.drawValue then
        t = value[self.drawValue] or error(string.format("No index %s",self.drawValue))
    end
    
    local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
    local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)

    love.graphics.setColor(fg)
    love.graphics.print(t, math.floor(x), math.floor(y))
  end
  function s:overMinus(x, y)
    return self:overIt() and x < (self.x + self.w / 2)
  end
  function s:overPlus(x, y)
    return self:overIt() and x >= (self.x + self.w / 2)
  end
  function s:plus()
    self:changeValue(1)
  end
  function s:minus()
    self:changeValue(-1)
  end
  function s:getValue()
    return gooi.round(self.value, 2)
  end
  function s:onRelease(func)
    self.r = func
    return self
  end
  function s:onPress(func)
    self.r = func
    return self
  end
  function s:onChange(func)
    self.r = func
    return self
  end
  function s:setItems(items)
    self.items = items
    return self
  end
  function s:setItem(it)
    if type(it) == "number" then
      self.currentPlace = it
      return self
    end
    for i = 1,#self.items do
      if self.items[i] == it then
        self.currentPlace = i
        return self
      end
    end
    return self
  end
  
  function s:getItem(n)
     return self.items[n or self.currentPlace]
  end
  function s:addItem(item)
    self.items[#self.items] = item
    return self
  end
  function s:removeItem(item)
    local i
    for u = 1,#self.items do
      if self.items[u] == item then
        table.remove(self.items,u)
        break
      end
    end
  end
  function s:reset(n)
    self.currentPlace = n or 1
  end
  
  function s:changeValue(sense)
    self.currentPlace = self.currentPlace+sense
    local i = self.items[self.currentPlace]
    if not i and sense>0 then
      self.currentPlace = 1
      return self:changeValue(0)
    elseif not i and sense<0 then
      self.currentPlace = #self.items
      return self:changeValue(0)
    end
    self.r(self:getItem(),self)
    
    return self
  end
  function s:update(dt)
    self.timerPreChange = self.timerPreChange + dt
    if self.timerPreChange > .4 then
      self.timerChange = self.timerChange + dt

      self.amountChange = self.amountChange - dt / 30
      if self.amountChange < .02 then self.amountChange = .02 end
      if self.timerChange >= self.amountChange then
        local sense = self.sense
        if self.minPressed then sense = -1 end
        self:changeValue(sense)
        self.timerChange = 0
      end
    end
  end
  return gooi.storeComponent(s, id)
end
