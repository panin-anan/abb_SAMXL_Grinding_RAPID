# abb_SAMXL_Grinding_RAPID
contains RAPID program for ABB robot trajectory setting. to be loaded onto ABB robot and navigate with Flexpendant

Currently has one program:
1. `Loop_Grind.pgf`: grinding trajectory control RAPID program of ABB robot by `panin-anan` and `Luka140`. For operation with ROS2, use in conjunction with `rws_motion_client` repository (https://github.com/Luka140/rws_motion_client)

## Loop_Grind RAPID Summary
Move robot arm through a set of waypoints once RAPID is started. Linear movement from TCP coordinate frame (MoveL)
There are 6 waypoints in the program:
1. two way points for home position: TopPlateHome and BTMPlateHome
2. four way points for grinding pass movement loop: PlateWP10, PlateWP20, PlateWP30, PlateWP40

These points are set manually using the ABB Robot FlexPendant. 
For the robot arm movement speed and number of grind pass, there are two variables which will be set by `rws_motion_client` ROS2 node:
1. tcp_feedrate: robot arm movement speed in mm/s for grinding pass
2. num_pass: number of grind passes for a single grind test

The RAPID program also contain variables for Wait instruction to coordinate with `rws_motion_client`:
1. `run_status`
2. `waiting_at_home`
3. `waiting_at_grind0`
4. `finished_grind_loop`

All four variables are bool and set to False by default. They are set to True by `rws_motion_client` node when the following conditions are met:
- `run_status` is set to True after initial RAPID starts. It will only be set to False when the RAPID program finish the grind.
- `waiting_at_home` is set to True when the robot arm moves to TopPlateHome position at the start and waits there until `waiting_at_home` is set to False by `rws_motion_client` node.
- `waiting_at_grind0` is set to True when the robot arm moves to PlateWP10 position before grinding and waits there until `waiting_at_grind0` is set to False by `rws_motion_client` node.
- `finished_grind_loop` is set to True immediately after looping the four grinding waypoints for the specified num_pass and wait for `rws_motion_client` node to set it back to False when the robot arm moves back to home.
