ax_core.levels = {}

-- Level 1: Intro
table.insert(ax_core.levels, function(player)
    local player_name = player:get_player_name()
    -- set player up in the right starting spot and look
    ax_core.lang.script(player,"one_shot",{
        {"pos" ,0,19,-8.7,56},
        {"look",0,19,-9,55},
    }, nil)
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
    ax_core.play_music(player_name,"mainmenu", true)
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
        {"objective",0,14.5,-2.5,87.5,17.5, 0,90.5},
        {"detect",0   ,16.0,-2.5,87.5,17.5, 0,90.5,45},
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
        {"wait",1.0},
        {"voice",0,"1_10_Alright_I_think_you_have",0,8.0},
        {"text",0,"Alright, I think you have mastered the basics, let's move on to Laser Fields...",0.25,0.25},
    }
    core.show_formspec(player:get_player_name(), "fadein", ax_core.fadein)
    core.after(1.275, function()
        core.close_formspec(player_name, "")
        ax_core.lang.script(player,"one_shot",script, function()
            --core.show_formspec(player:get_player_name(), "fadeout", ax_core.fadeout)
            core.after(0.9, function()
                --ax_core.levels[3](player)
            end)
        end)
    end)
end)