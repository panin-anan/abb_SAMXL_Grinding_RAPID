MODULE TRobRAPID
!=======================================================================================================================
! Copyright (c) 2017, ABB Schweiz AG
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
    ! Module: TRobRAPID [Autoloaded by the StateMachine AddIn]
    !
    ! Description:
    !   Provides interaction with predefined RAPID routines, as well as additional system specific routines
    !   added by a user.
    !
    ! Author: Jon Tjerngren (jon.tjerngren@se.abb.com)
    !
    ! Version: 1.1
    !
    !-------------------------------------------------------------------------------------------------------------------

    !---------------------------------------------------------
    ! Data that an external system can set,
    ! for example via Robot Web Services (RWS)
    !---------------------------------------------------------
    ! Input for specifying a RAPID routine to run.
    LOCAL VAR string routine_name_input := stEmpty;

    ! Inputs to the following predefined routines:
    ! - runMoveJ
    ! - runMoveAbsJ
    LOCAL VAR speeddata   move_speed_input := [100, 10, 100, 10];
    LOCAL VAR robtarget   move_robtarget_input;
    LOCAL VAR jointtarget move_jointtarget_input;

    ! Inputs to the following predefined routine:
    ! - runCallByVar
    LOCAL VAR string callbyvar_name_input := stEmpty;
    LOCAL VAR num callbyvar_num_input := 0;

    ! Input to the following predefined routines:
    ! - runModuleLoad
    ! - runModuleUnload
    LOCAL VAR string module_file_path_input := stEmpty;

    !---------------------------------------------------------
    ! Program data
    !---------------------------------------------------------
    ! Interrupt numbers.
    LOCAL VAR intnum intnum_run_rapid_routine;
TASK PERS wobjdata wobj_demo:=[FALSE,TRUE,"",[[-184.894,-859.154,321.543],[0.999989,-0.00397391,-0.000927967,0.00242583]],[[0,0,0],[1,0,0,0]]];


    !---------------------------------------------------------
    ! Primary procedures
    !---------------------------------------------------------
    PROC initializeRAPIDModule()
        move_robtarget_input := CRobT();
        move_jointtarget_input := CJointT();

        ! Setup an interrupt signal.
        IDelete intnum_run_rapid_routine;
        CONNECT intnum_run_rapid_routine WITH handleRunRAPIDRoutine;
        ISignalDI RUN_RAPID_ROUTINE, HIGH, intnum_run_rapid_routine;
    ENDPROC

    PROC runRAPIDRoutine()
        attemptRoutine;
        current_state := STATE_IDLE;
    ENDPROC

    !---------------------------------------------------------
    ! Traps
    !---------------------------------------------------------
    LOCAL TRAP handleRunRAPIDRoutine
        IF routine_name_input <> stEmpty THEN
            printRAPIDMessage "Attempting '" + routine_name_input + "'";
            attemptNonBlockingRoutine;

            IF routine_name_input <> stEmpty THEN
                IF current_state = STATE_IDLE THEN
                    current_state := STATE_RUN_RAPID_ROUTINE;
                    RAISE CHANGE_STATE;
                ENDIF
            ENDIF
        ENDIF

        ERROR (CHANGE_STATE)
            RAISE CHANGE_STATE;
    ENDTRAP

    !---------------------------------------------------------
    ! Auxiliary procedures
    !---------------------------------------------------------
    LOCAL PROC attemptRoutine()
        VAR bool found;
        found := attemptSystemRoutine(routine_name_input);

        IF NOT found THEN
            TEST routine_name_input
                CASE "runMoveToCalibrationPosition":
                    runMoveToCalibrationPosition;

                CASE "runMoveJ":
                    runMoveJ;

                CASE "runMoveAbsJ":
                    runMoveAbsJ;

                CASE "runCallByVar":
                    runCallByVar;
            ENDTEST
        ENDIF

        routine_name_input := stEmpty;
    ENDPROC

    PROC runMoveToCalibrationPosition()
        current_tool := CTool();
        MoveAbsJ getCalibrationTarget(), v100, fine, current_tool \WObj:=base_wobj;

        ERROR
            printRAPIDMessage "'runMoveToCalibrationPosition' failed!";
    ENDPROC

    LOCAL PROC runMoveJ()
        current_tool := CTool();
        MoveJ move_robtarget_input, move_speed_input, fine, current_tool \WObj:=base_wobj;

        ERROR
            printRAPIDMessage "'runMoveJ' failed!";
    ENDPROC

    LOCAL PROC runMoveAbsJ()
        current_tool := CTool();
        MoveAbsJ move_jointtarget_input, move_speed_input, fine, current_tool \WObj:=base_wobj;

        ERROR
            printRAPIDMessage "'runMoveAbsJ' failed!";
    ENDPROC

    LOCAL PROC runCallByVar()
        CallByVar callbyvar_name_input, callbyvar_num_input;

        ERROR
            printRAPIDMessage "'runCallByVar' failed!";
            TRYNEXT;
    ENDPROC

    !---------------------------------------------------------
    ! Auxiliary procedures (non-blocking)
    !---------------------------------------------------------
    LOCAL PROC attemptNonBlockingRoutine()
        VAR bool found;
        found := attemptNonBlockingSystemRoutine(routine_name_input);

        IF NOT found THEN
            TEST routine_name_input
                CASE "runModuleLoad":
                    runModuleLoad;

                CASE "runModuleUnload":
                    runModuleUnload;

                DEFAULT:
                    found := FALSE;
            ENDTEST
        ENDIF

        IF found THEN
            routine_name_input := stEmpty;
        ENDIF
    ENDPROC

    LOCAL PROC runModuleLoad()
        Load module_file_path_input;

        ERROR
            IF ERRNO <> ERR_LOADED THEN
                printRAPIDMessage "'runModuleLoad' failed!";
            ENDIF
            TRYNEXT;
    ENDPROC

    LOCAL PROC runModuleUnload()
        UnLoad module_file_path_input;

        ERROR
            printRAPIDMessage "'runModuleUnload' failed!";
            TRYNEXT;
    ENDPROC
ENDMODULE
