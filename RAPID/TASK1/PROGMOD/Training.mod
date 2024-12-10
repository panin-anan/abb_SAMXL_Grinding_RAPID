
MODULE Training
    VAR egmident egmID1;                   ! EGM session identifier
    VAR egm_minmax egm_condition:=[-10,10];

	TASK PERS tooldata PenJank:=[TRUE,[[-63.0663,45.907,311.334],[1,0,0,0]],[0.2,[0,0,100],[1,0,0,0],0,0,0]];
	TASK PERS wobjdata training_paper:=[FALSE,TRUE,"",[[494.049,-18.5946,-6.94719],[0.999986,0.0024666,-0.00304233,0.00354377]],[[0,0,0],[1,0,0,0]]];
	PROC main_draw()
		draw;
		draw_head;
	ENDPROC
	PROC draw()
		MoveJ [[89.56,64.43,121.77],[0.015993,0.0081887,0.999653,-0.019265],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[144.01,83.42,-0.34],[0.01597,0.00820343,0.999653,-0.0192517],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[118.68,83.57,-0.19],[0.0159603,0.00822843,0.999653,-0.0192479],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[118.78,83.63,10.94],[0.0159993,0.00821957,0.999653,-0.0192529],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[143.21,59.16,10.91],[0.0159988,0.00818677,0.999653,-0.0192624],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[143.10,59.10,0.21],[0.0159642,0.0081952,0.999653,-0.0192592],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[116.70,59.28,0.37],[0.0159677,0.00819822,0.999654,-0.0192526],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[116.79,59.36,18.12],[0.0159729,0.00820352,0.999653,-0.0192602],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL [[101.60,102.48,0.11],[0.0158512,0.00820083,0.999655,-0.0192775],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveC [[86.86,70.18,-0.12],[0.015776,0.00830161,0.999655,-0.0192708],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], [[101.20,35.81,-0.09],[0.0155471,0.00830475,0.999659,-0.019276],[-1,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z10, PenJank\WObj:=training_paper;
		MoveJ [[98.06,69.13,67.32],[0.0155505,0.00829167,0.999659,-0.0192928],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
	ENDPROC
	PROC draw_head()
		CONST robtarget head_left:=[[115.04,105.85,-0.25],[0.0153932,0.00838018,0.999661,-0.0192695],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget head_right:=[[119.36,26.75,-0.25],[0.0154388,0.00837668,0.99966,-0.0192607],[-1,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget head_top:=[[154.21,72.61,-0.25],[0.0154318,0.0083321,0.99966,-0.0192875],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		CONST robtarget head_bottom:=[[72.74,66.63,-0.25],[0.0154219,0.00842581,0.99966,-0.0192569],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		MoveJ [[152.30,73.65,19.21],[0.0154308,0.0084312,0.99966,-0.0192541],[0,1,2,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, PenJank\WObj:=training_paper;
		MoveL head_top, v200, z50, PenJank\WObj:=training_paper;
		MoveC head_right, head_bottom, v200, z10, PenJank\WObj:=training_paper;
		MoveC head_left, head_top, v200, z10, PenJank\WObj:=training_paper;
	ENDPROC
	PROC EGMTraining()
		EGMGetId egmID1;
        ! Set up EGM for Cartesian pose control
        EGMSetupUC ROB_1, egmID1, "default", "UCdevice"\Joint;
        EGMStreamStart egmID1\SampleRate:=16;
        
        MoveL TopPlateHome, v20, z0, grinder_assembly\WObj:=wobj_samplePlate;
        MoveL BtmPlateHome, v20, z0, grinder_assembly\WObj:=wobj_samplePlate;
        
        EGMStreamStop egmID1;
        EGMReset egmID1;
	ENDPROC

ENDMODULE