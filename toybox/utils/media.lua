--[[
-- media file
-- This file loads and controls all the sounds of the game.
-- * media.load() reads the sounds from the disk. It must be called before
--   the sounds or music are used
-- * media.music contains a source with the music
-- * media.sfx.* contains multisources (see lib/multisource.lua)
-- * media.cleanup liberates unused sounds.
-- * media.countInstances counts how many sound instances are there in the
--   system. This is used for debugging
]]

local media = {}
vv =100

media.am = AudioManager:new()
    
function media.newSource(name,_name)
  local source = media.am:getSound(_name)
  local pl = {source=source}
  
  function pl:play()
    source:setVolume(vv or 1)
   -- if not game.settings.sfxon then
      --  return
   -- end
    return media.am:playSound(source)
  end
  
  return pl
end

function media.setSource(s)
    return media.am:setSource(s)
end


local function _getMusic()
    return "Ova Melaa/Italo Unlimited.mp3"
end

media.sfx = {}
media.load = function(data, func)
  
    local names = [[
    debris
    entity_destroyed
    explosion
    bullet_shot
    laser
    player_landed
    player_jumped
    ]]
    
    media.sfx = {}
    
    for name, dir in pairs(data.sfx) do log(name)
        media.sfx[name] = media.newSource(name,dir)
        if func then func(media.sfx[name],name) end
    end
    
    --[[
    local items = love.filesystem.getDirectoryItems("assets/sfx/")
    for _, _name in ipairs(items) do
        local name = _name:sub(1,-5)
        media.sfx[name] = media.newSource(name,_name)--,_name:sub(-4,-1))
    end]]

    --media.loadMusic()
    media.setVolume(10)--6.5)
    --media.setSFXVolume(10)
    vv=100
    love.audio.setVolume(.6)

end

media.getMusic = function(source, notPlay)
  return media.am:getMusic(source or _getMusic())
end

media.loadMusic = function(source, Loop)
  media.music = media.am:playMusic(source or _getMusic(),Loop)
  return media.music
end

media.playMusic = media.loadMusic

media.cleanup = function(dt)
  if media.am then
      media.am:update(dt)
  end
  --[[for _,sfx in pairs(media.sfx) do
    sfx:cleanup()
  end]]
end

media.setSFXVolume = function(v)
  v = v/10
  for _,sfx in pairs(media.sfx) do --error(inspect(sfx))
    sfx.source:setVolume(v)
  end
  
end

media.setVolume = function(v)
    v = v/10
    love.audio.setVolume(v)
end

return media
