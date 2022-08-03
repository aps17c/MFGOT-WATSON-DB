BEGIN

  BEGIN
    SYS.DBMS_SCHEDULER.DROP_JOB('WATSON.WATSON_SHIFT_SCHD_GEN', TRUE, FALSE, NULL);
  EXCEPTION 
    WHEN OTHERS THEN NULL;
  END;
  
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'WATSON.WATSON_SHIFT_SCHD_GEN'
      ,start_date      => TO_TIMESTAMP_TZ(to_char(trunc(systimestamp) + 23/24 + (55/24/60), 'yyyy/mm/dd hh24:mi'), 'yyyy/mm/dd hh24:mi')
      ,repeat_interval => 'FREQ=DAILY;INTERVAL=1'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'BEGIN
    WATSON.SCHD_PAK.SET_LOGGING(''Y'');
    
    WATSON.SCHD_PAK.LOG(
           ''Processing Date Range: ''
        || TO_CHAR (TRUNC (SYSDATE) + 7, ''MM/DD/YYYY'')
        || '' thru ''
        || TO_CHAR (TRUNC (SYSDATE) + 8, ''mm/dd/yyyy''));
    
    WATSON.SCHD_PAK.LOG (''---------------------------------'');

    FOR lrec_plt IN (SELECT * FROM watson.locations)
    LOOP
        BEGIN
            WATSON.SCHD_PAK.LOG(
                   ''Processing Plant: ''
                || lrec_plt.plant_name
                || ''-(''
                || lrec_plt.plant_code
                || '')'');
            watson.schd_pak.gen_sched (
                p_plant_code      => lrec_plt.plant_code
              , p_start_dt        => TRUNC (SYSDATE) + 7
              , p_end_dt          => TRUNC (SYSDATE) + 8
              , p_setup_id        => NULL
              , p_break_id        => NULL
              , p_area_id         => NULL
              , p_shift_id        => NULL
              , p_team_id         => NULL
              , p_rotation_flag   => NULL
              , p_override_flag   => ''N'');
        END;

       WATSON.SCHD_PAK.LOG(''---------------------------------'');
    END LOOP;
END;'
      ,comments        => 'Schedules out 1 day of shift schdedule that is 7 days out.'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'RESTARTABLE'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,attribute => 'RAISE_EVENTS'
     ,value     => SYS.DBMS_SCHEDULER.JOB_STARTED + SYS.DBMS_SCHEDULER.JOB_SUCCEEDED + SYS.DBMS_SCHEDULER.JOB_FAILED + SYS.DBMS_SCHEDULER.JOB_BROKEN + SYS.DBMS_SCHEDULER.JOB_COMPLETED + SYS.DBMS_SCHEDULER.JOB_STOPPED + SYS.DBMS_SCHEDULER.JOB_SCH_LIM_REACHED + SYS.DBMS_SCHEDULER.JOB_DISABLED + SYS.DBMS_SCHEDULER.JOB_CHAIN_STALLED);

  SYS.DBMS_SCHEDULER.ADD_JOB_EMAIL_NOTIFICATION
    ( job_name          => 'WATSON.WATSON_SHIFT_SCHD_GEN'
     ,recipients        => 'andrew.p.scott@sherwin.com'
     ,sender            => 'NoReply@watson.support.sherwin.com'
     ,subject           => DBMS_SCHEDULER.DEFAULT_NOTIFICATION_SUBJECT
     ,body              => DBMS_SCHEDULER.DEFAULT_NOTIFICATION_BODY
     ,events            => 'JOB_BROKEN,JOB_CHAIN_STALLED,JOB_COMPLETED,JOB_DISABLED,JOB_FAILED,JOB_OVER_MAX_DUR,JOB_STOPPED'
     ,filter_condition  => NULL);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'WATSON.WATSON_SHIFT_SCHD_GEN');
END;
/