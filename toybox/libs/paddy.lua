
  
--[[
 Paddy - an onscreen controller display for touch enabled devices
 * Copyright (C) 2017 Ricky K. Thomson
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * u should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 --]]
--note joystick doesnt work when another button is presse before it due to pressed being called
--once
Paddy = class:extend("Paddy")
local angles = {
        ShootUp = 90,
        ShootDown = 270,
        ShootRight = 1,
        ShootLeft = 180,
        ShootTopRight = 45,
        ShootBottomRight = 315,
        ShootBottomLeft = 225,
        ShootTopLeft = 135,
}
Paddy.shootAngles = angles
    
function Paddy:__init__(kwargs)
    local kwargs = kwargs or {}
    self.debug = kwargs.debug
    if self.debug == nil then
        self.debug = true
    end
    
    self.parent = kwargs.parent or kwargs

    -- The size of the buttons which can be pressed.
    self.buttonw = W()*0.0781
    self.buttonh = W()*0.0781


    -- This lists any buttons which are currently being pressed
    self.touched = {}


    if kwargs.joysticks then
        kwargs.Ljoystick = true
        kwargs.Rjoystick = true
    end

    if kwargs.joystick then
        kwargs.Rjoystick = true
    end
    
    if kwargs.Rjoystick == false then
        kwargs.Rjoystick = nil
    end
    

    if kwargs.Ljoystick then

        if type(kwargs.joystick) ~= "table" then
        
            kwargs.Ljoystick = {
                r = self.buttonw*3/2,
                --h = self.buttonh*3,
                y = kwargs .ly or love.graphics.getHeight()-20-self.buttonh*3/2,
                x = kwargs.lx or 20+self.buttonw*3/2
            }
            
        end
        
        self.Ljoystick = Andralog(kwargs.Ljoystick)
        
        local lj = self.Ljoystick
        local gxd = lj.getX
        local gyd = lj.getY
        
        lj.getX = function(...)
            if IM:isDown("Left") then
                return -1
            elseif IM:isDown("Right") then
                return 1
            end
            return gxd(...)
        end
        
        lj.getY = function(...)
            if IM:isDown("Jump") then
                return -1
            end
            return gyd(...)
        end
        
    end

    
    -- Create a dpad widget
    self.dpad = {}

    -- The properties of the canvas to draw
    self.dpad.w = self.buttonw*3
    self.dpad.h = self.buttonh*3
    self.dpad.x = 20
    self.dpad.y = love.graphics.getHeight()-20-self.dpad.h
    self.dpad.x = love.graphics.getWidth()-20-self.dpad.w
    self.dpad.canvas = love.graphics.newCanvas(self.dpad.w,self.dpad.h)

    -- These just make things look prettier
    self.dpad.opacity = kwargs.padding or 200
    self.dpad.padding = kwargs.padding or 5

    -- Setup the names for the buttons, and their position on the canvas
    self.dpad.buttons = {
        { name="up",   x=self.buttonw, y=0 },
        { name="left", x=0, y=self.buttonh },
        { name="right",x=self.buttonw*2, y=self.buttonh },
        { name="down", x=self.buttonw, y=self.buttonh*2 },
        { name="upleft", x=0, y=0 },
        { name="upright", x=self.buttonw*2, y=0 },
        { name="downleft", x=0, y=self.buttonh*2 },
        { name="downright", x=self.buttonw*2, y=self.buttonh*2 },
        
    }


    if kwargs.Rjoystick then
        if type(kwargs.joystick) ~= "table" then
            kwargs.Rjoystick = {
                r = self.buttonw*3/2,
              --  h = self.buttonh*3,
                y = love.graphics.getHeight()-self.buttonw*3/2-20,
                x = love.graphics.getWidth()-self.buttonw*3/2-20
            }
        end
       -- kwargs.joystick.x = self.buttonw*3
      --  kwargs.joystick.y = 0
        self.Rjoystick = Andralog(kwargs.Rjoystick)
        local rj = self.Rjoystick
        local ga = rj.getAngle
        
        rj.getAngle = function(...)
            if IM.enabled then
                for x, i in ipairs(angles) do
                    if IM:isDown(x) then
                        --1 is distance from joystick centre to check if
                        --shooting or aiming(>.3 is shooting).
                        --Keyboards then use automatically shooting.
                        return math.rad(i), 1
                    end
                end
            end
            return ga(...)
        end
        
        --self.joystick.canvas = love.graphics.newCanvas(self.joystick.w, self.joystick.h)
   --     self.joystick.y = love.graphics.getHeight()-20-self.joystick.h*3
      --  self.joystick.x = love.graphics.getWidth()-20--self.joystick.w
    end

    -- Create a buttons widget
    self.buttons = {}
    

    -- The properties of the canvas to draw
    self.buttons.w = self.buttonw*3
    self.buttons.h = self.buttonh*3
    self.buttons.x = kwargs.lx or 20--love.graphics.getWidth()-20-self.buttons.w
    self.buttons.y = kwargs.ly or love.graphics.getHeight()-20-self.buttons.h
    self.buttons.canvas = love.graphics.newCanvas(self.buttons.w,self.buttons.h)

    -- These just make things look prettier
    self.buttons.opacity = kwargs.opacity or 200
    self.buttons.padding = kwargs.padding or 5

   -- Setup the names for the buttons, and their position on the canvas
    self.buttons.buttons = {
        { name="m_up",   x=self.buttonw, y=0 },
        { name="m_left", x=0, y=self.buttonh },
        { name="m_right",x=self.buttonw*2, y=self.buttonh },
        { name="m_down", x=self.buttonw, y=self.buttonh*2 },
        { name="m_upleft", x=0, y=0 },
        { name="m_upright", x=self.buttonw*2, y=0 },
        { name="m_downleft", x=0, y=self.buttonh*2 },
        { name="m_downright", x=self.buttonw*2, y=self.buttonh*2 },
    }
    
    self.angles = {
        up = 270,
        down = 90,
        right = 0,
        left = 180,
        upright = 315,
        downright = 45,
        downleft = 135,
        upleft = 225,
        
        
        m_up = 270,
        m_down = 90,
        m_right = 0,
        m_left = 180,
        m_upright = 315,
        m_downright = 45,
        m_downleft = 135,
        m_upleft = 225,
    }
    for x,i in pairs(self.angles) do
        self.angles[x] = math.rad(i)
    end

    -- Stores any widgets containing interactive buttons
    self.widgets = { self.dpad, self.buttons, self.Rjoystick, self.Ljoystick }
    
    if self.Rjoystick then
        --self.buttons.buttons={}
        self.Rjoystick.buttons = {}
        self.Rjoystick.notTouch = true
        self.doRjoystick = ntrue
    end
    if self.Ljoystick then
        self.buttons.buttons={}
        self.Ljoystick.buttons = {}
    end
       
    self.setButtonName = self.changeButtonName
    self.setButtonText = self.setButtonName
    self.changeButtonText = self.changeButtonName
end

function Paddy:changeButtonName(old,new)
    for i,b in ipairs(self.buttons.buttons) do
        if b.name == old then
            b.name = new
            return true
        end
    end
    for i,b in ipairs(self.dpad.buttons) do
        if b.name == old then
            b.name = new
            return true
        end
    end
end

function Paddy:draw()
    -- Draw the control pad
  --  if not iux then iux=4 self.joystick:rebuild() end
    local r,g,b,a = love.graphics.getColor()
        
    local p = paddyColor and getColor(paddyColor) or getPlayerColor()
    local pr,pg,pb = p[1],p[2],p[3]
    
    
    for _ = 1,4 do
        local widget = self.widgets[_]--widget in ipairs(self.widgets) do
        if widget then
        local x ,y = widget.x,widget.y
        if _ >= 3 then
            widget:draw()
            x,y = widget.__x,widget.__y
        end
        
        if _<3 then
            love.graphics.setColor(0.607,0.607,0.607,0.196)
            --love.graphics.circle("fill", x+widget.w/2,y+widget.h/2,widget.w/2)
            res.endRendering()

            love.graphics.setCanvas(widget.canvas)
            love.graphics.clear()
    
            love.graphics.setColor(0.607,0.607,0.607,1)
        end
        
        if self.doRjoystick then
            goto draw
        end

        for _,button in ipairs(widget.buttons) do
            local buttonw, buttonh = button.w or self.buttonw, button.h or self.buttonh
            if button.isDown then
                love.graphics.setColor(pr,pg,pb,.7)--1)
                love.graphics.rectangle("fill", 
                    button.x+widget.padding, 
                    button.y+widget.padding, 
                    buttonw-widget.padding*2, 
                    buttonh-widget.padding*2,
                    10
                )
            else
                love.graphics.setColor(pr,pg,pb,1)--784)
                love.graphics.rectangle("line", 
                    button.x+widget.padding, 
                    button.y+widget.padding, 
                    buttonw-widget.padding*2, 
                    buttonh-widget.padding*2,
                    10
                )
                love.graphics.setColor(pr,pg,pb,1)
                love.graphics.rectangle("line", 
                    button.x+widget.padding, 
                    button.y+widget.padding, 
                    buttonw-widget.padding*2, 
                    buttonh-widget.padding*2,
                    10
                )
                local bw = buttonw-widget.padding*2
                local bh = buttonh-widget.padding*2
                local g = paddyArrow or game:getAssetFromPath("toybox/utils/arrow.png")
                local gw,gh = resizeImage(g,bw,bh)
                local ggw,ggh = g:getWidth()/2, g:getHeight()/2
                local ang = self.angles[button.name]
                love.graphics.draw(
                    g,
                    (button.x+widget.padding)+bw/2,
                    (button.y+widget.padding)+bh/2,
                    ang
                    ,gw,gh,ggw,ggh
                )
            end
            
            
            -- Temporary code until  button naming can be improved
            if nil then--self.debiug then
                love.graphics.setColor(1,1,1,1)
                
                local font = love.graphics.newFont(20)
                love.graphics.setFont(font)
                local str = button.name
                

                
                love.graphics.printf(
                    button.name, 
                    button.x+self.buttonw/2,
                    button.y+self.buttonh/2, 
                    font:getWidth(str),
                    "center"
                )
            end
        end
        ::draw::
        local x ,y = widget.x,widget.y
        if _ >2 then
            widget:draw()
            x,y = widget.__x,widget.__y
        else
            res.beginRendering()
            love.graphics.setCanvas()
            love.graphics.setColor(1,144/255,1,1)--widget.opacity)
            love.graphics.draw(widget.canvas, x, y)
        end
    end
    end
    
    -- touch controls were messing up
    
    -- debug related
    if self.dekbug then
        for _,id in ipairs(self.touched) do
            if id~=0 then
                local x,y = love.touch.getPosition(id)
                local x,y=res.getMousePosition(ni,nil, x, y)
                love.graphics.circle("fill",x,y,20)
            end
        end
    end
    
    love.graphics.setColor(r,g,b,a)

end

function Paddy:isDown(...)
    local _keys = {...}
    local keys = {}
    for x = 1,#_keys do
        keys[_keys[x]] = true
    end
    
    -- Check for any buttons which are currently being pressed
    for _,widget in ipairs(self.widgets) do
        for _,button in ipairs(widget.buttons) do
            if button.isDown and keys[button.name] then
                self.parent.buttonPressed = true
                return true
            end
        end
    end
end

function Paddy:update(dt)
    self.pressed = nil
    -- Decide which buttons are being pressed based on a 
    -- simple collision, then change the state of the button

    self.touched = love.touch.getTouches()
    local ignore = nil
    if self.ignoreButton then
            self.ignoreButton = self.ignoreButton-dt
            if self.ignoreButton<=0 then
                self.ignoreButton = nil
            end
            ignore = 1
    end
    for _ = 1,4 do
        local widget = self.widgets[_]--widget in ipairs(self.widgets) do
        if widget then
        if _ >= 3 then
            widget:update(dt)
            goto continue
        end

        
        for _,button in ipairs(widget.buttons) do
            button.isDown = false
            if not ignore and not self.doRjoystick and (not self.Rjoystick or self.Rjoystick.angle==0 or widget~=self.dpad) then
                for _,id in ipairs(self.touched) do
                    -- touch controls were messing hp
                    --local txx,tyy = love.touch.getPosition(id)
                    local tx,ty = res.getMousePosition()--nil,nil,txx,tyy)
                    if  tx >= widget.x+button.x 
                    and tx <= widget.x+button.x+self.buttonw 
                    and ty >= widget.y+button.y 
                    and ty <= widget.y+button.y+self.buttonh then
                        button.isDown = true
                        game.buttonPressed = true
                        self.pressed = button.name
                        button.w, button.h = self.buttonw, self.buttonh
                        if toybox.room then toybox.room:squash_ui(button) end
                        break
                    end
                
                    if self.joystick and self.joystick:overItAux(tx,ty) then
                  --      self.joystick:pressed(tx,ty)
                  --      cwarn("","green")
                    end
                end
            end
        end
        end
        ::continue::
    end
end

--[[function Paddy:released(...)
    self.rtrash = self.Rjoystick and not self.Rjoystick:released(...)
    local trash = (self.Ljoystick and self.Ljoystick:released(...)) or trash
    return trash
end

function Paddy:mousereleased(...)
    self.rtrash = self.Rjoystick and not self.Rjoystick:released(...)
    local trash = (self.Ljoystick and self.Ljoystick:released(...)) or trash
    return trash
end

function Paddy:mousepressed(...)
    self.rtrash = self.Rjoystick and self.Rjoystick:pressed(...) or self.rtrash
    local trash = (self.Ljoystick and self.Ljoystick:pressed(...)) or trash
    return trash
end
]]

function Paddy:touchreleased(...)
    self.rtrash = self.Rjoystick and (self.Rjoystick:touchReleased(...))
    if self.rtrash then self.rtrash = nil end
    local trash = (self.Ljoystick and self.Ljoystick:touchReleased(...)) or trash
    return trash
end

function Paddy:touchpressed(...)
    self.rtrash = self.Rjoystick and self.Rjoystick:touchPressed(...) or self.rtrash
    local trash = (self.Ljoystick and self.Ljoystick:touchPressed(...)) or trash
    return trash
end

function Paddy:touchmoved(...)
    local trash = self.Rjoystick and self.Rjoystick:touchMoved(...)
    local trash = (self.Ljoystick and self.Ljoystick:touchMoved(...)) or trash
    return trash
end

function Paddy:prejssed(...)
    local trash = self.joystick and self.joystick:pressed(...)
    return trash
end

return Paddy
