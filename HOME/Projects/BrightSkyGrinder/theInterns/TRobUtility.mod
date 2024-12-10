MODULE TRobUtility
!=======================================================================================================================
! Copyright (c) 2016, ABB Schweiz AG
! All rights reserved.
!
! Redistribution and use in source and binary forms, with
! or without modification, are permitted provided that
! the following conditions are met:
!
!    * Redistributions of source code must retain the
!      above copyright notice, this list of conditions
!      and the following disclaimer.
!    * Redistributions in binary form must reproduce the
!      above copyright notice, this list of conditions
!      and the following disclaimer in the documentation
!      and/or other materials provided with the
!      distribution.
!    * Neither the name of ABB nor the names of its
!      contributors may be used to endorse or promote
!      products derived from this software without
!      specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
! ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
! LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
! SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
! CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
! THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!=======================================================================================================================

    !-------------------------------------------------------------------------------------------------------------------
    !
    ! Module: TRobUtility [Autoloaded by the StateMachine AddIn]
    !
    ! Description:
    !   Provides utility functionalities.
    !
    ! Author: Jon Tjerngren (jon.tjerngren@se.abb.com)
    !
    ! Version: 1.1
    !
    !-------------------------------------------------------------------------------------------------------------------

    !---------------------------------------------------------
    ! Records
    !---------------------------------------------------------
    RECORD GeneralInfo
        bool mech_unit_data_found;
        string mech_unit_name;
        bool is_active;
        bool is_tcp_robot;
        bool is_irb14000;
        num number_of_axes;
        bool using_modal_payload;
        pose base_frame;
    ENDRECORD
    
    RECORD CalibrationValues
        bool has_joint_1;
        num joint_1;
        bool has_joint_2;
        num joint_2;
        bool has_joint_3;
        num joint_3;
        bool has_joint_4;
        num joint_4;
        bool has_joint_5;
        num joint_5;
        bool has_joint_6;
        num joint_6;
        bool has_joint_7;
        num joint_7;
    ENDRECORD
    
    !---------------------------------------------------------
    ! Program data
    !---------------------------------------------------------
    ! For information messages.
    LOCAL CONST string INDENTION        := "  ";
    LOCAL CONST string CONTEXT_MAIN     := "[Main]: ";
    LOCAL CONST string CONTEXT_UTILITY  := "[Utility]: ";
    LOCAL CONST string CONTEXT_WATCHDOG := "[Watchdog]: ";
    LOCAL CONST string CONTEXT_RAPID    := "[RAPID]: ";
    LOCAL CONST string CONTEXT_SYSTEM   := "[System]: ";
    LOCAL CONST string CONTEXT_EGM      := "[EGM]: ";
    LOCAL CONST string CONTEXT_SG       := "[SmartGripper]: ";

    ! Useful constants.
    CONST num MAX_NUMBER_OF_MOTION_TASKS := 4;
    CONST num M_TO_MM    := 1000;
    CONST num MM_TO_M    := 0.001;
    CONST num RAD_TO_DEG := 180/PI;
    CONST num DEG_TO_RAD := PI/180;
    
    ! Useful persistents.
    TASK PERS wobjdata base_wobj := [FALSE, TRUE, "", [[0, 0, 0],[1, 0, 0, 0]], [[0, 0, 0],[1, 0, 0, 0]]];
    TASK PERS tooldata current_tool := [ TRUE, [ [0, 0, 0], [1, 0, 0 ,0] ], [0.001, [0, 0, 0.001], [1, 0, 0, 0], 0, 0, 0] ];
        
    ! Useful variables.
    VAR GeneralInfo general_info;
    VAR CalibrationValues calibration_values;

    !---------------------------------------------------------
    ! Primary procedures
    !---------------------------------------------------------
    PROC initializeUtilityModule()
        extractMechUnitData;
        extractCalibrationValues;
        extractBaseFrame;
        general_info.using_modal_payload := (GetModalPayloadMode() = 1);
    ENDPROC

    !---------------------------------------------------------
    ! Auxiliary procedures
    !---------------------------------------------------------
    PROC printMainMessage(string message)
        printInfoMessage 0, CONTEXT_MAIN, message;
    ENDPROC

    PROC printUtilityMessage(string message)
        printInfoMessage 0, CONTEXT_UTILITY, message;
    ENDPROC

    PROC printWatchdogMessage(string message)
        printInfoMessage 0, CONTEXT_WATCHDOG, message;
    ENDPROC

    PROC printRAPIDMessage(string message)
        printInfoMessage 0, CONTEXT_RAPID, message;
    ENDPROC

    PROC printSystemMessage(string message)
        printInfoMessage 0, CONTEXT_SYSTEM, message;
    ENDPROC

    PROC printEGMMessage(string message)
        printInfoMessage 0, CONTEXT_EGM, message;
    ENDPROC

    PROC printSGMessage(string message)
        printInfoMessage 0, CONTEXT_SG, message;
    ENDPROC

    LOCAL PROC printInfoMessage(num indention_level, string context, string message)
        VAR string temp_indention := "";

        IF(indention_level > 0) THEN
            FOR i FROM 0 TO indention_level - 1 DO
                temp_indention := temp_indention + INDENTION;
            ENDFOR
        ENDIF

        TPWrite temp_indention + context + message;
    ENDPROC

    PROC saturateValue(VAR num value, num minimum, num maximum)
        IF value < minimum THEN
            value := minimum;
        ELSEIF value > maximum THEN
            value := maximum;
        ENDIF
    ENDPROC

    LOCAL PROC extractMechUnitData()
        VAR num list_number := 0;
        VAR string temp_name := "";
        
        general_info.mech_unit_data_found := FALSE;
        general_info.mech_unit_name := GetMecUnitName(ROB_ID);
        general_info.is_irb14000 := (general_info.mech_unit_name = "ROB_L" OR general_info.mech_unit_name = "ROB_R");
        
        WHILE (NOT general_info.mech_unit_data_found) AND
              GetNextMechUnit(list_number, temp_name
                              \TCPRob:=general_info.is_tcp_robot
                              \NoOfAxes:=general_info.number_of_axes
                              \Active:=general_info.is_active)
        DO      
            general_info.mech_unit_data_found := (temp_name = general_info.mech_unit_name);
        ENDWHILE
    ENDPROC
    
    LOCAL PROC extractCalibrationValues()
        VAR num list_number := 0;
        VAR string joint_1;
        VAR string joint_2;
        VAR string joint_3;
        VAR string joint_4;
        VAR string joint_5;
        VAR string joint_6;
        VAR string joint_7;
        VAR string cfg_path;
        
        ! Extract the joint names from the configurations.
        cfg_path := "/MOC/ROBOT/" + general_info.mech_unit_name;
        ReadCfgData cfg_path, "use_joint_0", joint_1;
        ReadCfgData cfg_path, "use_joint_1", joint_2;
        ReadCfgData cfg_path, "use_joint_2", joint_3;
        ReadCfgData cfg_path, "use_joint_3", joint_4;
        ReadCfgData cfg_path, "use_joint_4", joint_5;
        ReadCfgData cfg_path, "use_joint_5", joint_6;
        
        IF general_info.is_irb14000 THEN
            cfg_path := "/MOC/SINGLE/" + general_info.mech_unit_name + "_7";
            ReadCfgData cfg_path, "use_joint", joint_7;
        ENDIF
        
        ! Extract the calibration values from the configurations.
        cfg_path := "/MOC/ARM/";
        IF joint_1 <> "" THEN
            calibration_values.has_joint_1 := TRUE;
            ReadCfgData cfg_path + joint_1, "cal_position", calibration_values.joint_1;
        ENDIF
        IF joint_2 <> "" THEN
            calibration_values.has_joint_2 := TRUE;
            ReadCfgData cfg_path + joint_2, "cal_position", calibration_values.joint_2;
        ENDIF
        IF joint_3 <> "" THEN
            calibration_values.has_joint_3 := TRUE;
            ReadCfgData cfg_path + joint_3, "cal_position", calibration_values.joint_3;
        ENDIF
        IF joint_4 <> "" THEN
            calibration_values.has_joint_4 := TRUE;
            ReadCfgData cfg_path + joint_4, "cal_position", calibration_values.joint_4;
        ENDIF
        IF joint_5 <> "" THEN
            calibration_values.has_joint_5 := TRUE;
            ReadCfgData cfg_path + joint_5, "cal_position", calibration_values.joint_5;
        ENDIF
        IF joint_6 <> "" THEN
            calibration_values.has_joint_6 := TRUE;
            ReadCfgData cfg_path + joint_6, "cal_position", calibration_values.joint_6;
        ENDIF
        IF joint_7 <> "" THEN
            calibration_values.has_joint_7 := TRUE;
            ReadCfgData cfg_path + joint_7, "cal_position", calibration_values.joint_7;
        ENDIF
        
        ERROR
            TRYNEXT;
    ENDPROC

    LOCAL PROC extractBaseFrame()
        VAR string cfg_path;
        cfg_path := "/MOC/ROBOT/" + general_info.mech_unit_name;

        ! Extract the base frame from the configurations.
        ReadCfgData cfg_path, "base_frame_pos_x", general_info.base_frame.trans.x;
        ReadCfgData cfg_path, "base_frame_pos_y", general_info.base_frame.trans.y;
        ReadCfgData cfg_path, "base_frame_pos_z", general_info.base_frame.trans.z;
        ReadCfgData cfg_path, "base_frame_orient_u0", general_info.base_frame.rot.q1;
        ReadCfgData cfg_path, "base_frame_orient_u1", general_info.base_frame.rot.q2;
        ReadCfgData cfg_path, "base_frame_orient_u2", general_info.base_frame.rot.q3;
        ReadCfgData cfg_path, "base_frame_orient_u3", general_info.base_frame.rot.q4;
        
        general_info.base_frame.trans.x := general_info.base_frame.trans.x*M_TO_MM;
        general_info.base_frame.trans.y := general_info.base_frame.trans.y*M_TO_MM;
        general_info.base_frame.trans.z := general_info.base_frame.trans.z*M_TO_MM;
        
        base_wobj.uframe := general_info.base_frame;
        
        ERROR
            TRYNEXT;
    ENDPROC
    
    !---------------------------------------------------------
    ! Auxiliary functions
    !---------------------------------------------------------
    FUNC jointtarget getCalibrationTarget()
        VAR jointtarget joint_target;
        joint_target := CJointT();
        
        IF calibration_values.has_joint_1 THEN
            joint_target.robax.rax_1 := calibration_values.joint_1*RAD_TO_DEG;
        ENDIF
        IF calibration_values.has_joint_2 THEN
            joint_target.robax.rax_2 := calibration_values.joint_2*RAD_TO_DEG;
        ENDIF
        IF calibration_values.has_joint_3 THEN
            joint_target.robax.rax_3 := calibration_values.joint_3*RAD_TO_DEG;
        ENDIF
        IF calibration_values.has_joint_4 THEN
            joint_target.robax.rax_4 := calibration_values.joint_4*RAD_TO_DEG;
        ENDIF
        IF calibration_values.has_joint_5 THEN
            joint_target.robax.rax_5 := calibration_values.joint_5*RAD_TO_DEG;
        ENDIF
        IF calibration_values.has_joint_6 THEN
            joint_target.robax.rax_6 := calibration_values.joint_6*RAD_TO_DEG;
        ENDIF
        IF calibration_values.has_joint_7 THEN
            joint_target.extax.eax_a := calibration_values.joint_7*RAD_TO_DEG;  
        ENDIF
        
        RETURN joint_target;
    ENDFUNC
    
    FUNC tooldata createToolData(bool robhold, pose tframe, loaddata tload)
        VAR tooldata temp_tool;
        
        temp_tool.robhold := robhold;
        temp_tool.tframe := tframe;
        temp_tool.tload := tload;
        
        return temp_tool;
    ENDFUNC
ENDMODULE