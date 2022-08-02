  SELECT schd_cal_setup_id                                         setup_id
       , schd_cal_break_setup_id                                   break_id
       , break_type
       , plant_code
       , area_id
       , area_name
       , shift_id
       , shift_name
       , team_id
       , team_name
       , next_start_dt                                             actual_start_dt
       , CASE
             WHEN calc_start_dow < 0 THEN TRUNC (next_start_dt) + 1
             ELSE next_start_dt
         END                                                       cal_shift_start
       , CASE
             WHEN calc_start_dow < 0
             THEN
                 TO_NUMBER (TO_CHAR (TRUNC ( :p_start_dt), 'D')) - 1
             ELSE
                 calc_start_dow
         END                                                       cal_start_dow
       , CASE WHEN calc_start_dow < 0 THEN 0 ELSE start_hod END    cal_start_hod
       , CASE WHEN calc_start_dow < 0 THEN 0 ELSE start_moh END    cal_start_moh
       , CASE
             WHEN TRUNC (next_end_dt) > TRUNC ( :p_end_dt)
             THEN
                 TRUNC ( :p_end_dt) + 1
             ELSE
                 next_end_dt
         END                                                       cal_shift_end
       , next_end_dt                                               actual_end_dt
       , CASE
             WHEN TRUNC (next_end_dt) > TRUNC ( :p_end_dt)
             THEN
                 TO_NUMBER (TO_CHAR (TRUNC ( :p_end_dt), 'D')) - 1
             ELSE
                 TO_NUMBER (TO_CHAR (TRUNC (next_end_dt), 'D')) - 1
         END                                                       cal_end_dow
       , CASE
             WHEN TRUNC (next_end_dt) > TRUNC ( :p_end_dt) THEN 0
             ELSE end_hod
         END                                                       cal_end_hod
       , CASE
             WHEN TRUNC (next_end_dt) > TRUNC ( :p_end_dt) THEN 0
             ELSE end_moh
         END                                                       cal_end_moh
       , ROUND (
               (  (CASE
                       WHEN TRUNC (next_end_dt) > TRUNC ( :p_end_dt)
                       THEN
                           TRUNC ( :p_end_dt) + 1
                       ELSE
                           next_end_dt
                   END)
                - CASE
                      WHEN calc_start_dow < 0 THEN TRUNC (next_start_dt) + 1
                      ELSE next_start_dt
                  END)
             * 24
             * 60
             * 60
           , 0)                                                    entry_dur_secs
       , rotation_day
       , rotation_days
       , rotation_flag
    FROM (SELECT s.*
               ,   MOD (TRUNC (d.range_start_dt) - TRUNC (start_dt)
                      , rotation_days)
                 - 1                            calc_start_dow
               ,   TRUNC (d.range_start_dt)
                 + MOD (TRUNC (d.range_start_dt) - TRUNC (start_dt)
                      , rotation_days)
                 + start_hod / 24
                 + start_moh / 24 / 60          next_start_dt
               ,   (  TRUNC (d.range_start_dt)
                    + MOD (TRUNC (d.range_start_dt) - TRUNC (start_dt)
                         , rotation_days)
                    + start_hod / 24
                    + start_moh / 24 / 60)
                 + (dur_secs / 24 / 60 / 60)    next_end_dt
               , d.range_start_dt
               , d.range_end_dt
            FROM watson.v_schd_cal_setup s
               , (SELECT TRUNC ( :p_start_dt) - 1     range_start_dt
                       , TRUNC ( :p_end_dt) + 1       range_end_dt
                    FROM DUAL) d
           WHERE plant_code = :p_plant_code
             AND area_name = :p_area_name
             AND rotation_flag = :p_rotation_flag
             AND activation_dt <= SYSDATE
             AND active_flag = 'Y')
   WHERE next_start_dt BETWEEN range_start_dt AND range_end_dt
     AND next_end_dt BETWEEN range_start_dt + 1 AND range_end_dt + 1
ORDER BY plant_code
       , area_name
       , next_start_dt
       , calc_start_dow
       , next_end_dt;