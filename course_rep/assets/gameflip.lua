-- choose:add
-- vertex shader

    local h = H()*.1
    local w = 500 or W()*nw
tex = require "course_rep/perspective"

local vertexShader = [[
    extern float tween;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    
    float angle = tween*90.0*(3.14/180.0);
     float depth = tween*5.0;
    vec2 center = vec2(0.5, 0.5);
    vec2 flipped_coords = texture_coords;
    flipped_coords.x = texture_coords.x * cos(angle) - texture_coords.y * sin(angle) + center.x * (1.0 - cos(angle)) + center.y * sin(angle);
    flipped_coords.y = texture_coords.x * sin(angle) + texture_coords.y * cos(angle) + center.y * (1.0 - cos(angle)) - center.x * sin(angle);
    float perspective = 1.0 - (flipped_coords.y - center.y) * depth;
    flipped_coords.x *= perspective;
    flipped_coords.y *= perspective;
    return Texel(texture, flipped_coords);
  }
]]
-- fragment shader
local fragmenttShader = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        float angle = 0.5; // adjust this value to control the flip angle
        float flip = smoothstep(0.0, 1.0, abs(screen_coords.x - 0.5) * 2.0 * angle);
        vec4 texel = Texel(texture, texture_coords);
        vec4 flipped_texel = Texel(texture, vec2(1.0 - texture_coords.x, texture_coords.y));
        return mix(texel, flipped_texel, flip);
    }
]]

local fshader = love.graphics.newShader(vertexShader, fragmentShader)

local mask_effect =
love.graphics.newShader  [[
vec4 effect(vec4 color, Image
texture, vec2 texture_coords, vec2
screen_coords) {
      if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]

local cdat
function maskStencil()
love.graphics.setShader(mask_effect)
local img = cdat
local self = img.parent
   
      local drawable = type(img.source)=="userdata" and img.source or game:getAsset(img.source)
      local _w, _h = resizeImage(img.source, img.w or self.imageW or self.w, img.h or self.imageH or self.h)
      
      if  not self.noStencil then
      love.graphics.stencil(stencilFunction,  "replace", 1)

      love.graphics.setStencilTest("greater", 0)

      end
      
      local ii = img
      
      love.graphics.draw(drawable,
          math.floor(img.x or self.x)+(img.offset_x or self.imageOffsetX)*(self.w/(self._sqow or self.w))+(self.w/(self._sqow or self.w))*(img.w or self.imageW or self._sqow or self.w)/2,
          math.floor(img.y or self.y)+(img.offset_y or self.imageOffsetY)+(img.h or self.imageH or self.h)/2,
          img.angle and math.rad(img.angle) or 0,
          _w, _h
          --self.w / self.bgImage:getWidth(),
          --self.h / self.bgImage:getHeight()
          ,
          drawable:getWidth()/2,
          drawable:getHeight()/2
        )
love.graphics.setShader()
end

function drawBar(dat, x, y, ang, w, h)
    cdat = dat
 lg.stencil(maskStencil,"replace", 1)
 lg.setStencilTest("greater", 0)
    local r, g, b, a = set_color(getColor(dat.parent.color or "blue"))
    draw_rect("fill", x, y+h-h*.5, w, h*.5)
    set_color(0,0,0,1)
    local l = lg.getLineWidth()
    lg.setLineWidth(4)
    lg.line(x, y+h-h*.5, x+w, y+h-h*.5)
    lg.setLineWidth(l)
    set_color(r, g, b, a)
    lg.setStencilTest()
end

local GameScreen = toybox.Room("GameScreen")
nw = .5
function GameScreen:setup()
    self:activate_gooi()
    
    local w = W()*.99
    local h = H()*.1
    
    local icons = {"church","brain","popularity","coin"}
    local stats = {
        church = {
            icon = "cross",
            color = "brown",
        },
        brain = {
            icon = "brain",
            color = "pink"
        },
        popularity = {
            icon = "popularity",
            color = "skyblue",
        },
        coin = {
            icon = "coin",
            color = "gold"
        }
    }
    
    local nums = {1,2,3,4}
    
    self.statsPanel = gooi.newPanel({padding=15, w = w, h = h, x = W()/2-w/2, y = 4, layout = "grid 1x4"})
    for x = 1, 4 do
        local b = gooi.newButton({text=""})
        self.statsPanel:add(b)
        b.h = b.w
        local i = b:addImage(string.format("panels/%s.png", lume.eliminate(nums)))
        i.offmset_x = -50
        i.offiiset_y = -50
        i.w = 140+20
        i.h = 140+20
        i.draw = drawBar or er()
        i.parent = b
        
        local stat = stats[icons[x]]
        
        b.color = stat.color
        
        local i = b:addImage(string.format("icons/%s.png", stat.icon))
        i.offset_x = 10
        i.offset_y = 10
        i.w = 140+0
        i.h = 140+0
        
        b.drawRect = false
        b.showBorder = false
        b.noStencil = true
        b.bgColor = {0,0,0,0}
    end
    
    
    
    local h = H()*.1
    local w = 500 or W()*nw
    
    local x, y = W()/2-w/2, h+10+((H()-h)/2-(W()*.55)/2)-h+80
    local choose = gooi.newButton({text="", x=x, y=y, w=w, h=w})
    
    choose.y = choose.y + 80
    choose.ogx = choose.x
    tw=600
    local i = choose:addImage("border_back_r.png")
    i.w = tw
    i.h = tw
    local ttw = 0--25
    i.offset_x = (i.offset_x or 0) - 50 + ttw
    i.offset_y = (i.offset_y or 0) - 82 + ttw
    i.flipX = -1
    
    local i = choose:addImage("border_empty.png")
    i.w = tw
    i.h = tw
    i.flipX = -1
    i.offset_x = (i.offset_x or 0) - 50 + ttw
    i.offset_y = (i.offset_y or 0) - 82 + ttw
    
        
    choose.onlyImage = true
    choose.showBorder = false
    choose.noStencil = true
    
    
    self:loadNewDialog()
    
    self.timer:every({1,1.5,1.3,2}, function()
        local f = self.face
        if not f then
            return
        end
        
        self.face.times = (self.face.times or 0)+1
        
        local oox, ooy = self.face.offset_x, self.face.offset_y
        local dx = math.random(-10,10)/10
        local dy = math.random(-10,10)/10
        local w = 20
        local xLeft = -40
        local xRight = 40
        local yTop = 40
        local yBottom = -40
        local ox = lume.clamp(oox+w*dx,xLeft,xRight)
        local oy = lume.clamp(ooy+w*dy,yBottom,yTop)
        
        if self.face.times>=3 and math.random()>.5 then
            ox, oy = 0,0
            self.face.times = 0
        end
        
        self:tween(.85, f, {offset_x=ox, offset_y=oy}, "linear")
    end)
    
    
end

function GameScreen:loadNewDialog(data)
    local text = getValue({"Finally some #good food ~ around here for once.","Im really tired. Help me write my report. #please","(They wink at you)","Heya\nloser","Polite aren't \nyah","Yosh"})
    text = text:upper()
    self.rr = -.6
    
    gooi.removeComponent(self.label2)
    gooi.removeComponent(self.nameLabel)
    gooi.removeComponent(self.choose)
    
    local h = H()*.1
    local w = 500 or W()*nw
    
    local x, y = W()/2-w/2, h+10+((H()-h)/2-(W()*.45)/2)-h
    if self.label then gooi.removeComponent(self.label) end--setText("")
    local ww = W()*.85
    
    local label2 = gooi.newLabel({w=ww, x=W()/2-ww/2, h=w/2, y=y, instant=true}):setOpaque(false)
    label2.yOffset = 10
    label2:setText(text)
    
    local label = gooi.newLabel({w=ww, x=W()/2-ww/2, h=w/2, y=y, instant=false}):setOpaque(false)
    label.yOffset = 10
    label:setText(text)
    label.ogy = y
    label.y = label.ogy-label2.texty.h
    gooi.removeComponent(label2)
    self.label = label
    
    -- self.label:setText(text)
    self.label.ye = self.label.ogy-self.label.texty.h
    
    
    local h = H()*.1
    local w = 500 or W()*nw
    
    local x, y = W()/2-w/2, h+10+((H()-h)/2-(W()*.55)/2)-h+80
    self.choose = gooi.newButton({text="", x=x, y=y, w=w, h=w})
    
    self.choose.y = self.choose.y + 80
    self.choose.ogx = self.choose.x
    
    self.choose:onPress(function(r)
        self.ox, self.oy = love.mouse.getX(),0
        -- self.rr = -.2
        if self.tweening then
            self.timer:cancel(self.tweening)
            self.tweening = nil
        end
    end):onRelease(function()end)
    -- self.choose.icon = game:getAsset("face.png")
    
    local byy = 82
    local tmpW = 600
    local i = self.choose:addImage("border.png")
    i.w = tmpW
    i.h = tmpW
    i.offset_x = (i.offset_x or 0) - 50
    i.offset_y = (i.offset_y or 0) - byy
    
    border = i
    
    local name = getValue({"steve","xoftest","ella","dumebi","skibi","fresh","beverage","favour","isioma","smith","donatus","kizito"})
    self.body = self.choose:addImage(string.format("people/%s/body.png", name))
    self.head = self.choose:addImage(string.format("people/%s/head.png", name))
    self.face = self.choose:addImage(string.format("people/%s/face.png", name))
    self.face.offset_x = 0
    self.face.offset_y = 0
    
    local pics = { self.body, self.head, self.face, self.hat}
    
    
    
    local i = self.choose:addImage("border_empty.png")
    i.w = tmpW
    i.h = tmpW
    i.offset_x = (i.offset_x or 0) - 50
    i.offset_y = (i.offset_y or 0) - byy
    
    i.shaderf = fshader

    
    local xx, yy = self.choose.x, self.choose.y
    self.choose.xr = -w
    self.choose.yu = -h
    -- self.choose.angle = -400
    local ready = function()
        self.choose.ready = true
    end
    self.diffx = 0
    -- self:tween(.45, self.choose, {x=xx, y=yy, angle=0}, "out-cos", ready)
    
    
local time = 0
local xScale = 1

    self.xScale = -1
    local ofy = i.offset_y
    self.ix, self.iy = 0,0
    self.iangle = 0
    self:after(.03,function()
    self:tween(.5,i,{w=800,h=800},"in-sine",function()
        self:tween(.5,i,{w=600,h=600},"out-quad")
    end)
    self:tween(.5,self,{ix=270,iy=0},'in-quad',function()
    self.ix = self.ix+10
        self:tween(.5,self,{ix=0,iy=0},'out-quad')
    end)
    self:tween(.8,self,{iangle=math.random()>.5 and 15 or -15},'in-quad',function()
        --self.iangle = self.iangle*-1
        self:tween(.5,self,{iangle=0},'out-quad')
    end)
    self:tween(.5, self, {xScale=-0.05}, "out-sine",function()
        self:tween(.5, self, {xScale=1}, "in-sine")
    end)
    end)
    i.draw = function(n)
    frontside = game:getAsset(i.source)
    local w = 600
    local xPos = -50 * math.abs(self.xScale)
    local yPos = 0--w/2 - frontside:getHeight()/2
    i.offset_x = xPos+self.ix+(600-i.w)/2
    i.offset_y = ofy+self.iy+(600-i.h)/2
    i.flipX = self.xScale
    assert(border.parent==i.parent)
    --f i.flipX>0 then i.flipX=i.flipX*-1 end
    
    for x, n in ipairs(pics) do
        n.flipX = i.flipX < 0 and 0 or i.flipX
        n.offset_x = i.offset_x+50
        n.offset_y = i.offset_y+byy
        n.w = i.w-100
        n.h = i.h-100
    end
    
    border.olds = border.olds or border.source
    border.source = i.flipX<0 and "border_back_r.png" or border.olds
    border.w = i.w
    border.h = i.h
    border.offset_x =i.offset_x
    border.offset_y = i.offset_y
    border.flipX = i.flipX
    self.choose.angle = self.iangle

    ii=[[f (xScale >= 0) then 
        love.graphics.draw(frontside, xPos, yPos, 0, xScale, 1)
    else
        love.graphics.draw(frontside, xPos, yPos, 0, -xScale, 1)
    end]]
    end
    i.draw()
    --border.draw=i.draw

    --xScale = math.cos(3.14/2 * time)

    
    self.choose.onlyImage = true
    self.choose.showBorder = false
    self.choose.noStencil = true
    
    self.label2 = gooi.newLabel({text="NO Way #Hosee , ~ even i then still no",
        x = xx,
        y = yy+self.choose.h+20,-10+yy+self.choose.h/2-self.label.h/2,6+20,
        w = self.choose.w,
        h = self.label.h,
    })
    self.label2.fgColor = {0,0,0,0}
    
    
    self.nameLabel = gooi.newLabel({text="Banana Man",
        x = xx,
        y = yy+self.choose.h+20,
        w = self.choose.w,
        h = font20:getHeight(),self.label.h,
    })
    self.nameLabel.fgColor = {0,0,0,0}
    self:tween(.9, self.nameLabel.fgColor,{0,0,0,1},"in-quad")
end

function GameScreen:mousereleased()
    if self.ox and self.rr > 0 then
        if math.abs(self.diffx) > 100 then
            local dir = getDir(self.diffx)
            self.diffx = 0
            self.ox = nil
            local x = dir == 1 and W()+500 or -500
            local y = H()+10
            self:tween(.4, self.choose, {angle=360, x=x, y=y}, "out-quad")
            self:after(.25, function()
                self:loadNewDialog()
            end)
        else
            self.diffx = 0
            self.ox, self.oy = nil
            self.tweening = self:tween(.25, self.choose, {angle=0, x=self.choose.ogx}, "in-quad")
        end
    end
end

function GameScreen:mousemoved(x, y)
    if self.ox and self.rr > 0 then
    
    local b = 200
    local diffx = lume.clamp(x-self.ox, -b, b)
    local diffy = y-self.oy
    
    self.diffx = diffx
    self.choose.x = self.choose.ogx+diffx
    self.choose.angle = (diffx/200)*30
    if true then
        -- self.label2.fgColor[4] =((math.abs(diffx)-20)/200)+0
    end
    end
end

function GameScreen:draw_before_gooi(dt)
    if true then
        self.label2.fgColor[4] =((math.abs(self.diffx)-30)/250)+0
    end
    
    local HH = H()*2
    self.rr = self.rr + dt
    local r,g,b,a = set_color(.9, .9, .9)
    draw_rect("fill", -20, -H()*.5, W()+10, H()*3+10)
    
    set_color(.1, .1, .8)
    local n = 30
    for x = 1, HH/n do
        lg.line(0, -H()*.5+(H()/n)*x, W(), -H()*.5+(H()/n)*x)
    end
    

    set_color(.9, .2, .1)
    lg.line(50, -H()*.5, 50, H()*4)
    lg.print(self.diffx or "?", 0,0)
    
    set_color(r,g,b,a)
end

function GameScreen:draw()
    set_color(0,0,0,(self.label2.fgColor[4])/1.4)
    local fx, fy = self.label2.x, self.label2.texty.y
    local fh = self.label2.texty.h
    draw_rect("fill", -W(), fy, W()*4, fh)
    gooi.drawComponent(self.label2)
end

Menu = toybox.Room("Menu")

function Menu:setup(k)
    self:activate_gooi()
    
    local w = 300
    self.play = gooi.newButton({
        x = W()/2-w/2,
        y = H()-w-100,
        w = w, h = w,
        text=""
    }):onRelease(function(n)
        self:squash_ui(n)
        self:tween(.8, self, {alpha=1}, "out-quad", function()
            game:startGame()
        end)
        self:tween(.7, self.playImage, {alpha=0}, "out-quad")
    end)
    
    self.alpha = 0
    self.play.drawRect = false
    self.play.showBorder = false
    self.play.bgColor = {0,0,0,0}
    self.playImage = self.play:addImage("play.png")
    self.playImage.alpha = 1
end

function Menu:draw(dt)
    self.count = (self.count or 0)+dt*3
    if self.count >= 3 then
        self.count = 0
    end
    n = math.floor(self.count)
    local img = game:getAsset(string.format("title%s.png", n))
    self.playImage.source = string.format("play%s.png",n)
    local _w, _h = resizeImage(img, W(), H())
    lg.draw(img, 0, 0, 0, _w, _h)
    
    local r,g,b,a = set_color(0,0,0,self.alpha)
    draw_rect("fill",-W(),-H(),W()*4,H()*4)
    set_color(r,g,b,a)
end



function Menu:draw_before_gooi(dt)
    local HH = H()*2
    
    self.rr = (self.rr or 0) + dt
    local r,g,b,a = set_color(.9, .9, .9)
    draw_rect("fill", -20, -H()*.5, W()+40, H()*3+10)
    
    set_color(.1, .1, .8)
    local n = 30
    for x = 1, HH/n do
        lg.line(-10, -H()*.5+(H()/n)*x, W()+40, -H()*.5+(H()/n)*x)
    end
    
    set_color(.9, .2, .1)
    lg.line(50, -H()*.5, 50, H()*4)
    lg.print(self.diffx or "?", 0,0)
    
    set_color(r,g,b,a)
end


do
    local fontName = true and "course_rep/chalkboard.ttf" --varsity_regular.ttf" or "course_rep/karate.ttf"--wild_words.ttf" or "coingame/seaside_resort.ttf"--nest/potato.otf"--"c"--wild_words.ttf"--""c"
    
    cfont = love.graphics.newFont(fontName)
    font40 = love.graphics.newFont(fontName,H(80))
    font20 = love.graphics.newFont(fontName,H(55))
    font18 = love.graphics.newFont(fontName,H(30))
    font17 = love.graphics.newFont(fontName,H(25))
    font13 = love.graphics.newFont(fontName,H(20))
    font10 = love.graphics.newFont(fontName,H(17))
    font8 = love.graphics.newFont(fontName,H(15))
    font7_5 = love.graphics.newFont(fontName,H(15)-1)
    font7 = love.graphics.newFont(fontName,H(14))
    font5 = love.graphics.newFont(fontName,H(11))
    love.graphics.setFont(font8)
    
    
 
    local fontName ="c"--"nest/potato.otf"
    p_font = love.graphics.newFont(fontName,H(15))
    p_font_13 = love.graphics.newFont(fontName,H(20))
    
    gooi.setStyle({
        bgColor = colors.white, --!{0,0,0},--250/255,1,252/255,1},colors.blue,
        fgColor = getColor("black"),
        showBorder = true,
        borderColor = getColor("black"),
        font = font20,
        mode3d = false,
        borderWidth = 1.5,--love.window.toPixels(2), -- in pixels
        radius = 10
    })
    
    -- gooi.secondBorder = {x=-7, y=0, oneSideX=true}
    
    gooi.desktopMode()
    gooi.roughShapes()
end

scale = 1--592,296
_W, _H = 640,1336,720,1280
_W, _H = 720,1280,296*2/scale,592*2/scale

tw, th = 50, 50
aspect.setGame(_W, _H)
love.window.setMode(1,2)

game = toybox.Game("game")

function game:setup()

    self:setSource("course_rep/assets/%s")

    -- media.load(req("sfx_data"))
    
    self:set_room(Menu)--GameScreen)
end

function game:startGame()
    gooi.components = {}
    self:set_room(GameScreen)
end


local op = love.graphics.print
old_print = op

-- stack shaders?
-- move x in upgrades to top
-- check attack ! Vertical down attacks

local tppt, xppx, yppy, ang, nsx, nsy

local function opp()
   op(tppt, xppx, yppy, ang, nsx, nsy)
end

function love.graphics.print(texty, x, y, ang, sx, sy, ...)
    if NO_DOUBLE_TEXT then
    --    return op(texty, x, y, ang, sy, sx, ...)
    end
    
    if type(texty) ~= "string" then
        texty = tostring(texty)
    end
    
    sx = sx or 1
    sy = sy or 1
    local font = love.graphics.getFont()
    
    for xx = 1, #texty do
        local text = texty:sub(xx,xx)
        local x = x+(xx~=1 and font:getWidth(texty:sub(1,xx-1)) or 0)*sx
        local r,g,b,a = love.graphics.getColor()
        local co = 1
        
        if (r+g+b) == 3 or true then
            co = 0
        end-- co = .5
        
        love.graphics.setColor(co, co, co, a)--getColor(coloyr or "green",a))
    
        local scale = 1.4
        local nsx, nsy = (sx or 1)*scale, (sy or 1)*scale
    
        local diffX = (nsx - (sx or 1))/2
        local diffY = 2--(nsy - (sy or 1))/2
        
        tppt, xppx, yppy, ang, nsx, nsy = text, x-diffX, y-diffY, ang, nsx, nsy
        l, e = pcall(opp)
        if type(e) == "string" then
            log(e..": " ..inspect(text,3))
        end
        gg,bb,aa=g,b,a
        --op(text, x-diffX, y-diffY, ang, nsx, nsy, ...)
        
        love.graphics.setColor(r,g,b,a)
        old_print(text, x, y, ang, sx, sy, ...)
    end
end


return game