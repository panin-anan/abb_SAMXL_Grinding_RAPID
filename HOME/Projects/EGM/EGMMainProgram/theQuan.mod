
MODULE theQuan
    TASK PERS tooldata toolPen:=[TRUE,[[2.54624,-7.07583,316.221],[0.999729,0.000158817,0.0232659,-3.6922E-06]],[1,[0,0,10],[1,0,0,0],0,0,0]];
    TASK PERS wobjdata wobjBox:=[FALSE,TRUE,"",[[525.7,52.9008,-168.695],[0.688698,0.0271935,0.0105152,-0.724462]],[[0,0,0],[1,0,0,0]]];
    
	CONST robtarget pHome:=[[26.37,82.47,226.12],[0.0134407,-0.642398,0.765809,-0.0260865],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pHome10:=[[61.79,226.82,15.17],[0.0134238,-0.642388,0.765818,-0.0260843],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pHome20:=[[61.83,226.76,2.81],[0.0133946,-0.642387,0.765818,-0.0261251],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget p0:=[[140.0,16.0,30.0],[0.0131988,-0.642342,0.765851,-0.0263522],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p10:=[[140.0,16.0,8.0],[0.0131988,-0.642342,0.765851,-0.0263522],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget p20:=[[80.0,16.0,6.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p30:=[[80.0,116.0,6.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p40:=[[130,166.0,6.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p50:=[[180,116.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p60:=[[150,116.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p70:=[[140,126.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p80:=[[130,116.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    CONST robtarget p90:=[[140,116.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p100:=[[240,116.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p110:=[[240,16.0,8.0],[0.0131387,-0.642314,0.765874,-0.0264109],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    CONST robtarget p120:=[[190.0, 66.0,8.0],[0.0131988,-0.642342,0.765851,-0.0263522],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p130:=[[240.0, 16.0,8.0],[0.0131988,-0.642342,0.765851,-0.0263522],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget p140:=[[190.0, -46.0,8.0],[0.0131988,-0.642342,0.765851,-0.0263522],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS intnum nums:=14;
    
    VAR robtarget temp := p10;
    VAR btnres Answer10;
    CONST string my_message{3} := ["rCircle", "rRectangle", "rJDRAW"];
    CONST string my_button{3} := ["CIRCLE", "RECTANGLE", "J_LETTER"];
    
    PERS intnum offsetX := 100;
    PERS intnum offsetY := 100;
    
	PROC rCircle() 
		MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
		MoveJ p0, v1000, z50, toolPen\WObj:=wobjBox;
		MoveL p10, v1000, z5, toolPen\WObj:=wobjBox;

        MoveC p120,p130,v1000,z5,toolPen\WObj:=wobjBox;
        MoveC p140,p10,v1000,z5,toolPen\WObj:=wobjBox;
        
		MoveJ p0, v1000, z50, toolPen\WObj:=wobjBox;
		MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
	ENDPROC
    
	PROC rRectangle() 
        rIntDimRec;      
		MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
		MoveJ p0, v1000, z50, toolPen\WObj:=wobjBox;
		MoveL p10, v1000, z5, toolPen\WObj:=wobjBox;
        
        temp:=p10;
        temp.trans.y := temp.trans.y + offsetY;   
		MoveL temp, v1000, z5, toolPen\WObj:=wobjBox;
        
        temp.trans.x := temp.trans.x + offsetX;    
		MoveL temp, v1000, z5, toolPen\WObj:=wobjBox;
        
        temp.trans.y := temp.trans.y - offsetY;
		MoveL temp, v1000, z5, toolPen\WObj:=wobjBox;
        
		MoveL p10, v1000, z5, toolPen\WObj:=wobjBox;
		MoveJ p0, v1000, z50, toolPen\WObj:=wobjBox;
		MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
	ENDPROC
	PROC main()
        execute;
	ENDPROC
    
    PROC rReRectangle()
		MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
		MoveJ p0, v1000, z50, toolPen\WObj:=wobjBox;
        MoveL RelTool(p10, 0,0, 0 \Rx:=25), v1000, z50, toolPen\WObj:=wobjBox;
        
        MoveL RelTool(p10, -50,50,0 \Rx:=25), v1000, z5, toolPen\WObj:=wobjBox;
        MoveL RelTool(p10, 0, 100, 0 \Rx:=25), v1000, z5, toolPen\WObj:=wobjBox;
        MoveL RelTool(p10, 50, 50, 0 \Rx:=25), v1000, z5, toolPen\WObj:=wobjBox;
        MoveL RelTool(p10, 0, 0, 0), v1000, z5, toolPen\WObj:=wobjBox;
        
		MoveJ RelTool(p0, 0, 0, 0), v1000, z5, toolPen\WObj:=wobjBox;
		MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
    ENDPROC
    
    PROC rIntDimRec()
        offsetX := UInumEntry(
        \Header:="Square dimension"
        \Message:="Give in X length"
        \Icon:=iconQuestion
        \InitValue:=100
        \MinValue:=20
        \MaxValue:=300
        \AsInteger
        );
        waitTime 0.1;
        
        offsetY := UInumEntry(
        \Header:="Square dimension"
        \Message:="Give in Y length"
        \Icon:=iconQuestion
        \InitValue:=100
        \MinValue:=20
        \MaxValue:=300
        \AsInteger
        );
        waitTime 0.1;        
    ENDPROC
    
    PROC rCreateUIBox()
        Answer10 := UIMessageBox(
        \Header:="Choose the routine"
        \MsgArray:=my_message
        \BtnArray:=my_button
        \Icon:=iconInfo
        );
    ENDPROC

    PROC execute()
        rCreateUIBox;
        TEST Answer10
        CASE 1:
            rCircle;
        CASE 2:
            IF QSig = 1 THEN
                rReRectangle;                
            ELSE
                rRectangle;
            ENDIF
        CASE 3:
            rJDRAW;
        ENDTEST
    ENDPROC
    
	PROC rJDRAW()
        MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox;
        MoveJ p0,v1000,z50,toolPen\WObj:=wobjBox;
        MoveL p10,v1000,z50,toolPen\WObj:=wobjBox;
        MoveL p20,v1000,z50,toolPen\WObj:=wobjBox;
        MoveL p30,v1000,z50,toolPen\WObj:=wobjBox;
        MoveC p40, p50,v1000,z50,toolPen\WObj:=wobjBox;
        MoveL p60,v1000,z50,toolPen\WObj:=wobjBox;
        MoveC p70, p80,v1000,z50,toolPen\WObj:=wobjBox;
        MoveL p10,v1000,z50,toolPen\WObj:=wobjBox;
        MoveJ p0,v1000,z50,toolPen\WObj:=wobjBox;
        MoveJ pHome, v1000, z50, toolPen\WObj:=wobjBox; 
	ENDPROC
	PROC packing()
		CONST jointtarget jpos10:=[[0,0,0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
		MoveAbsJ jpos10\NoEOffs, v1000, z50, toolPen\WObj:=wobjBox;
	ENDPROC

ENDMODULE