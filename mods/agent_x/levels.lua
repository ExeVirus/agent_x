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
        {"text",0,"You are equipped with finely calibrated decompositional sensors, capable of detecting impurities in data facility structures, displayed in blue in your sensor feed.",0.33,2.5},
        {"voice",0,"0_3_You_are_equipped_with_finely",0,10.0},
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
            ax_core.levels[2](player)
        end)
    end)
end)

-- Level 2: Tutorial 1, movement
table.insert(ax_core.levels, function(player)
    local player_name = player:get_player_name()
    ax_core.play_music(player_name,"mainmenu", true)
    -- local script = {
    --     {"pos" ,0,0.5,4,0},
    --     {"look",0.5,0.5,4,5},
    --     {"line",2,0.5,4,50,5}, -- 10
    --     {"replay",0,"mainmenu",true},
    --     {"line",2,0.5,4,50,5}, -- 20
    --     {"replay",0,"mainmenu",true},
    --     {"line",2,0.5,4,50,5}, -- 30
    --     {"replay",0,"mainmenu",true},
    --     {"line",2,0.5,4,50,5}, -- 40
    --     {"replay",0,"mainmenu",true},
    --     {"line",2,0.5,4,48,5}, -- 48
    --     {"replay",0,"mainmenu",true},
    -- }
    -- core.show_formspec(player:get_player_name(), "fadein", ax_core.fadein)
    -- core.after(1.275, function()
    --     ax_core.lang.script(player,"one_shot",script, function()
    --         ax_core.levels[2](player)
    --     end)
    -- end)
end)