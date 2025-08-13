BASIC = 10+2
SMALL_BASIC = 7+2
MEDIUM_BASIC = 13+2
BIG_BASIC = 20+3
LARGE_BASIC = 30+10

airdropName = {"moneycoin", "f-coin", "hamster cra$h", "blitzcoin", "fanta combat", "0x8432CBE0", "coinmarket", "potato market"}

losses = {
    church = {
        high = {
            {
                text = "You got too passionate and went on a journey of self discovery...",
                isLoss = true,
                source = "fail_states/church_high_1.png",
                sound = "angel_song",
                pictureIsBig = 1
            },
        },
        low = {
            {
                text = "Everyone is left unimpressed by your 'don't care attitude'...",
                isLoss = true,
                source = "fail_states/church_low_2.png",
                sound = "wahala"
            },
            {
                text = "You have embraced @vawulence ~ too much for the job...",
                isLoss = true,
                source = "fail_states/church_low_1.png",
                sound = {"peace_problems", "evil_laugh"}
            }
            
        },
        
    },
    
    brain = {
        high = {
            {
                text = "You're too smart. Everyone now needs a flowchart to understand you.",
                isLoss = true,
                pictureIsBig = .9,
                source = "fail_states/brain_high_1.png",
            },
            {
                text = "You study so much you run mad.",
                isLoss = true,
                source = "fail_states/brain_high_2.png"
            }
        },
        low = {
            {
                text = "Your brain has gone on strike...",
                isLoss = true,
                source = "fail_states/brain_low_1.png",
                sound = {"mumu_man", "mumu_man", "spongebob_laugh"}
            }
        },
    },
    
    popularity = {
        high = {
            {
                text = "You become so popular, the fame drives you crazy...",
                isLoss = true,
                source = "fail_states/popularity_high_1.png",
                sound = {"cheering", "wahala", "nono_laugh", "spongebob_laugh"},
            },
            {
                text = "You become #so liked ~ , everyone stops taking you seriously..",
                isLoss = true,
                source = "fail_states/church_low_2.png"
            }
        },
        low = {
            {
                text = "You become so @unpopular ~ , everyone forgets you're the course rep...",
                isLoss = true,
                source = "fail_states/popularity_low_1.png",
                sound = {"crickets", "nono_laugh"}
            }
        }
    },
    
    coin = {
        high = {
            {
                text = "You become so rich you realize school na scam...",
                isLoss = true,
                source = "fail_states/money_high_1.png"
            },
            {
                text = "You become so rich you buy your own Island and dropout...",
                isLoss = true,
                pictureIsBig = 1,
                source = "fail_states/money_high_2.png"
            }
        },
        low = {
            {
                text = "Your bank account is as empty as the attendance on a #Friday afternoon...",
                isLoss = true,
                source = "fail_states/money_low_1.png"
            }
        }
        
    }
}

local talk = {

    examWrite = {
        req = {},
        traits = {
            academic = true,
            -- sketchy = true,
        },
        text = [["Hey, I'll write your exam for you if you want.
For a price"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = -BASIC,
            },
            next = {
                isNarrator = true,
                text = "You ended up \n getting a pretty good result.",
                stats = {
                    brain = {LARGE_BASIC, BIG_BASIC, MEDIUM_BASIC, BASIC}
                },
                next = nil
            }
        },
    },
    
    examWriteSketchy = {
        req = {},
        traits = {
            sketchy = true,
        },
        text = [["Hey, I'll write your exam for you if you want.
For a price"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = -BASIC,
            },
            next = {
                isNarrator = true,
                text = "You failed woefully.",
                stats = {
                    brain = {-BIG_BASIC, -MEDIUM_BASIC, -BASIC, -SMALL_BASIC},
                },
                next = nil
            }
        },
    },
    
    examWriteSketchyPass = {
        req = {},
        traits = {
            sketchy = true,
        },
        text = [["Hey, I'll write your exam for you if you want.
For a price"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = -BASIC,
                church = -BIG_BASIC
            },
            next = {
                isNarrator = true,
                text = "Suprisingly you ended up \n getting a pretty good score.",
                stats = {
                    brain = {LARGE_BASIC, BIG_BASIC, MEDIUM_BASIC, BASIC},
                },
                next = nil
            }
        },
    },
    
    examWriteFail = {
        req = {},
        traits = {
            pious = false,
            lecturer = false
        },
        text = [["Hey, I'll write your exam for you if you want.
For a price"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = -BASIC,
                church = -BIG_BASIC
            },
            next = {
                isNarrator = true,
                text = "You failed woefully.",
                stats = {
                    brain = -LARGE_BASIC,
                },
                next = nil
            }
        },
    },
    
    churchProgram = {
        req = {},
        traits = {
            pious = true,
            -- sketchy = true,
        },
        text = [["I'm inviting you to my church program, will you come?"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -MEDIUM_BASIC,
                church = -SMALL_BASIC
            }
        },
        yes = {
            text = "yes (lie)",
            stats = {
                church = -BASIC,
                popularity = SMALL_BASIC
            },
        },
    },
    
    churchFlyers = {
        req = {},
        traits = {
            pious = true,
            -- sketchy = true,
        },
        text = '"Help me hand out these church flyers for our program..."',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                -- brain = SMALL_BASIC,
                -- popularity = BASIC,
                church = -MEDIUM_BASIC
            }
        },
        yes = {
            text = "okay",
            stats = {
                church = BASIC,
                popularity = -MEDIUM_BASIC
            },
        },
    },
    
    repent = {
        req = {
            hasDoneBad = true
        },
        traits = {
            pious = true,
            -- sketchy = true,
        },
        text = {'"Repent from your evil ways!"',[["Your soul will be judged!"]]},
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "what!?",
            next = nil,
            set = {},
            stats = {
                popularity = SMALL_BASIC,
                church = -BIG_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                church = SMALL_BASIC,
                popularity = -SMALL_BASIC
            },
        },
    },
    
    
    
    fastPrayer = {
        req = {},
        traits = {
            -- academic = true,
            -- sketchy = true,
        },
        text = '"Fast and pray, and keep the SAPA at bay"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                coin = -SMALL_BASIC,
                church = -SMALL_BASIC
            }
        },
        yes = {
            text = "okay",
            stats = {
                coin = BASIC,
                church = BASIC
            },
        },
    },
    
    examFaith = {
        req = {},
        traits = {
            pious = true,
            -- sketchy = true,
        },
        text = '"Leave your exams to faith"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                church = -SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                church = BIG_BASIC,
            },
            next = {
                isNarrator = true,
                text = "Faith answered your prayers ...\n But not your exam questions.",
                stats = {
                    brain = -BIG_BASIC,
                },
                next = nil
            }
        },
    },
    
    earthlyPossessions = {
        req = {},
        traits = {
            pious = true,
            -- sketchy = true,
        },
        text = '"Denounce your earthly possessions!"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                church = -BIG_BASIC--SMALL_BASIC
            }
        },
        yes = {
            text = "okay",
            stats = {
                coin = -LARGE_BASIC,
                popularity = -BASIC,
                brain = BASIC,
                church = BIG_BASIC
            },
        },
    },
    
    studySession = {
        req = {},
        traits = {
            academic = true,
            -- sketchy = true,
        },
        text = {[["Let's study for the upcoming tests"]], '"Do you want to join our study sessions?"','"Do you want to study with us?"'},
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = -SMALL_BASIC,
            }
        },
        yes = {
            text = "yes",
            stats = {
                brain = {LARGE_BASIC, BIG_BASIC, MEDIUM_BASIC, BASIC},
                popularity = -SMALL_BASIC
            },
        },
    },
    
    bribeLecturer = {
        req = {},
        traits = {
            sketchy = true,
        },
        text = [["Guy, abeg, let me give you a little #something ~ so you'll sort me out"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                popularity = {-BIG_BASIC, -MEDIUM_BASIC, -BASIC},
                church = SMALL_BASIC
            },
            next = {
                sameCharacter = true,
                text = {[["Nawah for you..."]],[["Aaahhh"]],[["This semester no funny at aaall"]],[["Nah how course rep suppose be?"]]},
            },
        },
        yes = {
            text = "sure",
            stats = {
                coin = BIG_BASIC,
                church = -SMALL_BASIC
            },
            set = {
                hasDoneBad = true
            },
        },
    },
    
    deyYourDm = {
        text = {[["Abeg, I dey your DM..."]], [["Abeg, later let's talk"]], [["No reason am."]]},
        traits = {
            sketchy = true
        },
        no = {text="okay...?"},
        yes = {text="no wam"}
    },
    
    taxStudents = {
        req = {},
        traits = {
            lecturer = true,--assistant = true,
            -- sketchy = true,
        },
        text = [["We need to @tax ~ these people. They're taking advantage of us..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                popularity = BASIC,
                coin = -SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = MEDIUM_BASIC,
                popularity = -BIG_BASIC
            },
        },
    },
    
    textbook = {
        req = {},
        traits = {
            lecturer = false,
            -- sketchy = true,
        },
        text = [["You still haven't given me the textbook I payed for @Sinccce"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "It's on it's way (lie)",
            next = nil,
            set = {},
            stats = {
                popularity = {-MEDIUM_BASIC, -BASIC},
                church = -SMALL_BASIC
            }
        },
        yes = {
            text = "Give refund",
            stats = {
                coin = {-BIG_BASIC, -BASIC},
                
            },
        },
    },
    
    gradesUp = {
        req = {},
        traits = {
            lecturer = true,
            -- sketchy = true,
        },
        text = '"You need to get your grades up soon OR ELSE!!"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = {-MEDIUM_BASIC, -BASIC},
            }
        },
        yes = {
            text = "stay up studying",
            stats = {
                brain = {LARGE_BASIC, BIG_BASIC, MEDIUM_BASIC, BASIC},
            },
        },
    },
    
    brainBoosters = {
        req = {},
        traits = {
            -- academic = true,
            sketchy = true,
        },
        text = '"I have some unconventional @brain boosting ~ items. You want some?"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = -BASIC,
                brain = BIG_BASIC
            },
            set = {
                hasDoneBad = true
            }
        },
    },
    
    letsBingeAnime = {
        req = {},
        traits = {
            otaku = true,
            -- sketchy = true,
        },
        text = [["Let's binge watch this @new anime!"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "gross",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
            }
        },
        yes = {
            text = "yes",
            stats = {
                brain = -BASIC,
            },
            next = {
                isNarrator = true,
                text = {
                    "You learnt about &colors.cyan #The power of friendship ~ .",
                    "You stayed up all night watching a boy swing a big sword",
                    "You watched a show where @everybody died. ~ Yikes",
                    "It was actually better than you thought.",
                    "You stayed up watching a show about a man with a chainsaw for a head.",
                    "You watched so much you feel like you can now speak Japanese.",
                    "You watched an almost infinite amount of time watching pirates eating weird fruit."
                },
                next = nil
            }
        },
    },
    
    letsBingeSeries = {
        req = {},
        traits = {
            cool = true,
            -- sketchy = true,
        },
        text = [["Let's stay up all night watching this new series!"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
            }
        },
        yes = {
            text = "yes",
            stats = {
                brain = -BASIC,
            },
            next = {
                isNarrator = true,
                text = {
                    "You watched a show about a boy's grandpa turning himself into a pickle",
                    "You watched a show where superman was blonde and covered in blood.",
                    "You stayed up all night watching a weirdly addictive romance show.",
                    "You watched something that had to do with a british accent."
                },
                stats = {
                    -- brain = BASIC,
                },
                next = nil
            }
        },
    },
    
    letsPlay = {
        req = {},
        traits = {
            gamer = true,
            -- sketchy = true,
        },
        text = {
            [["Let's play C.O.D all day."]],
            [["Let's setup Mini and play."]],
            [["Let's play a match in eFootball..."]],
            [["Let's play FIFA all day."]],
            [["Let's play 'Barbie dream house adventures' all day."]]
        },
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -SMALL_BASIC,
            }
        },
        yes = {
            text = "yes",
            stats = {
                brain = -BASIC,
                popularity = SMALL_BASIC
            },
            next = {
                isNarrator = true,
                text = "You enjoyed yourself well enough.",
                next = nil
            }
        },
    },
    
    tutorialClass = {
        req = {},
        traits = {
            academic = true,
            -- sketchy = true,
        },
        text = [["Come to my tutorial class, I'll even give you a discount..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = -SMALL_BASIC,
            }
        },
        yes = {
            text = "yes",
            stats = {
                coin = -BASIC,
                brain = SMALL_BASIC
            },
        },
    },
    
    party = {
        req = {},
        traits = {
            cool = true,
            quiet = false
            -- sketchy = true,
        },
        text = {'"Hey! Come and party #tonight."', [["Let's organize a party..."]]},
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "yes",
            stats = {
                church = -BASIC,
                brain = -SMALL_BASIC,
                popularity = BASIC,
            },
        },
    },
    
    --[[dating = {
        req = {},
        traits = {
            lecturer = false,
            -- sketchy = true,
        },
        oppositeGender = true,
        text = '"It only makes sense that me and you should hook up."',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = {"nah","ew"},
            next = nil,
            set = {},
            stats = {
                brain = SMALL_BASIC,
                popularity = -BASIC,
                church = SMALL_BASIC
            }
        },
        yes = {
            text = "sure, why not?",
            stats = {
                popularity = BASIC,
            },
            next = {
                isNarrator = true,
                text = "Everything went well until you eventually got dumped after you'd served your use..",
                stats = {
                    brain = -BASIC,
                    coin = -BASIC
                },
                next = nil
            }
        },
    },
    ]]
    organiseClasses = {
        req = {},
        traits = {
            lecturer = true,
            -- sketchy = true,
        },
        text = '"I want to organize a 5 hour class"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {unserious=true},
            stats = {
                brain = -MEDIUM_BASIC,
                popularity = BASIC,
                church = -SMALL_BASIC
            },
            next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "yes",
            stats = {
                popularity = -BIG_BASIC,
                brain = BASIC
            },
            next = {
                isNarrator = true,
                text = "Everyone starts disliking you.",
                next = nil,
                set = {
                    disappointed = true
                }
            }
        },
    },
    
    
    cowMoo = {
        req = {},
        traits = {
            cow = true
        },
        text = '"MoooOOoooOoo"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "Moo back",
            next = nil,
            set = {},
            stats = {
                brain = -MEDIUM_BASIC,
                popularity = BASIC,
                church = -SMALL_BASIC
            },
            next = {
                isNarrator = true,
                text = "You got a few laughs out of people...\nBut at the cost of your IQ...",
                stats = {
                    brain = -MEDIUM_BASIC,
                    popularity = MEDIUM_BASIC
                }
            }
        },
        yes = {
            text = "ignore",
            next = nil,
            set = {},
            next = {
                isNarrator = true,
                text = "You walk away quickly.",
                stats = {}
            }
        }
    },
    
    cowMoo2 = {
        req = {},
        traits = {
            cow = true
        },
        text = '".....mooooOoooooO"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "Scare",
            next = nil,
            set = {},
            stats = {
                -- brain = MEDIUM_BASIC,
                -- popularity = BASIC,
                church = -SMALL_BASIC
            },
            next = {
                isNarrator = true,
                text = "You try to scare the cow...",
                next = {
                    isNarrator = true,
                    text = "...But it chases after you and you're forced to run away.",
                    stats = {
                        brain = -MEDIUM_BASIC,
                        popularity = -MEDIUM_BASIC
                    }
                }
            }
        },
        
        yes = {
            text = "ignore",
            next = nil,
            set = {},
            next = {
                isNarrator = true,
                text = "You walk away quickly.",
                stats = {}
            }
        }
    },
    
    cowMooFalse = {
        req = {},
        traits = {
            cow = true
        },
        text = {'"Woof"','"Mew"','"*cough*"','"Nawah ooh"','"Woof"','"Mooooon walk"','"Mew"','"Woof"'},
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "WhAt!???",
            next = nil,
            set = {},
        },
        yes = {
            text = "ignore",
            next = nil,
            set = {},
            next = {
                isNarrator = true,
                text = "You walk away quickly.",
                stats = {}
            }
        }
    },
    
    lendMeMoney = {
        req = {},
        traits = {
            -- cow = true
        },
        text = [["Lend me some money, I'll pay you back..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                -- coin = SMALL_BASIC,
                popularity = -BIG_BASIC,
                church = -SMALL_BASIC
            },
            nil_next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "yes",
            next = nil,
            set = {},
            stats = {
                church = MEDIUM_BASIC,
                popularity = BASIC,
                coin = -BASIC
            },
            next = {
                isNarrator = true,
                text = "You never hear about the money again...",
                stats = {}
            }
        }
    },
    
    dropAccount = {
        req = {},
        traits = {
            
        },
        text = '"Drop your account number, \n Let me show some appreciation,"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                -- brain = -MEDIUM_BASIC,
                -- popularity = BASIC,
                church = SMALL_BASIC
            },
            next = {
                sameCharacter = true,
                text = "No, I insist...",
                no = {
                    text = "no",
                    stats = {
                    },
                    next = {
                        sameCharacter = true,
                        text = "Hah! your loss.",
                        stats = {}
                    }
                },
                yes = {
                    text = "Sure",
                    stats = {
                        coin = LARGE_BASIC,
                    },
                }
            }
        },
        yes = {
            text = "sure",
            next = nil,
            set = {},
            stats = {
                -- brain = MEDIUM_BASIC,
                -- popularity = BASIC,
                coin = MEDIUM_BASIC
            },
        }
    },
    
    
    sortCourse = {
        req = {},
        traits = {
            sketchy = true
        },
        text = '"See, I want you to help me sort one course like that..."',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                popularity = -BASIC,
                church = BASIC
            },
            nil_next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "how much?",
            next = nil,
            set = {unserious=true},
            stats = {
                brain = -MEDIUM_BASIC,
                popularity = BASIC,
                church = -MEDIUM_BASIC
            },
            next = {
                isNarrator = true,
                text = "The lecturer is payed well, and so are you \n ...",
                stats = {coin={LARGE_BASIC, BIG_BASIC, BASIC}}
            }
        }
    },
    
    chosen = {
        req = {},
        traits = {
            sketchy = true
        },
        text = '"I am a chosen"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "okay...?",
            next = nil,
            set = {},
        },
        yes = {
            text = "stop that",
            next = nil,
        }
    },
    
    jogging = {
        req = {},
        traits = {
            -- fit = true
        },
        text = [["You should try jogging on Saturdays. It'll keep you fit!"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "Too busy for that",
            next = nil,
            set = {},
            stats = {
                brain = -MEDIUM_BASIC,
                popularity = BASIC,
                -- church = -SMALL_BASIC
            },
        },
        yes = {
            text = "You start first, then I'll follow",
            next = nil,
            set = {},
            stats = {
                brain = -MEDIUM_BASIC,
                popularity = BASIC,
                -- church = -SMALL_BASIC
            },
            next = {
                {
                    sameCharacter = true,
                    text = "Uhmm...I'm too busy on saturdays so....",
                    stats = {},
                    no = {
                        text = "Thought so...",
                    },
                    yes = {
                        text = "You're the boss",
                    }
                },
                {
                    sameCharacter = true,
                    text = "I've already started...",
                    yes = {
                        text = "Okay, I'll join",
                        stats = {
                            brain = BASIC,
                        },
                        next = {
                            isNarrator = true,
                            text = "At first you feel like dying, \n but later you feel pretty good.",
                        }
                    },
                    no = {
                        text = "Oh...uhm...good luck then.",
                        next = {
                            isNarrator = true,
                            text = "For some reason you feel a little bit more more @unhealthier...",
                            stats = {
                                brain = -SMALL_BASIC
                            }
                        }
                    }
                }
            }
        }
    },
    
    
    
    hateYou = {
        req = {},
        traits = {
            pious = false, --lecturer = true,
            -- sketchy = true,
        },
        text = '"I @Hate you"',
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "It's like You're @mad",
            next = nil,
            set = {unserious=true},
            stats = {
                brain = -MEDIUM_BASIC,
                popularity = -BIG_BASIC,
                church = -SMALL_BASIC
            },
            next = {
                isNarrator = true,
                text = "Turns out they were just quoting a line from their favourite movie. You now seem like a jerk.",
                stats = {
                    popularity = -BASIC,
                    brain = -BASIC
                }
            }
        },
        yes = {
            text = "okay",
            stats = {
                popularity = BASIC,
                brain = SMALL_BASIC
            },
            next = {
                isNarrator = true,
                text = "Turns out they were just quoting a line from their favorite movie.\nNo hard feelings.",
                next = nil,
                set = {
                    
                }
            }
        },
    },
    
    feed = {
        req = {},
        traits = {
            --cow = true
        },
        text = [["Hey, I need your help with something..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                --coin = SMALL_BASIC,
                popularity = -BIG_BASIC,
                church = -BASIC
            },
            nil_next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "with what?",
            set = {},
            stats = {
                church = MEDIUM_BASIC,
                popularity = BASIC,
                coin = -BASIC
            },
            next = {
                sameCharacter = true,
                text = {[["Y'know, just some cash"]], [["Abeg, just small 8K"]], [["Help fund me small..."]]},
                no = {
                    text = "no",
                    stats = {
                        popularity = -BASIC,
                    }
                },
                yes = {
                    text = {"okay", "just this time"},
                    stats = {
                        coin = -BIG_BASIC,
                        popularity = BASIC
                    }
                }
            }
        }
    },
    
    airdrop = {
        req = {},
        traits = {
            crypto = true--cow = true
        },
        text = [["Let me refer you to this new airdrop..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            set = {},
            stats = {},
            nil_next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "yes",
            set = {},
            stats = {
                brain = -BASIC,
            },
            next = {
                isNarrator = true,
                text = "It's...\n@Really ~ addictive?\nInvest time into it?",
                yes = {
                    text = "yes",
                    stats = {
                        brain = -BIG_BASIC,
                        coin = -BASIC
                    },
                    next = {
                        {
                            text = "It #actually ~ payed off!",
                            isNarrator = true,
                            stats = {
                                coin = {LARGE_BASIC, BIG_BASIC, LARGE_BASIC}
                            }
                        },
                        {
                            text = "It never listed.\n What a waste of time...",
                            isNarrator = true,
                            stats = {
                                coin = -LARGE_BASIC
                            }
                        }
                    }
                },
                no = {
                    next = {
                        text = "You may be missing out.",
                        isNarrator = true
                    }
                }
            }
        }
    },
    
    cryptoQuiz = {
        req = {},
        traits = {
            crypto = true,
            --cow = true
        },
        text = [["Which crypto do you think is the best?"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = {"Joycoin", "Netbeans coin", "Catcoin", "Coinswap"},
            set = {unserious=true},
            stats = {},
            next = {
                isNarrator = true,
                text = "You end up spending so much time arguing about crypto you miss classes",
                stats = {brain=-BIG_BASIC}
            }
        },
        yes = {
            text = {"Banana Kombat", "PuppyTap", "BUmpZ"},
            set = {unserious=true},
            stats = {},
            next = {
                isNarrator = true,
                text = "You end up spending so much time arguing about crypto you miss classes",
                stats = {brain=-BIG_BASIC}
            }
        }
    },
    
    ownAirdrop = {
        req = {},
        traits = {
            crypto = true,--cow = true
        },
        text = string.format([["I want to start my own airdrop! I'll call it %s"]], getValue(airdropName)),
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "okay...",
            -- next = nil,
            set = {},
            nil_next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "uhh...",
        }
    },
    
    namelessEncounter = {
        req = {},
        traits = {
            isSpecial = true,
            isNameless = true
        },
        text = [["Shhhh..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "okay...",
            next = nil,
            set = {},
            stats = {},
        },
        yes = {
            text = "what?",
            next = nil,
            set = {},
            stats = {},
        },
        next = {
            sameCharacter = true,
            text = [["I was never here..."]],
            
            next = {
                isNarrator = true,
                text = {"You feel uneasy..", "Nevermind", "...?"},
                stats = {}
            },
            no = {
                text = "okay..."
            },
            yes = {
                text = "Yes you were...?"
            }
        }
    },
    
    
    namelessEncounter2 = {
        req = {},
        traits = {
            isSpecial = true,
            isNameless = true
        },
        text = [["The angry mosquito ate the orange paper..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "okay...",
            next = nil,
            set = {},
            stats = {},
        },
        yes = {
            text = "what?",
            next = nil,
            set = {},
            stats = {},
        },
        next = {
            sameCharacter = true,
            text = [["..."]],
            
            next = {
                isNarrator = true,
                text = {"You feel uneasy..", "Nevermind", "...?"},
                stats = {}
            },
            no = {
                text = "okay..."
            },
            yes = {
                text = "Yes you were...?"
            }
        }
    },
    
    namelessEncounterCat = {
        req = {},
        traits = {
            isSpecial = true,
            isNameless = true
        },
        text = {[[#You're shown pictures of _ _ cats]], [["Be warned ... of yesterday"]], [["The yellow dog sits on the excessive eba"]], [["They plan to attack from the @south!"]],[["The country mouse deceived the lucrative fish"]], [[#Ha ha ha ... ~ ha?]], [["The end is nigh, but for now, more bread."]]},
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = {"wow", "okay...", "nice", "what the...", "you are...?", "very wise", "ignore"},
            next = nil,
            set = {},
            stats = {},
        },
        yes = {
            text = {"I agree", "???", "...", "Uhmm...", "Hmmm", "what?", "come again?", "FBI..."},
            next = nil,
            set = {},
            stats = {},
        }
    },
    
    namelessEncounterCat2 = {
        req = {},
        traits = {
            isSpecial = true,
            isNameless = true
        },
        text = {[[#You hear something inaudible]], [["Winter is coming, but not here"]], [["Frogs hopped over the black juice"]], [["Finally here I am!!!"]]},
        
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = {"wow", "okay...", "nice", "you are...?"},
            next = nil,
            set = {},
            stats = {},
        },
        yes = {
            text = {"???", "...", "Uhmm...", "Hmmm", "what?"},
            next = nil,
            set = {},
            stats = {},
        }
    },
    
    lateClass = {
        req = {},
        traits = {
            lecturer = true
        },
        -- isNarrator = true,
        text = [["You're late for a class..."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "take a bike",
            -- next = nil,
            set = {},
            stats = {
                coin = -SMALL_BASIC,
            },
            next = {
                isNarrator = true,
                text = "You made it in time to the lecture.",
                stats = {
                    brain=SMALL_BASIC
                }
            }
        },
        yes = {
            text = "trek fast",
            -- next = nil,
            set = {
                unserious = true
            },
            stats = {
                popularity = -BASIC
            },
            next = {
                isNarrator = true,
                text = "Congrats!\nYou saved money...!",
                stats = {
                    coin = SMALL_BASIC,
                },
                next = {
                    isNarrator = true,
                    text = "...But you completely missed the class.",
                    stats = {
                        brain = -BASIC
                    }
                }
            }
        }
    },
    
    assignment = {
        req = {},
        traits = {
            lecturer = true
        },
        text = {[["There'll be a class tomorrow, be there.]], [[I'm setting a practical next week.]], [["Give your course mates this assignment."]]},
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = {"no problem", "oh"},
            -- next = nil,
            set = {},
        },
        yes = {
            text = {"thank you?", "okay"},
            -- next = nil,
            set = {},
        }
    },
    
    fail = {
        req = {
            unserious = true
        },
        traits = {
            lecturer = true
        },
        text = [["@YOU. ~ You'll fail my course."]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "please, no!",
            -- next = nil,
            set = {},
            stats = {
                brain = {-SMALL_BASIC, -BIG_BASIC}
            }
        },
        yes = {
            text = "why???",
            -- next = nil,
            set = {},
            stats = {
                brain = {-LARGE_BASIC, -BIG_BASIC, -BIG_BASIC}
            }
        }
    },
    
    
    campusEntrepreneur = {
        req = {},
        traits = { entrepreneurial = nil },
        text = [["Want to start a small business on campus?"]],
        repeatsAllowed = SMALL_BASIC,
        no = {
            text = "not interested",
            next = nil,
            set = {},
            stats = { popularity = -SMALL_BASIC }
        },
        yes = {
            text = "let's do it",
            stats = { coin = -SMALL_BASIC, brain = SMALL_BASIC, popularity = BASIC },
            next = {{
                isNarrator = true,
                text = "Your venture takes off.",
                stats = { coin = {BASIC, BIG_BASIC }}
            },
            {
                 isNarrator = true,
                 text = "Your business crashed...",
                 stats = {coin = {-LARGE_BASIC, -BASIC}}
            }}
        }
    },


    chickenScene = {
        req = {},
        traits = {
            -- sketchy = true
            isSpecial = true,
            isNameless = true,
        },
        text = [["I just saw a chicken wearing a tiny backpack. Want to investigate?"]],
        repeatsAllowed = SMALL_BASIC,
        no = {
            text = "what?",
            next = nil,
            set = {},
            stats = {
                popularity = -SMALL_BASIC
            }
        },
        yes = {
            text = "let's go",
            stats = {
                brain = -BASIC,
                popularity = BASIC
            },
            next = {
                isNarrator = true,
                text = "You spend the next hour chasing a chicken.",
                stats = {}
            }
        }
    },

    examStress = {
        req = {},
        traits = {
            academic = true
        },
        text = [["Boss, I'm freaking out about this exam. Got any tips?"]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "nope",
            next = nil,
            set = {},
            stats = {
                popularity = -SMALL_BASIC
            }
        },
        yes = {
            text = "stay calm",
            stats = {
                brain = SMALL_BASIC,
                popularity = BASIC
            },
                
            next = {{
                isNarrator = true,
                text = "You help your course mate relax and focus.",
                stats = {
                    brain = BASIC
                },
                
            },
            {
                next = {
                    isNarrator = true,
                    text = "But they end up getting an F when they @calmly ~ submitted a blank script",
                    stats = {
                        popularity = {-BIG_BASIC, -BASIC}
                    }
                },
                isNarrator = true,
                text = "You help your course mate relax and focus.",
                stats = {
                    brain = BASIC
                },
                
            }
            }
        }
    },

    campusEvent = {
        req = {},
        traits = {
            cool = true
        },
        text = [["Want to check out the campus music festival?"]],
        repeatsAllowed = SMALL_BASIC,
        no = {
            text = "nah",
            next = nil,
            set = {},
            stats = {
                popularity = -SMALL_BASIC
            }
        },
        yes = {
            text = "yeah",
            stats = {
                popularity = BASIC
            },
            next ={ {
                isNarrator = true,
                text = "You have a good time.",
                stats = {}
            }, {
                isNarrator = true,
                text = "It was pretty boring.",
                stats = {brain=-SMALL_BASIC}
            } }
        }
    },

    abroadStudy = {
        req = {},
        traits = {
            sketchy = true
        },
        text = [["Want to study abroad? I have some connections..."]],
        repeatsAllowed = SMALL_BASIC,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                popularity = {-BASIC, -SMALL_BASIC},
                brain = BASIC
            }
        },
        yes = {
            text = {"YES!","of course...","Why not?","Hook me up", "okay", "yes"},
            stats = {
                popularity = BASIC, brain = BASIC
            },
            next = {
                sameCharacter = true,
                text = "Okay, let me get my contacts...",
                stats = {},
                next = {
                    isNarrator = true,
                    text = "Turns out the contact was a pretty big scammer.",
                    stats = {coin=-LARGE_BASIC, brain={-BIG_BASIC,-BASIC}}
                }
            }
        }
    },

    gamerMoment = {
        req = {},
        traits = {
            gamer = true
        },
        text = [["Bro, have you played the new 'ePic ShoOTer' game?"]],
        repeatsAllowed = SMALL_BASIC,
        no = {
            text = "no",
            next = nil,
            set = {},
            stats = {
                popularity = -SMALL_BASIC
            }
        },
        yes = {
            text = "yes!",
            stats = {
                -- brain = -BASIC,
                popularity = BASIC
            },
            next = { {
                isNarrator = true,
                text = "You spend hours discussing gaming strategies.",
                stats = {brain=-BASIC}
            },{
                sameCharacter = true,
                text = [["Oh for real?? I hate that game..."]],
                stats = {popularity=-BASIC}
            } }
        }
    },

    cryptoAlert = {
        req = {},
        traits = {
            crypto = true
        },
        text = [["Check out this new crypto opportunity!"]],
        repeatsAllowed = SMALL_BASIC,
        no = {
            text = "not interested",
            next = nil,
            set = {},
            stats = {
                popularity = -SMALL_BASIC,
                brain = SMALL_BASIC
            }
        },
        yes = {
            text = "tell me more...",
            stats = {
                brain = -BASIC,
                popularity = BASIC
            },
            next = {
                isNarrator = true,
                text = "You invest and...",
                next = { {
                    isNarrator=true, text="It crashes",
                    stats = {coin = {-LARGE_BASIC, -BIG_BASIC, -BASIC}}
                }, {
                    isNarrator=true, text="It blows up",
                    stats = {coin = {LARGE_BASIC, BIG_BASIC, BASIC}}
                }}
            }
        }
    }
    
}

template = {
        req = {},
        traits = {
            --cow = true
        },
        text = [[""]],
        repeatsAllowed = BASIC_REPEATS,
        no = {
            text = "no",
            -- next = nil,
            set = {},
            stats = {
                coin = SMALL_BASIC,
                popularity = -BASIC,
                -- church = -SMALL_BASIC
            },
            nil_next = {
                isNarrator = true,
                text = "You seem to have offended the lecturer.",
                stats = {}
            }
        },
        yes = {
            text = "yes",
            -- next = nil,
            set = {},
            stats = {
                church = MEDIUM_BASIC,
                popularity = BASIC,
                coin = -BASIC
            },
            next = {
                isNarrator = true,
                text = "You never hear about the money again...",
                stats = {}
            }
        }
    }
    
return talk