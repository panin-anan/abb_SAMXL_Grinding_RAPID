MODULE TRobMain
!=======================================================================================================================
! Copyright (c) 2015, ABB Schweiz AG
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
    ! Module: TRobMain [Autoloaded by the StateMachine AddIn]
    !
    ! Description:
    !   The main module, which initializes submodules and manages the state machine.
    !
    ! Author: Jon Tjerngren (jon.tjerngren@se.abb.com)
    !
    ! Version: 1.1
    !
    !-------------------------------------------------------------------------------------------------------------------

    !---------------------------------------------------------
    ! Program data
    !---------------------------------------------------------
    ! The state machine's version.
    CONST num VERSION := 1.1;
    
    ! The state machine's states.
    CONST num STATE_IDLE              := 0;
    CONST num STATE_INITIALIZE        := 1;
    CONST num STATE_RUN_RAPID_ROUTINE := 2;
    CONST num STATE_RUN_EGM_ROUTINE   := 3;
    VAR num current_state := STATE_INITIALIZE;

    ! Error numbers.
    VAR errnum CHANGE_STATE := -1;
    
    ! Idle counter.
    VAR num idle_counter := 0;

    !---------------------------------------------------------
    ! Primary procedures
    !---------------------------------------------------------
    PROC main10()
        TPErase;
    
        ! Initialize the submodules.
        initializeSubmodules;

        ! Run the state machine.
        printMainMessage "Starting StateMachine loop";
        WHILE TRUE DO
            TEST current_state
                CASE STATE_RUN_RAPID_ROUTINE:
                    runRAPIDRoutine;

                CASE STATE_RUN_EGM_ROUTINE:
                    runEGMRoutine;

                DEFAULT:
                    runIdle;
            ENDTEST

            WaitTime 0.01;
        ENDWHILE

        ERROR(CHANGE_STATE)
            idle_counter := 0;
            TRYNEXT;
    ENDPROC

    !---------------------------------------------------------
    ! Auxliliary procedures
    !---------------------------------------------------------
    LOCAL PROC initializeSubmodules()
        ! Disable interrupts.
        IDisable;

        ! Book an error number.
        BookErrNo CHANGE_STATE;

        ! Initialize the submodules.
        initializeUtilityModule;
        initializeRAPIDModule;
        initializeEGMModule;
        initializeSystemModule;

        ! Set state to idle after finishing the initialization.
        current_state := STATE_IDLE;

        ! Enable interrupts.
        IEnable;
    ENDPROC
    
    LOCAL PROC runIdle()
        IF idle_counter MOD 1000 = 0 THEN
            printMainMessage "Idling...";
            idle_counter := 0;
        ENDIF
        Incr idle_counter;
    
        ERROR
            RAISE;
    ENDPROC
ENDMODULE
