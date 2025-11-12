# Agent X

![Agent X Screenshot](screenshot.jpg)

## A Luanti GAME JAM 2025 Submission
(Which means not everything is perfect)

Next Steps:

1. Add 3-way and 4-way connectors for neons
2. Create ax_core.neon = {}
3. ax_core.neons.colors, ax_core.neons.shapes
4. ax_core:air_dark, ax_core:air_dim, ax_core:air_light, ax_core:air_bright
5. Extend cage to handle arbtrary shapes, and any of the ax_core:air nodes as replacables
6. Move the cage function to commands.lua
7. Change stop and play to save recordings to file and load recordings from file, both stored in ax_core modpath/replays
8. Change the name to replays from recordings
9. Extend physics to have not hardcoded strength values, affects replays
10. Create agent.lua that has the base player agent, and a replay agent, the replay agent doesn't collide
11. Extend ax_core language extended with sound, text, replay, replay_loop, checkpoint, start functions (start is pos of player agent and attaches us)
12. Extend ax_core language with detect (player_agent within the bounding box)
13. Get Voice for Voicing the narrator
14. Create yellow weak attractor, and red repulsor
15. Create laser field node that when we crash into we go to last checkpoint (pos, index in ax_core lang)
16. Create Main Menu "level"
17. Create Main Menu replay_loop
18. Create Main Menu formspec to be shown after first ax_core completes, probably should be a function to run an ax_core.lang, and you register a callback for on completion
19. Create Intro Sequence (level 0)
20. Create Tutorial Level 1 (Movement)
21. Create Tutorial Level 2 (Laser Fields)
