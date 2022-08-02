INSERT INTO watson.schd_cal_shift (schd_cal_setup_id
                           , schd_cal_break_setup_id
                           , break_type
                           , plant_code
                           , area_id
                           , area_name
                           , shift_id
                           , shift_name
                           , team_id
                           , team_name
                           , start_dt
                           , start_dow
                           , start_hod
                           , start_moh
                           , end_dt
                           , end_dow
                           , end_hod
                           , end_moh
                           , dur_secs
                           , rotation_day
                           , rotation_days
                           , rotation_flag
                           , EDITED_FLAG
                           , ACTIVE_FLAG
                           , ACTIVATION_DT)                           
      SELECT schd_cal_setup_id                                         
           , schd_cal_break_setup_id                                   
           , break_type
           , plant_code
           , area_id
           , area_name
           , shift_id
           , shift_name
           , team_id
           , team_name
           , next_start_dt                                             start_dt
           , to_number(to_char(next_start_dt,'D')) -1                  start_dow
           , start_hod 
           , start_moh
           , next_end_dt                                               end_dt
           , to_number(to_char(next_end_dt,'D')) - 1                    end_dow
           , end_hod
           , end_moh
           , ROUND ((next_end_dt - next_start_dt) * 24 * 60 * 60, 0)   dur_secs
           , rotation_day
           , rotation_days
           , rotation_flag
           , 'N' EDITED_FLAG
           , 'Y' ACTIVE_FLAG
           , SYSDATE ACTIVATION_DT
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
                   , (SELECT TRUNC ( SYSDATE ) + 6     range_start_dt
                           , TRUNC ( SYSDATE) + 8       range_end_dt
                        FROM DUAL) d
               WHERE 1=1
                 /* plant_code = :p_plant_code
                 AND area_name = :p_area_name
                 AND rotation_flag = :p_rotation_flag */
                 AND activation_dt <= SYSDATE
                 AND active_flag = 'Y')
       WHERE next_start_dt BETWEEN range_start_dt AND range_end_dt
         AND next_end_dt BETWEEN range_start_dt + 1 AND range_end_dt + 1
         and breaK_type = 0
    ORDER BY plant_code
           , area_name
           , next_start_dt
           , calc_start_dow
           , next_end_dt;
commit;           