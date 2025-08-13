VERSION = "1.2.H"




local mask_shader = love.graphics.newShader[[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgba == vec4(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }  if (Texel(texture, texture_coords).rgb == vec3(1.0)) {
         // a discarded pixel wont be applied as the stencil.
         // discard;
      }
      return vec4(1.0);
   }
]]

-- choose:add
-- vertex shader

function lendir_x(s, ang)
    return s*math.cos(ang)
end

function lendir_y(s, ang)
    return s*-math.sin(ang)
end

colors.darklime = {93/255, 226/255, 167/255}
colors.darkdarklime = {93/255*.7, 226/255*.7, 167/255*.7}
colors.lighterlime = {93/255*1.1, 226/255*1.0, 167/255}
local e_url = ""


-- honeycomb backend server
API_URL = "https://love2d-honeycomb-server.onrender.com" -- "http://localhost:3000"

WHATSAPP_CHAT_URL = "https://chat.whatsapp.com/LKSy7tdmT8K5eBJWRGRZPj"

GAME_ID = "dev_23af70886adb4dd6b6005f3dd2c1bfb9"

--TEST IDS
SCOREBOARD_ID = 24460
ENERGYBOARD_ID = 24510
WEEKLY_SCOREBOARD_ID = 0

-- REAL IDS
SCOREBOARD_ID = 25251--24719
ENERGYBOARD_ID = 24720
WEEKLY_SCOREBOARD_ID = 24718

scoreboard = lootlocker(GAME_ID, SCOREBOARD_ID)
energyboard = lootlocker(GAME_ID, ENERGYBOARD_ID)
weeklyScoreboard = lootlocker(GAME_ID, WEEKLY_SCOREBOARD_ID)

STATS_COLOR = {.368, .47, .95}

SIGNS = 7
MAX_SCORE = 55 -- 100

    local h = H()*.1
    local w = 500 or W()*nw

function req(n)
    return require(string.format("course_rep/%s",n))
end

Network = req "network"

Menu2 = toybox.Room("Menu2")

req "wallet"

tex = require "course_rep/perspective"

local function greyDraw(self)
    local r,g,b,a = set_color(0,0,0,self.cover_alpha)
    draw_rect("fill",-W(),-H(),W()*4,H()*4)
    set_color(r,g,b,a)
end

function playGooiSound(sound, ...)
    toybox.room:play_sound(sound or "click", ...)
end

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
    local extra = 4--(toybox.room.stats[dat.stat]<=0 and 0) or (not toybox.room.statsButtons[dat.stat].failed and (5+2)) or 0
    local val = (toybox.room.stats[dat.stat]+extra)/(MAX_SCORE+12)
    if toybox.room.stats[dat.stat] >= MAX_SCORE*.9 then
        -- val = .85
    end
    
    lg.stencil(maskStencil,"replace", 1)
    lg.setStencilTest("greater", 0)
     
    local r, g, b, a = set_color(getColor(nil_STATS_COLOR or dat.parent.color or "blue"))
    draw_rect("fill", x, y+h-h*val, w, h*val)
    set_color(0,0,0,1)
    local l = lg.getLineWidth()
    lg.setLineWidth(4)
    lg.line(x, y+h-h*val, x+w, y+h-h*val)
    
    set_color(r, g, b, a)
    lg.setStencilTest()
    
    local val = toybox.room.statsAffected[dat.stat]
    if val then
        local extra = 0
        val = val+extra--gameov
        set_color(getColor(STATS_COLOR or dat.parent.color or "blue",toybox.room.label2.fgColor[4]))
        local r = lume.min(10*(20/15), lume.max(8, 10*val/15))
        lg.circle("fill", x+w/2-r/2, y+h+10+5, r)
        lg.setLineWidth(3)
        set_color(0,0,0,toybox.room.label2.fgColor[4])
        lg.circle("line", x+w/2-r/2, y+h+10+5, r)
        set_color(r, g, b, a)
    end
    
    lg.setLineWidth(l)
end


local quitTexts = {
    "You wan dropout?",
    "Do you want to dropout?",
}

local unlockTexts = {
    "You &colors.gold unlocked ~ a new character!",
    "A new character is &colors.gold unlocked!",
    "Your &colors.gold total increased!",
    "You &colors.gold unlocked ~ new dialog!",
    "Decisions are now &colors.gold more valuable!",
}

AskForPlayerDetails = function(self)
    self = self or toybox.room
    
    if true then
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 13,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 7x3"
        }):
            setColspan(1,1,3):
            setColspan(2,1,3):
            setColspan(4,1,3):
            setColspan(5,1,3):
            setColspan(3,1,3):
            setColspan(6,1,3):
            setColspan(7,1,3):
        setOpaque(true)
        
        local img = panel:addImage("resultSlipUI.png")
        img.offset_y = 10
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        local label = gooi.newLabel({text="\n \n Enter details", font=mario_font18, instant = true}):center()
        panel:add(label)
        
        local label2 = gooi.newLabel({text="", font=mario_font18, instant = true}):center()
        panel:add(label2)
        
        
        local canFinish, noButton = false
        local function allowFinish()
            if canFinish then
                return
            end
            
            canFinish = true
            noButton.enabled = true
            noButton.bgColor = colors.darkdarklime
            noButton:shake(15,.2,15)
        end
        
        local function refreshText(t)
            if t.refreshed then
                return
            end
            
            t.refreshed = true
            t:setText("")
            t:shake(15, .3, 15)
            
            t:onText(allowFinish)
        end
        
        local textInput = gooi.newText({text="enter name"}):setFont(mario_font13):setText("Enter Name")
        textInput.events.p = refreshText
        textInput.insideColor = {1,1,1,1}
        panel:add(textInput)
        
        
        local gender = gooi.newLabel({text="#Select your @real ~ # gender", font=mario_font17, instant = true}):center()
        panel:add(gender)
        
        local function selectFemaleGender(n)
            gdata.gender = "female"
            n:shake(15, .3, 15)
            self:play_sound("boing")
        end
        local function selectMaleGender(n)
            gdata.gender = "male"
            n:shake(15, .3, 15)
            self:play_sound("chest_break")
        end
        
        local f = mario_font13
        local maleRadio = gooi.newRadio({text="male", radioGroup="gender"}):onSelected(selectMaleGender):setFont(f)
        maleRadio.fillColor = colors.darkdarklime
        local femaleRadio = gooi.newRadio({text="female", radioGroup="gender"}):onSelected(selectFemaleGender):setFont(f):select()
        femaleRadio.fillColor = colors.orange
        panel:add(maleRadio)--,4,1)
        panel:add(femaleRadio)--,5,1)
        
        noButton = gooi.newButton({text="DONE", font=mario_font18})
        noButton.borderWidth = 7
        panel:add(noButton)--,6,2)
        
        self.egP = panel
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
            self:play_sound("bell")
            game:printErrorMessage(string.format("Welcome, @%s", gdata.name), colors.darklime)
        end
        
        local function no()
            if not canFinish then return end
            
            if not noButton.sure then
                noButton:setText("YOU SURE?")
                self:play_sound("spring")
                noButton.sure = true
                noButton:shake(15, .4, 15)
                self.camera:shake(15,.3,15)
                noButton.bgColor = colors.darklime
                return
            end
            
            self.egP = nil
            
            gdata.name = textInput:getText()
            
            for x = 1, 2 do
            self:play_sound("applause")
            self:play_sound("cheering")
            end
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            
            loadSong(getValue(titleSongs), nil, 2)
            --addGPScore(self, 35, "Extra Credit: &colors.gold %sgp")
        end
        
        noButton:onRelease(no)
        noButton.enabled = false
        
    end
end

NotifyPlayerDonorReward = function(self, helped)
    if true then
        loadSong("champions_league")
        self:play_sound(getValue({"applause", "xbox_levelup"}))
        
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 20,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 4x3"
        }):setColspan(1,1,3):setRowspan(1,1,3):setOpaque(true)
        panel:addImage("resultSlipUI.png")
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        self.egP = panel
        
        local label = gooi.newLabel({text="", font=mario_font18, instant = true}):left()
        panel:add(label)
        
        local noButton = gooi.newButton({text="CLAIM", font=mario_font18})
        noButton.borderWidth = 7
        panel:add(noButton,4,2)
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
            self.egP = nil
        end
        
        local reward = math.floor(math.random(10,50)*gdata.level*.5)
        local rewardText = string.format("You earned &colors.orange %s GP", reward)
        
        local unlockText = getValue(unlockTexts)
        
        local function no()
            self:play_sound("hit_1")
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            
            if unlockText == unlockTexts[1] or unlockText == unlockTexts[2] then--or true then
                game:unlockCharacter()
            end
            
            addGPScore(self, reward, "Extra Credit: %sgp")
            game:saveData()
        end
        
        noButton:onRelease(no)
        noButton.enabled = false
        
       
        local function sh()
            self.camera:shake(15, .4, 15)
            panel:shake(10,.3,10)
            label:shake(10,.3,10)
            self:play_sound("explosion")
            
            for x = 1,3 do
                label.texty:update(1/30)
            end
        end
        
        label:center()
        
        local helpedText = "Your &colors.darklime #Energy Donation helped &STATS_COLOR "
        local function text1()
            sh()
            label:setText(string.format(
[[%s %s ~]], helpedText, helped, rewardText, unlockText))

        end
        
        local function text2()
            
            label:setText(string.format(
[[%s %s ~

%s]], helpedText, helped, rewardText, unlockText))
            sh()
        end
        
        local function text3()
            
            label:setText(string.format(
[[%s %s ~

%s

%s]], helpedText, helped, rewardText, unlockText))
            sh()
        end
        
        local function button1()
            noButton.enabled = true
            sh()
        end
        
        local t = .9
        local extra = time+.2
        self:after(t+extra, text1);
        self:after(t*2+extra, text2);
        self:after(t*3+extra, text3);
        self:after(t*4+extra+.3, button1)
    end
end


local GameScreen = toybox.Room("GameScreen")

function GameScreen:showRewards(energyReward, funct)
    if true then
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 20,
            -- paddingY = 20,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 4x3"
        })
        -- panel.paddingY = 20
        panel:setColspan(1,1,3):setRowspan(1,1,3):setOpaque(true)
        panel:addImage("resultSlipUI.png")
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        local label = gooi.newLabel({text="", font=mario_font18, instant = true}):left()
        -- label.yOffset = 4
        panel:add(label)
        
        local noButton = gooi.newButton({text="CLAIM", font=mario_font18})
        noButton.borderWidth = 7
        panel:add(noButton,4,2)
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
        end
        
        local energyAmount = energyReward
        
        
        local unlockText = getValue(unlockTexts)
        
        local function no()
            gdata.energy = gdata.energy + energyAmount
            self:play_sound("slap")
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            
            if unlockText == unlockTexts[1] or unlockText == unlockTexts[2] or true then
                game:unlockCharacter()
            end
        
            if funct then
                if self.award then
                    local time = 1.3
                    self:after(.7, self.award)
                    self:after(time+1, funct)
                end
            end
            
            game:saveData()
        end
        noButton:onRelease(no)
        noButton.enabled = false
        
        local energyReward = string.format("You recieved &colors.darklime X%s energy!~", energyReward)
        
        local function sh()
            self.camera:shake(15, .4, 15)
            self:play_sound("explosion")
            
            panel:shake(10,.3,10)
            label:shake(10,.3,10)
            
            for x = 1,3 do
                label.texty:update(1/30)
            end
        end
        
        local function text1()
            sh()
            label:setText(string.format(
[[You are now @ Level %s ~]], gdata.level, energyReward, unlockText))

        end
        
        local function text2()
            
            label:setText(string.format(
[[You are now @ Level %s ~

%s]], gdata.level, energyReward, unlockText))
            sh()
        end
        
        local function text3()
            
            label:setText(string.format(
[[You are now @ Level %s ~
 
%s
 
%s]], gdata.level, energyReward, unlockText))
            sh()
        end
        
        local function button1()
            noButton.enabled = true
            sh()
        end
        
        local t = .9
        local extra = time+.2
        self:after(t+extra, text1);
        self:after(t*2+extra, text2);
        self:after(t*3+extra, text3);
        self:after(t*4+extra+1, button1)
        
    end
end

local function warnSlowdown(self)
    do
        self:play_sound("spongebob_fail")
        
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 5,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 4x3"
        }):setColspan(1,1,3):setRowspan(1,1,3):setOpaque(true)
        panel:addImage("resultSlipUI.png")
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        local label = gooi.newLabel({text=
[[ 
@ Slow down! ~
 
And take the time to view the consequences #to your choices...
]]})
        panel:add(label)
        label.yOffset = 15
        
        local noButton = gooi.newButton({text=""})
        noButton:addImage("yes.png")
        noButton.onlyImage = true
        panel:add(noButton, 4, 2)
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
            self.quit = nil
            self.egP = nil
            game.online = false
            game.scoreCoverAlpha = 0
        end
        
        local function no()
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            playGooiSound()
            
            self:play_sound("bell")
        end
        
        noButton:onRelease(no)
        
        self.quit = panel
    end
end

function GameScreen:keyreleased(k)
    if k and not self.quit then --return warnSlowdown(self) and self:showRewards(3) else
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 20,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 4x3"
        }):setColspan(1,1,3):setRowspan(1,1,3):setOpaque(true)
        panel:addImage("resultSlipUI.png")
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        local label = gooi.newLabel({text=getValue(quitTexts)})
        panel:add(label)
        
        local noButton = gooi.newButton({text=""})
        noButton:addImage("no.png")
        noButton.onlyImage = true
        panel:add(noButton)
        
        local yesButton = gooi.newButton({text=""})
        yesButton:addImage("yes.png")
        yesButton.onlyImage = true
        panel:add(yesButton,4,3)
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
            self.quit = nil
            self.egP = nil
            game.online = false
            game.scoreCoverAlpha = 0
        end
        
        local function no()
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            playGooiSound()
        end
        
        noButton:onRelease(no)
        
        
        local function yes()
            local function switch()
                gooi.components = {}
                game:set_room(Menu2)
            end
            playGooiSound()
            self:tween(.3, panel, {cover_alpha=1.1}, "out-quad", switch)
        end
        
        yesButton:onRelease(yes)
        
        
        self.quit = panel
    end
end

nw = .5
function GameScreen:setup()
    self:activate_gooi()
    
    gdata.gamePlayed = true
        
    loadSong(getValue(gameSongs))
    
    local w = W()*.99
    local h = H()*.1
    
    self.statsAffected = {}
    
    local icons = {"church","brain","popularity","coin"}
    local stats = {
        church = {
            icon = "cross",
            color = "brown",
            name = "church"
        },
        brain = {
            icon = "brain",
            color = "pink",
            name = "brain"
        },
        popularity = {
            icon = "popularity",
            color = "skyblue",
            name = "popularity"
        },
        coin = {
            icon = "coin",
            color = "gold",
            name = "coin"
        }
    }
    
    self.stats = {
        church = math.random(10,40),
        brain = math.random(10, 40),
        popularity = math.random(10, 40),
        coin = math.random(5, 45)
    }
    
    local nums = {1,2,3,4}
    local time2
    self.statsPanel = gooi.newPanel({padding=15, w = w, h = h, x = W()/2-w/2, y = 4, layout = "grid 1x4"})
    self.statsButtons = {}
    for x = 1, 4 do
        local bb = gooi.newLabel({text=""})
        local b = gooi.newButton({text=""})
        self.statsPanel:add(bb)
        bb.h = bb.w
        local i = b:addImage(string.format("panels/%s.png", lume.eliminate(nums)))
        i.offmset_x = -50
        i.offiiset_y = -50
        i.w = 140+20
        i.h = 140+20
        i.draw = drawBar or er()
        i.parent = b
        i.stat = icons[x]
        
        local stat = stats[icons[x]]
        
        b.color = lume.copy(STATS_COLOR or getColor(stat.color))
        b.ogColor = lume.copy(b.color)
        
        local i = b:addImage(string.format("icons/%s.png", stat.icon))
        i.offset_x = 10
        i.offset_y = 10
        i.w = 140+0
        i.h = 140+0
        
        b.drawRect = false
        b.showBorder = false
        b.noStencil = true
        b.bgColor = {0,0,0,0}
        
        b.img = i
        b.img.color = {1,1,1,1}
        
        b.x, b.y, b.w, b.h = bb.x, bb.y, bb.w, bb.h
        
        self.statsButtons[icons[x]] = b
        
        b.x = x<3 and math.random(-W()/4,W()/4) or math.random(W()/2, W()+10)
        b.y = -200-b.h
        b.outx = b.x
        b.outy = b.y
        b.angle = getValue({300, 180, 270,40})--math.random(1, 360*2)
        local time = .71*math.random(5,10)*.1
        time2 = lume.max(time2 or -1000, time)+-.1
        self:tween(time, b, {x=bb.x, y=bb.y}, "in-quad")
        self:tween(time, b, {angle=0}, "in-quad")
        i.alpha = 0
        self:tween(time, i, {alpha=1}, "out-quad")
    end
    
    self:play_sound("shuffle")
    
    --time2 = .8--time2*.89
    
    gooi.removeComponent(self.statsPanel)
    
    
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
    
    local func = function(n)
        return n.isSign
    end
    
    local function spawnSign()
        local count = 0
        local s, w, x, y
        while count < 30 do
            s = math.random(7, 14)/10
            w = 100*s
            x = math.random(0, W())
            y = math.random(0, H())
        
            local v, len = self.world:queryRect(x, y, w, w, func)
            
            if len <= 0 then
                break
            end
            
            count = count + 1
        end
        
        local obj = toybox.NewBaseObject({
            x = x, y = y,
            w = w, h = w,
            solid = false,
            static = false
        })
        obj:center()
        obj.angle = math.random(-350, 340)
        -- obj.debug = true
        obj.source = string.format("signs/sign_%s.png", math.random(SIGNS))
        obj.image_alpha = 0
        obj.color = {0, .0, .65}
        obj.isSign = true
        self:tween(math.random(10, 30), obj, {image_alpha=math.random(3,6)/10}, "in-quad")
    end
    
    spawnSign()
    self.draw_signs = self.__draw_instances
    self.__draw_instances = null  -- before_gooi
    
    self:every({15,5,5,5,3,3,7,7,7,10,30}, spawnSign)
        
    choose.onlyImage = true
    choose.showBorder = false
    choose.noStencil = true
    gooi.drawComponent(choose)
    gooi.removeComponent(choose)
    
    local startD = self:getNextDialog()
    local startC = self:getCharacterForDialog(startD)
    
    do--for name, char in pairs(characters) do
        name = startC
        game:getAsset(string.format("people/%s/body.png", name))
        game:getAsset(string.format("people/%s/face.png", name))
        game:getAsset(string.format("people/%s/head.png", name))
    end
    
    local nnxt = {
                    isNarrator = true,
                    text = "Don't let any of the bars above \n(faith, #grade, ~ @popularity ~ and # money ~ ) \n get too low...",--n:draw
                    setStats = {
                        popularity = 5,
                        coin = 5,
                        brain = 5,
                        church = 5
                    },
                    next = {
                        isNarrator = true,
                        text = "....or @too high...",
                        setStats = {
                            popularity = 90,
                            coin = 90,
                            brain = 90,
                            church = 90
                        },
                        next = {
                            --isNarrator = true,
                            --text = "so you ckeep your job as course rep.",
                
                            -- next = {
                                isNarrator = true,
                                text = "If they do, you get relieved of your duties and @lose.",
                                setStats = {
                                    popularity = {30,50},
                                    coin = {20,50},
                                    brain = {20,50},
                                    church = {30,45}
                                },
                                
                                next = {
                                    isNarrator = true,
                                    text = "Make sure to read the decisions...\nAnd Beware...",
                                    yes = {text="?"},
                                    no = {text="?"},
                                    next = {
                                        isNarrator = true,
                                        text = "...They'll drive you crazy...",
                                        no = {text="what!?"},
                                        yes = {text="who??"}
                                    }
                            -- }
                            }
                        }
                    }
                }
                
    self:after(time2, function()
        self:loadNewDialog(not gdata.seenCardRules and {
            isNarrator = true,
            text = "Hold and slowly Swipe this card left or right to make decisions...",
            yes = {text="okay..."},
            no = {text="seems easy"},
            next = {
                isNarrator = true,
                text = "You are the\n Course Rep. \nYour decisions have consequences.",
                yes = {text="That's nice", next={
                    text = "Or so it seems...",
                    isNarrator = true,
                    next = nnxt
                }},
                no = {text="Nooo. I don,t want", next={
                    text = "well! too bad.",
                    isNarrator = true,
                    next = nnxt
                }},
                --next = 
            }
        })--startD)--, startC)
        
        gdata.seenCardRules = true
    end)
    
    
    game.startedGameOnce = true
        
    self.timer:every({1,1.5,1.3,2}, function()
        local f = self.face
        if not f then
            return
        end
        
        self.face.times = (self.face.times or 0)+1
        
        local oox, ooy = self.face.offset_x, self.face.offset_y
        local dx = math.random(-10,10)/10
        local dy = math.random(-10,self.cap and 3 or 10)/10
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
    
    local f = kb_font19
    local w = f:getWidth("Week 1: 500pt")
    local h = f:getHeight()*1.0
    
    self.scoreLabel = gooi.newLabel({text="Week 1: 50pt", font=f, w=w, h=h, x=10 or W()-w*1.5, y=H()-h*2+20})
    self.scoreLabel.texty.noWordwrap = true
    self.scoreLabel.angle = 3
    self.scoreLabel.fgColor = {0,0,0,1}
    self.scoreLabel.alpha = 0
    self.scoreLabel.ogy = self.scoreLabel.y
    self.scoreLabel.y = H()*h*3
    self:tween_in_ui(self.scoreLabel, .75)
    self.scoreShake = gooi.newLabel({text="",x=0,y=0,w=10,h=10})
    
    self.currentTime = 1
    self.currentWeek = 1
    self.currentMonth = 0
    self.currentYear = 0
    
    self.currentScore = 0
    self.scoreMultiplier = 10
    self.scorePoints = {1, 1.5, 1}
    
    self.oldYear = 0
    self.oldMonth = 0
    
    self:addScore(10)
end

function GameScreen:addScore(val)
    self.scoreShake:shake(10,.6,30)
    
    self.currentTime = self.currentTime+1
    self.currentWeek = math.floor(self.currentTime/4)+1
    self.currentMonth = math.floor(self.currentWeek/4)
    self.currentYear = math.floor(self.currentMonth/12)
    
    local val = (val or math.floor(self.scoreMultiplier*getValue(self.scorePoints)))
    self.currentScore = self.currentScore + val
    
    if self.oldYear ~= self.currentYear then
        self.scoreMultiplier = self.scoreMultiplier + getValue({5, 5, 5, 2, 10})
    
    elseif self.oldMonth ~= self.currentMonth then
        self.scoreMultiplier = self.scoreMultiplier + getValue({5, 5, 10, 10, 20})
    end
    
    local oldm = self.oldMonth
    
    self.oldYear = self.currentYear
    self.oldMonth = self.currentMonth
    
    local timeText
    if self.currentYear > 0 then
        timeText = string.format("Year %s", self.currentYear)
    elseif self.currentMonth > 0  and oldm~=self.currentMonth then
        timeText = string.format("Month %s", self.currentMonth)
    else
        timeText = string.format("Week %s", self.currentWeek)
    end
    
    timeText = string.format("%s: %spt", timeText, self.currentScore)
    
    self.scoreLabel:setText(timeText)
    
    local sl = self.scoreLabel
    
    local nLabel = gooi.newLabel({w=sl.w, h=sl.h, x=sl.x, y=sl.y, font=mario_font18 or sl.font})
    nLabel.texty.scale = .7
    nLabel:setText(string.format("+%s", val))
    nLabel.fgColor = {0,0,0,1}
    local nn = .75
    self:tween(nn, nLabel, {y=nLabel.y-70, fgColor={0,0,0,0}})
    self:tween(nn, nLabel.texty, {scale=2})
    
    
end

local char_keys
function GameScreen:getCharacterForDialog(data)
    char_keys = char_keys or lume.keys(characters)
    local keys = lume.copy(char_keys)
    
    local char
    local yes
    local none
    
    log("getting chars")
    
    while true do
        if #keys <= 0 then
            log("WARNING: NO CHARACTER FOUND FOR "..inspect(data, 1))
            none = true
            break
        end
        
        char = lume.eliminate(keys)
        local dat = characters[char]
        
        yes = true
        
        data.traits = data.traits or {}
        
        if (dat.locked and not gdata.unlocked[char]) or (dat.traits.isSpecial and not data.traits.isSpecial) then
            log(string.format("%s locked, can't use", char))
            yes = false
        end
        
        -- cows should only do cow things
        if dat.traits.cow and not data.traits.cow then
            yes = false
        end
        
        if yes then
            for trait, value in pairs(data.traits or {}) do
                if (value and dat.traits[trait]) or (not value and not dat.traits[trait]) then
                    -- pass
                else--not (dat.traits[trait] and value or not value)  then
                    yes = false
                    break
                end
            end
        end
        
        if yes then
            break
        end
    end
    
    -- if not yes then error(inspect(data.traits)) end
    
    self.none = none
    
    return char
end

function GameScreen:changeStats(stats, set)
    local saved
    
    for x, v in pairs(stats) do
        if not self.stats[x] then error(x) end
        
        local val = set and (MAX_SCORE+1)*(v/100) or lume.clamp(self.stats[x]+v,0,MAX_SCORE+1)
        
        if val <= 0 then
            val = -4
        elseif val > MAX_SCORE then
            val = MAX_SCORE + 1 + 12
        end
        
        if val <= 0 or val > MAX_SCORE then
            -- log(x.." over "..val..","..self.stats[x])
            if (val<=0 or true) and 
            self.savedFromFailure ~= false and
            (math.abs(self.stats[x]-val)>=4) and 
            (
            
                (not self.savedFromFailure and math.abs(self.stats[x]-val)>=5) or
                math.random() < .4
                
            ) then
                saved = true
                
                val = val > MAX_SCORE and lume.max(self.stats[x]+1, math.random(45,55)) or lume.min(self.stats[x]-1, math.random(3,6))
                -- log("saved Waiting for save "..val)
            else
                -- log("yeahx")
                self:gameover(x, val>0)
            end
        end
        
        local flash = colors.red
        if v > 0 then
            flash = colors.darkdarklime
        end
        
        local b = self.statsButtons[x]
        
        if b.tweener then
            self.timer:cancel(b.tweener)
            b.tweener = nil
        end
        
        b.tweener = self:tween(.4, b.color, flash, "in-quad")
        
        local function func()
            if b.tweener then
                self.timer:cancel(b.tweener)
                b.tweener = nil
            end
            b.tweener = self:tween(.85, b.color, b.ogColor, "out-quad")
        end
        
        self:after(.6, func)
        
        tt = lume.max(1, 1*math.abs(v/15))
        self:tween(.8*tt, self.stats, {[x]=val}, "out-quad")
        -- log(x.." to "..val)
        
    end
    
    if saved then
        self.savedFromFailure = (self.savedFromFailure or math.random(1,3)) - 1
        if self.savedFromFailure <= 0 then
            self.savedFromFailure = false
        end
    end
    --self:gameover("church")
end

function GameScreen:gameover(stat, high)
    if self.lost then
        return
    end
    self.lost = true
    
    local b = self.statsButtons[stat]
    b.failed = true
    
    if stat ~= "popularity" then
        self:tween(.4, b.img.color, colors.red, "in-quad")
    else
        b.img.source = "icons/popularity_down.png"
    end
    
    if high then
        self:tween(.8, b.color, colors.red, "in-quad")
    end
    
    self.nextLoad = {getValue(losses[stat][high and "high" or "low"]), "You were relieved of your duties..."}
end


function addGPScore(m2, score, templateText, gameover)
    game.scoreSubmitted = false
    
    if gameover then
    local self = m2
    local w = W()*.3*1.5
    self.awardLabel = gooi.newButton({
        w = w, h = w, x = W()-w-10+w/4, y = w+w-w-w/2
    }):setText("")
    -- self.awardLabel:addImage("ratingPanel.png")
    self.awardLabel.onlyImage = true
    self.awardLabel.showBorder = false
    local aw = self.awardLabel
    
    self.award = nil
    
    local function award()
        local am = score or 0
        local rank
        local n = 55
        
        if     am <=   15+n then rank = "f"
        elseif am <=   50+n then rank = "e"
        elseif am <=  150+n then rank = "d"
        elseif am <=  270+n then rank = "c"
        elseif am <=  500+n then rank = "b"
        else                     rank = "a"
        end
        
        local rating = gooi.newButton({x = W()+aw.w, y = aw.y-H()/4, w = 1, h = 1}):setText("")
        rating.onlyImage = true
        self.rating = rating
        local rimg = rating:addImage(string.format("rankings/%s.png", rank))
        local function endFunc()
            if not self.shakenAW then
                m2:shake(15, .16, 15)
                self:play_sound("whack")
                self.shakenAW = true
            end
            rimg.color = {1,1,1,1}
            self:tween(4, rimg.color, {1,1,1,0}, "out-quad")
        end
        self:tween(.6, rating, {x=aw.x, y=aw.y, w=aw.w, h=aw.h}, "in-quad", endFunc)
        self.award = nil
    
    end
    
    self.award = award--scores and award or null
    end
    
    
    
    if true then
        m2.currentScore = score
        m2.scoreLabel = m2.scoreLabel
        m2.scoreShake = m2.scoreShake
        
        gdata.highscore = lume.max(gdata.highscore or 0, m2.currentScore)
        gdata.lastScore = m2.currentScore
            
        if not m2.scoreLabel then
            local f = kb_font19
            local w = f:getWidth("Week 1: 500pt")
            local h = f:getHeight()*1.0
            m2.scoreLabel = gooi.newLabel({text="...", font=f, w=w, h=h, x=10 or W()-w*1.5, y=H()-h*2+20})
            m2.scoreLabel.texty.noWordwrap = true
            m2.scoreLabel.angle = 3
            m2.scoreLabel.fgColor = lume.copy(colors.black)
            m2.scoreLabel.fgColor[4] = 1
            m2.scoreLabel.alpha = 0
            m2.scoreLabel.ogy = m2.scoreLabel.y
            m2.scoreLabel.y = H()*h*3
            m2:tween_in_ui(m2.scoreLabel, .29)
            m2.scoreShake = m2.scoreShake or gooi.newLabel({text="",x=0,y=0,w=10,h=10})
        end
                
        m2:after(.3, function()
    
        local sl = m2.scoreLabel
        local f = mario_font25
        sl.font = f
        sl.texty.font = f
        sl:setText(sl.text)
        m2.scoreShake:shake(14, .4, 35)
        
        --[[m2:tween(2, sl.texty, {scale=12}, "out-quad", function() m2:tween(2, sl.texty, {scale=3}, "in-quad", function() m2.camera:shake(15, .2, 15) end) end) -- isbig
        ]]
        local tiltFunc = function()
            m2.camera:shake(25,.35,25)
            m2:play_sound("hit_1")
            sl.noTilt = nil
        end
        
        local function submitScoreEnd()
            
            if scoreboard:submitScore(gdata.name, gdata.totalGP, nil, {timePlayed=gdata.playTime, gamesPlayed=gdata.totalPlays}) and weeklyScoreboard:submitScore(gdata.name, score or m2.currentScore or 10) then
                game.scoreSubmitted = true
            else
                game:printErrorMessage("No Network, Submission failed?", {.7,.7,.7,.7})
                m2:play_sound("negative")
                game.scoreSubmitted = false
                gdata.weekly = score
            end
            
            local function func()
                game.online = false
                game.onlineText = nil
            end
            
            game.timer:tween(.2, game, {scoreCoverAlpha=0}, "out-quad", func)
        end
        
        sl.noTilt = true
        m2:tween(.75, sl, {x=W()/2-sl.w/2, y=90, angle=360}, "in-quad", tiltFunc)
        m2:play_sound("miss_1")
        m2:tween(.5, m2.nameText.fgColor, {[4]=0}, "out-quad")
        
        local function submitScore()
            game.onlineText = "submitting score online..."
            game.timer:tween(.5, game, {scoreCoverAlpha=1}, "in-quad",submitScoreEnd)
            game.online = true
            
        end
        
        m2.draw_gooi_with_camera = true
        
        m2:after(1.5, function()
            
            local function updateText()
                local timeText = string.format(templateText, m2.currentScore, math.random(100))
                sl:setText(timeText)
            end
            
            local tag, tag2 = m2:every(.1, updateText)
            
            local div = m2.currentScore<20 and 4 or m2.currentScore>100 and 10 or 5 
            
            local t = m2.currentScore/div
            local v = lume.min(m2.currentScore/div, 20)
            local chunk = math.floor(m2.currentScore/v)
            
            --for x = 1, lume.min(m2.currentScore/10, 20) do
            
            local func2l
            
            local pitches = {1.1, 1.2, .7, .9, .8, 1, 1}
            
            gdata.totalGP = gdata.totalGP + m2.currentScore
            
            local function chunkIt()
                --self:tween()
                m2.currentScore = lume.max(0, m2.currentScore - chunk)
                m2.scoreShake:shake(15,.3,30)
                m2:shake(15, .2, 15)
                m2:play_sound("bell", math.random(900,1100)/1000)--getValue(pitches))--string.format("stone_%s", math.random(1,8)))
                if m2.currentScore <= 0 then
                    updateText()
                    
                    local function outTag()
                        m2.timer:cancel(tag)
                        gooi.removeComponent(sl)
                        m2.scoreLabel = nil
                    end
                    
                    m2.timer:cancel(tag2)
                    m2:after(1, function()
                        m2.scoreShake:shake(10,.3,30)
                        m2:play_sound("throw")
                        m2:tween(.55, sl, {y=-sl.h*2, fgColor={0,0,0,0}}, "out-quad")
                        m2:tween(.65, m2.nameText.fgColor, {[4]=1}, "in-quad", outTag)
                        m2:after(.70, not func2l and m2.award or null)
                        m2:after(m2.award and 1.7 or .7, not func2l and submitScore or null)
                    end)
                end
            end
            
            local time = lume.min(.35, 2/v)
            tag2 = m2:every(time, chunkIt)
            
            local gd = gdata.levelExp     

            Honeycomb.add_xp(m2.currentScore)

            gdata.levelExp = gdata.levelExp + m2.currentScore
            local l = lume.min(1, gdata.levelExp/LEVEL_EXP())*100
        
            local soundPlayed
            if gdata.levelExp >= LEVEL_EXP() then
                func2l = true
                gdata.levelExp = gdata.levelExp - LEVEL_EXP()
                
                if math.random() > .4 then
                    m2:play_sound("let_him_cook")
                    soundPlayed = true
                end
            end
            
            --progression >
            
            func2 = func2l and function()
                gdata.level = gdata.level+1
                gdata.levelText = getValue(LEVEL_TEXTS[gdata.level]) or "Jesus is Lord @ALWAYS"
                
                local l = lume.min(1, lume.max(.05, gdata.levelExp/LEVEL_EXP()))*100
                if gdata.levelExp >= LEVEL_EXP() then
                    gdata.levelExp = gdata.levelExp - LEVEL_EXP()
                end
                       
                m2.freeze = .45
                
                if not soundPlayed then
                    loadSong("champions_league")
                end
                
                m2:play_sound(getValue({"applause", "xbox_levelup"}))
                
                
                log("Level UP!! "..gdata.level)
                m2.levelText:shake(15,2,20)
                m2.camera:shake(24,1.3,24)
                
                local function reward()
                    m2:play_sound("levelup_achievement")
                    GameScreen.showRewards(m2, gdata.energy>1 and 1 or math.random(1,3), submitScore)--gdata.level+1)
                end
                
                m2:after(.3, reward)
                
                -- m2.levelText:setText(string.format("Level %s", gdata.level))
                
                m2.nameText:setText(string.format("LEVEL %s: %s", gdata.level, gdata.levelText))

                game:saveData()
        
                m2.bar.progression = 0
                m2:tween(.3, m2.bar, {progression = l+1}, "in-quad")
            end or function()
                game:saveData()
            end
            
            local function func()
                m2:after(.2, func2)
            end
            
            m2:tween(time*(m2.currentScore/chunk), m2.bar, {progression=l+1}, "in-quad", func2)
        end)
        end)
    end
end

function GameScreen:getScorePopup()
    if 1 then
        local m2 = Menu2()
        
        gooi.addComponent(self.scoreLabel)
        gooi.addComponent(self.scoreShake)
        
        m2.scoreLabel = self.scoreLabel
        m2.scoreShake = self.scoreShake
        
        
        local currentYear = self.currentYear
        local currentMonth = self.currentMonth
        local currentWeek = self.currentWeek
        
        local timeText
        if currentYear > 0 then
            timeText = string.format("Year %s", currentYear)
        elseif currentMonth > 0 then
            timeText = string.format("Month %s", currentMonth)
        else
            timeText = string.format("Week %s", currentWeek)
        end
    
        timeText = string.format("%s: %sgp", timeText, "%s")
        m2.playAgainSound = true
        addGPScore(m2, self.currentScore, timeText, true)
        
        return game:set_room(m2)
    end
    

    local uw, uh = W()*.7, H()*.45
    local ux, uy = W()/2-uw/2, H()/2-uh/2-100
    self.statsUI = gooi.newLabel({
        x = ux,
        y = -uh,
        w = uw, h = uh,
        font = font40,
        text = "LEVEL 1"
    }):setOpaque(true)
    self.statsUI.yOffset = 65
    self.statsUI.ogy = uy
    local su = self.statsUI
    local img = su:addImage("resultSlipUI.png")
    su.onlyImage = true
    su.showBorder = false
    
    self:tween_in_ui(self.statsUI, .65, "out-quad")
    
    self:after(.65, function() self.labelUI = gooi.newLabel({x=su.x, y=uy, w=uw, h=uh, instant = false,
        text = not "\"If only the invigilator wasn't looking this way...@if only. ~ I for get A1 #steady...\"" or "\"kids these days don't know the struggle...\"",
    })
    self.labelUI.yOffset = 65+font40:getHeight()+10 end)
    
    local rw = 100
    self.retryButton = gooi.newButton({x=su.x+su.w/2-rw/2, y=uy+uh-rw-20, w=rw, h=rw, text=""})
    self.retryButton.onlyImage = true
    
    local rb = self.retryButton:addImage("title/play_up.png")
    rb.alpha = 0
    
    self:after(.7, function()
        self:tween(.5, rb, {alpha=1}, "in-quad")
    
    
    local bw = su.w*.8
    local bh = 50
    local xx = su.x+su.w/2-bw/2
    local yy = su.ogy+su.h-bh-150
    self.bar = toybox.ProgressBar({
        x = xx, y = yy,
        w = bw, h = bh,
        progress = 10,
        --glows = "white",
        totalColor = {1,1,1,0},
        progressColor = colors.yellow
    })
    self.bar:setProgress(1)
    self:every({1,.5,.4,.3,.2,.5},function() self.bar:progress(1) end)
    
    
    local draw_af = self.draw or null
    
    self.draw = function(self, ...)
        if self.bar.progression >= 100 then
            if not self.started then
                self.started = true
                self:after(math.random(2,12)/10, function()
                    game:set_room(Menu)
                end)
            end
            self.bar.progression = 100
        end
    
        self.bar:draw()
        set_color(1,1,1,1)
        
        local bimg = game:getAsset("resultBarUI.png")
        local nn = 15--10
        lg.draw(bimg, self.bar.x-nn, self.bar.y-nn, 0, resizeImage(bimg, self.bar.w+nn*2, self.bar.h+nn*2))
    
        do
    
            local r,g,bb,a = love.graphics.getColor()
        
            local p = love.graphics.getLineWidth()
            local pp = 0--p*4
            love.graphics.setLineWidth(10)
            
            local line = love.graphics.line
        
            love.graphics.setColor(0,0,0)
         
            local b = self.bar
            local bx = b:getLoadedWidth()+b.x
            line(bx, b.y, bx, b.y+b.h)
        
            lg.setLineWidth(p)
            lg.setColor(r,g,bb,a)
        
        end
        return draw_af(self, ...)
    end end)
end

function GameScreen:endGame()

    self:tween(1, self.nameLabel.fgColor, {0,0,0,0}, "out-quad")
    --self.label.fgColor = {0,0,0,1}
    self:tween(.2, self.label, {fgColor={0,0,0,0}}, "out-quad")
    --self:tween(.2, self.scoreLabel, {fgColor={0,0,0,0}}, "out-quad")
    
    for _, b in pairs(self.statsButtons) do
        self:tween(1, b, {x=b.outx, y=b.outy, angle=450}, "out-quad")
    end
    
    for _, s in pairs(self.instances) do
        self:tween(.7, s, {image_alpha=0}, "out-quad")
    end
    
    local function fun()
        self:getScorePopup()
    end
    
    self:after(.4, fun)

end

function GameScreen:getNextDialog()
    self.oldDialogs = self.oldDialogs or {}
    
    local data
    local done = {}
    
    while not data do
        data = getValue(dialogs)
        
        if done[data] then
            data = nil
        end
        
        for i = 0, data and 3 or 0 do
            if self.oldDialogs[#self.oldDialogs-i] == data then
                done[data] = true
                data = nil
                break
            end
        end
    end
    
    return data
end

function GameScreen:loadNewDialog(data, char)
    self.oldDialogs = self.oldDialogs or {}
    
    if self.lost and (not data or not data.isLoss) then
        if not self.nextLoad then
            return
        end
        
        local nx = self.nextLoad
        self.nextLoad = nil
        
        loadSong(getValue(gameOverSongs))
        
        local tro = string.format("sad_trombone_%s", math.random(1,2))
        self:play_sound(getValue(nx[1].sound or {"wahala", "nono_laugh", "spongebob_fail", tro, tro, string.format("sad_trombone_%s", math.random(1,2))}))
        
        return self:loadNewDialog(nx[1], nx[2])
    end
    
    if not data then
        gdata.choices = gdata.choices + 1
        
        self:addScore()
    end
    
    if not gdata.warnedSlow then
        local time = os.time()
        if (time - (self.timeSinceLastChoice or 0)) < 3 then
            self.slowWarn = (self.slowWarn or 0)+1
            if self.slowWarn > 3 then
                local function warnSlow()
                    warnSlowdown(self)
                    gdata.warnedSlow = true
                end
                self:after(.2, warnSlow)
            end
        end
        
        self.timeSinceLastChoice = time
    end
    
    local dataGiven = data and true
    
    data = data or dialogs.exajmWrite or GameScreen.getNextDialog(self)
    
    self.oldDialogs[#self.oldDialogs+1] = data
    
    self.none = nil
    
    local char = char or data.sameCharacter and self.oldChar or not data.isNarrator and (self.isMenu and game.menuChar or self:getCharacterForDialog(data))
    
    
    local charData = characters[char]
    
    if self.none then-- and not dataGivetttn then
        local count = 10
        log("reloading dialog")
        while self.none do
            data = GameScreen.getNextDialog(self)
            char = self:getCharacterForDialog(data)
            count = count - 1
            if count <= 0 then
                log("oof, max reached. Reload failed")
                break
            end
        end
    end
    
    
    local charData = characters[char]
    
    if char and not dataGiven then
        -- so that reloading of characters won't be allowed entering and leaving the menu
        game.menuChar = char
    end
    
    data.tmpStats = {}
    if data.stats then
        for x, i in pairs(data.stats) do
            data.tmpStats[x] = getValue(i)
        end
    end
    
    
    data.tmpSetStats = {}
    if data.setStats then
        for x, i in pairs(data.setStats) do
            data.tmpSetStats[x] = getValue(i)
        end
    end
    
    
    if data.no and data.no.stats then
        data.no.tmpStats = {}
        for x, i in pairs(data.no.stats) do
            data.no.tmpStats[x] = getValue(i)
        end
    end
    
    if data.yes and data.yes.stats then
        data.yes.tmpStats = {}
        for x, i in pairs(data.yes.stats) do
            data.yes.tmpStats[x] = getValue(i)
        end
    end
    
    self.none = nil
    
    self.isNarrator = not char
    self.oldChar = char
    
    local text = getValue(not "Lol, hey there" or data.text or error() or '"Finally some #good food ~ around here for once.","Im really tired. Help me write my report.#please","(They wink at you)","Heya\nloser","Polite arent \nyah","Yosh"}')
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
    
    
    
    local h = H()*.1
    local w = 500 or W()*nw
    
    local ccx, ccy = W()/2-w/2, h+10+((H()-h)/2-(W()*.55)/2)-h+80
    
    local label = gooi.newLabel({
        w=not char and w or ww,
        x=not char and ccx or W()/2-ww/2,
        h=not char and c or w/2,
        y=not char and ccy or y,
        instant=false
    }):setOpaque(false)
    
    
    do
        local h = H()*.1
        local w = 500 or W()*nw
    
        local x, y = W()/2-w/2, h+10+((H()-h)/2-(W()*.55)/2)-h+80
        self.choose = (char and gooi.newButton or gooi.newLabel)({insant=false,text="", x=x, y=y, w=w, h=w})
        self.choose.yOffset = 5--(label2.texty.h*.5)
    end
    
    label.yOffset = 10
    label:setText(text)
    label.ogy = y
    label.y = char and (label.ogy-label2.texty.h+gooi.font:getHeight()) or (label.y+label2.texty.h*.5)
    
    gooi.removeComponent(label2)
    
    -- add display card the front (for graphical drawing)
    local function funcg()
        if not self.quit and not self.egP then
            gooi.removeComponent(self.choose)
            gooi.addComponent(self.choose)
        end
    end
    
    if not self.isMenu then
        -- self:every(1, funcg)
    end
    
    self.label = label
    
    -- self.label:setText(text)
    self.label.ye = self.label.ogy-self.label.texty.h
    
    
    local h = H()*.1
    local w = 500 or W()*nw
    
    local x, y = W()/2-w/2, h+10+((H()-h)/2-(W()*.55)/2)-h+80
    
    self.choose.y = self.choose.y + 80
    self.choose.ogx = self.choose.x
    
    
    self.choose.odraw = self.choose.odraw or self.choose.draw
    self.choose.odrawSpecifics = self.choose.odrawSpecifics or self.choose.drawSpecifics
    if not self.isMenu then
        self.choose.draw = null
        self.choose.drawSpecifics = null
    end
    
    self.choose:onPress(function(r)
        self.touched = true
        self.ox, self.oy = love.mouse.getX(),0
        -- self.rr = -.2
        if self.tweening then
            self.timer:cancel(self.tweening)
            self.tweening = nil
        end
    end):onRelease(function() playGooiSound() end)
    -- self.choose.icon = game:getAsset("face.png")
    
    local byy = 82
    local tmpW = 600
    local i = self.choose:addImage("border.png")
    i.w = tmpW
    i.h = tmpW
    i.offset_x = (i.offset_x or 0) - 50
    i.offset_y = (i.offset_y or 0) - byy
    
    border = i
    
    --[[for name, char in pairs(chars) do
        game:getAsset(string.format("people/%s/body.png", name))
        game:getAsset(string.format("people/%s/body.png", name))
        game:getAsset(string.format("people/%s/body.png", name))
    end]]
    -- data = losses.brain.high[1]
    local name = char--getValue({"steve","xoftest","ella","dumebi","skibi","fresh","beverage","favour","isioma","smith","donatus","kizito"})
    if data.isLoss then
        self.body = self.choose:addImage(data.source)
        self.body.mustUseStencil = true
        self.body.stencilImage = i
        
        if data.pictureIsBig then
            local b = self.body
            local nn = data.pictureIsBig
            b.w = tmpW*nn
            b.h = tmpW*nn
            b.offset_x = -50
            b.offset_y = b.offset_x
        
        end
        
    elseif char then
        self.body = self.choose:addImage(string.format("people/%s/body.png", name))
        self.head = self.choose:addImage(string.format("people/%s/head.png", name))
        self.face = self.choose:addImage(string.format("people/%s/face.png", name))
        
        self.cap  = nil
        local function hat()
            game:getAsset(string.format("people/%s/hat.png", name))
            self.cap = self.choose:addImage(string.format("people/%s/hat.png", name))
        end
        pcall(hat)
        
        self.face.offset_x = 0
        self.face.offset_y = 0
    

    elseif nil then
        local b = self.choose:addImage("border_back.png")
        b.w = tmpW
        b.h = tmpW
        b.offset_x = (b.offset_x or 0) - 50
        b.offset_y = (b.offset_y or 0) - byy
    end
    
    local pics = { self.body, self.head, self.face, self.cap}
    
    
    
    local i = self.choose:addImage(not char and "border.png" or "border_empty.png")
    i.w = tmpW
    i.h = tmpW
    i.offset_x = (i.offset_x or 0) - 50
    i.offset_y = (i.offset_y or 0) - byy
    
    i.shaderf = fshader

    local lb = self.label
    
    local xx, yy = self.choose.x, self.choose.y
    local lxx, lyy = lb.x, lb.y
    self.choose.x = not self.doneBefore and -w*2 or (math.random()>.5 and W()+w or -w)
    self.choose.y = -h
    self.choose.angle = -360
    
    lb.x = self.choose.x
    lb.y = self.choose.y
    lb.angle = self.choose.angle
    
    self:tween(.745, lb, {x=lxx, y=lyy, angle=0}, "out-quad")
    
    self.doneBefore = true
    
    if not char then
        self.choose:setText(text)
        self.label:setText("")
    end
    
    self.noText = getValue(data.no and data.no.text)
    self.yesText = getValue(data.yes and data.yes.text)
    
    self.data = data
    
    self.label2 = gooi.newLabel({text="" or "NO Way #Hosee , ~ even i then still no",
        x = xx,
        y = yy+self.choose.h+20,-10+yy+self.choose.h/2-self.label.h/2,6+20,
        w = (self.choose.w+100)/(self.isMenu and 1 or 1.5),
        h = self.label.h,
        instant = true,-- font=font30--mario_font18
    })
    self.label2.fgColor = {1,1,1,0}--{0,0,0,0}
    
    
    self.nameLabel = gooi.newLabel({text=charData and charData.name or char or "" or "Banana Manana",
        x = xx,
        y = yy+self.choose.h+20,
        w = self.choose.w,
        h = font20:getHeight(),self.label.h,
    })
    self.nameLabel.fgColor = {0,0,0,0}
    
    self:play_sound("playcard")
    
self:after(.1, function()
    local ready = function()
        self.choose.ready = true
        self.shownCard = true
    end
    self.diffx = 0
    
    
    self:tween(.745, self.choose, {x=xx, y=yy, angle=0}, "out-quad", ready)
    
    if char then
        self:tween(.5,i,{w=700,h=700},"in-sine",function()
            self:tween(.5,i,{w=600,h=600},"out-quad")
        end)
        local ii = border
        self:tween(.5,ii,{w=700,h=700},"in-sine",function()
            self:tween(.5,ii,{w=600,h=600},"out-quad")
        end)
        -- self:after(.5, function() error(border.w..","..border.h..","..i.w..","..i.h) end)
    end
    
    local time = 0
    local xScale = 1

    self.xScale = -1
    local ofy = i.offset_y
    self.ix, self.iy = 0,0
    self.iangle = 0
    
    if false then
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
    end
    
    ogiw = i.w
    
    self.choose.preDraw = function(n)
        frontside = game:getAsset(i.source)
        local w = 600
        local xPos = -50 * math.abs(self.xScale)
        local yPos = 0--w/2 - frontside:getHeight()/2
        --i.offset_x = xPos+self.ix+(600-i.w)/2
       -- i.offset_y = ofy+self.iy+(600-i.h)/2
        --i.flipX = self.xScale
       -- assert(border.parent==i.parent)
        --f i.flipX>0 then i.flipX=i.flipX*-1 end
    
        for x, n in ipairs(pics) do
            if not data.pictureIsBig then
                -- n.flipX = i.flipX < 0 and 0 or i.flipX
                n.offsert_x = i.offset_x+50
                n.offsert_y = i.offset_y+byy
                n.w = i.w-100
                n.h = i.h-100
            else
                n.offset_x = data.pictureIsBig == 1 and n.offset_x or 5*(1-data.pictureIsBig)--(tmpW/2-(tmpW*(i.w/ogiw)*data.pictureIsBig)/2)
                -- n.offset_y = n.offset_x
                n.w = tmpW*(i.w/ogiw)*data.pictureIsBig
                n.h = n.w
            end
        end
    
        border.olds = border.olds or border.source
       -- border.source = i.flipX<0 and "border_back_r.png" or border.olds
        border.w = i.w
        border.h = i.h
        border.offset_x =i.offset_x
        border.offset_y = i.offset_y
        border.flipX = i.flipX
       -- self.choose.angle = self.iangle

        local ii=[[f (xScale >= 0) then 
            love.graphics.draw(frontside, xPos, yPos, 0, xScale, 1)
        else
            love.graphics.draw(frontside, xPos, yPos, 0, -xScale, 1)
        end]]
    end
    
    self.choose.preDraw()--i.draw()
    
    -- don't tilt text in gameplay so people will pay more attention to them
    local transformStuff = not self.isMenu
    
    function imageStencilFunction()
    
      local selff = self.choose
      
      if transformStuff then
        local gtran = gooi_transform
        gtran:reset()
        lg.push()
        local rx = selff.w/6
        local ry = selff.h/6
        
        local tr = selff.transformParent or selff
        local rrx,rry = (tr.x+tr.w/2), (tr.y+tr.h/2)
        Graphics.translate(rrx,rry)
        Graphics.rotate(math.rad(tr.angle or 0))
        love.graphics.applyTransform(gtran)
        Graphics.translate(-rrx, -rry)
      end
      
      local img = border
      local oldShader = img.shader
      img.shader = mask_shader
      selff:drawImage(img)
      img.shader = oldShader
      
      if transformStuff then
          lg.pop()
      end
    end
        
    local oldd = self.choose.draw
    local ddraw = self.label2.draw
    local ddraws = self.label2.drawSpecifics
    
    self.label2.noStencil = true -- to not override stencil applied
    
        self.label2.texty.w = self.label2.w/2
        
    self.choose[transformStuff and "postPostDraw" or "postDraw"] = function(selff, ...)
        -- oldd(selff, ...)
        local ox, oy = self.label2.x, self.label2.y
        -- self.label2.angle = selff.angle
        
        love.graphics.stencil(imageStencilFunction,  "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        
    
        local fh = self.label2.texty.h
        local ffh = (fh+5)*(1-self.labelTweenValue)
        
        -- self.label2:setText("A very comlpicated message is arriving to you noq you know")
        self.label2.x = selff.x-50+((selff.w+100)-self.label2.w)/2
        self.label2.y = selff.y-50-ffh
        self.label2.yOffset = 30
        --self.label2.w = selff.w+100
        -- self.label2.transformParent = selff
        --self.label2.texty.w = selff.w
        
        
        
        local r,g,b,a = set_color(0,0,0,(self.label2.fgColor[4])/1.45)
        local fx, fy = self.label2.x, self.label2.texty.y
 
        local ww = 500
        draw_rect("fill", fx-ww, selff.y-55-ww-ffh, selff.w+100+ww*2, fh+70+ww)
        set_color(r,g,b,a)
        
        
        self.label2.draw = ddraw
        self.label2.drawSpecifics = ddraws
        
        self.label2:draw()--gooi.drawComponent(self.label2)
        self.label2:drawSpecifics(self.label2.fgColor or self.label2.style.fgColor)
        
        self.label2.draw = null
        self.label2.drawSpecifics = null
        
        self.label2.kx = ox
        self.label2.ky = oy
        
        lg.setStencilTest()
    end
    
    --border.draw=i.draw

    --xScale = math.cos(3.14/2 * time)
    self.labelTweenValue = 0
    
    self.choose.onlyImage = true
    self.choose.showBorder = false
    self.choose.noStencil = true
    
    
    self:tween(1.3, self.nameLabel.fgColor,{0,0,0,1},"in-quad")
end) end

function GameScreen:mousereleased()
    if self.labelTween then
        self.timer:cancel(self.labelTween)
        self.labelTween = nil
    end
    
    self.labelTweenValue = 0
    
    if (self.egP and self.isMenu) or self.quit or game.online then return end
    
    if self.labelUI and not self.labelUI.texty.done then
        while not self.labelUI.texty.done do
            self.labelUI.texty:update(1/30)
        end
    end
    
    if self.ox and self.rr > 0 then
        if math.abs(self.diffx) > 100 and not (self.isMenu and self.chosen==self.data.yes and gdata.energy<=0) then
            self:play_sound("plastic_click")
            local dir = getDir(self.diffx)
            self.diffx = 0
            self.ox = nil
            local x = dir == 1 and W()+500 or -500
            local y = H()+100
            self:tween(.4, self.choose, {angle=360, x=x, y=y}, "out-quad")
            
            
            self:tween(.2, self.nameLabel, {fgColor={0,0,0,0}}, "out-quad")
            self.label.fgColor = {0,0,0,1}
            self:tween(.2, self.label, {fgColor={0,0,0,0}}, "out-quad")
            
            if self.isMenu then
            
                if self.chosen == self.data.yes or not gdata.gamePlayed then
                    self:startGame()
                else
                    self:viewHighscores()
                end
                
                return
            end
            
            local next = self.data.next or nil
            if next and type(next[1]) == "table" then
                next = getValue(next)
            end
            
            if self.data.stats then
                assert(self.data.tmpStats)
                self:changeStats(self.data.tmpStats)
            end
            
            if self.data.setStats then
                assert(self.data.tmpSetStats)
                self:changeStats(self.data.tmpSetStats, true)
            end
            
            if self.chosen then
                next = self.chosen.next or next
                if next and type(next[1]) == "table" then
                    next = getValue(next)
                end
                self:changeStats(self.chosen.tmpStats or {})
            end
            
            
            self:after(.25, function()
                if self.lost and not self.nextLoad then
                    self:endGame()
                else
                    self:loadNewDialog(next or nil)
                end
            end)
        else
            self.diffx = 0
            self.ox, self.oy = nil
            self.tweening = self:tween(.25, self.choose, {angle=0, x=self.choose.ogx}, "in-quad")
            if (self.isMenu and self.chosen==self.data.yes and gdata.energy<=0) then
                -- self.chosen = nil
                self:play_sound("negative")
                self.energyButton.events.r(self.energyButton)
            end
            
            self.chosen = nil
        end
    end
end

function GameScreen:mousemoved(x, y)
    if self.egP or self.quit or game.online then return end
    
    if self.ox and self.rr > 0 then
    
        for x = 1, self.label.texty.done and 0 or 7 do
            self.label.texty:update(love.timer.getDelta())
        end
        
        
        -- cancel card tilt demonstration if screen touched (and dragged?)
        if self.cardTween then
            self.timer:cancel(self.cardTween)
            self.cardTween = nil
        end
        
        local b = 200
        local diffx = lume.clamp(x-self.ox, -b, b)
        local diffy = y-self.oy
    
        self.diffx = diffx
        self.choose.x = self.choose.ogx+diffx
        self.choose.angle = (diffx/200)*30
        
        local changed
        
        if self.choose.angle <= 0 then
            if self.chosen ~= self.data.no then
                self.label2:setText(self.noText)
                self.chosen = self.data.no
                self.statsAffected = self.chosen and self.chosen.tmpStats or self.data.tmpStats or {}
                changed = true
            end
        else
            if self.chosen ~=self.data.yes then
                self.label2:setText(self.yesText)
                self.chosen = self.data.yes
                self.statsAffected = self.chosen and self.chosen.tmpStats or self.data.tmpStats or {}
                changed = true
            end
        end
        
        if changed then
            self:play_sound("card_swipe")
        
            if self.labelTween then
                self.timer:cancel(self.labelTween)
                self.labelTween = nil
            end
            self.labelTweenValue = 0
            self.labelTween = self:tween(.3, self, {labelTweenValue = 1}, "linear")
        end
        
        for x = 1, changed and 5 or 0 do
           -- self.label2.texty:update(1/30)
        end
        
        if true then
            -- self.label2.fgColor[4] =((math.abs(diffx)-20)/200)+0
        end
    end
end

function GameScreen:update(dt)
    gdata.playTime = gdata.playTime + dt
end

local function checkCardChoice(self)
        local changed
        
        if self.choose.angle <= 0 then
            if self.chosen ~= self.data.no then
                self.label2:setText(self.noText)
                self.chosen = self.data.no
                self.statsAffected = self.chosen and self.chosen.tmpStats or self.data.tmpStats or {}
                changed = true
            end
        else
            if self.chosen ~=self.data.yes then
                self.label2:setText(self.yesText)
                self.chosen = self.data.yes
                self.statsAffected = self.chosen and self.chosen.tmpStats or self.data.tmpStats or {}
                changed = true
            end
        end
        
        if changed then
            self:play_sound("card_swipe")
        
            if self.labelTween then
                self.timer:cancel(self.labelTween)
                self.labelTween = nil
            end
            self.labelTweenValue = 0
            self.labelTween = self:tween(.3, self, {labelTweenValue = 1}, "linear")
        end
end

function GameScreen:draw_before_gooi(dt)
    if self.isNarrator then
        self.label.x = self.choose.x
        self.label.y = self.choose.y
        self.label.angle = self.choose.angle
        self.label.w, self.label.h = self.choose.w, self.choose.h
    end
    
    if self.label2 then
    
        if self.cardTween then
            checkCardChoice(self)
        end
        local div = 100 --250
        local diffx = self.diffx
        if self.cardTween then--- =
            local ang = (self.chooseDiff/200)*30
            diffx = self.choose.x-self.choose.ogx
            self.label2.images.color = getValue(colors)
            
            if (self.choose.angle > ang or self.choose.x > self.chooseX) and self.chooseDiff > 0 then
                self.choose.angle = ang
                self.choose.x = self.chooseX
            end
            
            if (self.choose.angle < ang or self.choose.x < self.chooseX) and self.chooseDiff < 0 then
                self.choose.angle = ang
                self.choose.x = self.chooseX
            end
            
        end
        
        self.label2.fgColor[4] = self.label2.text == "" and 0 or ((math.abs(diffx or 0)-30)/div)+0+.2
        if self.scoreLabel and nil then
            self.scoreLabel.fgColor[4] = lume.max(self.isMenu and .25 or 0, 1-self.label2.fgColor[4]*1.7*(diffx and diffx>0 and 2 or 1))
            self.scoreLabel:setText(self.scoreLabel.text)
        end
    end
    
    if self.scoreLabel and not self.scoreLabel.noTilt then
        self.scoreLabel.angle = self.scoreShake.shake_x
    end
    
    local HH = H()*2
    self.rr = (self.rr or 0) + dt
    local r,g,b,a = set_color(.9, .9, .9)
    draw_rect("fill", -W(), -H()*.5, W()*4, H()*3+10)
    
    set_color(.1, .1, .8)
    local n = 30
    for x = 1, HH/n+100 do
        lg.line(-W(), -H()*.5+(H()/n)*x, W()*4, -H()*.5+(H()/n)*x)
    end
    
       -- lg.line(500,500, W()*4, H()*2)

    set_color(.9, .2, .1)
    lg.line(50, -H()*.5, 50, H()*4)
    -- lg.print(self.diffx or "?", 0,0)
    
    set_color(r,g,b,a)
    
    if self.draw_signs then
        self:draw_signs(dt)
    end
end

local nully = function() end

function GameScreen:draw()
    if self.label2 and nil then
        set_color(0,0,0,(self.label2.fgColor[4])/1.4)
        local fx, fy = self.label2.x, self.label2.texty.y
        local fh = self.label2.texty.h
        draw_rect("fill", -W(), fy, W()*4, fh+H())
        gooi.drawComponent(self.label2)
    end
        
    if self.choose and not self.isMenu then
        self.choose.draw = self.choose.odraw
        self.choose.drawSpecifics = self.choose.odrawSpecifics
        gooi.drawComponent(self.choose)
        self.choose.draw = nully
        self.choose.drawSpecifics = nully
    end
    
    if self.egP and type(self.egP) == "table" then
        gooi.drawComponent(self.egP, true)
        if self.egP.b2 then
            gooi.drawComponent(self.egP.b2)
        end
    end
    
    
    if self.quit and type(self.quit) == "table" then
        gooi.drawComponent(self.quit, true)
        if self.quit.b2 then
            gooi.drawComponent(self.quit.b2)
        end
    end
    
    
    if self.rating then
        -- gooi.drawComponent(self.rating)
    end
end

Menu2.draw = GameScreen.draw
Menu2.mousemoved = GameScreen.mousemoved
Menu2.mousereleased = GameScreen.mousereleased
Menu2.loadNewDialog = GameScreen.loadNewDialog
Menu2.getCharacterForDialog = GameScreen.getCharacterForDialog
Menu2.changeStats = GameScreen.changeStats

function Menu2:keyreleased(k)
    if self.egP and self.egP~=true and self.egP.cancel then
        self.egP.cancel(self.egP)
        self.egP.cancel = nil
        
    elseif k == "escape" and not self.quit then-- return self:showRewards(3) else
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 20,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 4x3"
        }):setColspan(1,1,3):setRowspan(1,1,3):setOpaque(true)
        panel:addImage("resultSlipUI.png")
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        local label = gooi.newLabel({text=getValue(quitTexts)})
        panel:add(label)
        
        local noButton = gooi.newButton({text=""})
        noButton:addImage("no.png")
        noButton.onlyImage = true
        panel:add(noButton)
        
        local yesButton = gooi.newButton({text=""})
        yesButton:addImage("yes.png")
        yesButton.onlyImage = true
        panel:add(yesButton,4,3)
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
            self.quit = nil
            self.egP = nil
            game.online = false
            game.scoreCoverAlpha = 0
        end
        
        local function no()
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            playGooiSound()
        end
        
        noButton:onRelease(no)

        
        local function yes()
            self:tween(.4, self, {cover_alpha=1.1}, "out-quad", love.event.quit)
        end
        
        yesButton:onRelease(yes)
        
        
        self.quit = panel
        
    elseif nil and k == "escape" then
        local function func()
            gooi.components = {} ldgm = true
            LoadMenu.__draw = LoadMenu.ddr or error()
            game:set_room(LoadMenu)
        end
        self:tween(.4, self, {coverAlpha=1.1}, "out-quad", func)
    end
end

local bnn = 0
function Menu2:startGame()
    gdata.energy = gdata.energy-1
    -- data.gamesPlayed = gdata.
    
    local function stop()
        self.energy.tweeningColor = false
    end
    self.energy.tweeningColor = true
    self.energy.fgColor = lume.copy(self.energy.fgColor)
    local function funcBack()
        self:tween(.6, self.energy, {fgColor=colors.darkdarklime}, "in-quad", stop)
    end
    self:tween(.35, self.energy, {fgColor=colors.lighterlime}, "out-quad", funcBack)
    
    game:saveData()
    self:squash_ui(self.energy, .64, 1.4, .4)
    local eimg = self.energy
    eimg.angle = 0
    self.enkergyUsed = true
   -- self:tween(1, eimg, {angle=360*2}, "out-quad")
    local nLabel = gooi.newLabel({w=self.energy.w, h=self.energy.h, x=self.energy.x, y=self.energy.y, font=self.energy.font})
    nLabel.texty.scale = .7
    nLabel:setText("&colors.darklime x1")
    nLabel.fgColor = {0,0,0,1}
    local nn = .6
    self:tween(nn, nLabel, {y=nLabel.y-70, fgColor={0,0,0,0}})
    self:tween(nn, nLabel.texty, {scale=2})
    
    
    self:after(.8, function()
        if self.rating then
            self:tween(tt, self.rating, {x=W()+self.rating.w, angle=360}, f)
        end
        
        self.energy.doneSquash = -4
        local tt =.7
        local hh = -self.hh*1.6-self.bar.h*16
        local f = not "out-bounce" or "in-quad"
        self:tween(tt+bnn, self.bar, {y=-self.bar.h*4}, "out-quad")
        self:tween(tt, self.levelText, {y=hh, angle = 0 or 180}, f)
        self:tween(tt, self.nameText, {y=hh, angle = 0 or 180}, f)
        self:tween(tt, self.nameLabel.fgColor, {0,0,0,0})
        self:tween(tt, self.energy, {y=hh}, f)
    
        if self.playAgainSound then
            self:play_sound(getValue(math.random()>.9 and "erwin_speech" or {"another_one", "aot_short"}))
        end
        
        local func =  function()
            gooi.components = {}
            gdata.totalPlays = gdata.totalPlays + 1
            game:set_room(GameScreen)
        end
    
        self:after(tt+.4, func)
    end)
end

function Menu2:viewHighscores()
    local tt =.7
    local hh = -self.hh*1.6-self.bar.h*16
    local f = not "out-bounce" or "in-quad"
    self:tween(tt+bnn, self.bar, {y=-self.bar.h*4}, f)
    self:tween(tt, self.levelText, {y=hh, angle = 0 or 180}, f)
    self:tween(tt, self.nameText, {y=hh, angle = 0 or 180}, f)
    self:tween(tt, self.nameLabel.fgColor, {0,0,0,0})
    self:tween(tt, self.energy, {y=hh}, f)
    
    if self.rating then
        self:tween(tt, self.rating, {x=W()+self.rating.w, angle=360}, f)
    end
    
    self:tween(tt, game, {scoreCoverAlpha=1}, f)
    game.online = true
    self:after(tt+.4, function()
        game:set_room(ScoreMenu)
    end)
    self:tweenCoverAlpha(tt*1.05, 1)
end


function Menu2:setup()
    self:activate_gooi(k)
    self.isMenu = true
    gooi.components = {}
    
    local ww = W()*.9
    local xx = W()/2-ww/2+4
    
    local f = font40 or mario_font40
    local h = f:getHeight()
    self.hh = h
    local w = f:getWidth("Level 100")
    self.levelText = gooi.newLabel({
        text = string.format("%s", gdata.name),
        instant = false,
        font = f,
        w = W(), h = h,
        x = xx, y = 10
    }):left()
    local lt = self.levelText
    
    
    local f = font19 or mario_font18
    local h = f:getHeight()
    local w = f:getWidth("Level 100")
    self.nameText = gooi.newLabel({
        text = string.format("LEVEL %s: %s", gdata.level, gdata.levelText),
        instant = false,
        font = f,
        w = ww, h = h,
        x = xx, y = lt.h+lt.y
    }):left()
    self.nameText.fgColor = {0,0,0,1}
    
    self.bar = toybox.ProgressBar({
        progression = (gdata.levelExp/LEVEL_EXP())*100,
        totalColor = "orange",
        x = xx,
        y = lt.h+lt.y+20+h,
        h = h,
        w = ww,
        glows = "black"
    })
    
    local function checkForDonationReward()
    
        local scores = energyboard:getScores()
        scoreboard:authenticate()
        self:tween(.1, game, {scoreCoverAlpha=0}, "out-quad")
        game.online = false
        game.onlineText = nil

        
        if scores then
            local me
            log("Found "..inspect(scores, 1))
            for x, score in ipairs(scores or {}) do
                if score.member_id == gdata.name then
                    me = score
                    log(" found me!!!!"..inspect(score))
                    break
                end
            end
            
            if me then
                me.metadata = json.decode(me.metadata)
            end
            
            if me and me.metadata and me.metadata.extraMetadata and me.metadata.extraMetadata.helped and energyboard:submitScore(me.member_id, me.score, me.metadata.playerID, {helped = false}) then
                local function func()
                    NotifyPlayerDonorReward(self, me.metadata.extraMetadata and me.metadata.extraMetadata.helped)
                end
                
                local function funcn()
                    if self.shownCard then
                        if self.egP == true then
                            self.egP = nil
                        end
                        self:after(.7, func)
                        self.timer:cancel(self.rtimer)
                        self.rtimer, self.rfunc = nil
                    end
                end
                
                self.rfunc = funcn
                
                self.egP = true
                self.rtimer = self:every(.7, self.rfunc)
            elseif me then
                log("Nope "..inspect(me.metadata)..","..inspect(me.metadata.extraMetadata))
              -- game:printErrorMessage("@No helpers fund")
            end
            
            return
        end
        
        game:printErrorMessage("No Network Connection?", {.8,.8,.8,.8})
        -- failed
        
    end
    
    
    local function check()
        game.checkedForReward = true
        game.onlineText = "Checking online rewards..."
        self:tween(.13, game, {scoreCoverAlpha=1}, "in-quad")
        game.online = true
        self:after(.15, checkForDonationReward)
        self.checkedDemonstration = true
        self:after(.05, self.demonstrateFunction or null)
    end
    
    assert(null)
    
    log("check")
    
    self:after(.5, (game.checkedForReward or not gdata.loggedIn) and null or check)
    log("a")
    gdata.loggedIn = true
    
    local function donateEnergy(button)
        local scores = energyboard:getScores()
        self:tween(.1, game, {scoreCoverAlpha=0}, "out-quad")
        game.online = false
        game.onlineText = nil
        
        if scores ~= null then
            local score = scores
            local energy = lume.min(math.random(1, gdata.energy), 3)
            log("Donating energy "..energy..","..gdata.name)
            if energyboard:submitScore(gdata.name, energy) then
                
                gdata.energy = gdata.energy - energy
                local function n()
                game:printErrorMessage(string.format("&colors.darkdarklime %s #Energy donated!!\n ~ This might help someone in need!", energy))
                
                local function func()
                    addGPScore(self, not gdata.donatedBefore and math.random(1000, 1200) or math.random(50,600), "Reward: %sgp")
                    gdata.donatedBefore = true
                    self:play_sound("anime_wow")
                end
                
                self.toReward = func
                self.egP.cancel(self.egP)
                self:after(1.3, func)
                end
                
                self:after(.4, n)
                
                gdata.donatedTime = os.time()
                self.askedForEnergy = true
                button.enabled = false
                return true
            end
        end
        
        game:printErrorMessage("Action failed: Check Network Connection?", "lightred")
        self:play_sound("negative")
        
        -- failed
        
    end
    
    local function lookForEnergy(button)
        local scores = energyboard:getScores()
        self:tween(.1, game, {scoreCoverAlpha=0}, "out-quad")
        game.online = false
        game.onlineText = nil
        
        if scores then
            local helper
            
            local scores = lume.copy(scores)
            while #scores > 0 do
                local dat = lume.eliminate(scores)
                if dat.member_id ~= gdata.name and dat.score > 0 then
                    helper = dat
                    break
                end
            end
            
            self.askedForEnergy = true
            button.enabled = false
            gdata.donatedTime = os.time()
            
            if helper then
                log("FOUND HELPER "..helper.member_id)
                local energy = lume.min(3, math.random(1, helper.score))
                if energyboard:submitScore(helper.member_id, helper.score-energy, helper.metadata.playerID, {helped = gdata.name}) then
                    gdata.energy = gdata.energy + energy
                    local function ff()
                        game:printErrorMessage(string.format("You got &colors.darkdarklime @%s ~ energy from # &STATS_COLOR %s ~!!", energy, helper.member_id), "gold")
                    end
                    self:after(.3, ff)
                    return true
                end
            else
                game:printErrorMessage("@No helpers found!! ~ &colors.darkdarklime NO ONE DONATED!", "grey")
                gdata.donatedTime = gdata.donatedTime-60*20
                self:play_sound("negative")
                
                return true
            end
        end
        
        game:printErrorMessage("Action failed: Check Network Connection?", "lightred")
        self:play_sound("negative")
        
        -- failed
    end
    
    local function showEnergy()
        if self.egP then
            return
        end
        
        playGooiSound("paper_tear")
        
        self:squash_ui(self.energy)
        
        local ew, eh = W()*.9, H()*.5
        local egP = gooi.newPanel({
            x = W()/2-ew/2,
            y = H()/2-eh/2,
            w = ew, h = eh,
            padding = 15,
            layout = "grid 5x3"
        }):setRowspan(1,1,5):setColspan(1,1,3)
        self.egP = egP
        
        egP.dalpha = 0
        self:tween(1, egP, {dalpha=.7}, "in-quad")
        egP.preDraw = function()
            local r,g,b,a = set_color(0,0,0,egP.dalpha)
            draw_rect("fill",-W(),-H(),W()*4,H()*4)
            set_color(r,g,b,a)
        end
        
        local img = egP:addImage("energyPanel.png")
        egP.onlyImage = true
        egP.showBorder = false
        
        egP.ogy = egP.y
        egP.y = -eh-100
        egP.opaque = true
        
        checkEnergy()
        
        local txt = gooi.newLabel({text="You have earned so and so energy", instant=true})
        txt:setText(
            gdata.energy>=MAX_ENERGY and string.format("You have &colors.lime %s ~ energy", gdata.energy) or
                string.format(gdata.energy<=0 and "You have no energy %s" or string.format("You have &colors.lime %s ~ energy %s", gdata.energy, "%s"), string.format("\n%s", getTimeText(gdata.timeToNextEnergy)))
        )
        
        txt.yOffset = 10
        egP:add(txt)
        
        local function donateOrRecieve(button)
            self:tween(.1, game, {scoreCoverAlpha=1}, "in-quad")
            game.online = true
            
            game.onlineText = gdata.energy > 0 and "Donating energy online..." or "Looking for energy online..."
            
            playGooiSound()
            
            local function func()
                if gdata.energy>0 then
                    return donateEnergy(button)
                else
                    return lookForEnergy(button)
                end
            end
            
            self:after(.2, func)
        end
        
        local button = gooi.newButton({font=font18,text=gdata.energy>0 and "DONATE" or "LOOK FOR\nENERGY"})
        button.bgColor = {93/255, 226/255, 167/255}--lume.copy(colors.lime)
        egP:add(button,5,2)
        button.borderWidth = 10
        button:onRelease(donateOrRecieve)
        
        local b2
        
        local function remove()
            gooi.removeComponent(egP)
            self.egP = nil
            gooi.removeComponent(b2)
        end
        
        local function cancel(n)
            -- self:squash_ui(b2)
            playGooiSound()
            local func = "out-quad"
            self:tween_out_ui(egP, .5, func)
            self:tween(.5, b2, {fgColor={0,0,0,0}, y=egP.outy}, func, remove)
        end
        
        self.egP.cancel = cancel
        
        b2 = gooi.newLabel({text="X", x=egP.x-10, y=egP.ogy-5, w=100, h=100, font=mario_font20}):onRelease(cancel)
        b2.fgColor = {0,0,0,0}
        self:tween(.6, b2.fgColor, {0,0,0,1}, "in-quad")
        
        egP.b2 = b2
        
        egP.outy = egP.y
        self:tween_in_ui(egP, .5, "in-bounce")
        
        local function refreshPanel()
            egP:refresh()
        end
        self:after(.5+.1, refreshPanel)
        
        local e_update = function()
            checkEnergy()
            txt:setText(
            gdata.energy>=MAX_ENERGY and string.format("You have &colors.lime %s ~ energy%s", gdata.energy, gdata.lastDonated<=(1*60*60) and "\n \nCome back later to donate." or "\n \nConsider donating to help someone else?") or
                string.format(gdata.energy<=0 and "You have no energy %s" or string.format("You have &colors.lime %s ~ energy %s", gdata.energy, "%s"), string.format("\n \nTime til next energy:\n%s", getTimeText(ENERGY_TIME-gdata.timeToNextEnergy)))
            )
            for x = 1, 2 do
                txt.texty:update(1/30)
                txt.texty:draw()
            end
            
            if gdata.lastDonated<=(1*60*30) and not gdata.hack then--and gdata.energy>=1 then
                --[[button.ddraw = button.ddraw or button.draw
                button.sdraw = button.sdraw or button.drawSpecifics
                button.draw = null
                button.drawSpecifics = null
                button.isActive = false]]
                button.enabled = false
                button.oldT = button.oldT or button.text
                button:setText(getTimeText((1*60*30)-gdata.lastDonated))
            else
                button.draw = button.ddraw or button.draw
                button.drawSpecifics = button.sdraw or button.drawSpecifics
                button.isActive = true
                
                button.enabled = true
                
                button:setText(gdata.energy>0 and "DONATE" or "LOOK FOR\nENERGY")
            
                if button.oldT then -- not needed?
                    -- button:setText(button.oldT)
                    -- button.oldT = nil
                end
            end
            
        end
        
        button.enabled = true
        e_update()
        
        local e = self.timer:every(1.1, e_update)
        
        game:saveData()
    end
    
    local eww = 100
    
    self.energy = gooi.newButton({w=eww, h=eww, x=ww-eww+10, y=20, font=mario_font20})
    self.energy.opaque = true
    local eimg = self.energy:addImage("energy.png")
    self.energy.noStencil = true
    eimg.offset_x = -eww/1.5
    self.eimg = eimg

    self.energy:setText(string.format("%sx%s", "", gdata.energy))
    self.energy.postDraw = self.energy.draw
    self.energy.bgColor = {0,0,0,0}
    self.energy.showBorder = false
    local eg = self.energy
    self.energyButton = gooi.newButton({text="", w=eww*2, h=eww, x=eg.x-eww, y=eg.y})
    self.energyButton:onRelease(showEnergy)
    self.energyButton.bgColor = {0,0,0,0}
    self.energyButton.showBorder = false

      local eww = 100
    self.walletBtn = gooi.newButton({
        w=eww, h=eww, 
        x=self.energy.x+50-eww/1.5,--eww-10, 
        y=self.energy.y+(eww+10+70),
        font=mario_font20
    })


    self.walletBtn:setText("")
    self.walletBtn.noStencil = true
    local wimg = self.walletBtn:addImage("icons/popularity_old.png")
  --  wimg.offset_x = -eww/1.5
    
    self.walletBtn.postDraw = self.walletBtn.draw
    self.walletBtn.bgColor = {0,0,0,0}
    self.walletBtn.showBorder = false

    
    local wdir = 1
    local function walletAngle()
        local w = self.walletBtn

        if game.walletAddress then
            w.angle = 0
            wimg.color = colors.lime

            return
        end
        
        w.angle = w.angle + 30*0.1*wdir
        if math.abs(w.angle) > 25 then
            wdir = wdir * -1
        end
    end

    self:every(0.1, walletAngle)

    -- Make whole area clickable
    self.walletButtonArea = gooi.newButton({
        text="", 
        w=eww*2, h=eww, 
        x=self.walletBtn.x-eww, 
        y=self.walletBtn.y
    })

    self.walletBtn:onRelease(function() 
        self:showWalletConnect() 
    end)

    self.walletButtonArea.bgColor = {0,0,0,0}
    self.walletButtonArea.showBorder = false
    gooi.removeComponent(self.walletButtonArea)
    
    
    local items = {
        self.energy, self.bar, self.levelText, self.nameText, self.walletBtn,
        self.nameLabel
    }
    
    self.ogby = self.bar.y
    
    local tt = 1.2
    for x, ii in ipairs(items) do
        local ogy = ii.y
        ii.y = -100-(ii.h or 100)
        self:tween(tt, ii, {y=ogy}, "in-bounce")
    end
    
    local w = W()*.99
    local h = H()*.1
    
    self.statsAffected = {}
    
    local icons = {"church","brain","popularity","coin"}
    local stats = {
        church = {
            icon = "cross",
            color = "brown",
            name = "church"
        },
        brain = {
            icon = "brain",
            color = "pink",
            name = "brain"
        },
        popularity = {
            icon = "popularity",
            color = "skyblue",
            name = "popularity"
        },
        coin = {
            icon = "coin",
            color = "gold",
            name = "coin"
        }
    }
    
    self.stats = {
        church = 10,
        brain = 30,
        popularity = 30,
        coin = 40
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
        i.stat = icons[x]
        
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
    
    gooi.removeComponent(self.statsPanel)
    
    
    
    
    
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
    gooi.removeComponent(choose)
    
    self.timer:every({1,1.5,1.3,2}, function()
        local f = self.face
        if not f then
            return
        end
        
        self.face.times = (self.face.times or 0)+1
        
        local oox, ooy = self.face.offset_x, self.face.offset_y
        local dx = math.random(-10,10)/10
        local dy = math.random(-10, self.cap and 0 or 10)/(self.cap and 14 or 10) -- so certain characters won't look to down
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
    
    
    local function start()
        local idk = not game.startedGameOnce
        self:loadNewDialog({
            text=gdata.gamePlayed and "Swipe to Decide...\n \n " or " \n You are Course Rep.",
            isNarirator=true,
            yes={text="@Begin Semester"},
            no=gdata.gamePlayed and {text="&colors.gold #View highscores"} or {text="@Begin Semester"},
            isLoss=idk, source=idk and "idk.png"
        }, not gdata.gamePlayed and "Swipe to make decisions..." or idk and "") --label2
        
        --self.label2.texty.ftont = mario_font18
        
        local function demonstrate()
            local nextSide, nextSide2
            
            nextSide = function()
                local diffx = 100
                self.chooseDiff = diffx
                local chooseX = self.choose.ogx+diffx
                local chooseAngle = (diffx/200)*30
                
                self.chooseX = chooseX
            
                self.cardTween = self.timer:tween(1.65, self.choose, {x = chooseX, angle = chooseAngle}, "in-quad", nextSide2)
            end
            
            nextSide2 = function()
                local diffx = -100
                self.chooseDiff = diffx
                local chooseX = self.choose.ogx+diffx
                local chooseAngle = (diffx/200)*30
                
                self.chooseX = chooseX
            
                self.cardTween = self.timer:tween(1.65, self.choose, {x = chooseX, angle = chooseAngle}, "in-quad", nextSide)
            end
            
            nextSide()
        end
        
        self.demonstrateFunction = function()
            
        end
        
        do
            self:after(not gdata.gamePlayed and .7 or idk and 5.2 or math.random(7,15), not idk and false_null or gdata.energy > 0 and not self.touched and demonstrate or null)
        end
        
        if self.checkedDemonstration or (game.checkedForReward or not gdata.loggedIn) then -- didn't actually demonstrate yet
            self.demonstrateFunction()
        end
    end
    self:after(1.0, start)
    
    if not game.old_room.stats then
        self.cover_alpha = 1
        self:tweenCoverAlpha(.5, 0, "out-quad")
    end
end


Menu2.draw_before_gooi = function(self, dt)
    GameScreen.draw_before_gooi(self, dt)
    
    self.camera:attach()
    
    checkEnergy()
    
    self.energy:setText(string.format("%sx%s", "", gdata.energy))
    if not self.energy.tweeningColor then
        self.energy.fgColor = gdata.energy <= 0 and colors.red or self.energyUsed and colors.darklime or colors.dark or colors.darkdarklime
    end
    
    set_color(1,1,1)
    local w, h = W()*.95, H()*.25
    --draw_rect("line", W()/2-w/2, -10, w, h)
    self.ogby = self.ogby or self.bar.y
    local bimg = game:getAsset("backdrop.png")
    lg.draw(bimg, W()/2-w/2, -10+(self.bar.y-self.ogby), 0, resizeImage(bimg, w, h))
    
    self.bar:draw()
    if self.bar.progression >= 100 then
        if nil then--not self.started then
            self.started = true
            self:after(math.random(2,12)/10, function()
                game:set_room(Menu)
            end)
        end
        self.bar.progression = 0
    end
    
    set_color(1,1,1)
    local bimg = game:getAsset("levelBarUI.png")
    self.bar.drawFrame = null
    local nn = 3--10
    lg.draw(bimg, self.bar.x-nn, self.bar.y-nn, 0, resizeImage(bimg, self.bar.w+nn*2, self.bar.h+nn*2))
    
    if self.bar then

        local func = function()
            lg.setShader(mask_shader)
            local bimg = game:getAsset("levelBarUI.png")
            self.bar.drawFrame = null
            local nn = 3--10
            self.bar:draw()
            lg.draw(bimg, self.bar.x-nn, self.bar.y-nn, 0, resizeImage(bimg, self.bar.w+nn*2, self.bar.h+nn*2))
            lg.setShader()
        end
    
        
        love.graphics.stencil(func,  "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        
        local r,g,bb,a = love.graphics.getColor()
        
        local p = love.graphics.getLineWidth()
        local pp = 0--p*4
        love.graphics.setLineWidth(10/2.2)
        
        local line = love.graphics.line
        
        love.graphics.setColor(0,0,0)
        
        local b = self.bar
        local bx = b:getLoadedWidth()+b.x
        line(bx, b.y, bx, b.y+b.h)
        
        lg.setLineWidth(p)
        lg.setColor(r,g,bb,a)
        
        lg.setStencilTest()
        
    end
    
    self.camera:detach()
end

Menu = toybox.Room("Menu")

function Menu:mousereleased()
    self.playImage.source = "title/play_up.png"
end

function Menu:setup(k)
    self:activate_gooi()
    local col = {234/255, 170/255 or 117/255, 75/255}
    
    local w = 255
    self.play = gooi.newButton({
        x = W()/2-w/2,
        y = H()-w-100,
        w = w, h = w+1,
        text=""
    }):onRelease(function(n)
        if self.playImage.alpha <= .7 then-- ~= "title/play_down.png" then
            return
        end
        
        playGooiSound("facebook_sound")
        
        self.playImage.source = "title/play_up.png"
        -- self:squash_ui(n)
        self:tween(.8, self, {alpha=1}, "out-quad", function()
            game:set_room(Menu2)
            -- game:startGame()
        end)
        self:tween(.7, self.playImage, {alpha=0}, "out-quad")
        self:tween(.7, self.whatsappImage, {alpha=0}, "out-quad")
        self:tween(.6, n, {y=H()+n.h+10}, "out-quad")
        self:tween(.6, self.whatsapp, {y=H()+n.h+10}, "out-quad")
        for x = 1, 3 do
            local nn = self[string.format("title%s", x)]
            self:tween(.87, nn, x == 3 and {y=H()+nn.h} or {y=-nn.h-10}, "out-quad")
        end
    end):onPress(function()
        self.playImage.source = "title/play_down.png"
        self.playPressed = true
    end):onMoveReleased(function(n)
        self.playImage.source = "title/play_up.png"
        self.playPressed = false
    end):onMoved(function(n)
        if self.playPressed then
            self.playImage.source = "title/play_down.png"
        end
    end)
    
    self.cover_alpha = 1
    self:tweenCoverAlpha(.3, 0)
    
    self.alpha = 0
    
    self.play.drawRect = false
    self.play.showBorder = false
    self.play.bgColor = {0,0,0,0}
    self.playImage = self.play:addImage("title/play_up.png")
    self.playImage.alpha = 0
    
    
    local jigg
    
    do
    local w = 105--*2.2--drawcomponent(self.label2)
    self.whatsapp = gooi.newButton({
        x = W()/2-255/2+255+10,W()-w-10,--/2-w/2,
        y = H()-255-100+255/2+30,H()-w-10,10, H()-w-100,
        w = w, h = w+1,
        text=""
    }):onRelease(function(n)
        if self.playImage.alpha <= .7 then-- ~= "title/play_down.png" then
            return
        end
        
        jigg()
        playGooiSound("facebook_sound")
        love.system.openURL(WHATSAPP_CHAT_URL)
    end)
    
    
    self.whatsappJiggle = gooi.newLabel({
        x = W()-w-10,--/2-w/2,
        y = self.whatsapp.y, H()-w-100,
        w = w, h = w+1,
        text=""
    })
    
    end
    
    
            
    function jigg()
        self.whatsappJiggle:shake(60, .65, 40)
        self:play_sound("trill")
        self.wjigged = true
    end
            

    
    self.whatsappJiggle.drawRect = false
    self.whatsappJiggle.showBorder = false
    self.whatsappJiggle.bgColor = {0,0,0,0}
    
    local whw = self.whatsapp.w
    local whh = self.whatsapp.h
    
    local wn = 2
    self.wx = self.whatsapp.x-self.play.x+self.play.w/2
    self.wy = self.whatsapp.y-self.play.y+self.play.h/2
    
    self.whatsapp.w = whw*wn
    self.whatsapp.h = whh*wn
    
    self.whatsapp.drawRect = false
    self.whatsapp.showBorder = false
    self.whatsapp.bgColor = {0,0,0,0}
    self.whatsappImage = self.whatsapp:addImage("title/whatsapp.png")
    
    --gooi.removeComponent(self.play)
    
    self.tapAlpha = 0
    self.tapAlpha2 = 0
    
    local oy = 100
    
    local nn = toybox.NewBaseObject({
        w = W(), h = H(), x = 0, y = 0,
        source = "title/course_rep.png"
    })
    local title = nn
    self.title1 = nn
    
    nn:center()
    nn.w, nn.h = 10,10
    nn.x, nn.y = 0 or W()+W(), -W()
    
    local tt = .85
    local function playSound()
        self:play_sound(getValue({"explosive_impact"}), math.random(900,1100)/1000)--"hit", "slap", "whack"}))
    end

    self:tween(tt, nn, {x=0,y=oy,angle=360*0}, "in-bounce")
    self:tween(tt, nn, {w=W(), h=H()}, "in-bounce")
    self:after(.465, playSound)
    
    local tn = .8 -- 1.3
    self:after(.5, function()
        local nn = toybox.NewBaseObject({
            w = W(), h = H(), x = 0, y = 0,
            source = "title/rep.png"
        })
        self.title2 = nn
        nn:center()
        nn.w, nn.h = 10,10
        nn.x, nn.y = W(), -1
        nn.angle = 180
        self:tween(tn, nn, {x=0,y=oy,angle=0}, "in-quad", function()
            self.camera:shake(15,.2,15)
            nn:shake(25, .32, 25)
            title.color = col
            playSound()
        end)
        self:tween(tn, nn, {w=W(), h=H()}, "out-quad")
    end)
    self.wangle = 0
    local vw = W()*.65
    local vh = lg.getFont():getHeight()*2
    self.version = gooi.newLabel({text="ver. "..VERSION,w=vw,h=vh,x=W()/2-vw/2, y=self.play.y-vh*4})
    self.version.fgColor = {0,0,0,0}
    self:after(tn*2, function()
        local nn = toybox.NewBaseObject({
            w = W(), h = H(), x = 0, y = 0,
            source = "title/101.png"
        })
        -- nn.debug = true
        self.title3 = nn
        nn:center()
        nn.w, nn.h = W()*1.5,H()*1.5
        nn.x, nn.y = W()+W(), -W()
        nn.angle = 50
        self:tween(.7, nn, {x=0,y=oy,angle=0}, "in-quad", function()
            self.camera:shake(20,.3,20)
            self:play_sound("explosion")
        end)
    
        self:tween(1.3, nn, {w=W(), h=H()}, "in-bounce",function()
            self:tween(.65, self, {tapAlpha=1}, "in-quad")
            self:tween(2.2, self.whatsapp, {w=whw,h=whh}, "in-bounce")
            self:tween(1.4, self, {tapAlpha2=1}, "in-quad", jigg)
            self:every(5, self.makeNewText)
            self.makeNewText()
        end)
    end)
    
    local loadTexts = {
        "Rewriting curriculum\n...",
        "Building new exam halls\n...",
        "Appointing Course Advisor\n...",
    }
    local lLoadTexts = lume.copy(loadTexts)
    
    self.makeNewText = function()
            if self.label and self.label.texty.done then
                gooi.removeComponent(self.label)
                self.label = nil
            end
            local w = W()*.65
            self.label = self.label or gooi.newLabel({
                x = W()/2-w/2,
                y = H()/2-10+oy,
                font = font_7,
                w = w, h = w,
                text ="", lume.eliminate(lLoadTexts):upper(),--"Rebuilding schools\n...",
                instant = false,
                --scale = .5
            })
            
            --self.label.texty.scale = .5
            
            if #lLoadTexts <= 0 then
                lLoadTexts = lume.copy(loadTexts)
            end
    end
    
    
    --[[local uw, uh = W()*.7, H()*.45
    local ux, uy = W()/2-uw/2, H()/2-uh/2-100
    self.statsUI = gooi.newLabel({
        x = ux,
        y = -uh,
        w = uw, h = uh,
        font = font40,
        text = "LEVEL 1"
    }):setOpaque(true)
    self.statsUI.yOffset = 65
    self.statsUI.ogy = uy
    local su = self.statsUI
    local img = su:addImage("resultSlipUI.png")
    su.onlyImage = true
    su.showBorder = false
    self:tween_in_ui(self.statsUI, .65, "out-quad")
    
    self.labelUI = gooi.newLabel({x=su.x, y=uy, w=uw, h=uh, instant = false,
        text = not "\"If only the invigilator wasn't looking this way...@if only. ~ I for get A1 #steady...\"" or "\"kids these days don't know the struggle...\"",
    })
    self.labelUI.yOffset = 65+font40:getHeight()+10
    
    local rw = 100
    self.retryButton = gooi.newButton({x=su.x+su.w/2-rw/2, y=uy+uh-rw-20, w=rw, h=rw, text=""})
    self.retryButton.onlyImage = true
    local rb = self.retryButton:addImage("title/play_up.png")
    
    local bw = su.w*.8
    local bh = 50
    local xx = su.x+su.w/2-bw/2
    local yy = su.ogy+su.h-bh-150
    self.bar = toybox.ProgressBar({
        x = xx, y = yy,
        w = bw, h = bh,
        progress = 10,
        --glows = "white",
        totalColor = {1,1,1,0},
        progressColor = colors.yellow
    })
    self.bar:setProgress(1)
    self:every({1,.5,.4,.3,.2,.5},function() self.bar:progress(1) end)]]
end

function Menu:mousereleased()
    if nil and self.tapAlpha > .6 then
    
        self:tween(.8, self, {alpha=1}, "out-quad", function()
            game:startGame()
        end)
        -- self:tween(.7, self.playImage, {alpha=0}, "out-quad")
    end
end

function Menu:draw(dt)
    
    gooi.drawComponent(self.whatsapp)
    self.wangle = (not self.wjigged and 0 or self.wangle or 0)+dt*35
    local w = self.whatsapp
    if w and self then
        local ang = math.rad(self.wangle)
        w.x = self.play.x+self.play.w/4+lendir_x(self.wx/2, ang)
        w.y = self.play.y+self.play.h/4+lendir_y(self.wx/2, ang)
    end
    
    if false then
        self.bar:draw()
        
        local bimg = game:getAsset("resultBarUI.png")
        local nn = 15--10
        lg.draw(bimg, self.bar.x-nn, self.bar.y-nn, 0, resizeImage(bimg, self.bar.w+nn*2, self.bar.h+nn*2))
    
    
        local r,g,bb,a = love.graphics.getColor()
        
        local p = love.graphics.getLineWidth()
        local pp = 0--p*4
        love.graphics.setLineWidth(10)
        
        local line = love.graphics.line
        
        love.graphics.setColor(0,0,0)
        
        local b = self.bar
        local bx = b:getLoadedWidth()+b.x
        line(bx, b.y, bx, b.y+b.h)
        
        lg.setLineWidth(p)
        lg.setColor(r,g,bb,a)
        
    end
    
    self.count = (self.count or 0)+dt*3
    if self.count >= 3 then
        self.count = 0
    end
    local r,g,b,a = set_color(1,1,1,self.tapAlpha)
    n = math.floor(self.count)
    local img = game:getAsset(string.format("title/tap%s.png", n))
    
    self.playImage.alpha = self.tapAlpha-- = string.format("play%s.png",n)
    self.whatsappImage.alpha = self.tapAlpha2
    self.whatsapp.angle = self.whatsappJiggle.shake_x
    
    self.version.fgColor[4] = self.tapAlpha2*.8
    
    local _w, _h = resizeImage(img, W(), H())
   -- lg.draw(img, 0, 0, 0, _w, _h)
   
    if self.quit then
        gooi.drawComponent(self.quit, true)
    end
    
    set_color(0,0,0,self.alpha)
    draw_rect("fill",-W(),-H(),W()*4,H()*4)
    set_color(r,g,b,a)
end

function Menu:keyreleased(k)
    if k == "escape" and not self.quit then-- return self:showRewards(3) else
        local w, h = W()*.7, H()*.45
        local panel = gooi.newPanel({
            padding = 20,
            x=W()/2-w/2, y=H()/2-h/2,
            w=w, h=h,
            layout = "grid 4x3"
        }):setColspan(1,1,3):setRowspan(1,1,3):setOpaque(true)
        panel:addImage("resultSlipUI.png")
        panel.onlyImage = true
        panel.preDraw = greyDraw
        
        panel.ogy = panel.y
        panel.y = -panel.h*2
        panel.cover_alpha = 0
        
        local label = gooi.newLabel({text=getValue(quitTexts)})
        panel:add(label)
        
        local noButton = gooi.newButton({text=""})
        noButton:addImage("no.png")
        noButton.onlyImage = true
        panel:add(noButton)
        
        local yesButton = gooi.newButton({text=""})
        yesButton:addImage("yes.png")
        yesButton.onlyImage = true
        panel:add(yesButton,4,3)
        
        local time = .7
        panel.outy = panel.y
        self:tween_in_ui(panel, time)
        
        local function refreshPanel()
            panel:refresh()
        end
        self:after(time+.1, refreshPanel)
        
        self:tween(.7, panel, {cover_alpha=.75}, "in-quad")
        
        local function rem()
            gooi.removeComponent(panel)
            self.quit = nil
            self.egP = nil
            game.online = false
            game.scoreCoverAlpha = 0
        end
        
        local function no()
            self:tween_out_ui(panel, time)
            self:tween(.7, panel, {cover_alpha=0}, "out-quad", rem)
            playGooiSound()
        end
        
        noButton:onRelease(no)

        
        local function yes()
            self:tween(.4, self, {cover_alpha=1.4}, "out-quad", love.event.quit)
        end
        
        yesButton:onRelease(yes)
        
        
        self.quit = panel
    end
end

function Menu:draw_before_gooi(dt)
    local HH = H()*2
    
    self.rr = (self.rr or 0) + dt
    local r,g,b,a = set_color(.9, .9, .9)
    draw_rect("fill", -W(), -H()*.5, W()*4, H()*3+10)
    
    set_color(.1, .1, .8)
    local n = 30
    for x = 1, HH/n do
        lg.line(-W(), -H()*.5+(H()/n)*x, W()*4, -H()*.5+(H()/n)*x)
    end
    
    set_color(.9, .2, .1)
    lg.line(50, -H()*.5, 50, H()*4)
    
    set_color(r,g,b,a)
    
end

LoadMenu = toybox.Room("LoadMenu")

function LoadMenu:setup()
    self.cover_alpha = 1
    self:tweenCoverAlpha(.3, 0)
    
    local uw, uh = W()*.7, H()*.45
    local ux, uy = W()/2-uw/2, H()/2-uh/2-100
    
    
    local bw = uw*.8
    local bh = 50
    local xx = W()/2-bw/2
    local yy = H()/2+bh*2
    self.bar = toybox.ProgressBar({
        x = xx, y = yy,
        w = bw, h = bh,
        progress = 10,
        --glows = "white",
        totalColor = {1,1,1,0},
        progressColor = colors.yellow
    })
    self.freeze = nil
    
    
    self.taps = 0
    
    local function start()
        self.speedUp = function()
            self.speedUp = nil
            self.timer:cancel(self.ev)
            self:tween(math.random(4,6)/10, self.bar, {progression=101}, "in-quad")
        end
    
        self.bar:setProgress(1)
        local ev = self:every({1,.5,.4,.3,.2,.5,.2,.3,.2},function() self.bar:progress(math.random(1,3)) end)
        self.ev = ev
        self.af = self:after(5+math.random(30,50)/10, self.speedUp)


    
        local loadTexts = {
            "Rewriting curriculum\n...",
            "Building new exam halls\n...",
            "Appointing Course Advisor\n...",
        }
        local lLoadTexts = lume.copy(loadTexts)
    
        self.makeNewText = function()
            if self.waitText then
                return
            end
            
            if self.label and self.label.texty.done then
                gooi.removeComponent(self.label)
                self.label = nil
            elseif self.label then
                return
            end
            
            local w = W()*.65
            local font = font18--getValue({font15, font15, mario_font17, font15})
            self.label = self.label or gooi.newLabel({
                x = W()/2-w/2,
                y = yy-font:getHeight()+30,
                font = font,
                w = w, h = w,
                text = toybox.room == self and lume.eliminate(lLoadTexts):upper() or "",--"Rebuilding schools\n...",
                instant = false,
                --scale = .5
            })
            
            --self.label.texty.scale = .5
            
            if #lLoadTexts <= 0 then
                lLoadTexts = lume.copy(loadTexts)
            end
        end
        
        self:every(2, self.makeNewText)
        self.makeNewText()
        
    
    
    end
    
    self:activate_gooi()
    
    if not gdata.name then
        self:activate_gooi()
        self:after(.4, AskForPlayerDetails)
        self.egP = true
        self.startBar = start
    else
        start()
    end
    
end

function LoadMenu:mousereleased()
    self.taps = self.taps+1
    if self.taps > math.random(3,5) and self.speedUp then
        self.timer:cancel(self.af)
        self.speedUp()
    end
end

function LoadMenu:update(dt)
    if not game.renderStartedUp then
        love.graphics.present()
        game.renderStartedUp = true
    end
    
    if self.startBar then
        if not self.egP then
            self.startBar()
            self.startBar = nil
        end
    end
end

function LoadMenu:draw(dt)
    
    if self.bar.progression >= 100 then
        if not self.started and self.canMoveOn then
            self.started = true
            self:tweenCoverAlpha(.4,1)
            self:after(math.random(5,12)/10, function()
                gooi.components = {}
                game:set_room(Menu)
            end)
        end
        self.bar.progression = 100
    end
    
    self.bar:draw()
        
    local bimg = game:getAsset("resultBarUI.png")
    local nn = 15--10
    lg.draw(bimg, self.bar.x-nn, self.bar.y-nn, 0, resizeImage(bimg, self.bar.w+nn*2, self.bar.h+nn*2))
    
    if self.bar then

        local func = function()
            lg.setShader(mask_shader)
            local bimg = game:getAsset("resultBarUI.png")
            self.bar.drawFrame = null
            local nn = 3--10
            self.bar:draw()
            lg.draw(bimg, self.bar.x-nn, self.bar.y-nn, 0, resizeImage(bimg, self.bar.w+nn*2, self.bar.h+nn*2))
            lg.setShader()
        end
    
        
        love.graphics.stencil(func,  "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        
        local r,g,bb,a = love.graphics.getColor()
        
        local p = love.graphics.getLineWidth()
        local pp = 0--p*4
        love.graphics.setLineWidth(10)
        
        local line = love.graphics.line
        
        love.graphics.setColor(0,0,0)
        
        local b = self.bar
        local bx = b:getLoadedWidth()+b.x
        line(bx, b.y, bx, b.y+b.h)
        
        lg.setLineWidth(p)
        lg.setColor(r,g,bb,a)
        
        lg.setStencilTest()
        
    end
    
    gooi.draw()
end

LoadMenu.ddr = LoadMenu.draw
LoadMenu.draw_before_gooi = Menu.draw_before_gooi

do
    local fontName = true and "course_rep/chalkboard.ttf" --varsity_regular.ttf" or "course_rep/karate.ttf"--wild_words.ttf" or "coingame/seaside_resort.ttf"--nest/potato.otf"--"c"--wild_words.ttf"--""c"
    
    cfont = love.graphics.newFont(fontName)
    font40 = love.graphics.newFont(fontName,H(80))
    font30 = love.graphics.newFont(fontName,H(75))
    font20 = love.graphics.newFont(fontName,H(55))
    font19 = love.graphics.newFont(fontName,H(40))
    font18_5 = love.graphics.newFont(fontName,H(35))
    font18 = love.graphics.newFont(fontName,H(30))
    font17 = love.graphics.newFont(fontName,H(25))
    font15 = love.graphics.newFont(fontName,H(22))
    font13 = love.graphics.newFont(fontName,H(20))
    font10 = love.graphics.newFont(fontName,H(17))
    font8 = love.graphics.newFont(fontName,H(15))
    font7_5 = love.graphics.newFont(fontName,H(15)-1)
    font7 = love.graphics.newFont(fontName,H(14))
    font5 = love.graphics.newFont(fontName,H(11))
    love.graphics.setFont(font8)
    
    
    local fontName = true and "course_rep/mario.ttf" --varsity_regular.ttf" or "course_rep/karate.ttf"--wild_words.ttf" or "coingame/seaside_resort.ttf"--nest/potato.otf"--"c"--wild_words.ttf"--""c"
    
    cfont = love.graphics.newFont(fontName)
    mario_font40 = love.graphics.newFont(fontName,H(100))
    mario_font30 = love.graphics.newFont(fontName,H(75))
    mario_font25 = love.graphics.newFont(fontName,H(60))
    mario_font20 = love.graphics.newFont(fontName,H(55))
    mario_font18 = love.graphics.newFont(fontName,H(30))
    mario_font17 = love.graphics.newFont(fontName,H(25))
    mario_font13 = love.graphics.newFont(fontName,H(20))
    mario_font10 = love.graphics.newFont(fontName,H(17))
    mario_font8 = love.graphics.newFont(fontName,H(15))
    mario_font7_5 = love.graphics.newFont(fontName,H(15)-1)
    mario_font7 = love.graphics.newFont(fontName,H(14))
    mario_font5 = love.graphics.newFont(fontName,H(11))
    love.graphics.setFont(mario_font8)
    
    
    local fontName = true and "course_rep/kb.ttf" --varsity_regular.ttf" or "course_rep/karate.ttf"--wild_words.ttf" or "coingame/seaside_resort.ttf"--nest/potato.otf"--"c"--wild_words.ttf"--""c"
    
    cfont = love.graphics.newFont(fontName)
    --mario_font40 = love.graphics.newFont(fontName,H(100))
    --mario_font30 = love.graphics.newFont(fontName,H(75))
    kb_font25 = love.graphics.newFont(fontName,H(60))
    kb_font20 = love.graphics.newFont(fontName,H(55))
    kb_font19 = love.graphics.newFont(fontName,H(50))
    --[[mario_font17 = love.graphics.newFont(fontName,H(25))
    mario_font13 = love.graphics.newFont(fontName,H(20))
    mario_font10 = love.graphics.newFont(fontName,H(17))
    mario_font8 = love.graphics.newFont(fontName,H(15))
    mario_font7_5 = love.graphics.newFont(fontName,H(15)-1)
    mario_font7 = love.graphics.newFont(fontName,H(14))
    mario_font5 = love.graphics.newFont(fontName,H(11))
    love.graphics.setFont(mario_font8)]]
 
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
        borderWidth = 7,--1.5,--love.window.toPixels(2), -- in pixels
        radius = 10
    })
    
    -- gooi.secondBorder = {x=-7, y=0, oneSideX=true}
    
    gooi.desktopMode()
    gooi.roughShapes()
end

scale = 1--592,296
sscale = 1
_W, _H = 640,1336,720,1280
_W, _H = 720*sscale,1280*sscale,296*2/scale,592*2/scale

tw, th = 50, 50
aspect.setGame(_W, _H)
-- love.window.setMode(2,1)

req("extra")
ScoreMenu.draw_before_gooi = Menu.draw_before_gooi

req("data")
dialogs = req("talkdata")

game = toybox.Game("game")

MAX_ENERGY = math.random(3,4)
OG_MAX_ENERGY = MAX_ENERGY
ENERGY_TIME = 5*60

function checkEnergy()
    gdata.lastDonated = gdata.lastDonated or 2500
    gdata.donatedTime = (gdata.donatedTime or 0)--os.time())
    gdata.lastDonated = os.time()-gdata.donatedTime
    
    if gdata.energy >= MAX_ENERGY or gdata.hack then
        return gdata.energy
    end
    
    gdata.energyTime = (gdata.energyTime or os.time())
    gdata.timeToNextEnergy = os.time()-gdata.energyTime
    if gdata.timeToNextEnergy >= ENERGY_TIME then
        gdata.energy = lume.min(MAX_ENERGY, gdata.energy+math.floor(gdata.timeToNextEnergy/ENERGY_TIME))
        gdata.energyTime = os.time()
    end
    
    -- gdata.energy = 10
    
    return gdata.energy
end

LEVEL_EXP_SCORES = {
    [1] = 150+20,
    [2] = 700,
    [3] = 1450,
    [4] = 2990,
    [5] = 6500,
    [6] = 7000,
    [7] = 12000,
    [8] = 14000,
    [9] = 16300,
    [10] = 20000,
    [11] = 29000
}

LEVEL_EXP = function(level)
    level = level or gdata.level
    return LEVEL_EXP_SCORES[level] or 1000*(level)
end

LEVEL_TEXTS = {
    [1] = {"small pikin", "unsuspecting", "newborn", "fresher"},
    [2] = {"oblivious", "enthusiastic", "you still attend every class"},
    [3] = {"It don red", "001 formation", "you have 6am classes"},
    [4] = {"Drop results nau", "Waiting for results", "@Brrrrrrrrr", "#Jesus is @Lord"},
    [5] = {"Graduate?", "Heat wan killll", "Sun wan kill person", "Drenched in sweat", "heatstroke ooooh"},
    [6] = {"Course Rep. Regime", "Tired of the struggle", "School don tire", "Uni dey lag"},
    [7] = {"You don chop rubbish", "Semester don fall hand"},
    [8] = {'"Let them eat the attendance"', '"If I perish I perish"'},
    [9] = {"@Drop out??"},
    [10] = {"Abeg, make I rest"},
    [11] = {"Oga boss!!!!!!!!!!"}
}
    

function game:setup()

    self:setSource("course_rep/assets/%s")
    
    media.load(req("sfx_data"))
    songs = req "songs"
    
    --[[self.timer:every(3.8, function()
       -- toybox.room:play_sound("yah", math.random(600,1500)/1000, 1)
    end)]]
    
    local function song()
        loadSong(getValue(titleSongs), nil, 2)--"carnival_of_strangeness",1)
    end
    
    local load3, load4
    
    local function load1()
        local count = 0
        for name, char in pairs(not {} or characters) do
            game:getAsset(string.format("people/%s/body.png", name))
            game:getAsset(string.format("people/%s/face.png", name))
            game:getAsset(string.format("people/%s/head.png", name))
            count = count + 1
            if count > 10 then break end
        end
        
        toybox.room.waitText = true
        toybox.room:after(.5, load3)
    end
    
    
    function load3()
        local count = 0
        for name, char in pairs(not {} or characters) do
            game:getAsset(string.format("people/%s/body.png", name))
            game:getAsset(string.format("people/%s/face.png", name))
            game:getAsset(string.format("people/%s/head.png", name))
            count = count + 1
            if count > 20 then break end
        end
        
        if toybox.room.speedUp then
            toybox.room.speedUp()
        end
        
        toybox.room.waitText = true
        toybox.room:after(.8, load4)
    end
    
    function load4()
        for name, char in pairs(not {} or characters) do
            game:getAsset(string.format("people/%s/body.png", name))
            game:getAsset(string.format("people/%s/face.png", name))
            game:getAsset(string.format("people/%s/head.png", name))
        end
        
        
        toybox.room.waitText = false
    end
    
    local function load2()
    game:getSource("title/course.png")
    game:getSource("title/rep.png")
    game:getSource("title/course_rep.png")
    game:getSource("title/101.png")
    game:getSource("title/tap0.png")
    game:getSource("title/tap1.png")
    game:getSource("title/tap2.png")
    
    
    game:getSource("border_back_r.png")
    game:getSource("border_empty.png")
    
    game:getSource("energyPanel.png")
    end
    
    local function waitFor(func)
        local tim
        local function val()
            if toybox.room and (not toybox.room.label or toybox.room.label.texty.done) and gdata.name then
                func()
                toybox.room.canMoveOn = (toybox.room.canMoveOn or 0)+1
                toybox.room.timer:cancel(tim)
            end
        end
        
        local function repeat_()
            tim = toybox.room.timer:every(.3, val)
        end
        
        return repeat_
    end
    
    game.timer:after(1, waitFor(load2))
    game.timer:after(2, waitFor(load1))
    
    for num = 1, 4 do
        game:getSource(string.format("panels/%s.png", num))
    end
    
    
    
    self.data = toybox.getData("course_rep")
    gdata = self.data
    
        
    if gdata.gamePlayed then
        self.timer:after(2, song)
    end
    
    gdata.energy = gdata.energy or 2
    gdata.energyTimer = 0
    
    gdata.unlocked = gdata.unlocked or {}
    
    gdata.level = gdata.level or 1
    gdata.levelExp = gdata.levelExp or 10
    gdata.levelText = gdata.levelText or getValue(LEVEL_TEXTS[gdata.level])
    
    gdata.totalGP = gdata.totalGP or 0
    gdata.totalPlays = gdata.totalPlays or 0
    gdata.playTime = gdata.playTime or 0
    
    gdata.choices = gdata.choices or 0

    -- media.load(req("sfx_data"))
    -- energy
    
    tryToInitializeWallet()

    self.scoreCoverAlpha = 0
    self:set_room(LsdoadMenu or Menu2)--LoadMenu)--GameScreen)--LoadMenu)--GameScreen)--duties
    -- toybox.room:after(3, function() love.timer.sleep(3) end)
    
    
    MAX_ENERGY = OG_MAX_ENERGY+math.floor((gdata.level-1)/4)
end


function game:printErrorMessage(message, color)
    local h = 200
    local gb = gooi.newLabel({text=message, w=W()*1.3, x=W()*.5-W()*1.3*.5, y=H()-h, h=h*1.5})
    gb.ogy = gb.y
    gb.y = H()+gb.h*1.5
    local outy = gb.y
    gb.yOffset = 10
    gb.opaque = true
    gb.bgColor = getColor(color or {1,1,1,1})
    local shake = function()
        toybox.room.camera:shake(20, .25, 20)
    end
    
    self.gb = gb
    
    self.timer:tween(.85, gb, {y=gb.ogy}, "in-quad", shake)
    local funcOut = function()
        self.timer:tween(color == "lightred" and 2 or 3.4, gb, {y=outy}, "out-quad", function()
            gooi.removeComponent(gb)
            self.gb = nil
        end)
    end
    self.timer:after(color == "lightred" and 2.5 or 3.4, funcOut)
end

function game:draw()
    
    if self.gb then
        gooi.drawComponent(self.gb)
    end
    
    if self.online or self.scoreCoverAlpha > .5 then
        local r,g,b,a = set_color(0,0,0,self.scoreCoverAlpha*.95)
        draw_rect("fill", -W(), -H(), W()*4, H()*4)
        
        set_color(1,1,1,self.scoreCoverAlpha)
        
        local font = mario_font18
        local text = self.onlineText or "Finding online scores..."
        local h = font:getHeight()
        local w = font:getWidth(text)
        
        local f = lg.getFont()
        lg.setFont(font)
        lg.print(text, W()/2-w/2, H()/2-h/2)
        lg.setFont(f)
        
        set_color(r,g,b,a)
    end
end

function game:unlockCharacter(fromDonor)
    
    if  (fromDonor or gdata.level >= math.random(3,5) or math.random(100000)<=2 ) and not gdata.unlocked.nameless then
        local c = "nameless"
        local char = characters[c]
        
        if true then--char.locked and not gdata.unlocked[c] then
            gdata.unlocked[c] = true
            log("One without a name now lurks...")
            self:printErrorMessage("One without a name now lurks...", {.8, .2, .8, 1})
            return
        end
    end
    
    local key = lume.shuffle(lume.keys(characters))
    
    while #key > 0 do
        local c = lume.eliminate(key)
        local char = characters[c]
        
        if char.locked and not gdata.unlocked[c] then
            gdata.unlocked[c] = true
            log(string.format("UNLOCKed %s", c))
            self:printErrorMessage(string.format("UNLOCKed %s", c), "gold")
            break
        end
    end
end

function game:saveData()
    return toybox.saveData("course_rep")
end

function game:startGame()
    gooi.components = {}
    self:set_room(GameScreen)
end

function game:step(dt)
    Network.update()
end

function game:doKeyPress(key)
    if key == "f11" then
        local fullscreen, fstype = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen, fstype)
    end
end

function game:get_volume(s)
    return 1.85--.25
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

function love.graphics._print(texty, x, y, ang, sx, sy, ...)
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
