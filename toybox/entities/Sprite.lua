local Sprite = class:extend("Sprite")

function Sprite:__init__(p,kwargs)
    self.uuid = lume.uuid
    
    if not kwargs then
        kwargs = p
        p = nil
    end
    
    self.parent = (kwargs and p) or kwargs.parent or {}
    
    --assert(self.parent and self.parent.isObject, "<Sprite> class needs an <Object> parent, ya Dingdong.")
    
    self.x = kwargs.x or self.parent.x or 0
    self.y = kwargs.y or self.parent.y or 0
    
    self.image_alpha = kwargs.image_alpha or 1
    self.light_alpha = kwargs.light_alpha or 1
    
    -- causes darkness problems
    -- self.useParentAlpha = kwargs.useParentAlpha == nil and true or kwargs.useParentAlpha
    
    self.w = kwargs.w or self.parent.w or 16
    self.h = kwargs.h or self.parent.h or 16
    
    self.offset_x = kwargs.offset_x or self.parent.offset_x or 0
    self.offset_y = kwargs.offset_y or self.parent.offset_y or 0
    
    self.angle = kwargs.angle or nil
    self.map = kwargs.map or toybox.room
    
    self.noResize = kwargs.noResize
    self.noFixOffset = kwargs.noFixOffset
    
    
    
    local anim = kwargs.animations and (kwargs.animations.idle or lume.randomchoice(kwargs.animations)) or kwargs
    
    
    self.bind = kwargs.bind ~= false
    --error(tostring(llkk==game) ..traceObject(game))--(game,3))
     anim.useImages = anim.useImages or kwargs.useImages
     if game.useImages then
        anim.useImages = (anim.useImages~=false and true) or (kwargs.useImages~=false and true) or false
    end
    
    self.source_name = anim.source or error("Animation source not found? (<source> field missing)")
    
    self.source = kwargs.anim_source or kwargs.animation_source or (not anim.useImages and game:getAsset(anim.source))-- or game:getAsset(anim.source..(anim.useImages and "/0.png" or ""))
    self.animation = animx.newActor()
    
    self.kwargs = kwargs
    
    if kwargs.source then
      local i = kwargs
      local animm = self.animation:
        addAnimation(kwargs.name or "norm",{
            img =i.source,
            delay = i.delay or kwargs.delay or .2,
            useImages = i.useImages and true or string.sub(i.source, -4, -4)==".",
            mode = i.mode or kwargs.mode or "once",
            noOfFrames = i.noOfFrames or i.images,
            qw = i.qw,
            qh = i.qh,
            sw = i.imageW or i.imgWidth or i.sw,
            sh = i.imageH or i.imgHeight or i.sh,
            frames= i.frames,
            spritesPerRow = i.spr or i.spritesPerRow,
            onAnimOver = kwargs.onAnimOver or kwargs.onAnimEnd or kwargs.onAnimFinish or kwargs.destroy and function()
                self.parent:destroy()
            end,
            onAnimStart = kwargs.onAnimStart
        })
        if not kwargs.noSwitch then
            animm:switch(kwargs.name or "norm")
        end
    end
    
    local kpairs = kwargs.animations and kwargs.animations[1] and ipairs or pairs
    
    for x , i in kpairs(kwargs.animations or {}) do
        --self.source =  game:getAsset(i.source)
        self.source_name = i.source or error("wierd anim")
        if i.useImages == false then
            anim.useImages = false
        end
        
        local animm = self.animation:addAnimation(i.name or x, {
            img = i.source,
            delay = i.delay or kwargs.delay or .2,
            useImages = i.useImages~=false and kwargs.useImages~= false or false,
            mode = i.mode or kwargs.mode or "loop",
            noOfFrames = i.noOfFrames or i.images,
            qw = i.qw,
            qh = i.qh,
            sw = i.imageW or i.imgWidth or i.sw,
            sh = i.imageH or i.imgHeight or i.sh,
            frames= i.frames,
            spritesPerRow = i.spr or i.spritesPerRow,
            onAnimOver = function()
                local ii = i.onAnimOver or i.onAnimEnd or i.onAnimFinish or kwargs.onAnimOver or kwargs.onAnimEnd or kwargs.onAnimFinish
                if ii then
                    return ii(self)
                end
            end,
            onAnimStart = i.onAnimStart
        })
        if not i.noSwitch and not kwargs.noSwitch then
            animm:switch(i.name or x)
        end
    end
    
    if anim.useImages then
        self.useImages = true
        self.source = self.source or game:getAsset((self:getCurrentAnimation() or getValue(self.animation.animations)).frames[1])
    else
        self.useImages = false
    end
    
    self.animation.parent = self.parent
    
    
    self:update(0)
end

function Sprite:switch(s)
    if self:hasAnimation(s) then
        self.animation:switch(s)
        return self
    end
    return false
end

function Sprite:getDelay(frame, ...)
    return self:getCurrentAnimation():getDelay(frame, ...)
end

function Sprite:setDelay(delay, ...)
    return self:getCurrentAnimation():setDelay(delay, ...)
end

function Sprite:getAnimationDelay(frame, ...)
    return self:getDelay(frame, ...)
end

function Sprite:setAnimationDelay(delay, ...)
    return self:setDelay(delay, ...)
end

function Sprite:setFrame(frameNumber)
    return self:getCurrentAnimation():setFrame(frameNumber)
end

function Sprite:jumpToFrame(frameNumber)
    return self:getCurrentAnimation():jumpToFrame(frameNumber)
end

function Sprite:getAnimationSize()
    return self:getCurrentAnimation():getSize()
end

function Sprite:getAnimationLength()
    return self:getAnimationSize()*self:getDelay()
end

function Sprite:destroy()
    self.destroyed = true
    return self.animation:destroy()
end

function Sprite:getSource()
    return self.source
end

function Sprite:hasAnimation(n)
    return self.animation.animations[n]
end

function Sprite:getCurrentImage()
    local a = self.animation:getCurrentAnimation()
    return a:getCurrentQuad()-- a.useImages and a:getCurrentQuad() or a:getTexture()
end

function Sprite:getCurrentFrame()
    local a = self.animation:getCurrentAnimation()
    return a:getCurrentFrame()
end

function Sprite:getCurrentAnimation()
    return self.animation:getCurrentAnimation()
end

function Sprite:getCurrentAnimationName()
    return self:getCurrentAnimation().name
end

function Sprite:updateOffset()
    if not self.noFixOffset then
        self.offset_x = self.parent.offset_x or 0
        self.offset_y = self.parent.offset_y or 0
    end
end

function Sprite:update(dt)
    self.upp=true
    if self.bind then
        self.x, self.y = self.parent.x, self.parent.y
        if not self.noResize then
            self.w, self.h = self.parent.w, self.parent.h
        end
    end
    
    self:updateOffset()
    
    --self.angle = self.parent.angle or 0
    self.flipX = self.parent.flipX
    self.flipY = self.parent.flipY
    
    if not self.w then error("Wierd parent for sprite? (with no .w or .h?) "..inspect(self.parent, 2)) end
    
    self:getQuadSize()
    self._w, self._h = resizeImage(self.sw, self.sh, self.w, self.h)
    
    if self.animation.parent then
        --self.animation:getCurrentAnimation():update(dt)
    end
end

function Sprite:syncTo(parentSprite)
    self.parentSprite = parentSprite ~= self and parentSprite
    if self.parentSprite then
        -- self:setDelay(parentSprite:getDelay(parentSprite:getCurrentFrame()))
    end
end

function Sprite:getQuadSize()

    local sw, sh, sx, sy
    
    if not self.useImages then
        self.qsource=self:getCurrentImage() --error(self.source)
        sx, sy, sw, sh = self.qsource:getViewport()
    else
        local s = game:getAsset(self.source)
        assert(s, string.format("Can't access sprite <%s>!",self.source_name))
        sw, sh = s:getDimensions()
    end
    self.sw, self.sh = sw, sh
    
    return sw, sh
end

function Sprite:draw()
    if self.parentSprite then
        local a = self:getCurrentAnimation()
        local a2 = self.parentSprite:getCurrentAnimation()
        a.actor.parent=nil
        --error(inspect(a, 3))
        a:setFrame(a2:getCurrentFrame())
    end
    
    local r,g,b,a = love.graphics.getColor()
    
    
    if self.useParentAlpha then
        self.image_alpha = self.parent.image_alpha
        self.light_alpha = self.parent.light_alpha
    end
    
    
    if self.color then
        love.graphics.setColor(getColor(self.color,self.image_alpha))
    elseif self.image_alpha ~= 1 then
        love.graphics.setColor(r,g,b,self.image_alpha)
    end
    
    if self.light_alpha ~= 1 then
        local r,g,b,a = lg.getColor()
        local l = self.light_alpha
        set_color(r*l, g*l, b*l, a*(l == 0 and 0 or 1))
    end
  
    local img = self.source assert(self.upp, "Sprite has not been updated, yo.")
    --self:update(0)
    if self.noResfize then
        self._w, self._h = self.parent._w, self.parent._h
    else
        self._w, self._h = resizeImage(self.sw or self:getQuadSize(), self.sh, self.w, self.h)
    end
    
    if self.parent.angle~= 0 and toybox.debug then self.dd=self.dd or self.parent.angle self.parent.color=getColor("yellow") log(math.deg(self.parent.angle)) end 
    if not (self.parent.angle) then error( inspect(self.kwargs,10)) end
    local ang = math.rad(self.angle or self.parent.angle)+(self.parent.angle_2 and math.rad(self.parent.angle_2) or 0)
    if self.flipX == -1 and ang~=0 then
        --ang = math.rad(180-math.deg(ang))*-1
    end
    
    self.animation:draw(
        self.x+self.offset_x+self.parent.shake_x+(self.flipX == -1 and -self.w*0 or 0),
        self.y+self.offset_y+self.parent.shake_y+(self.flipY == -1 and self.h*0 or 0) ,
        -ang,
        self._w*self.flipX, self._h*self.flipY
        ,self.sw/2,--*self.flipX,
        self.sh/2
    )
    love.graphics.setColor(r,g,b,a)
end

function Sprite:drawTexture(texture, color, alpha)
    local r,g,b,a = love.graphics.getColor()
    if color or self.color then
        love.graphics.setColor(getColor(color or self.color,alpha or self.image_alpha))
    elseif self.image_alpha ~= 1  or alpha then
        love.graphics.setColor(r,g,b,alpha or self.image_alpha)
    end
    
    if self.light_alpha ~= 1 then
        local r,g,b,a = lg.getColor()
        local l = self.light_alpha
        set_color(r*l, g*l, b*l, a*(l == 0 and 0 or 1))
    end
  
    local img = self.source assert(self.upp, "Sprite has not been updated, yo.")
    --self:update(0)
    if self.noResfize then
        self._w, self._h = self.parent._w, self.parent._h
    else
        self._w, self._h = resizeImage(self.sw or self:getQuadSize(), self.sh, self.w, self.h)
    end
    
    if self.parent.angle~= 0 and toybox.debug then self.dd=self.dd or self.parent.angle self.parent.color=getColor("yellow") log(math.deg(self.parent.angle)) end 
    if not (self.parent.angle) then error( inspect(self.kwargs,10)) end
    local ang = math.rad(self.angle or self.parent.angle)+(self.parent.angle_2 and math.rad(self.parent.angle_2) or 0)
    if self.flipX == -1 and ang~=0 then
        ang = math.rad(180-math.deg(ang))*-1
    end
    
    self:getCurrentAnimation():drawTexture(
        texture,
        self.x+self.offset_x+self.parent.shake_x+(self.flipX == -1 and -self.w*0 or 0),
        self.y+self.offset_y+self.parent.shake_y+(self.flipY == -1 and self.h*0 or 0) ,
        -ang,
        self._w*self.flipX, self._h*self.flipY
        ,self.sw/2,--*self.flipX,
        self.sh/2
    )
    love.graphics.setColor(r,g,b,a)
end

return Sprite