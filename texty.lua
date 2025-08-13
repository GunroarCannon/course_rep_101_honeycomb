local textEffects = {
	"~", --resets all effects
	"_", --has a brief pause in the text, which is double the length of a normal character time span
	"#", --makes text wave
	"@", --makes text shake
	"$", --makes text the current highlight colour
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

local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		if str=="\n" then error() end table.insert(t, str)
	end
	return t
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
	
	o.pause = o.time or o.pause or .1
	
	o.w = k.w or 100
	o.x = k.x or 0
	o.y = k.y or 0
	
	o.color = k.color
	o.highlight = k.highlight or dCol3
	o.sound = k.sound
	
	o.font = k.font
	
	return o
end

function Sentence:newText(text)
	self.text = text
	self.words = {}
	
	local tempWords = split(text)
	for z = 1,#tempWords do
		table.insert(self.words,Word:new(tempWords[z]))
		--table.insert(self.words,Word:new(" "))
	end
	for i,o in pairs(self.words) do
		o:load(self)
	end
	self.activeWord = 1
	self.words[self.activeWord].active = true
	
	for z = 1,#textEffects do
		self.effects[z] = false
	end
end

function Sentence:update(dt)
	local isActive = false
	for i,o in pairs(self.words) do
		o:update(dt)
		if o.active then
			isActive = true
		end
	end
	if not isActive then
		self.activeWord = self.activeWord + 1
		if self.activeWord <= #self.words then
			self.words[self.activeWord].active = true
		end
	end
end

function Sentence:draw()
	if self.font then
	    love.graphics.setFont(self.font)
	end
	local r,g,b,a = love.graphics.getColor()
	
	local spaceLen = 12
	local letH = love.graphics.getFont():getHeight()
	local wordX = 0
	local wordY = 0
	for i,o in pairs(self.words) do
		if (wordX + o.len > self.w-12) or o.skipped then
			wordX = 0
			wordY = wordY + letH
		end
		o:draw(self.x+8+wordX,self.y+8+wordY)
		wordX = wordX + spaceLen + o.len
	end
	if #self.options > 1 then
		for z=1,#self.options do
			love.graphics.print(self.options[z],4,z*20)
		end
	end
	
	love.graphics.setColor(r,g,b,a)
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

function Word:new(text)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.letters = {}
	o.text = text
	
	
	o.parent = {}
	
	return o
end

function Word:load(parent)
	local cutText = self.text
	for z = 1,#textEffects do
		cutText = cutText:gsub("%"..textEffects[z], "")
	end
	local text = love.graphics.newText(parent.font or love.graphics.getFont(),cutText)
	self.len = text:getWidth()
	
	self.waitTimerMax = parent.pause or Word.waitTimerMax
	
	self.active = false
	
	self.waitTimer = self.waitTimerMax
	self.letterNum = 1
	self.letterCount = string.len(self.text)
	
	self.parent = parent
end

function Word:update(dt)
	if self.active then
		self.waitTimer = self.waitTimer - dt
		if self.waitTimer <= 0 then
			self.waitTimer = self.waitTimerMax
			local isEffect = false
			local curChr = string.sub(self.text,self.letterNum,self.letterNum)
			for z = 1,#textEffects do
				if curChr == textEffects[z] then
					self.waitTimer = 0
					isEffect = true
					if z == 1 then
						for zz = 1,#self.parent.effects do
							self.parent.effects[zz] = false
						end
					elseif z == 2 then
						self.waitTimer = self.waitTimerMax*2
					else
						self.parent.effects[z] = true
					end
					break
				end
			end
			if curChr == "\n" then
			    self.skipped = true
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
				table.insert(self.letters,Letter:new(curChr,clrNum,shake,wave,self))
			end
		end
	end
	for i,o in pairs(self.letters) do
		o:update(dt)
	end
end

function Word:draw(x,y)
	local lOff = 0
	for i,o in pairs(self.letters) do
		o:draw(x+lOff,y)
		lOff = lOff+o.len
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
	
	local text = love.graphics.newText(parent.parent.font or love.graphics.getFont(),chr)
	o.len = text:getWidth()
	
	return o
end

function Letter:update(dt)
	self.offy = 0
	self.offx = 0
	if self.wave then
		self.timer = self.timer + dt/0.25
		self.offy = self.offy + math.sin(self.timer)*4
	end
	if self.shake then
		self.offx = self.offx + math.random(-1,1)
		self.offy = self.offy + math.random(-1,1)
	end
	if self.clr == 7 then
		self.timer = self.timer + dt*4
	end
end

function Letter:draw(x,y)
	local clr = self.clr
	
	if type(clr) == "table" then
	    love.graphics.setColor(clr)
	end
	
	if self.clr == 7 then
		clr = math.floor(self.timer%6)+1
	end
	if clr == 0 then -- default
		love.graphics.setColor(self.parent.parent.color or dCol)
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
	love.graphics.print(self.chr,x+self.offx,y+self.offy)
end