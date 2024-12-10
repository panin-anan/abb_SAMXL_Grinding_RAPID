
MODULE Grinding
	TASK PERS tooldata grinder_assembly:=[TRUE,[[243.782,-12.1178,218.512],[1,0,0,0]],[5.2,[0,0,0],[1,0,0,0],0,0,0]];
	PROC ReturnHome()
		MoveJ [[291.05,138.69,357.90],[0.499872,0.473805,0.499219,0.525754],[0,1,1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, z50, grinder_assembly\WObj:=wobjBox;
	ENDPROC

ENDMODULE