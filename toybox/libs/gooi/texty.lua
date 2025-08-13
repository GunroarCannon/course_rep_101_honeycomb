local textEffects = {
	"~", --resets all effects
	"_", --has a brief pause in the text, which is double the length of a normal character time span
	"#", --makes text wave
	"@", --makes text shake
	"$", --makes text the current highlight colour,
	"&"  --set color/real code, no gaps in between
}
Sentence = {
	words = {},
	options = {},
	
	effects = {},
	
	text = nil,
}
local dCol = {1,1,1}--3/255,39/255,3/255}
local dCol2 = {.7,.2,.5}
local dCol3 = {.7,.7,.2}

local function getCutText(text)
	local cutText = text
    	for z = 1, #textEffects do
    	    local old = cutText
		    cutText = z == 6 and cutText:gsub("&[^%s]+", "") or cutText:gsub("%"..textEffects[z], "")
		    lastN = nil
		end
	return cutText
end

local function split(inputstr, sep)
	if sep == nil then
		sep = " "
	end
	local t={}
	local clumps = {}
	local currentClump = 1
	
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		if str=="\n" then  end table.insert(t, str)
	end
	local tt = {}
	for x, i in ipairs(t) do
	    local tex = ""
	    for st = 1, #i do
	        if i:sub(st,st) == "\n" then
	            table.insert(tt,tex)
	            clumps[#tt] = currentClump
	            tex = ""
	            table.insert(tt,"\n")
	            currentClump = currentClump+1
	            clumps[#tt] = currentClump
	            
	        else
	            tex = tex..i:sub(st,st)
	            if st == #i then
	                table.insert(tt,tex)
	                clumps[#tt] = currentClump
	           end
	       end
	        
	    for str in string.gmatch(inputstr, "([^".."\n".."]+)") do
	    	--if str=="\n" then  end table.insert(tt, str)
	    end end
	end
	--assert(#tt==0,inspect(clumps))

	
	return tt, #clumps==0 and {""} or clumps
end

function Sentence:new(k)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	k = k or {}
	
	o.words = {}
	o.options = {}
	
	o.effects = {}
	
	o.text = nil
	
	o.pause = k.time or k.pause or .1
	o.waveSpeed = k.wave or k.waveSpeed or textyWaveSpeed
	o.shakeSpeed = k.shake or k.shakeSpeed or textyShakeSpeed
	
	o.instant = k.immediate or k.instant
	
	o.w = k.w or 100
	o.x = k.x or 0
	o.y = k.y or 0
	
	o.h = 0
	
	o.color = k.color
	o.highlight = k.highlight or dCol3
	o.sound = k.sound
	
	o.font = k.font or love.graphics.getFont()
	o.scale = k.scale
	
	o.alpha = k.alpha
	
	o.fixedClumps = {}
	
	return o
end

function Sentence:newText(text, instant)
	self.text = text
	self.words = {}
	local count = 0
	
	local tempWords, clumps = split(text)-- log(inspect(tempWords))
	--assert(#tempWords==0,inspect((split(text,"\n"))))
	self.clumps = {}
	self.tempWords = tempWords
	local tts = ""
	local lastN
	for z = 1,lume.max(#tempWords, 1) do
	    local w = Word:new(tempWords[z] or "", instant or self.instant)
	    w.z = z
		table.insert(self.words,w)
		w.index = #self.words
		count = count + w.letterCount
		local cutText = w.text
    	for z = 1,#textEffects do
    	    local old = cutText
		    cutText = z == 6 and cutText:gsub("&[^%s]+", "") or cutText:gsub("%"..textEffects[z], "")
		    if z == 6 and old ~= cutText then
		        cutText = ""
		        lastN = true
		        break
		    elseif lastN == true and cutText == "\n" then
		        cutText = ""
		    end
		    lastN = nil
		end
		w.cutText = cutText
	    if true then
		    tts = tts.." "..cutText
		end
		--table.insert(self.words,Word:new(" "))
	end
	self.shortText = tts--if self.font==font5 then error(tts) end
	
	

	for i,o in pairs(self.words) do
		o:load(self) if not clumps[(o.z)] then error(inspect(clumps)..o.z) end
		self.clumps[clumps[o.z]] = (self.clumps[clumps[o.z]] or "")..(o.colorer and "" or o.cutText).." "--0)+o.len+12
		o.clump = clumps[o.z]
	end
	self.activeWord = 1
	self.words[self.activeWord].active = true
	
	for z = 1,#textEffects do
		self.effects[z] = false
	end
	
	self.done = false
	
	if instant or self.instant then
    	for i,o in pairs(self.words) do
	        o.active = true
	        for xx = 1, o.letterCount do
	            o:update(1,true)
	            if not o.active then
	                break
	            end
	            for x, i in pairs(o.letters) do
	                i:update(1/30)
	            end
	        end
	    end
	    self.done = true
	end
	
	self:draw()
	
	return self
end

function Sentence:update(dt)
	local isActive = false
	for i,o in pairs(self.words) do
		o:update(dt)
		if o.active then
			isActive = true
		end
	end
	if not isActive and self.activeWord then
		self.activeWord = self.activeWord + 1
		if self.activeWord <= #self.words then
			self.words[self.activeWord].active = true
		else
		    self.done = true
		end
	end
end


function Sentence:getWordClumps()
    local of = love.graphics.getFont()
	if self.font then
	    love.graphics.setFont(self.font)
	end
	
	local f = love.graphics.getFont()
	local r,g,b,a = love.graphics.getColor()

	
	local xx = (not self.centered and 0) or -self.w/4
	local scale = self.scale or 1
	local yy = 0
	local spaceLen = (self.spaceLen or love.graphics.getFont():getWidth(" ") or 12)*scale
	local letH = love.graphics.getFont():getHeight()*scale*1.2
	local spacing = 8*scale
	local wordX = 0--(not self.centered and 0) or (self.w-spaceLen)/2
	local wordY = 0
	local wordW = 0
	local realX = nil
	local oo,so

	
	self.h = letH
	self.baseH = letH
	
	local words = {}
	word = nil
	for i,o in pairs(self.words) do
	    
		-- font might change after text obj was already made?
		o.len = o.len> 0 and f:getWidth(o.cutText) or o.len
	    
		if realX and ((not self.noWordwrap and (wordX + o.len*scale > self.w-spaceLen*scale)) or (oo and oo.skipped)) and oo then -- only move on if not first word
			self.toSkip = (wordX + o.len > self.w-spaceLen)
			wordX = 0--(not self.centered and 0) or (self.w-spaceLen)/2--0
			wordY = wordY + letH
			realX = nil
			self.h = self.h + letH
			wordW = 0
			soo = 1
			words[#words+1] = word
			word = nil
		end
		
		o.alpha = self.alpha
		
		
		o.clumpID = #words+1
		
		word = string.format("%s%s%s", word or "", word and " " or "", o.cutText)
		
		wordW = (not self.centered and 0) or o.len == 0 and 0 or f:getWidth(o.cutText or self.clumps[o.clump])*scale
		
		-- o:draw((self.x+spacing+wordX)-wordW/(self.toSkip and 1 or 1),self.y+spacing+wordY-yy,scale,f)

		realX = (realX or (self.x+spacing+wordX)-wordW/(1))+o.len*scale
		- ((o._coloring or o.antiColoring) and spacing or 0)
		
		wordX = wordX + spaceLen*(1 or o and yho and 3 or 1)*scale + o.len*scale
	
		oo = o
	end
	
	if word then
	    words[#words+1] = word
	    word = nil
    end
    
	self.h = wordY+letH
	
	self.wordClumps = words

	love.graphics.setColor(r,g,b,a)
	love.graphics.setFont(of)
end

function Sentence:draw()
    self:getWordClumps()
    
    local of = love.graphics.getFont()
	if self.font then
	    love.graphics.setFont(self.font)
	end
	
	local f = love.graphics.getFont()
	local r,g,b,a = love.graphics.getColor()
	
	if self.debug then
	    draw_rect("line",self.x,self.y,self.w,self.w)
	end
	
	local xx = (not self.centered and 0) or -self.w/4
	local scale = self.scale or 1
	local yy = 0
	local spaceLen = (self.spaceLen or love.graphics.getFont():getWidth(" ") or 12)*scale
	local letH = love.graphics.getFont():getHeight()*scale*1.2
	local spacing = 8*scale
	local wordX = (not self.centered and 0) or (self.w-spaceLen*0)/2
	local wordY = 0
	local wordW = 0
	local realX = nil
	local oo,so
	
	if self.color then
	    love.graphics.setColor(getColor(self.color))
	end
	
	self.h = letH
	self.baseH = letH
	
	for i,o in pairs(self.words) do
	    if o._coloring then
	        self.coloring = true
	    end
	    if o.antiColoring then
	        self.coloring = false
	    end
	    
	    if self.coloring and o.active then
	        o.coloring = true
	    
	    end
	    
		o.len = o.len> 0 and f:getWidth(o.cutText) or o.len
	    
		if --realX and ((wordX + o.len*scale > self.w-spaceLen) or 
		((oo and oo.clumpID ~= o.clumpID) or
		(oo and oo.skipped)) and oo then -- only move on if not first word
			self.toSkip = (wordX + o.len > self.w-spaceLen*0)
			wordX = (not self.centered and 0) or (self.w-spaceLen)/2--0
			wordY = wordY + letH
			realX = nil
			self.h = self.h + letH
			wordW = 0
			soo = 1
		end
		o.alpha = self.alpha
		
		local clump = self.wordClumps[o.clumpID]
		
		-- font might change after text obj was already made?
		o.len = o.len> 0 and f:getWidth(o.cutText) or o.len
		--log(self.clumps[o.clump])
		-- problem with spacing when centering text, but otherwise fine..
		
		self.fixedClumps[clump] = self.fixedClumps[clump] or getCutText(clump)
		local c_clump = self.fixedClumps[clump]
		
		wordW = (not self.centered and 0) or o.len == 0 and 0 or f:getWidth(c_clump)*scale
		if not wordW then error(inspect(self.clumps)..o.len) end--wordW+o.len+spaceLen*(o and yho and 3 or 1)+8
		o:draw((self.x+spacing+wordX)-wordW/(self.toSkip and 2 or 2),self.y+spacing+wordY-yy,scale,f)
		
		if self.debug then
		    draw_rect("line",self.x+spacing+wordX-wordW/(self.toSkip and 2 or 2),self.y+wordY, wordW, 12)
		end
		
		realX = (realX or (self.x+spacing+wordX)-wordW/(self.toSkip and 2 or 2))+o.len*scale
		- ((o._coloring or o.antiColoring) and spacing or 0)
		
		wordX = wordX + spaceLen*(1 or o and yho and 3 or 1) + o.len*scale 
		- ((o._coloring or o.antiColoring) and spacing or 0)
		
	
		oo = o
	end
	self.h = wordY+letH
	if #self.options > 1 then
		for z=1,#self.options do
			love.graphics.print(self.options[z],4,z*20)
		end
	end
	
	love.graphics.setColor(r,g,b,a)
	love.graphics.setFont(of)
end


Word = {
	len = 0,
	text = "",
	letters = {},
	
	active = false,
	
	waitTimer = 0,
	waitTimerMax = 0.06,
	
	letterNum = 1,
	letterCount = 1,
	
	parent = {},
}

function Word:new(text, instant)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.instant = instant
	o.letters = {}
	o.text = text
	
	
	o.parent = {}
	
	return o
end

function Word:load(parent)
	local cutText = self.text
	local sp, o
	for z = 1,#textEffects do
		o = cutText
		cutText = z == 6 and cutText:gsub("&[^%s]+", "") or cutText:gsub("%"..textEffects[z], "")
		if textEffects[z]~="~" and cutText~=o then
		    self.special = true
		    self.colorer = z == 6
		end
		
	end
	local f = parent.font or love.graphics.getFont() fft = f-- assert(f==font13)
	local text = love.graphics.newText(f,cutText)
	if text == "\n" then
	    self.jump = true
	end
	
	self.font = f
	self.len = text:getWidth()
	--assert(self.len ==f:getWidth(cutText))
	--log(cutText..","..self.text)
	self.cutText = cutText
	
	self.waitTimerMax = self.instant and 0 or parent.pause or Word.waitTimerMax
	
	--self.special = cutText~=self.text
	
	self.active = false
	
	self.waitTimer = self.waitTimerMax
	self.letterNum = 1
	self.letterCount = string.len(self.text)
	
	
	self.parent = parent
	if self.instant then
	end
end

function Word:update(dt, skip)
	if self.active then
		self.waitTimer = self.waitTimer - dt
		if self.waitTimer <= 0 then
			self.waitTimer = self.waitTimerMax
			local isEffect = false
			local col
			local curChr = string.sub(self.text,self.letterNum,self.letterNum)
			for z = 1,#textEffects do
				if curChr == textEffects[z] then
					self.waitTimer = 0
					isEffect = true
					if z == 1 then
						for zz = 1,#self.parent.effects do
							self.parent.effects[zz] = false
						end
						self.antiColoring = true
						self.parent.coloring = false
					elseif z == 2 then
						self.waitTimer = self.waitTimerMax*2
					elseif z == 6 then
					     col = loadstring(string.format("return %s",
					     string.sub(self.text,self.letterNum+1,#self.text)))()
					     local ot = self.parent.words[self.index+1]
					     if ot then
					         --ot.textColor = col
					         --ot.coloring = true
					     end
					     self.textColor = getColor(col)
					     self.active = false
					     --self.parent.coloring = true
					     self._coloring = true
					     self.len = 0
					     self.letterCount = self.letterNum-1
					     self.letters = {}
					     if self.instant then return end
					else
						self.parent.effects[z] = true
					end
					break
				end
			end
			if curChr == "\n" then
			   -- self.skipped = true
			end
			
			self.letterNum = self.letterNum + 1
			if self.letterNum > self.letterCount then
				self.active = false
			end
			if not isEffect then
				local wave,shake = false,false
				local clrNum = 0
				if self.parent.effects[3] then
					wave = true
				end
				if self.parent.effects[4] then
					shake = true
				end
				if self.parent.effects[5] then
					clrNum = self.parent.highlight or dCol2
				end
				if self.parent.sound and (not self.parent.sound:isPlaying()) then
					self.parent.parent.sound:play()
				end
				self.pword = self.letters[#self.letters]
				table.insert(self.letters,Letter:new(curChr,clrNum,shake,wave,self))
				if self.letters[#self.letters].toSkip then
				    self.skipped = true
				end
			end
		end
	end
	for i,o in pairs(skip and {} or self.letters) do
		o:update(dt)
	end
end

function Word:draw(x,y,scale,font)
	local lOff = 0
	
	assert(font==self.font, "Font changed, that's bad!!")
	
	if self.textColor then
	    love.graphics.setColor(self.textColor)
	end
	for i,o in pairs(self.letters) do
	    o.alpha = self.alpha
		o:draw(x+lOff,y,scale)
	--	draw_rect("line",x+lOff,y,o.len,10)
		lOff = lOff+o.len*scale
	end
end

Letter = {
	clr = 0,
	
	chr = "",
	
	timer = 0,
	
	shake = false,
	wave = false,
	
	offx = 0,
	offy = 0,
}

function Letter:new(chr,clr,shake,wave,parent)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.chr = chr
	
	o.clr = clr
	o.parent = parent
	if shake then
		o.shake = shake
	end
	if wave then
		o.wave = wave
	end
	
	o.timer = 0
	o.offx = 0
	o.offy = 0
	local old
	--log(o.chr.."?")
	if parent.pword and (parent.pword.chr == "\\") and o.chr == "n"  or o.chr=="\n" then
	    o.toSkip = true
	end
	local text = love.graphics.newText(parent.parent.font or love.graphics.getFont(),chr)
	o.len = text:getWidth()
	
	return o
end

function Letter:update(dt)
	self.offy = 0
	self.offx = 0
	if self.wave then
		self.timer = self.timer + dt/(self.parent.parent.waveSpeed or 0.25)
		self.offy = self.offy + math.sin(self.timer)*4
	end
	if self.shake then
		self.offx = self.offx + math.random(-1,1) * (self.parent.parent.shakeSpeed or 1)
		self.offy = self.offy + math.random(-1,1) * (self.parent.parent.shakeSpeed or 1)
	end
	if self.clr == 7 then
		self.timer = self.timer + dt*4
	end
end

function Letter:draw(x,y,scale)
	local clr = self.clr

	if type(clr) == "table" then
	    love.graphics.setColor(clr)
	end
	
	if self.clr == 7 then
		clr = math.floor(self.timer%6)+1
	end
	if clr == 0 then -- default
		if not self.parent.coloring then
		    love.graphics.setColor(self.parent.parent.color or dCol)
		end
	elseif clr == 1 then -- terrence
		love.graphics.setColor(92/255,95/255,135/255)
	elseif clr == 2 then -- derek
		love.graphics.setColor(176/255,174/255,120/255)
	elseif clr == 3 then -- gabriel
		love.graphics.setColor(129/255,116/255,146/255)
	elseif clr == 4 then -- mandy/maria
		love.graphics.setColor(109/255,136/255,139/255)
	elseif clr == 5 then -- darryl
		love.graphics.setColor(110/255,134/255,86/255)
	elseif clr == 6 then -- virgil
		love.graphics.setColor(148/255,108/255,117/255)
	end
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(r,g,b,self.alpha or a)
	
	--if self.chr==" " then self.chr=" 5 " end
	love.graphics.print(self.chr,x+self.offx,y+self.offy,0,scale,scale)
end

texty = Sentence