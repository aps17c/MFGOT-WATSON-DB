 SELECT *
    FROM watson.v_schd_cal
   WHERE plant_code = 'COL' AND area_name = 'LINE 1'
ORDER BY plant_code
       , area_name
       , start_dt
       , break_type;