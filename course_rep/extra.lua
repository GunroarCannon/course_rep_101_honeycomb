
ScoreMenu = toybox.Room("ScoreMenu")

function ScoreMenu:setup()
    ttime = 2
    gooi.components = {}
    
    local uw, uh = W()*.7, H()*.45
    local ux, uy = W()/2-uw/2, H()/2-uh/2-100
    self.cover_alpha = 1
    self:tween(.85, self, {cover_alpha=0}, "in-quad")
    
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
    
    self.speedUp = function()
        self.speedUp = nil
        self.timer:cancel(self.ev)
        self:tween(math.random(4,6)/10, self.bar, {progression=101}, "in-quad")
    end
    
    self.taps = 0
    self.bar:setProgress(1)
    local ev = self:every({1,.5,.4,.3,.2,.5,.2,.3,.2},function() self.bar:progress(math.random(1,3)) end)
    self.ev = ev
    self.af = self:after(5+math.random(30,50)/10, self.speedUp)
    
    if not game.scoreSubmitted and gdata.highscore then
        
        if scoreboard:submitScore(gdata.name, gdata.totalGP) and weeklyScoreboard:submitScore(gdata.name, gdata.weekly or gdata.highscore) then
        -- if scoreboard:submitScore(gdata.name, gdata.highscore) then
            game.scoreSubmitted = true
        end
    end
    
    local function getScoresTotalText()
        log("total getting")
        self._scoreboard = scoreboard
        
        if self.scoresTotalText then
            self.scores = self.scoresTotal
            return self.scoresTotalText
        end
        
        local scores = scoreboard:getScores(ttime)
        local text
        if scores then
            text = " \n  "
            local default = {member_id="...", score=""}
             for x = 1, 5 do
                local i = scores[x] or default
                local t = string.format("%s) %s ... %sGP", x, i.member_id, i.score)
                text = string.format("%s\n%s", text, t)
            end
        end
        self.scoresTotal = scores
        self.scores = scores
        self.scoresTotalText = text
        log(self.scores and "yes scoreessssss" or "no scores?")
        return text
    end
    
    local function getScoresWeeklyText()
        self._scoreboard = weeklyScoreboard
        log("weekly getting")
        
        if self.scoresWeeklyText then
            self.scores = self.scoresWeekly
            return self.scoresWeeklyText
        end
        
        local scores = weeklyScoreboard:getScores(ttime)
        local text
        if scores then
            text = " \n  "
            local default = {member_id="...", score=""}
             for x = 1, 5 do
                local i = scores[x] or default
                local t = string.format("%s) %s ... %sGP", x, i.member_id, i.score)
                text = string.format("%s\n%s", text, t)
            end
        end
        self.scoresWeekly = scores
        self.scores = scores
        log(self.scores and "weekly yes scoreessssss" or "no scores?")
        self.scoresWeeklyText = text
        return text
    end
    
    local function donateEnergy()
        local scores = e_scoreboard:getScores()
        
        if scores then
            local score = scores
            local energy = math.random(1, gdata.energy) 
            if e_scoreboard:submitScore(gdata.name, energy) then
                gdata.energy = gdata.energy - energy
                return true
            end
        end
        
        game:printErrorMessage("Action failed: Check Network Connection?")
        -- failed
    end
    
    getScoresTotalText()
    
    self:activate_gooi()
    local w, h = W()*.9, H()*.3
    self.scoreboard = gooi.newLabel({
        x = W()/2-w/2, y = 50,
        w = w, h = h,
        font = font19
    }):setOpaque(true):left():setText(
    self.scoresTotalText or [[
    
        @Connection Problem
        
        ~ CLICK HERE TO RELOAD.
]])
    if not self.scoresTotalText then
        self.scoreboard:center()
    else
        self.scoreboard.yOffset = 15+20
        self.scoreboard.xOffset = 15
    end
    
    self.scoreboard.borderWidth = 10
    local sc = self.scoreboard
    local simg = sc:addImage("scoreboard_1.png")
    sc.onlyImage = true
    sc.currentScoreboard = 1
    
    self.connectionProblem = not self.scores--text
    
    self.tmp = gooi.newLabel({x=-100,y=-100,text=""})
    
    local function reload()
        local tt = 0
        game.timer:tween(tt, game, {scoreCoverAlpha=1}, f)
        game.online = true
        game.timer:after(tt+.4, function()
            game:set_room(ScoreMenu)
        end)
    end
    
    local setScoreboardText
    
    function setTextTotal()
        local text = getScoresTotalText() log(self.scores and "scoores")
        setScoreboardText(text)
    end
        
    function setTextWeekly()
        local text = getScoresWeeklyText()
        setScoreboardText(text)
    end
        
    function setScoreboardText(text)
    
        local scores = self.scores
        local notError = self._scoreboard.code ~= 0
        self.connectionProblem = not scores and notError
        
        
        local me, old, next
        if scores then
            for x, i in ipairs(scores) do
                if i.member_id == gdata.name then
                    me = x
                    break
                end
            end
        
            if me then
                if scores[me-1] then
                    old = scores[me-1]
                else
                    old = false
                
                end
            
                if scores[me+1] then
                    next = scores[me+1]
                else
                    next = false
                end
            end
        
            me = scores[me]
        end
    
        self.placementScore:setText(
me and string.format([[YOU RANKED &colors.darkblue NUMBER %s ~ with #%s GP]], me.rank, me.score) or scores and (game.scoreSubmitted and "Your rank is missing or too low..." or "Your score failed to submit (bad network)") or notError and "A problem occured, please reload" or "Connection problem, couldn't find ranking")

        if self.placeTimer then
            self.timer:cancel(self.placeTimer)
        end
        
        if self.placementScore2 then
            self.placementScore2:setText("")
        end
        
        local function doit()
    
            if not self.placementScore.texty.done then
                return
            end
            
            -- self.doit = nil
    
            self.timer:cancel(self.placeTimer)
            --  self.placeTimer = nil
            
            local nh = -50
            
            if not self.placementScore2 then
  
    
                  self.placementScore2 = gooi.newLabel({
                      x = W()/2-w/4, y = h+100+font19:getHeight()*2+nh,
                      w = w, h = h,
                      font = font19, instant=false
                  }):setOpaque(false):left()
              end
               
               self.placementScore2:setText(
    
                me and string.format("&colors.grey %s%s%s%s%s &{0,0,0} %s%s%s%s&colors.grey %s%s%s",
                old and string.format("%s) ", old.rank) or "",
                old and old.member_id or "",
                old and string.format(" ... %sGP", old.score) or "",
                old and "\n" or "",
                string.format("...\n%s) ", me.rank),
                me.member_id,
                string.format(" ... %sGP", me.score or "?"),
                "\n...",
                next and "\n" or "",
                next and string.format("%s) ", next.rank) or "",
                next and next.member_id or "",
                next and string.format(" ... %sGP", next.score) or "\n..."
            ) or 
            scores and "Your result is @missing?" or notError and "\n  Results are @missing" or 
            "@Connection Problem")
        end
        
        self.placeTimer = self.timer:every(.3, doit)
        self.doit = doit
        
        self.scoreboard:setText(
            text or notError and "\n  \n  \n  Results are empty?" or [[
    
        @Connection Problem
        
        ~ CLICK HERE TO RELOAD.
]])
        if not text then
            self.scoreboard:center()
        else
            self.scoreboard.yOffset = 15+20
            self.scoreboard.xOffset = 15
            self.scoreboard:left()
        end
    end
    
        
    local function switch()
        playGooiSound()
        self.tmp:shake(30,.2,25)
        
        if self.connectionProblem then
            self:after(.1, reload)
            return
        end
        
        if sc.currentScoreboard == 1 then
            sc.currentScoreboard = 2
            simg.source = "scoreboard_2.png"
            self.scoreboard:setText("\n  \n  \n..."):center()
            self:after(.3, setTextTotal)
        else
            sc.currentScoreboard = 1
            simg.source = "scoreboard_1.png"
            self.scoreboard:setText("\n  \n  \n..."):center()
            self:after(.3, setTextWeekly)
        end
    end
    
    sc:onRelease(switch)
    self.scoreLabels = {}
    -- error(w..","..h)
    for sbx = 1, 2 do
    local w = self.scoreboard.w/2
    local sb = gooi.newLabel({
        x = W()/2-w+(sbx==1 and 0 or w), y = 50,
        w = w, h = h,
        font = font18_5
    }):setText(sbx == 1 and "Top Weekly Score" or "Top Overall Scores"):left()
    sb.yOffset = 15
    sb.xOffset = 0
    
    sb.transformParent = sc
    
    self.scoreLabels[sbx] = sb
    end
    
    local nh = -50
    
        
    local me, old, next
    if scores then
        for x, i in ipairs(scores) do
            if i.member_id == gdata.name then
                me = x
                break
            end
        end
        
        if me then
            if scores[me-1] then
                old = scores[me-1]
            else
                old = false
                
            end
            
            if scores[me+1] then
                next = scores[me+1]
            else
                next = false
            end
        end
        
        me = scores[me]
    end
    
    self.placementScore = gooi.newLabel({
        x = W()/2-w/2, y = h+50+nh-50-50,
        w = w, h = h,
        font = font20, instant=false
    }):setOpaque(false):setText(
me and string.format([[YOU RANKED &colors.darkblue NUMBER %s ~ with #%s GP]], me.rank, me.score) or scores and (game.scoreSubmitted and "Your rank is missing or too low..." or "Your score failed to submit (bad network)") or "Connection problem, couldn't find ranking")
    
    local w = w
    
    local function doit()
    
        if not self.placementScore.texty.done then
            return
        end
    
        self.timer:cancel(self.placeTimer)
    
    self.placementScore2 = gooi.newLabel({
        x = W()/2-w/4, y = h+100+font19:getHeight()*2+nh,
        w = w, h = h,
        font = font19, instant=false
    }):setOpaque(false):left():setText(
    
    me and string.format("&colors.grey %s%s%s%s &{0,0,0} %s%s%s%s&colors.grey %s%s%s",
        old and string.format("%s) ", old.rank) or "",
        old and old.member_id or "",
        old and string.format(" ... %s", old.score) or "",
        old and "\n" or "",
        string.format("%s) ", me.rank),
        me.member_id,
        string.format(" ... %s", me.score),
        next and "\n" or "",
        next and string.format("%s) ", next.rank) or "",
        next and next.member_id or "",
        next and string.format(" ... %s", next.score) or ""
    ) or 
    scores and "Your result is @missing?" or
    "@Connection Problem" or 
[[&colors.grey 29) Francis ... 40pt ~
&{0,0,0} 30) GunroarC ... 30pt ~
&colors.grey 31) Rumis ... 10pt
]])
    end
    
    self.placeTimer = self.timer:every(.3, doit)
    self.doit = doit
    
    local w = W()*.3*1.5
    self.awardLabel = gooi.newButton({
        w = w, h = w, x = W()/2-w/2, y = H()-w-80
    }):setText("")
    self.awardLabel:addImage("ratingPanel.png")
    self.awardLabel.onlyImage = true
    self.awardLabel.showBorder = false
    local aw = self.awardLabel
    
    local function award()
        local am = gdata.lastScore or 0
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
        rating:addImage(string.format("rankings/%s.png", rank))
        local function endFunc()
            if not self.shakenAW then
                aw:shake(15, .16, 15)
                self:play_sound("whack")
                self.shakenAW = true
            end
        end
        self:tween(.6, rating, {x=aw.x, y=aw.y, w=aw.w, h=aw.h}, "in-quad", endFunc)
    
    end
    
    self.award = award--scores and award or null
    
    setTextTotal()
    setTextWeekly()
    
    game.timer:tween(.1, game, {scoreCoverAlpha=0}, "out-quad")
    game.online = false
end

function ScoreMenu:mousepressed()
    self.pressedDown = true
end

function ScoreMenu:mousereleased()
    self.pressedDown = nil
    
    self.taps = self.taps+1
    if self.taps > math.random(3,5) and self.speedUp then
        self.timer:cancel(self.af)
        self.speedUp()
    end
    
    
    if true then
        local s = 50
        while self.placementScore and not self.placementScore.texty.done do
            for x = 1, s do
                self.placementScore.texty:update(1/30)
            end
        end
        self.doit()
        while self.placementScore2 and not self.placementScore2.texty.done do
            for x = 1, s do
                self.placementScore2.texty:update(1/30)
            end
        end
    end
    
end

function ScoreMenu:keyreleased(k)
    if k and not game.online then
        game:set_room(Menu2)
    end
end

function ScoreMenu:draw(dt)
    self.scoreboard.angle = self.tmp.shake_x
    for x, sb in ipairs(self.scoreLabels) do
       -- sb.angle = self.scoreboard.angle
    end
    
    if self.pressedDown then
        local s = 4
        if self.placementScore and not self.placementScore.texty.done then
            for x = 1, s do
                self.placementScore.texty:update(1/30)
            end
        end
        
        if self.placementScore2 and not self.placementScore2.texty.done then
            for x = 1, s do
                self.placementScore2.texty:update(1/30)
            end
        end
    end
    
    if self.placementScore2 and self.placementScore2.texty.done then
        if self.award then
            self.award()
            self.awardn = (self.awardn or 0)+1
            if self.awardn > 10 then
                self.award = nil
            end
        end
    end
end