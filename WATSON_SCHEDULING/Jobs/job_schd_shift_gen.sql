BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'WATSON.JOB_SHIFT_SCHD_GEN');
 EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'WATSON.JOB_SHIFT_SCHD_GEN'
      ,start_date      => TO_TIMESTAMP_TZ('2022/08/03 23:55:00.00000 -04:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=DAILY;INTERVAL=1'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'WATSON.DBJOB_SCHD_SHIFT_GEN'
      ,comments        => NULL
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'WATSON.JOB_SHIFT_SCHD_GEN'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'WATSON.JOB_SHIFT_SCHD_GEN');
END;
/
