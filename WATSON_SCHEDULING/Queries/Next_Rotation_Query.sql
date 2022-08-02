SELECT *
  FROM (  SELECT X.*
               ,   TRUNC ( :p_start_dt)
                 + calc_rotation_day
                 + start_hod / 24
                 + start_moh / 24 / 60          next_start_dt
               ,   (  TRUNC ( :p_start_dt)
                    + calc_rotation_day
                    + start_hod / 24
                    + start_moh / 24 / 60)
                 + (dur_secs / 24 / 60 / 60)    next_end_dt
            FROM (  SELECT c.*
                         , MOD (TRUNC ( :p_start_dt) - TRUNC (start_dt)
                              , rotation_days)    calc_rotation_day
                      FROM (SELECT schd_cal_setup_id
                                 , NULL     schd_cal_break_setup_id
                                 , plant_code
                                 , area_id
                                 , area_name
                                 , shift_id
                                 , shift_name
                                 , team_id
                                 , team_name
                                 , 0        break_type
                                 , start_dt
                                 , start_dow
                                 , start_hod
                                 , start_moh
                                 , end_dt
                                 , end_dow
                                 , end_hod
                                 , end_moh
                                 , dur_secs
                                 , rotation_flag
                                 , rotation_day
                                 , rotation_days
                                 , activation_dt
                                 , active_flag
                                 , ins_user
                                 , ins_dt
                                 , upd_user
                                 , upd_dt
                              FROM watson.schd_cal_setup c
                            UNION
                            SELECT schd_cal_setup_id
                                 , schd_cal_break_setup_id
                                 , plant_code
                                 , area_id
                                 , area_name
                                 , shift_id
                                 , shift_name
                                 , team_id
                                 , team_name
                                 , break_type
                                 , start_dt
                                 , start_dow
                                 , start_hod
                                 , start_moh
                                 , end_dt
                                 , end_dow
                                 , end_hod
                                 , end_moh
                                 , dur_secs
                                 , rotation_flag
                                 , rotation_day
                                 , rotation_days
                                 , activation_dt
                                 , active_flag
                                 , ins_user
                                 , ins_dt
                                 , upd_user
                                 , upd_dt
                              FROM watson.schd_cal_break_setup b) c
                     WHERE 1 = 1
                       AND plant_code = :p_plant_code
                       AND area_name = :p_area_name
                       AND rotation_flag = :p_rotation_flag
                       AND activation_dt <= SYSDATE
                       AND active_flag = 'Y'
                  ORDER BY plant_code
                         , area_name
                         , rotation_day
                         , start_dt
                         , break_type DESC) x
        ORDER BY plant_code
               , area_name
               , calc_rotation_day
               , start_dt)
 WHERE TRUNC(next_end_dt) <= TRUNC(:p_end_dt);