MODULE Module4
    !***********************************************************
    !
    ! Module:  Module4
    !
    ! Description:
    !
    ! Author: Eugenio
    !
    ! Version: 1.0
    !
    !***********************************************************
    
    CONST jointtarget home:=[[88.9282,2.63306,0.804827,0.0621004,87.0007,0.870506],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_10:=[[23.65,471.07,226.16],[0.00347444,0.694586,-0.719391,0.00380316],[0,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_20:=[[23.69,499.53,226.13],[0.00349434,0.69457,-0.719406,0.00382612],[0,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_30:=[[47.88,624.02,189.02],[0.185262,0.671069,-0.695123,0.179298],[0,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_40:=[[47.98,670.85,165.23],[0.185328,0.671069,-0.695094,0.179342],[0,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_50:=[[-102.67,641.11,157.57],[0.154626,0.887015,-0.31998,0.294802],[1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_60:=[[-113.15,668.45,118.14],[0.15465,0.887031,-0.319919,0.294807],[1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_70:=[[-198.77,438.65,104.97],[0.00651115,0.938547,0.0905082,0.333009],[1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_80:=[[-184.11,446.79,140.12],[0.00653603,0.938548,0.0905633,0.332991],[1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_90:=[[258.61,313.02,66.73],[0.332548,-0.891666,-0.0792558,0.296752],[0,0,-3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_100:=[[212.46,290.08,98.15],[0.332494,-0.891737,-0.0792846,0.296593],[0,1,-3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_110:=[[220.29,664.45,125.29],[0.307069,0.909633,-0.113254,-0.255833],[0,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_120:=[[171.84,667.03,125.05],[0.307142,0.909612,-0.113298,-0.2558],[0,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

    PROC main()
        MoveAbsJ home, v1000, z100, tool0;
        Path_10;
        Path_20;
        Path_30;
        Path_40;
        Path_50;
        Path_60;
    ENDPROC
    PROC Msh_prompt()
       TPReadFK reg1, "Go on?", stEmpty, stEmpty, stEmpty, stEmpty,"Yes";
    ENDPROC
    PROC Path_10()
        MoveJ Target_10,v1000,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_20,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
    PROC Path_20()
        MoveJ Target_30,v1000,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_40,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
    PROC Path_30()
        MoveJ Target_50,v100,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_60,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
    PROC Path_40()
        MoveJ Target_70,v1000,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_80,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
    PROC Path_50()
        MoveJ Target_90,v1000,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_100,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
    PROC Path_60()
        MoveJ Target_110,v1000,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_120,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
    PROC Path_100()
        MoveJ Target_110,v1000,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveL Target_120,v500,z0,tool0\WObj:=wobj0;
        Msh_prompt;
        MoveAbsJ home, v1000, z100, tool0;
    ENDPROC
ENDMODULE