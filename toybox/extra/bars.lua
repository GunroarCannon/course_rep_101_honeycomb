local LifeBar = class:extend("LifeBar")

function d3(self)
    self.colorTop = self.bgColor or self.style.bgColor
    self.colorBot = self.bgColor or self.style.bgColor
    local bgColor = self.bgColor or self.style.bgColor

    self.colorTop = changeBrig(bgColor, 0.06)
    self.colorBot = changeBrig(bgColor, -0.06)

    self.colorTopHL = changeBrig(bgColor, 0.1)
    self.colorBotHL = changeBrig(bgColor, -0.02)

    self.imgData3D = love.image.newImageData(1, 2)
    self.imgData3D:setPixel(0, 0, self.colorTop[1], self.colorTop[2], self.colorTop[3], self.colorTop[4])
    self.imgData3D:setPixel(0, 1, self.colorBot[1], self.colorBot[2], self.colorBot[3], self.colorBot[4])

    self.imgData3DHL = love.image.newImageData(1, 2)
    self.imgData3DHL:setPixel(0, 0, self.colorTopHL[1], self.colorTopHL[2], self.colorTopHL[3], self.colorTopHL[4])
    self.imgData3DHL:setPixel(0, 1, self.colorBotHL[1], self.colorBotHL[2], self.colorBotHL[3], self.colorBotHL[4])

    self.img3D = love.graphics.newImage(self.imgData3D)
    self.img3DHL = love.graphics.newImage(self.imgData3DHL)

    self.img3D:setFilter("linear", "linear")
    self.img3DHL:setFilter("linear", "linear")
end

local dd3 = {bgColor={1,0,0}}
d33 = dd3
d3(dd3)

function LifeBar:__init__(kwargs)
    self.parent = kwargs.parent or kwargs
    self.totalHealth = kwargs.totalHealth or self.parent.totalHealth or
                       self.parent.life or self.parent.health
                       
    self.x = kwargs.x or 0
    self.y = kwargs.y or 0
    self.w = kwargs.w or 40
    self.h = kwargs.h or 4
    
    self.thickness = kwargs.thickness or 4
    
    self.follow = kwargs.follow
    self.drawText = kwargs.drawText ~= false
    
    self.damagedColor = getColor(kwargs.damagedColor or "red")
    self.healthColor = getColor(kwargs.healthColor or "green")
    self.oldHealthColor = self.healthColor
    
    self.alwaysDraw = kwargs.alwaysDisplay or kwargs.alwaysDraw
    self.glows = kwargs.glows or getColor("black")
    
    self.font = kwargs.font
end

function LifeBar:getHealth()
    local h = self.parent.stats and self.parent.stats.health or self.parent.life or self.parent.health or 100
    if h<=0 then
        return 0
    end
    return h
end

function LifeBar:getTotalHealth()
    return self.parent.maxHealth or self.parent.totalHealth or self.parent.totalLife or self.totalHealth or 100
end

function LifeBar:draw(alpha)

    if self.parent.isPoisoned and self.parent:isPoisoned() and not self.poison then
        self.healthColor = getColor("purple")
        self.poison = true
    elseif not self.parent.isPoisoned and self.poison then
        self.healthColor = self.oldHealthColor
        self.poison = nil
    end
    
    if self.follow then
        self.x = self.parent:getCenter()
        self.x = self.x-self.w/2--self.x-self.lifeBar.w/4
        self.y = self.parent.y-self.h-self.parent.h/5
    end
    
    local h = self:getHealth()
    local t = self:getTotalHealth()
    
    if h/t >= 1 and not self.alwaysDraw then
        return
    end
    
    local r,g,b, a = love.graphics.getColor()
    
    self.healthColor=getColor(self.healthColor)
    self.damagedColor=getColor(self.damagedColor)
     
    local d4 = self.damagedColor[4]
    self.damagedColor[4] = alpha or d4

    local h4 = self.healthColor[4]
    self.healthColor[4] = alpha or h4
    
    if (h/t) > 1 then
        h = t
    end
    
    love.graphics.setColor(self.damagedColor)
    love.graphics.rectangle('fill', self.x + (h/t*self.w), self.y, self.w-(h/t*self.w), self.h)
    love.graphics.setColor(self.healthColor)
    love.graphics.rectangle('fill', self.x, self.y, h / t * self.w, self.h)
    
    self.healthColor[4] = h4
    self.damagedColor[4] = d4
    
    love.graphics.setColor(getColor(self.glows,alpha))
    
    for x  = 1, t do
        --love.graphics.line(self.x+self.w*(x/t), self.y, self.x+self.w*(x/t), self.y+self.h)
    end
    
    local text = string.format("%s/%s", self.healthText or h, t)
    local ofont = love.graphics.getFont()
    local font = self.font or ofont
    love.graphics.setFont(font)
    local sc = 1.5
    local tw = font:getWidth(text)*sc
    local th = font:getHeight()*sc
    
    if self.drawText then
        love.graphics.print(text, self.x+self.w/2-tw/2, self.y+self.h/2-th/2, 0, sc, sc)
    end
    
    
    if self.glows then
        love.graphics.setColor(getColor(self.glows,alpha))
        --love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
        local p = love.graphics.getLineWidth()
        local th = self.thickness+2
        local pp = p*th
        love.graphics.setLineWidth(self.glowThickness or p*(th+1))
        local line = love.graphics.line
        
        love.graphics.setColor(getColor(self.damagedColor,.5))
        --line(self.x, self.y+self.h-pp, self.x+self.w+pp,self.y+self.h-pp)
        line(self.x, self.y+pp,self.x+self.w+pp,self.y+pp)
        --line(self.x+self.w-pp,self.y,self.w+self.x-pp,self.h+self.y+pp)
        --line(self.x+pp,self.y,self.x+pp,self.h+self.y+pp)
        
        
        love.graphics.setColor(getColor(self.glows,alpha))
        
        local pp = p*(th/2)
        
        line(self.x+self.w,self.y,self.w+self.x,self.h+self.y+pp)
        line(self.x, self.y+self.h, self.x+self.w+pp,self.y+self.h)
        line(self.x,self.y,self.x,self.h+self.y+pp)
        line(self.x, self.y,self.x+self.w+pp,self.y)
        
        love.graphics.setLineWidth(p)
    end
    
    if self.flash then
        local c = colors[self.flash] or getColor(self.glows)
        love.graphics.setColor(c)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end
    
    
    local i = game:getAssetFromPath("toybox/utils/lifebar_gradient.png")
    local ww, hh = resizeImage(i, self.w, self.h)
    love.graphics.draw(i, self.x, self.y, 0, ww, hh)
    
    
    love.graphics.setColor(r,g,b,a)
    love.graphics.setFont(ofont)
end

local ProgressionBar = class:extend("ProgressionBar")

function ProgressionBar:__init__(kwargs)
    self.loadedColor = getColor(kwargs.loadedColor or kwargs.progressColor or "white")
    self.totalColor = getColor(kwargs.totalColor or "red")
    self.progression = kwargs.progression or 0
    self.total = kwargs.total or 100
    
    self.x = kwargs.x or 0
    self.y = kwargs.y or 0
    self.h = kwargs.h or 10
    self.w = kwargs.w or 10
    
    self.glows = kwargs.glows
    
    self.radius = kwargs.radius

end

function ProgressionBar:progress(n)
    self.progression = self.progression+(n or 0)
    
    return self
end

function ProgressionBar:isComplete()
    return self.progression/self.total==1
end

function ProgressionBar:setProgress(n)
    self.progression = n or 0
    
    return self
end

function ProgressionBar:setTotal(n)
    self.total = n or 100
    
    return self
end

function ProgressionBar:getProgressWidth()
    local p = self.progression
    local t = self.total
    
    return p/t * self.w
end

function ProgressionBar:getLoadedWidth()
    local p = self.progression
    local t = self.total
    
    return p / t * self.w
end

function ProgressionBar:drawLoadedBar()
    local p = self.progression
    local t = self.total
    
    local r,g,b, a = love.graphics.getColor()
    
    love.graphics.setColor(self.totalColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    
    
    --lazy 3d
    if self==game.progress then
        love.graphics.setColor(r,g,b,a)
    
        local img = mainMenu.nextLabel.img3D
        local _w,_h = resizeImage(img, self.w, self.h)
        love.graphics.draw(img, self.x, self.y, 0, _w, _h)
    end
    
    love.graphics.setColor(self.loadedColor)
    if self.drawLoadedFunction then
        self:drawLoadedFunction(p/t*self.w)
    else
        love.graphics.rectangle("fill", self.x, self.y, p / t * self.w, self.h)
    end
    
    --lazy 3d
    if self == game.progress then
        love.graphics.setColor(r,g,b,a)
    
        local img = mainMenu.advice.img3D
        local _w,_h = resizeImage(img, p / t * self.w, self.h)
        love.graphics.draw(img, self.x, self.y, 0, _w, _h)
    end
    
    love.graphics.setColor(r,g,b,a)
    
end

function ProgressionBar:drawBlackFrame(noLeft, noTop, noRight, noBottom)

        local r,g,b,a = love.graphics.getColor()
        
        local p = love.graphics.getLineWidth()
        local pp = 0--p*4
        love.graphics.setLineWidth(p*2)
        
        local line = love.graphics.line
        
        love.graphics.setLineWidth(p)
        local line = love.graphics.line
        
        love.graphics.setColor(0,0,0)
        
        local pp = p--p*2
        
        if not noRight then
            line(self.x+self.w-pp,self.y+pp,self.w+self.x-pp,self.h+self.y-pp)
        end
        
        if not noBottom then
            line(self.x+pp, self.y+self.h-pp, self.x+self.w-pp,self.y+self.h-pp)
        end
        
        if not noLeft then
            line(self.x+pp,self.y+pp,self.x+pp,self.h+self.y-pp)
        end
        
        if not noTop then
            line(self.x+pp, self.y,self.x+self.w-pp,self.y+pp)
        end
        
        love.graphics.setLineWidth(p)
        
        love.graphics.setColor(r,g,b,a)
end

function ProgressionBar:drawFrame(noLeft, noTop, noRight, noBottom)
    local p = self.progression
    local t = self.total
    
    if self.glows then
        local r,g,b,a = love.graphics.getColor()
        love.graphics.setColor(getColor(self.glows,alpha))
        
        local p = love.graphics.getLineWidth()
        local pp = 0--p*4
        love.graphics.setLineWidth(p*2)
        local line = love.graphics.line
        
        
        love.graphics.setColor(getColor(self.glows,alpha))
        
       -- love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.radius, self.radius)
        
        love.graphics.setColor(getColor(self.totalColor,.5))
        --line(self.x, self.y+self.h-pp, self.x+self.w+pp,self.y+self.h-pp)
        line(self.x, self.y+pp,self.x+self.w+pp,self.y+pp)
        --line(self.x+self.w-pp,self.y,self.w+self.x-pp,self.h+self.y+pp)
        --line(self.x+pp,self.y,self.x+pp,self.h+self.y+pp)
        
        
        love.graphics.setColor(getColor(self.glows,alpha))
        
        local pp = 0--p*2
        
        if not noRight then
            line(self.x+self.w,self.y,self.w+self.x,self.h+self.y+pp)
        end
        line(self.x, self.y+self.h, self.x+self.w+pp,self.y+self.h)
        line(self.x,self.y,self.x,self.h+self.y+pp)
        line(self.x, self.y,self.x+self.w+pp,self.y)
        
        love.graphics.setLineWidth(p)
        
        
        
        love.graphics.setLineWidth(p)
        local line = love.graphics.line
        
        love.graphics.setColor(0,0,0)
        
        local pp = p--p*2
        
        line(self.x+self.w-pp,self.y+pp,self.w+self.x-pp,self.h+self.y-pp)
        line(self.x+pp, self.y+self.h-pp, self.x+self.w-pp,self.y+self.h-pp)
        line(self.x+pp,self.y+pp,self.x+pp,self.h+self.y-pp)
        line(self.x+pp, self.y,self.x+self.w-pp,self.y+pp)
        
        love.graphics.setLineWidth(p)
        
        love.graphics.setColor(r,g,b,a)
    end
end

function ProgressionBar:draw(alpha)
    local p = self.progression
    local t = self.total
    
    local r,g,b, a = love.graphics.getColor()
    
    love.graphics.setColor(self.totalColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    
    
    --lazy 3d
    if self==game.progress then
        love.graphics.setColor(r,g,b,a)
    
        local img = mainMenu.nextLabel.img3D
        local _w,_h = resizeImage(img, self.w, self.h)
        love.graphics.draw(img, self.x, self.y, 0, _w, _h)
    end
    
    love.graphics.setColor(self.loadedColor)
    if self.drawLoadedFunction then
        self:drawLoadedFunction(p/t*self.w)
    else
        love.graphics.rectangle("fill", self.x, self.y, p / t * self.w, self.h)
    end
    
    --lazy 3d
    if self == game.progress then
        love.graphics.setColor(r,g,b,a)
    
        local img = mainMenu.advice.img3D
        local _w,_h = resizeImage(img, p / t * self.w, self.h)
        love.graphics.draw(img, self.x, self.y, 0, _w, _h)
    end
    
    self:drawFrame()
    
    if self.flash then
        local c = colors[self.flash] or getColor(self.glows)
        love.graphics.setColor(c)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end
    
    love.graphics.setColor(r,g,b,a)
    
    
end

return {LifeBar = LifeBar, ProgressionBar = ProgressionBar}