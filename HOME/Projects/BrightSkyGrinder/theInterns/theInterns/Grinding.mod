
MODULE Grinding
	TASK PERS tooldata grinder_assembly:=[TRUE,[[243.782,-12.1178,218.512],[1,0,0,0]],[5.2,[0,0,0],[1,0,0,0],0,0,0]];
	TASK PERS wobjdata wobj_samplePlate:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
	CONST robtarget PlateWP30:=[[640.72,-263.31,200.69],[0.706887,0.707227,-0.00835972,0.00841083],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	PROC ReturnHome()
		MoveL [[640.73,-263.32,175.99],[0.707016,0.707095,-0.00848551,0.00854303],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, z50, grinder_assembly\WObj:=wobj_samplePlate;
	ENDPROC
	PROC packing()
		CONST jointtarget jpos10:=[[0,0,0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		MoveAbsJ jpos10\NoEOffs, v1000, z50, grinder_assembly\WObj:=wobj_samplePlate;
	ENDPROC
	PROC main()
		FeedRate_Loop;
	ENDPROC
	PROC FeedRate_Loop()
		CONST robtarget TopPlateWP:=[[640.68,-263.32,200.95],[0.706988,0.707125,-0.00840507,0.00844204],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget PlateWP20:=[[640.72,-263.31,163.42],[0.706926,0.707187,-0.00838843,0.00843419],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget PlateWP10:=[[640.72,-263.31,200.69],[0.706887,0.707227,-0.00836105,0.0084095],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		MoveL PlateWP10, v10, z1, grinder_assembly;
		MoveL PlateWP20, v10, z1, grinder_assembly;
		MoveL PlateWP10, v10, z1, grinder_assembly;
	ENDPROC

ENDMODULE