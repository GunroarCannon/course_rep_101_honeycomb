local songs = {}

local pitch = .4
slowPitch = .4


songs.lofi_loop = {
    source = "chill_lofi_loop.ogg",
    loop = true,
    name = "The Battle of Atheria",
    pitch = 1
}

songs.nono_song = {
    source = "nono_song.mp3",
    loop = false,
}

songs.dorime = {
    source = "dorime.mp3",
    loop = false,
    pitch = .9
}

songs.jojo_continued = {
    source = "jojo_continued.mp3",
    loop = false
}

songs.lion_king = {
    source = "lion_king.mp3",
    loop = false
}

songs.sad_naruto_song = {
    source = "sad_naruto_song.mp3",
    loop = false
}

songs.sad_meow_song = {
    source = "sad_meow_song.mp3",
    loop = false
}

songs.meme_song = {
    source = "meme_song.mp3",
    loop = false
}

songs.meme_sax = {
    source = "meme_sax.mp3",
    loop = false
}

songs.chill_meme_song = {
    source = "chill_tunes_i_have_no_enemies.mp3",
    loop = false
}

songs.indian = {
    source = "indian.mp3",
    loop = false
}

songs.epic = {
    source = "epic.mp3",
    loop = false
}

songs.song_4eyes = {
    source = "song_4eyes.mp3",
    loop = true
}

songs.cat_rap = {
    source = "cat_rap.mp3",
    loop = false
}

songs.chai = {
    source = "chai.mp3",
    loop = false
}

songs.dialup_song = {
    source = "dialup_song_0.ogg",
    loop = true
}

songs.dirty_loop = {
    source = "dirty_.mp3",
    loop = true
}

songs.fun_bass_loop = {
    source = "fun_bass_loop.ogg",
    loop = true
}

songs.feel_good_island = {
    source = "feel_good_island.ogg",
    loop = true
}

songs.MSTR_Choro_bavario = {
    source = "MSTR_Choro_bavario.mp3",
    loop = true
}

-- this one is actually pretty cool
songs.funny_thai_song = {
    source = "funny_thai_song.mp3",
    loop = false
}

songs.we_got_him_song = {
    source = "we_got_him_song.mp3",
    loop = false
}

songs.champions_league = {
    source = "champions_league.mp3",
    loop = false
}

gameOverSongs = {"jojo_continued", "dorime", "nono_song", "chai", "sad_meow_song", "sad_naruto_song", "lion_king", "meme_sax", "meme_song", "cat_rap", "chill_meme_song", "indian", "we_got_him_song"}
gameSongs = {"dirty_loop", "dirty_loop", "lofi_loop", "song_4eyes", "feel_good_island", "fun_bass_loop", "MSTR_Choro_bavario"}
titleSongs = {"epic", "cat_rap", "funny_thai_song"}

function loadSong(dat, pitch, fade)
    local song = songs[dat] or type(dat)=="table" and dat or error("No song "..tostring(dat))
    
    if CURRENT_SONG == song then
        return
    end
    
    CURRENT_SONG = song
    
    local function load()
        media.loadMusic(song.source, song.loop)
        media.am:fadeMusic(fade or 1, nil, true)
        media.music:setPitch(pitch or song.pitch or 1)
        media.am.maxVolume = .7
        -- media.am:setMusicVolume(.1)
    end
    
    if media.music then
        media.am:fadeMusic(fade or 1, load)
    else
        assert(not grogg)
        grogg = true
        load()
    end
end

for i, dat in pairs(songs) do
    -- media.loadMusic(dat.source)
end

loadSong(getValue(songs))

return songs