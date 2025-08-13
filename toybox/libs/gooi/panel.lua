----------------------------------------------------------------------------
--------------------------   Panel creator   -------------------------------
----------------------------------------------------------------------------

function gooi.newPanel(params)
  params = params or {}
  local p = {}
  local defLayout = "grid 3x3"

  local x, y, w, h = gooi.checkBounds(
    "..........",
    params.x or 10,
    params.y or 10,
    params.w or gooi.unit * 5,
    params.h or gooi.unit * 5,
    "panel"
  )

  p = component.new("panel", x, y, w, h, params.group)
  p = gooi.setStyleComp(p)
  p.opaque = false
  p.x = x
  p.y = y
  p.w = w
  p.h = h
  p.sons = {}
  p.editedSpans = {}
  function p:setLayout(l)
    if l then
      if l:sub(0, 4) == "grid" then
        p.layout = layout.new(l)
        p.layout.paddingGrid = params.padding or params.paddingGrid
        p.layout.paddingY = params.paddingY or nil
        p.layout:init(p)
      elseif l:sub(0, 4) == "game" then
        p.layout = layout.new(l)
      else
        error("Layout definition must be 'grid NxM' or 'game'")
      end
      --print(unpack(split(theLayout, " ")))
    else
      p.layout = layout.new(defLayout)
      p.layout:init(p)
    end
    return self
  end
  p:setLayout(params.layout or defLayout)
  p.bLabel = gooi.newLabel(params):setText("")
  function p:debug()
    self.layout.debug = true
    return self
  end
  function p:drawSpecifics(fg)
    if self.layout.kind == "grid" then
      love.graphics.setColor(0, 0, 0, 0.5)
      self.layout:drawCells()
    end
    if self.background then
      self.bLabel.w = self.w
      self.bLabel.h = self.h
      self.bLabel.x = self.x
      self.bLabel.y = self.y
      self.bLabel:setOpaque(true)
      self.bLabel:setText("")
      self.bLabel:drawSpecifics(fg)
    end
  end
  function p:rebuild()
    if self.layout.kind == "grid" then
      self.layout:init(self)
    end
  end
  
  function p:getUIMap(group)
    local ui = toybox.room:new_ui_map_data()
    for x, i in ipairs(self.sons) do
      if i.ref.type ~= "label" and i.ref.type ~= "text" then
        ui:map_ui(i.ref, i.cellCol, i.cellRow, group or self.group)
      end
    end
    
    self.ui_map_data = ui --assert(ui)
    return ui
  end
  
  
  --p:rebuild()
  function p:addf(...)
    local c = {...}
    c = c[1]
    if type(c) == "table" and c.setFontDimensions then
      self:add(...)
      c:setFontDimensions()
    
    else
      return self:add(...)
    end
  end
    
  function p:add(...)
    local params = {...}
    if self.layout.kind == "grid" then
      if type(params[2]) == "string" or type(params[2]) == "number" then-- Add component in a given position:
        local row, col
        
        if type(params[2]) == "string" then
            row = split(params[2], ",")[1]
            col = split(params[2], ",")[2]
        else
            row = params[2]
            col = params[3]
        end
        
        local cell = self.layout:getCell(tonumber(row), tonumber(col))

        if not cell then
          error("Row "..row.." and Col "..col.." not defined")
        end

        local c = params[1]
        c.group = self.group
        -- Set bounds according to the parent layout:
        c:setBounds(cell.x, cell.y, cell.w, cell.h)

        -- Save son:
        table.insert(self.sons,
        {
          id = c.id,
          parentId = self.id,
          cellRow = cell.row,
          cellCol = cell.col,
          ref = c
        })
        if not self.visible then
          c:setVisible(false)
        end

        c.ongrid = true
        cell.on = false

        -- Joysticks are always a square or cirle:
        if c.type == "joystick" then
          c.w = c.smallerSide
          c.h = c.smallerSide
        end

        if c.rebuild then c:rebuild() end
        if c.type == "joystick" then
          -- Workaround for joysticks:
          c.pressed = true
          c.stickPressed = true
          c:restore()
          c.stickPressed = false
          c.pressed = false
        end
        c.group = self.group
      else-- Add component in the next available cell:
        for i = 1, #params do
          local c = params[i]
          c.group = self.group
          local cell = self.layout:nextCell(c)



          if not cell then
            error("Insufficient cells in grid layout")
          end

          -- Set bounds according to the parent layout:
          c:setBounds(cell.x, cell.y, cell.w, cell.h)
          c.ongrid = true
          --print("cell: ", c.x, c.y)

          -- Save child:
          table.insert(self.sons, {
            id = c.id,
            parentId = self.id,
            cellRow = cell.row,
            cellCol = cell.col,
            ref = c
          })
          if not self.visible then
            c:setVisible(false)
          end

          -- Joysticks are always a square or cirle:
          if c.type == "joystick" then
            c.w = c.smallerSide
            c.h = c.smallerSide
          end
          c.group = self.group

          if c.rebuild then c:rebuild() end
          if c.type == "joystick" then
            -- Workaround for joysticks:
            c.pressed = true
            c.stickPressed = true
            c:restore()
            c.stickPressed = false
            c.pressed = false
          end
        end
      end
    elseif self.layout.kind == "game" then
      local ref = params[1]
      ref.group = self.group
      local position = params[2]
      if not(
        position == "t-l" or
        position == "t-r" or
        position == "b-l" or
        position == "b-r")
      then
        error("valid positions are: 't-l', 't-r', 'b-l' and 'b-r'")
      end
      self.layout:suit(self, ref, position)
      -- Save son:
      ref.ongame = true
      table.insert(self.sons,
      {
        id = ref.id,
        parentId = self.id,
        cellRow = -1,
        cellCol = -1,
        ref = ref
      })
      if not self.visible then
        ref:setVisible(false)
      end
      if ref.rebuild then ref:rebuild() end
    end
    return self
  end
  function p:changePadding(padding)
    -- body
  end
  
  function p:refreshSpans()
    local editedSpans = self.editedSpans
    self.editedSpans = {}
    for x = 1, #editedSpans do
      local e = editedSpans[x]
      self:changeSpan(e[1], e[2], e[3], e[4]) -- unpack function is slow
    end
  end
  
  -- used when positions or size change
  function p:refresh()
    self:rebuild()
    self:refreshSpans()
    
    for x, i in ipairs(self.sons) do
      if (i.ref.doneSquash or 0)<=10 and not i.ref.noSet then
        local cell = self.layout.gridCells[i.cellRow][i.cellCol]
        i.ref:setBounds(cell.x,cell.y,cell.w,cell.h)
      end
    end
  end
  
  function p:changeSpan(spanType, row, col, size)
    local l = self.layout
    self.editedSpans[#self.editedSpans+1] = {spanType, row, col, size}
    
    if l.kind ~= "grid" then
      error("Panel "..self.id.." has not a grid layout")
    else
      local point, limit
      if spanType == "rowspan" then point, limit = row, l.gridRows end
      if spanType == "colspan" then point, limit = col, l.gridCols end
      -- Check for a valid size:
      if (point + size - 1) > limit then
        error("Invalid rowspan size, max allowed for this row index: "..(limit - point))
      else
        local cell = l:getCell(row, col)
        -- Resize cell according to the new span:
        if spanType == "rowspan"  then
          cell.h = cell.h * size + (cell.padding * 2 * (size - 1))
          cell.rowspan = size
        end
        if spanType == "colspan"  then
          cell.w = cell.w * size + (cell.padding * 2 * (size - 1))
          cell.colspan = size
        end
        -- Turn 'off' the cells which are in the way of the rowspan:
        l:offCellsInTheWay(spanType, row, col, size)
      end
      return self
    end
  end
  function p:setRowspan(row, col, size)
    return self:changeSpan("rowspan", row, col, size)
  end
  function p:setColspan(row, col, size)
    return self:changeSpan("colspan", row, col, size)
  end

  return gooi.storeComponent(p, id)
end
