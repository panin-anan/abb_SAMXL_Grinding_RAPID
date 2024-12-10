
MODULE Grinding
    TASK PERS tooldata grinder_assembly:=[TRUE,[[243.782,-12.1178,218.512],[1,0,0,0]],[5.2,[150,5,20],[1,0,0,0],0,0,0]];
	TASK PERS wobjdata wobj_samplePlate:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
	CONST loaddata grinder_load:=[0,[0,0,0],[1,0,0,0],0,0,0];
    CONST robtarget TopPlateHome:=[[619.29,-216.75,204.16],[0.706956,0.707256,0.000975651,-0.000509137],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget BtmPlateHome:=[[619.92,-216.68,89.75],[0.706972,0.70724,0.00101863,-0.00052772],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST num tolerance := 5.0;
    
    VAR num num_pass:= 3;                         ! Number of loops
    VAR speeddata velocity := [10,500,5000,1000];   ! Adjustable velocity
    VAR num tcp_feedrate:= 10;
    VAR bool run_status;
    VAR bool waiting_at_home;
    VAR bool waiting_at_grind0;
    VAR bool finished_grind_pass;
    VAR num distance;
    
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
    
	PROC main()
		FeedRate_Loop num_pass, velocity, tcp_feedrate;
	ENDPROC
    
	PROC FeedRate_Loop(num num_pass,speeddata velocity, num tcp_feedrate)
		CONST robtarget PlateWP20:=[[653.68,-216.80,82.93],[0.706981,0.707232,0.00102561,-0.000647388],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget PlateWP10:=[[653.80,-216.76,157.91],[0.706968,0.707245,0.000868185,-0.000448946],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        VAR string last_position := "";  ! Tracks the last position
        VAR pos current_position;  ! Store the current position
        VAR num i; ! Loop index variable
        velocity.v_tcp := tcp_feedrate;
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
                MoveL PlateWP20, velocity, z0, grinder_assembly\WObj:=wobj_samplePlate;
                last_position := "PlateWP20";  ! Update the last position
            ELSEIF last_position = "PlateWP20" THEN
                MoveL PlateWP10, velocity, z0, grinder_assembly\WObj:=wobj_samplePlate;
                last_position := "PlateWP10";  ! Update the last position
            ELSE
                TPWrite "Warning: Unknown last position. Manual intervention required.";
                Stop;  ! Halt the program for manual intervention
            ENDIF
        ENDFOR
        finished_grind_pass := TRUE;
        
        !after loop process
        current_position := CPos();
        IF last_position = "PlateWP20" THEN
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