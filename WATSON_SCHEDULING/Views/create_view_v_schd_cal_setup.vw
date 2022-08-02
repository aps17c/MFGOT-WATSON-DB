CREATE OR REPLACE VIEW WATSON.V_SCHD_CAL_SETUP
AS
SELECT schd_cal_setup_id
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
  FROM watson.schd_cal_break_setup b