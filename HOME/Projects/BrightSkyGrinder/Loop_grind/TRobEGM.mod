MODULE TRobEGM
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
    ! Module: TRobEGM [Autoloaded by the StateMachine AddIn]
    !
    ! Description:
    !   Provides support of using the following Externally Guided Motion (EGM) features:
    !   - EGM UDP unicast variant (i.e. type of communication), with the following modes:
    !     - EGM joint mode (for controlling motion).
    !     - EGM pose mode (for controlling motion).
    !     - EGM stream mode (for streaming position data).
    !
    ! Author: Jon Tjerngren (jon.tjerngren@se.abb.com)
    !
    ! Version: 1.1
    !
    !-------------------------------------------------------------------------------------------------------------------

    !---------------------------------------------------------
    ! Records
    !---------------------------------------------------------
    LOCAL RECORD EGMSetupUCSettings
        bool use_filtering; ! Flag indicating if the EGM controller should apply extra filtering on the EGM corrections.
                            !   If true: Applies extra filtering on the corrections, but also introduces some extra
                            !            delays and latency.
                            !   Else: Raw corrections will be used.
        num comm_timeout;   ! Communication timeout [s].
    ENDRECORD

    LOCAL RECORD EGMActivateSettings
        tooldata tool;           ! The tool to use.
        wobjdata wobj;           ! The work object to use.
        pose correction_frame;   ! Specifies the correction frame.
                                 !   Note: Only used in EGM pose mode.
        pose sensor_frame;       ! Specifies the sensor frame.
                                 !   Note: Only used in EGM pose mode.
        num cond_min_max;        ! Condition value [deg or mm] for when the EGM correction is considered to be finished.
                                 !   E.g.: For joint mode, then the condition is fulfilled when the joints are
                                 !         within [-cond_min_max, cond_min_max].
        num lp_filter;           ! Low pass filer bandwidth of the EGM controller [Hz].
        num sample_rate;         ! Sample rate for the EGM communication [ms].
                                 !   Note: Only multiples of 4 are allowed (i.e. 4, 8, 16, etc...).
        num max_speed_deviation; ! Maximum admitted joint speed change [deg/s]:
                                 !   Note: Take care if setting this higher than the lowest max speed [deg/s],
                                 !         out of all the axis max speeds (found in the robot's data sheet).
    ENDRECORD

    LOCAL RECORD EGMRunSettings
        num cond_time;     ! Condition time [s].
        num ramp_in_time;  ! Ramp in time [s].
        pose offset;       ! A static offset applied on top of the references supplied by the external system.
                           !   Note: Only used in EGM pose mode.
        num pos_corr_gain; ! Position correction gain of the EGM controller.
    ENDRECORD

    LOCAL RECORD EGMStopSettings
        num ramp_out_time; ! Desired duration for ramping out EGM motions [s].
    ENDRECORD

    LOCAL RECORD EGMSettings
        bool allow_egm_motions;       ! Flag indicating if EGM motions are allowed to start.
        bool use_presync;             ! Flag indicating if the motion tasks should be synchronized before starting EGM.
                                      !   Note: Only used in multi robot systems.
        EGMSetupUCSettings setup_uc;  ! Settings for EGMSetupUC instructions.
        EGMActivateSettings activate; ! Settings for EGMAct instructions.
        EGMRunSettings run;           ! Settings for EGMRun instructions.
        EGMStopSettings stop;         ! Settings for EGMStop instructions.
    ENDRECORD

    !---------------------------------------------------------
    ! Data that an external system can set,
    ! for example via Robot Web Services (RWS)
    !---------------------------------------------------------
    ! Settings to the arguments used in the EGM instructions.
    LOCAL VAR EGMSettings settings;

    !---------------------------------------------------------
    ! Program data
    !---------------------------------------------------------
    ! EGM actions supported by this module.
    LOCAL CONST num ACTION_NONE         := 0;
    LOCAL CONST num ACTION_RUN_JOINT    := 1;
    LOCAL CONST num ACTION_RUN_POSE     := 2;
    LOCAL CONST num ACTION_STOP         := 3;
    LOCAL CONST num ACTION_START_STREAM := 4;
    LOCAL CONST num ACTION_STOP_STREAM  := 5;
    LOCAL VAR num current_action := ACTION_NONE;

    ! Default values for the EGM instructions.
    LOCAL CONST bool DEFAULT_ALLOW_EGM_MOTIONS   := TRUE;
    LOCAL CONST bool DEFAULT_USE_PRESYNC         := FALSE;
    LOCAL CONST bool DEFAULT_USE_FILTERING       := TRUE;
    LOCAL CONST num  DEFAULT_COMM_TIMEOUT        := 1;
    LOCAL CONST pose DEFAULT_CORRECTION_FRAME    := [[0, 0, 0], [1, 0, 0, 0]];
    LOCAL CONST pose DEFAULT_SENSOR_FRAME        := [[0, 0, 0], [1, 0, 0, 0]];
    LOCAL CONST num  DEFAULT_COND_MIN_MAX        := 0.5;
    LOCAL CONST num  DEFAULT_LP_FILTER           := 20;
    LOCAL CONST num  DEFAULT_SAMPLE_RATE         := 4;
    LOCAL CONST num  DEFAULT_MAX_SPEED_DEVIATION := 1;
    LOCAL CONST num  DEFAULT_CONDITION_TIME      := 60;
    LOCAL CONST num  DEFAULT_RAMP_IN_TIME        := 1;
    LOCAL CONST pose DEFAULT_OFFSET              := [[0, 0, 0], [1, 0, 0, 0]];
    LOCAL CONST num  DEFAULT_POSITION_CORR_GAIN  := 1;
    LOCAL CONST num  DEFAULT_RAMP_OUT_TIME       := 1;

    ! Identifier for the EGM process.
    LOCAL VAR egmident egm_id;

    ! ExtConfigName and UCdevice arguments for EGMSetupUC instruction.
    !
    ! They are defined at:
    ! ExtConfigName: Controller tab -> Configuration Editor -> Motion -> External Motion Interface Data
    ! UCdevice:      Controller tab -> Configuration Editor -> Communication -> Transmission Protocol
    !
    ! Important: Set correct values for the UCdevice's remote address and port.
    LOCAL VAR string ext_config_name;
    LOCAL VAR string uc_device;

    ! The currently used tool, work object and load for the EGM instructions.
    LOCAL PERS wobjdata egm_wobj := [ FALSE, TRUE, "", [ [0, 0, 0], [1, 0, 0 ,0] ], [ [0, 0, 0], [1, 0, 0 ,0] ] ];
    LOCAL PERS tooldata egm_tool := [ TRUE, [ [0, 0, 0], [1, 0, 0 ,0] ], [0.001, [0, 0, 0.001], [1, 0, 0, 0], 0, 0, 0] ];
    LOCAL PERS loaddata egm_load := [0.001, [0, 0, 0.001],[1, 0, 0, 0], 0, 0, 0];

    ! Convergence condition for rotations [deg] and for positions [mm].
    LOCAL VAR egm_minmax minmax_condition;

    ! Interrupt numbers.
    LOCAL VAR intnum intnum_egm_start_joint;
    LOCAL VAR intnum intnum_egm_start_pose;
    LOCAL VAR intnum intnum_egm_start_stream;
    LOCAL VAR intnum intnum_egm_stop;
    LOCAL VAR intnum intnum_egm_stop_stream;

    !---------------------------------------------------------
    ! Primary procedures
    !---------------------------------------------------------
    PROC initializeEGMModule()
        current_action := ACTION_NONE;
        EGMReset egm_id;
        EGMGetId egm_id;
        
        ! Initialize default settings for the EGM instructions.
        initializeEGMSettings;

        ! Setup interrupt signals.
        IDelete intnum_egm_start_joint;
        CONNECT intnum_egm_start_joint WITH handleEGMStartJoint;
        ISignalDI EGM_START_JOINT, HIGH, intnum_egm_start_joint;

        IDelete intnum_egm_start_pose;
        CONNECT intnum_egm_start_pose WITH handleEGMStartPose;
        ISignalDI EGM_START_POSE, HIGH, intnum_egm_start_pose;
        
        IDelete intnum_egm_start_stream;
        CONNECT intnum_egm_start_stream WITH handleEGMStartStream;
        ISignalDI EGM_START_STREAM, HIGH, intnum_egm_start_stream;
        
        IDelete intnum_egm_stop;
        CONNECT intnum_egm_stop WITH handleEGMStop;
        ISignalDI EGM_STOP, HIGH, intnum_egm_stop;
        
        IDelete intnum_egm_stop_stream;
        CONNECT intnum_egm_stop_stream WITH handleEGMStopStream;
        ISignalDI EGM_STOP_STREAM, HIGH, intnum_egm_stop_stream;
    ENDPROC

    PROC runEGMRoutine()
        ! Parse any new settings (e.g. updated via RWS).
        parseEGMSettings;
        
        ! Prepare EGM based on the current EGM action.
        IF current_action = ACTION_RUN_JOINT OR current_action = ACTION_RUN_POSE THEN
            printEGMMessage "Waiting for fine point...";
            WaitRob \InPos;
            prepareEGMRun;
        ELSEIF current_action = ACTION_START_STREAM THEN
            printEGMMessage "Waiting for fine point...";
            WaitRob \InPos;
            prepareEGMStream;
        ENDIF

        ! Perform the chosen EGM action.
        TEST current_action
            CASE ACTION_RUN_JOINT:
                printEGMMessage "Starting joint motion";
                IF isEGMStateConnected() THEN
                    EGMRunJoint egm_id,
                                EGM_STOP_HOLD
                                \J1 \J2 \J3 \J4 \J5 \J6
                                \CondTime:=settings.run.cond_time
                                \RampInTime:=settings.run.ramp_in_time
                                \PosCorrGain:=settings.run.pos_corr_gain;
                ENDIF
                current_action := ACTION_NONE;

            CASE ACTION_RUN_POSE:
                printEGMMessage "Starting pose motion";
                IF isEGMStateConnected() THEN
                    EGMRunPose egm_id,
                               EGM_STOP_HOLD,
                               \X \Y \Z \RX \RY \RZ
                               \CondTime:=settings.run.cond_time
                               \RampInTime:=settings.run.ramp_in_time
                               \Offset:=settings.run.offset
                               \PosCorrGain:=settings.run.pos_corr_gain;
                ENDIF
                current_action := ACTION_NONE;
                           
            CASE ACTION_STOP:
                printEGMMessage "Stopping motion...";
                IF isEGMStateRunning() THEN
                    EGMStop egm_id, EGM_STOP_HOLD \RampOutTime:=settings.stop.ramp_out_time;
                ENDIF
                current_action := ACTION_NONE;
                
            CASE ACTION_START_STREAM:
                printEGMMessage "Starting stream";
                IF isEGMStateConnected() THEN
                    EGMStreamStart egm_id \SampleRate:=settings.activate.sample_rate;
                    current_action := ACTION_START_STREAM;
                ELSE
                    current_action := ACTION_NONE;
                ENDIF
                
            CASE ACTION_STOP_STREAM:
                printEGMMessage "Stopping stream...";
                IF isEGMStateRunning() THEN
                    EGMStreamStop egm_id;
                ENDIF
                current_action := ACTION_NONE;
        ENDTEST

        current_state := STATE_IDLE;

    ERROR
        IF ERRNO = ERR_UDPUC_COMM THEN
            printEGMMessage "Communication timed out";
            current_action := ACTION_NONE;
            TRYNEXT;
        ELSEIF ERRNO = ERR_WAITSYNCTASK THEN
            printEGMMessage "Pre-synchronization timed out";
            current_action := ACTION_NONE;
            TRYNEXT;
        ENDIF
    ENDPROC
    
    !---------------------------------------------------------
    ! Traps
    !---------------------------------------------------------
    LOCAL TRAP handleEGMStartJoint
        IF startEGMRunAllowed() THEN
            current_state := STATE_RUN_EGM_ROUTINE;
            current_action := ACTION_RUN_JOINT;
            RAISE CHANGE_STATE;
        ENDIF

        ERROR (CHANGE_STATE)
            RAISE CHANGE_STATE;
    ENDTRAP

    LOCAL TRAP handleEGMStartPose
        IF startEGMRunAllowed() THEN
            current_state := STATE_RUN_EGM_ROUTINE;
            current_action := ACTION_RUN_POSE;
            RAISE CHANGE_STATE;
        ENDIF

        ERROR (CHANGE_STATE)
            RAISE CHANGE_STATE;
    ENDTRAP
    
    LOCAL TRAP handleEGMStartStream
        IF startEGMStreamAllowed() THEN
            current_state := STATE_RUN_EGM_ROUTINE;
            current_action := ACTION_START_STREAM;
            RAISE CHANGE_STATE;
        ENDIF

        ERROR (CHANGE_STATE)
            RAISE CHANGE_STATE;
    ENDTRAP
    
    LOCAL TRAP handleEGMStop
        IF stopEGMAllowed() THEN
            current_state := STATE_RUN_EGM_ROUTINE;
            current_action := ACTION_STOP;
            RAISE CHANGE_STATE;
        ENDIF

        ERROR (CHANGE_STATE)
            RAISE CHANGE_STATE;
    ENDTRAP
    
    LOCAL TRAP handleEGMStopStream
        IF stopEGMStreamAllowed() THEN
            current_state := STATE_RUN_EGM_ROUTINE;
            current_action := ACTION_STOP_STREAM;
            RAISE CHANGE_STATE;
        ENDIF

        ERROR (CHANGE_STATE)
            RAISE CHANGE_STATE;
    ENDTRAP
    
    !---------------------------------------------------------
    ! Auxiliary procedures
    !---------------------------------------------------------
    LOCAL PROC initializeEGMSettings()
        ! Set default settings for the EGM instructions' arguments.
        settings.allow_egm_motions            := DEFAULT_ALLOW_EGM_MOTIONS;
        settings.use_presync                  := DEFAULT_USE_PRESYNC;
        settings.setup_uc.use_filtering       := DEFAULT_USE_FILTERING;
        settings.setup_uc.comm_timeout        := DEFAULT_COMM_TIMEOUT;
        settings.activate.tool                := tool0;
        settings.activate.wobj                := base_wobj;
        settings.activate.correction_frame    := DEFAULT_CORRECTION_FRAME;
        settings.activate.sensor_frame        := DEFAULT_SENSOR_FRAME;
        settings.activate.cond_min_max        := DEFAULT_COND_MIN_MAX;
        settings.activate.lp_filter           := DEFAULT_LP_FILTER;
        settings.activate.sample_rate         := DEFAULT_SAMPLE_RATE;
        settings.activate.max_speed_deviation := DEFAULT_MAX_SPEED_DEVIATION;
        settings.run.cond_time                := DEFAULT_CONDITION_TIME;
        settings.run.ramp_in_time             := DEFAULT_RAMP_IN_TIME;
        settings.run.offset                   := DEFAULT_OFFSET;
        settings.run.pos_corr_gain            := DEFAULT_POSITION_CORR_GAIN;
        settings.stop.ramp_out_time           := DEFAULT_RAMP_OUT_TIME;

        ! This program assumes that the robot's name is used as the name
        ! for the ExtConfigNames and UCdevices in the configurations.
        ext_config_name := GetMecUnitName(ROB_ID);
        uc_device       := GetMecUnitName(ROB_ID);

        ! Default work object, tool and load.
        egm_wobj := settings.activate.wobj;
        egm_tool := settings.activate.tool;
        egm_load := settings.activate.tool.tload;
    ENDPROC

    LOCAL PROC parseEGMSettings()
        VAR num sample_rate;

        ! Arguments for EGMSetupUC instruction.
        IF settings.setup_uc.use_filtering THEN
            ext_config_name := GetMecUnitName(ROB_ID);
        ELSE
            ext_config_name := GetMecUnitName(ROB_ID) + "_RAW";
        ENDIF

        ! Arguments for EGMAct instructions.
        egm_wobj := settings.activate.wobj;
        egm_tool := settings.activate.tool;
        egm_load := egm_tool.tload;

        minmax_condition.max := Abs(settings.activate.cond_min_max);
        minmax_condition.min := -Abs(settings.activate.cond_min_max);

        sample_rate := Round(settings.activate.sample_rate);
        IF(sample_rate > DEFAULT_SAMPLE_RATE) THEN
            settings.activate.sample_rate := (sample_rate - (sample_rate MOD DEFAULT_SAMPLE_RATE));
        ELSE
            settings.activate.sample_rate := DEFAULT_SAMPLE_RATE;
        ENDIF
        
        ! Arguments for EGMRun instructions.
        saturateValue settings.run.pos_corr_gain, 0, 1;

        ! Arguments for EGMStop instruction.
        settings.stop.ramp_out_time := Abs(settings.stop.ramp_out_time);
    ENDPROC

    LOCAL PROC prepareEGMRun()
        ! Prepare for the chosen run mode (i.e. joint or pose mode).
        TEST current_action
            CASE ACTION_RUN_JOINT:
                EGMSetupUC ROB_ID,
                           egm_id,
                           ext_config_name,
                           uc_device
                           \Joint
                           \CommTimeout:=settings.setup_uc.comm_timeout;

                IF general_info.using_modal_payload THEN
                    EGMActJoint egm_id
                                \Tool:=egm_tool,
                                \WObj:=egm_wobj,
                                \J1:=minmax_condition
                                \J2:=minmax_condition
                                \J3:=minmax_condition
                                \J4:=minmax_condition
                                \J5:=minmax_condition
                                \J6:=minmax_condition
                                \LpFilter:=settings.activate.lp_filter
                                \SampleRate:=settings.activate.sample_rate
                                \MaxSpeedDeviation:=settings.activate.max_speed_deviation;
                ELSE
                    EGMActJoint egm_id
                                \Tool:=egm_tool,
                                \WObj:=egm_wobj,
                                \TLoad:=egm_load,
                                \J1:=minmax_condition
                                \J2:=minmax_condition
                                \J3:=minmax_condition
                                \J4:=minmax_condition
                                \J5:=minmax_condition
                                \J6:=minmax_condition
                                \LpFilter:=settings.activate.lp_filter
                                \SampleRate:=settings.activate.sample_rate
                                \MaxSpeedDeviation:=settings.activate.max_speed_deviation;
                ENDIF

            CASE ACTION_RUN_POSE:
                EGMSetupUC ROB_ID,
                           egm_id,
                           ext_config_name,
                           uc_device
                           \Pose
                           \CommTimeout:=settings.setup_uc.comm_timeout;

                IF general_info.using_modal_payload THEN
                    EGMActPose egm_id
                               \Tool:=egm_tool,
                               \WObj:=egm_wobj,
                               settings.activate.correction_frame,
                               EGM_FRAME_BASE,
                               settings.activate.sensor_frame,
                               EGM_FRAME_BASE
                               \X:=minmax_condition
                               \Y:=minmax_condition
                               \Z:=minmax_condition
                               \Rx:=minmax_condition
                               \Ry:=minmax_condition
                               \Rz:=minmax_condition
                               \LpFilter:=settings.activate.lp_filter
                               \SampleRate:=settings.activate.sample_rate
                               \MaxSpeedDeviation:=settings.activate.max_speed_deviation;
                ELSE
                    EGMActPose egm_id
                               \Tool:=egm_tool,
                               \WObj:=egm_wobj,
                               \TLoad:=egm_load,
                               settings.activate.correction_frame,
                               EGM_FRAME_BASE,
                               settings.activate.sensor_frame,
                               EGM_FRAME_BASE
                               \X:=minmax_condition
                               \Y:=minmax_condition
                               \Z:=minmax_condition
                               \Rx:=minmax_condition
                               \Ry:=minmax_condition
                               \Rz:=minmax_condition
                               \LpFilter:=settings.activate.lp_filter
                               \SampleRate:=settings.activate.sample_rate
                               \MaxSpeedDeviation:=settings.activate.max_speed_deviation;
                ENDIF
        ENDTEST
    ENDPROC
    
    LOCAL PROC prepareEGMStream()
        ! Prepare for the streaming mode.
        EGMSetupUC ROB_ID,
                   egm_id,
                   ext_config_name,
                   uc_device
                   \Joint;
    ENDPROC

    !---------------------------------------------------------
    ! Auxiliary functions
    !---------------------------------------------------------
    LOCAL FUNC bool stopEGMAllowed()
        RETURN current_state = STATE_RUN_EGM_ROUTINE AND
               (current_action = ACTION_RUN_JOINT OR current_action = ACTION_RUN_POSE);
    ENDFUNC
    
    LOCAL FUNC bool stopEGMStreamAllowed()
        RETURN current_state = STATE_IDLE AND
               current_action = ACTION_START_STREAM;
    ENDFUNC
    
    LOCAL FUNC bool startEGMRunAllowed()
        RETURN current_state = STATE_IDLE AND
               current_action = ACTION_NONE AND 
               settings.allow_egm_motions;
    ENDFUNC
    
    LOCAL FUNC bool startEGMStreamAllowed()
        RETURN current_state = STATE_IDLE AND
               current_action = ACTION_NONE;
    ENDFUNC
    
    LOCAL FUNC bool isEGMStateDisconnected()
        RETURN EGMGetState(egm_id) = EGM_STATE_DISCONNECTED;
    ENDFUNC
    
    LOCAL FUNC bool isEGMStateConnected()
        RETURN EGMGetState(egm_id) = EGM_STATE_CONNECTED;
    ENDFUNC
    
    LOCAL FUNC bool isEGMStateRunning()
        RETURN EGMGetState(egm_id) = EGM_STATE_RUNNING;
    ENDFUNC
    
    FUNC string mapEGMState()
        TEST EGMGetState(egm_id)
            CASE EGM_STATE_DISCONNECTED:
                RETURN "EGM_STATE_DISCONNECTED";
            
            CASE EGM_STATE_CONNECTED:
                RETURN "EGM_STATE_CONNECTED";
            
            CASE EGM_STATE_RUNNING:
                RETURN "EGM_STATE_RUNNING";
            
            DEFAULT:
                RETURN "EGM_STATE_UNKNOWN";
        ENDTEST
    ENDFUNC
ENDMODULE
