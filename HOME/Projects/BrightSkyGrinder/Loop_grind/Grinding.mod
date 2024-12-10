
MODULE Grinding
    TASK PERS tooldata grinder_assembly:=[TRUE,[[243.782,-12.1178,218.512],[1,0,0,0]],[5.2,[150,5,20],[1,0,0,0],0,0,0]];
	TASK PERS wobjdata wobj_samplePlate:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
	CONST loaddata grinder_load:=[0,[0,0,0],[1,0,0,0],0,0,0];
    CONST robtarget TopPlateHome:=[[571.60,-222.59,237.44],[0.706893,0.707318,0.00122417,-0.000923157],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget BtmPlateHome:=[[582.48,-216.83,149.93],[0.706897,0.707315,0.00133125,-0.000984594],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST num tolerance := 5.0;
    
    VAR num num_pass:= 3;                         ! Number of loops
    VAR speeddata velocity := [10,500,5000,1000];   ! Adjustable velocity
    VAR speeddata velocity_edge := [10,500,5000,1000];
    VAR num tcp_feedrate:= 20;
    VAR bool run_status;
    VAR bool waiting_at_home;
    VAR bool waiting_at_grind0;
    VAR bool finished_grind_pass;
    VAR num distance;
    LOCAL VAR intnum intnum_reset_grind_bool;
    VAR num feedrate_factor:=0.5;
    
    FUNC bool IsNear(pos p1, pos p2, num tolerance)
        distance := Sqrt(Pow(p2.x - p1.x, 2) + Pow(p2.y - p1.y, 2) + Pow(p2.z - p1.z, 2));
        TPWrite "Distance: " + NumToStr(distance, 2);
        RETURN Sqrt(Pow(p2.x - p1.x, 2) + Pow(p2.y - p1.y, 2) + Pow(p2.z - p1.z, 2)) <= tolerance;
    ENDFUNC
    
	PROC ReturnHome()
		MoveL TopPlateHome, v100, z50, grinder_assembly\WObj:=wobj_samplePlate;
	ENDPROC
    
	PROC packing()
		CONST jointtarget jpos10:=[[0,0,0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		MoveAbsJ jpos10\NoEOffs, v100, z50, grinder_assembly\WObj:=wobj_samplePlate;
	ENDPROC
    
    TRAP ResetAllbool
		 run_status := FALSE;
         waiting_at_home := FALSE;
         waiting_at_grind0 := FALSE;
         finished_grind_pass := FALSE;
         Stop;
    ENDTRAP
    
	PROC main()
        IDelete intnum_reset_grind_bool;
        CONNECT intnum_reset_grind_bool WITH ResetAllbool;
        ISignalDI RESET_GRIND_BOOL,edge,intnum_reset_grind_bool;
		FeedRate_Loop num_pass, velocity, velocity_edge, tcp_feedrate;
	ENDPROC
    
	PROC FeedRate_Loop(num num_pass,speeddata velocity, speeddata velocity_edge, num tcp_feedrate)
		CONST robtarget PlateWP10:=[[652.72,-247.89,226.93],[0.706845,0.707366,0.00144232,-0.00118361],[0,1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget PlateWP20:=[[652.70,-247.89,216.86],[0.706837,0.707374,0.00149292,-0.00123459],[0,1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        CONST robtarget PlateWP30:=[[651.22,-247.90,136.49],[0.706846,0.707364,0.00157415,-0.00133491],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget PlateWP40:=[[651.17,-247.91,127.36],[0.706836,0.707374,0.00166929,-0.00143818],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        VAR string last_position := "";  ! Tracks the last position
        VAR pos current_position;  ! Store the current position
        VAR num i; ! Loop index variable
        velocity.v_tcp := tcp_feedrate;
        velocity_edge.v_tcp := tcp_feedrate * feedrate_factor;
        
        waiting_at_home := FALSE;
        waiting_at_grind0 := FALSE;
        finished_grind_pass := FALSE;
        !RAPID officially START
        run_status := TRUE;
        
        ! Move to Home position
        MoveL TopPlateHome, v50, z0, grinder_assembly\WObj:=wobj_samplePlate;
        last_position := "TopPlateHome";
        waiting_at_home := TRUE;
        WaitUntil waiting_at_home = FALSE;
        
        ! Move to initial position
        MoveL PlateWP10, v50, z0, grinder_assembly\WObj:=wobj_samplePlate;
        last_position := "PlateWP10";
        waiting_at_grind0 := TRUE;
        WaitUntil waiting_at_grind0 = FALSE;
        
        current_position := CPos();
        
        !begin grind loop
        FOR i FROM 1 TO num_pass DO
            current_position := CPos();
            ! Decide the next position based on the last position
            IF last_position = "PlateWP10" THEN
                MoveL PlateWP20, velocity_edge, z1, grinder_assembly\WObj:=wobj_samplePlate;
                MoveL PlateWP30, velocity, z5, grinder_assembly\WObj:=wobj_samplePlate;
                MoveL PlateWP40, velocity_edge, z1, grinder_assembly\WObj:=wobj_samplePlate;
                last_position := "PlateWP40";  ! Update the last position
            ELSEIF last_position = "PlateWP40" THEN
                MoveL PlateWP30, velocity_edge, z1, grinder_assembly\WObj:=wobj_samplePlate;
                MoveL PlateWP20, velocity, z5, grinder_assembly\WObj:=wobj_samplePlate;
                MoveL PlateWP10, velocity_edge, z1, grinder_assembly\WObj:=wobj_samplePlate;
                last_position := "PlateWP10";  ! Update the last position
            ELSE
                TPWrite "Warning: Unknown last position. Manual intervention required.";
                Stop;  ! Halt the program for manual intervention
            ENDIF
        ENDFOR
        finished_grind_pass := TRUE;
        
        !after loop process
        current_position := CPos();
        IF last_position = "PlateWP40" THEN
            MoveL BtmPlateHome, v50, z0, grinder_assembly\WObj:=wobj_samplePlate;
            MoveL TopPlateHome, v50, z0, grinder_assembly\WObj:=wobj_samplePlate;
            last_position := "TopPlateHome";
        ELSEIF last_position = "PlateWP10" THEN
            MoveL TopPlateHome, v50, z0, grinder_assembly\WObj:=wobj_samplePlate;
            last_position := "TopPlateHome";
        ELSE
            TPWrite "Warning: Unknown last position. Manual intervention required.";
            Stop;  ! Halt the program for manual intervention
        ENDIF
        
        WaitUntil finished_grind_pass = FALSE;
        run_status := FALSE; 
        IF RunMode() = RUN_CONT_CYCLE THEN
            Stop;
        ENDIF
        
	ENDPROC

!        ! Begin grind loop
!        FOR i FROM 1 TO num_pass DO
!            ! Get the current position
!            current_position := CPos();
        
!            ! Compare current position with waypoints
!            IF IsNear(current_position, PlateWP10.trans, tolerance) THEN
!                MoveL PlateWP20, velocity, z0, grinder_assembly\WObj:=wobj_samplePlate;
!            ELSEIF IsNear(current_position, PlateWP20.trans, tolerance) THEN
!                MoveL PlateWP10, velocity, z0, grinder_assembly\WObj:=wobj_samplePlate;
!            ELSE
!                TPWrite "Warning: Current position does not match expected waypoints.";
!                Stop;  ! Halt for manual intervention
!            ENDIF
!        ENDFOR
        
!        ready_status := FALSE;

!        ! After loop process
!        current_position := CPos();  ! Get the final position
!        IF IsNear(current_position, PlateWP20.trans, tolerance) THEN
!            MoveL BtmPlateHome, v100, z20, grinder_assembly\WObj:=wobj_samplePlate;
!        ELSEIF IsNear(current_position, PlateWP10.trans, tolerance) THEN
!            MoveL TopPlateHome, v100, z20, grinder_assembly\WObj:=wobj_samplePlate;
!        ELSE
!            TPWrite "Warning: Unknown final position. Manual intervention required.";
!            Stop;  ! Halt the program for manual intervention
!        ENDIF  
    
    
ENDMODULE       