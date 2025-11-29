ax_core.levels = {}

-- Level 1: Intro
table.insert(ax_core.levels, function(player)
    local player_name = player:get_player_name()
    ax_core.players[player_name].max_target_distance = ax_core.default_max_target_distance
    -- set player up in the right starting spot and look
    ax_core.lang.script(player,"one_shot",{
        {"pos" ,0,19,-8.7,56},
        {"look",0,19,-9,55},
    }, nil)
    ax_core.play_music(player_name,"0_0_music", false)
    ax_core.play_replay("intro")
    core.show_formspec(player_name, "fadein", ax_core.fadein)
    local script = {
        {"text",0,"Welcome, Agent X, to your Infiltration - Operative - Orientation.",0.3,1.5},
        {"voice",0,"0_1_Welcome_Agent_X_to_your",0,4.5},
        {"wait",4.5},
        {"text",0,"You are a state of the art autonomous robot created for the sole purpose of espionage.",0.22,1.5},
        {"voice",0,"0_2_You_are_a_state_of",0,5.0},
        {"circle_look", 2.5,19,55,0.785,0,19,-9,55},
        {"circle_look", 2.5,19,55,-0.785,0,19,-9,55},
        {"text",0,"We have equipped you with finely calibrated decompositional sensors, capable of detecting impurities in data facility structures, displayed in blue in your sensor feed.",0.32,2.6},
        {"voice",0,"0_3_We_have_equipped_you_with",0,11.0},
        {"circle_look", 2.0,19,55,-0.785,0,19,-9,55},
        {"line_look_line",8,26,-6,55,7/8,19,-7,55,2/8},
        {"wait",0.8},
        {"text",0,"Using these impurities and our company's proprietary mag-grav attractors, you are able to traverse secure facilities without any moving parts whatsoever.",0.3,2.5},
        {"voice",0,"0_4_Using_these_impurities_and_our",0,9.0},
        {"wait",3},
        {"line",8,26,-6,61,6/8},
        {"text",0,"Our Targets go to great lengths to protect their secrets with complex installations - with laser fields capable of melting you in an instant.",0.3,3.5},
        {"voice",0,"0_5_Our_Targets_go_to_great",0,9.0},
        {"line",9.0,26,-6,70,1},
        {"look",0,19,-7,70},
        {"replay",0,"intro2",0},
        {"wait",0.8},
        {"text",0,"Before you are given your first mission, we must calibrate your control and reaction functionality.",0.28,1.5},
        {"voice",0,"0_6_Before_you_are_given_your",0,5.0},
        {"line",2,22,-4.5,76,3.7},
        {"look",0,19,-5.5,76},
        {"line_look_line",1,19,-4.5,79,3.7,19,-4.5,81,6},
        {"line_look_line",1,19,-6.0,82,3.7,19,-7.0,82,5},
        {"line_look_line",1,19,-9.0,82,3.7,19,-9.0,83,3.7},
        {"wait",0.8},
        {"text",0,"Are you ready?",0.25,0.25},
        {"voice",0,"0_7_Are_you_Ready",0,1.0},
        {"wait",0.9},
        {"line_look_line",0.05,0,0,0,0,19,-6.0,83,1},
        {"line_look_line",0.22,0,0,0,0,19,-12.0,83,1.2},
        {"line_look_line",0.22,0,0,0,0,19,-6.0,83,1.2},
        {"line_look_line",0.22,0,0,0,0,19,-12.0,83,1.2},
        {"line_look_line",0.22,0,0,0,0,19,-9.0,83,1},
    }
    core.after(0.9, function()
        core.close_formspec(player_name, "")
        ax_core.lang.script(player,"one_shot",script, function()
            core.show_formspec(player:get_player_name(), "fadeout", ax_core.fadeout)
            core.after(0.9, function()
                ax_core.levels[2](player)
            end)
        end)
    end)
end)

-- Level 2: Tutorial 1, movement
table.insert(ax_core.levels, function(player)
    local player_name = player:get_player_name()
    ax_core.players[player_name].max_target_distance = ax_core.default_max_target_distance
    ax_core.play_music(player_name,"1_0_music", true)
    ax_core.lang.script(player,"one_shot",{
        {"pos" ,0.0,19,-9,82},
        {"look",0.0,19,-9,83},
    }, nil)
    local script = {
        {"attach",0},
        {"objective",0,25.5,-5.0, 89,22.5,-4, 91.0},
        {"detect",0   ,25.5,-5.0, 88,22.5,-2, 91.0,15},
        {"voice",0,"1_01_First_lets_begin_with_the",0,4.0},
        {"chat",0,"First, let's begin with the basics: mag-grav movement and objectives."},
        {"wait",4.0},
        {"voice",0,"1_02_Notice_the_yellow_glowing_orbs",0,6.0},
        {"chat",0,"Notice the yellow glowing orbs on that platform, your current objective, and the attractor above it."},
        {"look",0,0,0,0},
        {"line_look_line",3,0,0,0,0,25,-3,90,3},
        {"wait",3.2},
        {"voice",0,"1_03_Click_or_tap_the_attractor",0,4.0},
        {"chat",0,"Click or tap the attractor above that platform to propel there."},
        {"wait",900000000},
        {"objective",0,12.5,-0.5,104,10.5, 0,106.5},
        {"detect",0,   12.5,-1.5,104.5,10.5, 0,106.5,31},
        {"voice",0,"1_04_Now_that_you_are_here",0,5.0},
        {"chat",0,"Now that you are here, click again anywhere there isn't an attractor to stop attracting."},
        {"wait",6.0},
        {"voice",0,"1_05_Notice_the_new_objective_on",0,5.0},
        {"chat",0,"Notice the new objective on that platform far in the corner, and the blue attractor on the ceiling."},
        {"look",0,0,0,0},
        {"line_look_line",3,0,0,0,0,16.5,0,100.5,5},
        {"wait",2.0},
        {"voice",0,"1_06_You_will_need_to_first",0,6.0},
        {"chat",0,"You will need to first propel to the attractor and time your release to land on the objective platform."},
        {"wait",5.7},
        {"voice",0,"1_07_If_you_miss_use_the",0,4.0},
        {"chat",0,"If you miss, use the floor attractors to start at the beginning."},
        {"wait",900000000},
        {"objective",0,14.5,-3.5,87.5,17.5, -1,90.5},
        {"detect",0   ,16.0,-3.5,87.5,17.5, -1,90.5,45},
        {"voice",0,"1_08_Great_job_Now_you_need",0,5.0},
        {"chat",0,"Great job! Now you need to propel to the far attractors on the opposite wall."},
        {"wait",2.0},
        {"look",0,0,0,0},
        {"line_look_line",3,0,0,0,0,11.5,1.6,89,3},
        {"voice",0,"1_09_Along_the_way_youll_quickly",0,8.0},
        {"chat",0,"Along the way you'll quickly need to switch to the attractors embedded in the wall on the left"},
        {"wait",3.0},
        {"line_look_line",1.5,0,0,0,0,16,0,92,3},
        {"chat",0,"to make it to the last objective platform nearby."},
        {"wait",3.5},
        {"wait",900000000},
        {"detach",0},
        {"wait",0.5},
        {"voice",0,"1_10_Alright_I_think_you_have",0,8.0},
        {"text",0,"Alright, I think you have mastered the basics, let's move on to Laser Fields...",0.25,0.75},
        {"wait",4.25}
    }
    core.show_formspec(player:get_player_name(), "fadein", ax_core.fadein)
    core.after(1.275, function()
        core.close_formspec(player_name, "")
        ax_core.lang.script(player,"one_shot",script, function()
            core.show_formspec(player:get_player_name(), "fadeout", ax_core.fadeout)
            core.after(0.9, function()
                ax_core.levels[3](player)
            end)
        end)
    end)
end)

-- Level 3: Tutorial 2, laser fields, weak attractors, max distance
table.insert(ax_core.levels, function(player)
    local player_name = player:get_player_name()
    ax_core.players[player_name].max_target_distance = 18
    ax_core.play_music(player_name,"2_0_music", true)
    local script = {
        {"pos" ,0,5,-8,86},
        {"look",0,4,-8,85},
        {"objective",0,-4,-3,86.5,-2,0,87.5},
        {"detect",   0,-4,-3,86.5,-2,0,87.5,28},
        {"formspec",0,"fadein"},
        {"wait",1.25},
        {"formspec",0,""},
        {"voice",0,"2_1_Sensor_tech_has_not_kept",0,5.0},
        {"text",0,"Sensor tech has not kept up with the pace of stealth tech in the past several decades.",0.22,0.75},
        {"text",0,"Sensor tech has not kept up with the pace of stealth tech in the past several decades.",0.22,0.75},
        {"wait",0.5},
        {"line_look_line",4.5,2,-6,84,1,-12,-6,84,2.5},
        {"voice",0,"2_2_As_a_result_secure_facilities",0,7.0},
        {"text",0,"As a result, secure facilities have gone the oldschool route: If they can't sense you, they'll just destroy you.",0.27,1.3},
        {"line_look_line",7.0,-11,-6,84,2,-12,-6,84,2.5},
        {"voice",0,"2_3_Your_next_objective_is_at",0,6.0},
        {"text",0,"Your next objective is at the left doorway, and take note of all the laser fields between you and that location.",0.25,0.75},
        {"line_look_line",1.5,-11,-1,84,2,-11,-1,87,2.5},
        {"line_look_line",1.5,-11,-1,84,3,-3,-1,85,3},
        {"wait",3.0},
        {"voice",0,"2_4_For_now_we_are_having",0,10.0},
        {"text",0,"For now, we are having you practice in simulation, but be careful in real missions. Making so many operatives is a core cost driver in our line of work.",0.27,1.5},
        {"line_look_line",1.5,-11,-6,84,3,4,-6,85,2.5},
        {"line_look_line",7.0,  2,-6,84,3,4,-6,85,2.5},
        {"line_look_line",1.5,  5,-8,86,3,4,-8,85,2.5},
        {"attach",0},
        {"wait",100000000},
        {"detach",0},
        {"pos" ,0,-3,0,87},
        {"objective",0,5,-1,101.5,3,2,102.5},
        {"detect",   0,5,-1,101.5,3,2,102.5,52},
        {"voice",0,"2_5_That_took_fewer_attempts_than",0,6.0},
        {"text",0,"That took fewer attempts than predicted - adjusting future prediction models accordingly.",0.32,1.0},
        {"look",0,0,0,0},
        {"line_look_line",6.0,-3,-3,87,0.5,-3,0,97,2.5},
        {"voice",0,"2_6_The_real_world_is_messy",0,9.0},
        {"text",0,"The real world is messy, and our mag-grav technology sometimes can only find so many impurities in top of the line facility structures.",0.3,1.0},
        {"line_look_line",9.0,-3,0,97,0.5,-3,0,97,2.5},
        {"voice",0,"2_7_We_have_noted_these_more",0,9.0},
        {"text",0,"We have noted these more pure targets in purple on your sensor feed. Your attraction to these targets will be less than the normal blue ones.",0.3,1.0},
        {"line_look_line",9.0,-3,0,97,0.5,-2,2.5,100,2.5},
        {"voice",0,"2_8_Leverage_such_differences_as_you",0,6.0},
        {"text",0,"Leverage such differences as you see fit, they can often be more helpful than not.",0.29,1.0},
        {"line_look_line",4.0,1,-1.5,95,2,4,-3,90,5},
        {"line_look_line",2.0,4,-3,90,2,0,-7.5,93.5,3},
        {"voice",0,"2_9_Your_next_objective_is_through",0,4.0},
        {"text",0,"Your next objective is through this maze of lasers, good luck.",0.24,0.75},
        {"wait",2.0},
        {"line_look_line",2.0,-3,-3,87,5,-3,0,97,4},
        {"attach",0},
        {"wait",100000000},
        {"objective",0,-0.5,-2.5,86.5,2.5,0.5,83.5},
        {"detect",   0,-0.5,-2.5,86.5,2.5,0.5,83.5,63},
        {"detach",0},
        {"voice",0,"2_10_Well_Done_For_the_final",0,9.0},
        {"text",0,"Well Done! For the final part of this test, we want to make clear that our mag-grav technology has a limit: it can only shoot medium distances",0.3,1.2},
        {"look",0,0,0,0},
        {"line_look_line",9.0,4,-1,102,0.25,2,2,104,1},
        {"voice",0,"2_11_Further_many_missions_we_wont",0,9.0},
        {"chat",0,"Further, many missions we won't have full intel on the target facility. Be fast, careful, and seek out the hidden safe room in the rest of this facililty."},
        {"attach",0},
        {"wait",100000000},
        {"detach",0},
        {"voice",0,"2_12_Congratulations_we_find_your_control",0,7.3},
        {"text",0,"Congratulations, we find your control and reaction functionality to be sufficiently calibrated for your first company mission.",0.33,1.3},
        {"wait",7.3},
        {"formspec",0,"fadeout"},
        {"wait",0.9},
    }
    ax_core.lang.script(player,"one_shot",script, function()
        ax_core.levels[4](player)
    end)
end)

-- Level 4: Mission One: Routine Compliance
table.insert(ax_core.levels, function(player)
    local player_name = player:get_player_name()
    ax_core.players[player_name].max_target_distance = 18
    ax_core.play_music(player_name,"3_0_music", true)
    local script = {
        {"pos" ,0,-2,32,94},
        {"look",0,-8.5,28.5,95},
        {"objective",0,-8,21.5,96.5,-10.5,24.5,93.5},
        {"detect",   0,-8,21.5,96.5,-10.5,23.0,93.5,37},
        {"formspec",0,"fadein"},
        {"wait",1.25},
        {"formspec",0,""},
        {"voice",0,"3_1_Our_line_of_work_has",0,4.5},
        {"text",0,"Our line of work has one reliable source of income: Regulation.",0.28,1.1},
        {"wait", 4.5},
        {"voice",0,"3_2_A_customer_will_build_a",0,6.6},
        {"text",0,"A customer will build a new facility and require our expertise in qualifying exacly how secure it is.",0.27,1.0},
        {"wait", 6.6},
        {"voice",0,"3_3_This_is_a_C_tier",0,7.6},
        {"text",0,"This is a C tier company installation, with no laser fields whatsoever. Instead they have opted for slowing operatives down.",0.3,1.2},
        {"circle_look",7.6,-8.5,95,1.2,0,-8.5,28.5,95},
        {"voice",0,"3_4_You_see_our_industry_can",0,8.6},
        {"text",0,"You see, our industry can send operatives into a facility for only short windows, and therefore delaying an operative is a valid strategy.",0.3,1.2},
        {"circle_look",8.6,-8.5,95,1.2,0,-8.5,28.5,95},
        {"voice",0,"3_5_Our_company_is_capable_of",0,7.6},
        {"text",0,"Our company is capable of very long windows, but in this case, we are qualifying this customer for a 30 second window.",0.27,1.2},
        {"circle_look",7.6,-8.5,95,1.2,0,-8.5,28.5,95},
        {"voice",0,"3_6_As_you_are_a_new",0,6.2},
        {"text",0,"As you are a new operative, but also state of the art, we figure your skill will mirror a run-of-the-mill operative.",0.25,1.0},
        {"circle_look",6.2,-8.5,95,1.2,0,-8.5,28.5,95},
        {"voice",0,"3_7_We_will_give_you_a",0,6.9},
        {"text",0,"We will give you a total of 45 seconds, after which you must try again - we need you to improve rapidly.",0.25,1.2},
        {"wait", 4.0},
        {"line_look_line",2.9,-18,22,85,6,-16,22,83,6},
        {"voice",0,"3_8_Good_Luck_Agent_X",0,1.5},
        {"text",0,"Good Luck, Agent X",0.25,0.5},
        {"line_look_line",1.5,-18,22,85,6,-16,22,83,3},
        {"pos",0,-18,22,85},
        {"timer",0,45},
        {"attach",0},
        {"wait",10000000},
        {"detach",0},
        {"voice",0,"3_9_Woohoo_You_finished_this_Luanti",0,9.2},
        {"text",0,"Woohoo! You finished this Luanti 2025 Game Jam version of Agent X - the rest of the story will be released later - stay tuned!",0.285,2.0},
        {"wait",9.2},
        {"formspec",0,"fadeout"},
        {"wait",0.9},
        {"formspec",0,""},
    }
    ax_core.lang.script(player,"one_shot",script, function()
        ax_core.startup(player)
    end)
end)