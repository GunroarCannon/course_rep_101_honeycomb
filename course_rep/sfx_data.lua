local sfx = {}


sfx.fesliyan_studios = {
    coins_falling = "coins_falling.ogg",
    
    trill = "trill.mp3",
    
    laugh = "laugh.ogg",
    
    sad_trombone_1 = "sad_trombone_1.mp3",
    sad_trombone_2 = "sad_trombone_2.mp3",
    
    gut_1 = "gut_1.mp3",
    gut_2 = "gut_2.mp3",
    gut_3 = "gut_3.mp3",
    
    joke_drum = "joke_drum.mp3",
    
    bomb_explosion = "bomb_explosion.mp3",
    
    chest_break = "chest_break.mp3",
    
    cluck = "cluck.mp3",
    clucks = "clucks.mp3"
}

sfx.sfx_other = {

    
    chicken_cluck = "chicken_cluck.mp3",

    
    wild_dog = "wilddog.ogg",
    mud = "mud_1.ogg",

    beep = "beep.mp3",
    
    splash_2 = "splash_1.ogg",
    switch = "switch_01.ogg",
    entrance = "entrance.ogg",
    negative = "negative_sound2.ogg",
    paper = "paper_01.ogg",
    zip = "zip.ogg",
    blessing = "blessing.ogg",
    curse = "curse.ogg",
    curse = "curse.ogg",
    freeze = "freeze.ogg",
    ice_attack = "ice_attack.ogg",
    insect = "insect.ogg",
    dive = "dive.ogg",
    bell = "bell_02.ogg",
    steam = "steam.ogg",
    splash_1 = "splash_2.ogg",
    sand = "sand.ogg",
    grass = "sand.ogg",
    door_slam = "slam.ogg",
    

    clock = "clock.ogg",
    coins = "coins.ogg",

    
    heartbeat = "heartbeat.ogg",
    hard_hit = "hit_2.ogg",
    door = "door.ogg",

    angel = "angel.mp3",
    
    win_sound = "win_sound.ogg",
    
    spider_1 = "spider_1.ogg",
    spider_2 = "spider_2.ogg",
    hog = "hog.ogg",
    mouse = "mouse.ogg",
    bat = "bat.ogg",
    
    bug = "bug.ogg",
    grunt = "hog.ogg"
}

sfx.extra_sounds = {
    let_him_cook = "let_him_cook.mp3",
    angel_song = "angel_song.mp3",
    a_few_moments_later = "a_few_moments_later.mp3",
    applause = "applause.mp3",
    aot_short = "aot_short.mp3",
    xbox_levelup = "xbox_levelup.mp3",
    wahala = "wahala.mp3",
    sad_violin = "sad_violin.mp3",
    peace_problems = "peace_problems.mp3",
    --nono_song = "nono_song.mp3",
    nono_laugh = "nono_laugh.mp3",
    mumu_man = "mumu_man.mp3",
    
    evil_laugh = "evil_laugh.ogg",
    erwin_speech = "erwin_speech.mp3",
    crickets = "crickets.ogg",
    congratulations_failure = "congratulations_failure.mp3",
    cheering = "cheering.mp3",
    levelup_achievement = "levelup_achievement.mp3",
    another_one = "another_one.mp3",
    anime_wow = "anime_wow.mp3",
    
    click = "click.wav",
    shuffle = "shuffle.wav",
    plastic_click = "click_plastic.mp3",
    error = "error.wav",
    card_swipe = "card_swipe.ogg",
    playcard = "playcard.wav",
    draw_card = "draw.wav",
    
    facebook_sound = "button_click.mp3",
    
    paper_tear = "paper_tear.mp3",
    
    spongebob_laugh = "spongebob_laugh.mp3",
    spongebob_fail = "spongebob_fail.mp3"
}

local speeches = {
    "luv", "iv", "dis", "kant",
    "bos", "sun", "jo", "coh", "soh",
    "fi", "gro", "mi", "num", "po",
    
    --"rey", "rah", "hav",
    
    "tin", "vox", "bah"
}

SPEECH_SOUNDS = speeches
MAGIC_SPEECH_SOUNDS = {"loh", "fah", "ski", "kong", "fasc", "yah"}
BAT_SPEECH_SOUNDS = {"kant", "vox", "ski", "bat"} -- "hiss"
KOBOLD_SPEECH_SOUNDS = {"fi", "fi", "fi", "fi", "fi", "fi", "mi", "mi", "mi", "mi", "mi", "mi", "po", "soh"}
JACKAL_SPEECH_SOUNDS = {"jackal_bark_1", "jackal_bark_2", "fah"}
PIG_SPEECH_SOUNDS = {"pig_1", "pig_2", "pig_3"}
DOG_SPEECH_SOUNDS = {"woof","fah"}
CHICKEN_SPEECH_SOUNDS = {
    "cluck", "cluck", "clucks" --"chicken_cluck", "chicken_cluck", "chicken_cluck",
    --"chicken_cluck_long"
}

sfx.speech = {}

sfx.magic_speech = {}

for i, txt in ipairs({} or speeches) do
    local sound = string.format("%s.mp3", txt)
    sfx.speech[txt] = sound
end

lume.remove(speeches, "kant")

for i, txt in ipairs(MAGIC_SPEECH_SOUNDS) do
    local sound = string.format("%s.mp3", txt)
    -- sfx.magic_speech[txt] = sound
end

sfx.sci_fi_sfx = {
    glurp = "weird_01.ogg",
    bat = "weird_02.ogg",
    hiss = "weird_03.ogg",
    
    teleport = "teleport_01.ogg",
    long_teleport = "teleport_02.ogg",
    teleport_out = "teleport_01.ogg",
    alert = "retro_laser_01.ogg",
    teleport_in = "misc_04.ogg"
}

sfx.fleshy_fight_sounds = {
    sword_attack_1 = "wetsword.mp3",
    sword_attack_2 = "wetsword2.mp3",
    sword = "sword.mp3",
    wet_step = "wetstep.mp3",
    squash = "squash.mp3"
}

sfx["smc-wwviRetroActionSounds"] = {
    zap = "tesla_tower.ogg",
    laser = "synthetic_laser.ogg",
    
    stone_1 = "stonebang1.ogg",
    stone_2 = "stonebang1.ogg",
    stone_3 = "stonebang3.ogg",
    stone_4 = "stonebang4.ogg",
    stone_5 = "stonebang5.ogg",
    stone_6 = "stonebang7.ogg",
    stone_7 = "stonebang7.ogg",
    stone_8 = "stonebang8.ogg",
    
    explosive_impact = "missile_explosion.ogg",
    clang = "clang.ogg",
    big_explosion2 = "big_explosion.ogg",
    explosion = "bomb_explosion.ogg",
}

sfx.battle_sound_effects = {
    bow = "bow.wav",
    miss_1 = "swish_2.wav",
    miss_2 = "swish_4.wav",
    throw = "swish_3.wav"
}

sfx.Juhani_Junkala = {
    hit_1 = "sfx_wpn_punch1.wav",
    hit_2 = "sfx_wpn_punch2.wav",
    hit_3 = "sfx_wpn_punch3.wav",
    
    missile = "sfx_wpn_missilelaunch.wav",
    explosion2 = "sfx_wpn_cannon2.wav",
    boing = "sfx_movement_jump8.wav",
    
    step_1 = "sfx_movement_footsteps1b.wav",
    step_2 = "sfx_movement_footsteps1a.wav",
    
    slippery = "sfx_movement_footstepsloop3_fast.wav"
}

sfx.JBM_sfxr_pack_1 = {
    collect = "collect01.ogg"
}


sfx.Byte_Man_SFX = {
--    score = "score.wav"
}


sfx.hits = {
    whack = "1.ogg",
    hit = "2.ogg",
    slap = "3.ogg",
    slap2 = "4.ogg",
    whack_slap = "6.ogg",
    whack_slap2 = "7.ogg",
    hard_slip = "8.ogg",
    hard_slap2 = "9.ogg"
}

sfx.GameBurp_FREE_Game_Sound_FX_Pack_OGG = {
	spring = "BOUNCE Twang Spring 13.ogg",
    big_explosion = "EXPLOSION Bang 04.ogg",
	zap = "ELECTRIC Shock Zap Short 03.ogg",
}

local sounds = {}

for dir, data in pairs(sfx) do
    for name, filename in pairs(data) do
        sounds[name] = string.format("%s/%s",dir,filename)
    end
end

SFX_data = {
	sfx = sounds,
	data = sfx
}

return SFX_data
	