
local AudioManager = class:extend("AudioManager")
local form ="%s%s"
local formp3 = "%s%s"

function AudioManager:__init__()
	self.data = {}
	self.currMusic = nil
	self.fs = 0
	self.fv = 0
	
	self.maxVolume = 1
end

function AudioManager:isBusy()
	return self.fs > 0 and self.fv > 0
end

soundSource = "sfx/"
function AudioManager:playSound(name)
    local s = name
    if type(name) == "string" then
    	local path = string.format(game.sourcie or "assets/%s",string.format("%s%s", soundSource, name))
    	if not self.data[path] then
    		self.data[path] = love.audio.newSource(path, "static")
    	end
	    s = self.data[path]
	end
	s:setVolume(.6)--game.settings.sfx/10)
	s:stop()
	s:play()
end

function AudioManager:getSound(name)
	local path = string.format(game.sourcie or "assets/%s",string.format("%s%s", soundSource, name))
	if not self.data[path] then
		self.data[path] = love.audio.newSource(path, "static")
	end
	local s = self.data[path]
    return s
end

function AudioManager:sfx(...)
    return self:playSound()
end

function AudioManager:playCursorSound()
	self:playSound("cursor.wav")
end

function AudioManager:playSelectSound()
	self:playSound("select.wav")
end

function AudioManager:playCancelSound()
	self:playSound("cancel.wav")
end

function AudioManager:playActionSound()
	self:playSound("action.wav")
end

function AudioManager:playEscapeSound()
	self:playSound("escape.wav")
end

function AudioManager:stopMusic()
	self.fs = 0
	self.fv = 0
	if self.currMusic then
		self.currMusic:stop()
	end
end

function AudioManager:fadeMusic(duration, func, rev)
    self.endF = func
    self.rev = rev
	if duration > 0 then
		self.fs = 1 / duration
		self.fv = 1
		if self.currMusic then
			self.currMusic:setVolume(self.maxVolume*(self.rev and 0 or self.fv))
		end
	else
		self.fs = 0
		self.fv = 0
		self.rev = nil
		if self.currMusic then
			self.currMusic:stop()
		end
		if func then
		    func()
		    self.endF = nil
		end
	end
end

local musicSource = "music/"
function AudioManager:playMusic(name, loop)
	-- Load
	local path = string.format(formp3, game.musicSource or string.format(game.sourcie or "assets/%s", musicSource), name)
	if not self.data[path] then
		self.data[path] = love.audio.newSource(path, "stream")
	end
	-- Stop
	self.fs = 0
	self.fv = 0
	if self.currMusic then-- self.currMusic ~= self.data[path] then
		self.currMusic:stop()
	end
	-- Play
	self.currMusic = self.data[path]
	self.currMusic:setLooping(loop ~= nil and loop)
	self.currMusic:setVolume(self.maxVolume)--game.settings.music/10 or 1)
	self.currMusic:play()
	return self.currMusic
end


function AudioManager:setSource(s)
    musicSource = string.format("%s/music/",s)
    soundSource = string.format("%s/sfx/",s)
end
    
function AudioManager:getMusic(name)
	-- Load
	local path = string.format(formp3, musicSource, name)
	if not self.data[path] then
		self.data[path] = love.audio.newSource(path, "stream")
	end
	return self.data[path]
end

function AudioManager:playTitleMusic()
	self:playMusic("bof4truthandfiction.ogg", true)
end

function AudioManager:playBattleMusic()
	self:playMusic("rnhbattle.ogg", true)
end

function AudioManager:playVictoryMusic()
	self:playMusic("ff3fnfar.ogg", true)
end

function AudioManager:setMusicVolume(v)
    self.fv = v
end

function AudioManager:update(dt)
	if self.fs > 0 and self.fv > 0 then
		self.fv = math.max(0, self.fv - self.fs*dt)
		if self.fv > 0 then
			if self.currMusic then
				self.currMusic:setVolume((self.maxVolume or 1)*(not self.rev and self.fv or 1-self.fv))
			end
		elseif not self.rev then
			self:stopMusic()
			if self.endF then
			    self.endF()
			    self.endF = nil
			end
		else
			if self.currMusic then
				self.currMusic:setVolume((self.maxVolume or 1)*(not self.rev and self.fv or 1-self.fv))
			end
		    self.rev = nil
		end
	end
end

return AudioManager