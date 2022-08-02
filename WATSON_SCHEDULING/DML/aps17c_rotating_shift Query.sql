
insert into watson.schd_cal_setup ( plant_code
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
                                  , rotation_flag
                                  , rotation_day
                                  , rotation_days
                                  , activation_dt
                                  , active_flag)
/* rotating schedule query */
SELECT z.plant_code
     , a.area_id
     , a.area_name
     , x.shift_id
     , x.shift_name
     , t.team_id
     , t.team_name
     , z.start_time start_dt
     , z.day_of_week start_dow
     , z.hour_of_day start_hod
     , z.minute_block start_moh
     , trunc(z.start_time) + nvl(z.end_hour_of_day, y.hour_of_day)/24 + nvl(z.end_minute_block, y.minute_block)/1440 
       + CASE WHEN z.day_of_week = nvl(z.end_day_of_week, y.day_of_week) THEN 0 ELSE 1 END
        end_dt
     , nvl(z.end_day_of_week, y.day_of_week) end_dow
     , nvl(z.end_hour_of_day, y.hour_of_day) end_hod
     , nvl(z.end_minute_block, y.minute_block) end_moh
     , round(((trunc(z.start_time) + nvl(z.end_hour_of_day, y.hour_of_day)/24 + nvl(z.end_minute_block, y.minute_block)/1440 
       + CASE WHEN z.day_of_week = nvl(z.end_day_of_week, y.day_of_week) THEN 0 ELSE 1 END) - z.start_time) * 24 * 60 * 60,0) dur_secs        
     , 'Y' rotation_flag
     , z.day_of_rotation rotation_day
     , z.days_in_rotation rotation_days
     , SYSDATE activation_dt
     , 'Y' active_flag
FROM fill_shifts@WATSONP.WORLD fs
   , watson.schd_area a
   , watson.schd_team t
   , watson.v_schd_shift_xref x
, 
(
    SELECT plant_code, line_number, shift_id
        , effective_date + hour_of_day/24 + minute_block/1440 start_time
        , day_of_rotation, days_in_rotation, day_of_week, hour_of_day, minute_block
        , lead(day_of_week) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) end_day_of_week
        , lead(hour_of_day) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) end_hour_of_day
        , lead(minute_block) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) end_minute_block
    FROM (
        SELECT lag(shift_id) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) lag_shift_id
            , a.*
        FROM (
            WITH minute_blocks
            AS (SELECT level * 10 - 10 minute_block
                FROM dual
                CONNECT BY LEVEL < 7
                )
            SELECT mb.minute_block 
                  , mb.minute_block + 10 minute_block_end
                  , CASE WHEN mb.minute_block = 0 THEN minute_block_0
                         WHEN mb.minute_block = 10 THEN minute_block_10
                         WHEN mb.minute_block = 20 THEN minute_block_20
                         WHEN mb.minute_block = 30 THEN minute_block_30
                         WHEN mb.minute_block = 40 THEN minute_block_40
                         WHEN mb.minute_block = 50 THEN minute_block_50   
                         ELSE -999
                     END shift_id  
                  , sh.*
            FROM fill_shift_schedule_rotating sh
                , minute_blocks mb
            WHERE 1=1
--                AND sh.plant_code = nvl(:plantCode, sh.plant_code)
--                AND sh.line_number = nvl(:lineNumber, sh.line_number)
                AND sh.active_rotation = 'Y'
            ORDER BY sh.plant_code, sh.line_number, sh.day_of_rotation, sh.hour_of_day, mb.minute_block
            ) a
        ) b
    WHERE shift_id <> lag_shift_id
) z
, (  /*  "y" query is used to get the first shift of the entire rotation.  this start day/hour/minute is the end time for the last shift in the "z" shift schedule*/
    SELECT plant_code, line_number, shift_id
        , effective_date + hour_of_day/24 + minute_block/1440 start_time
        , day_of_rotation, days_in_rotation, day_of_week, hour_of_day, minute_block
        , lead(day_of_week) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) end_day_of_week
        , lead(hour_of_day) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) end_hour_of_day
        , lead(minute_block) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) end_minute_block
        , rank() OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) the_rank
    FROM (
        SELECT lag(shift_id) OVER (PARTITION BY plant_code, line_number ORDER BY day_of_rotation, hour_of_day, minute_block) lag_shift_id
            , a.*
        FROM (
            WITH minute_blocks
            AS (SELECT level * 10 - 10 minute_block
                FROM dual
                CONNECT BY LEVEL < 7
                )
            SELECT mb.minute_block 
                  , mb.minute_block + 10 minute_block_end
                  , CASE WHEN mb.minute_block = 0 THEN minute_block_0
                         WHEN mb.minute_block = 10 THEN minute_block_10
                         WHEN mb.minute_block = 20 THEN minute_block_20
                         WHEN mb.minute_block = 30 THEN minute_block_30
                         WHEN mb.minute_block = 40 THEN minute_block_40
                         WHEN mb.minute_block = 50 THEN minute_block_50   
                         ELSE -999
                     END shift_id  
                  , sh.*
            FROM fill_shift_schedule_rotating sh
                , minute_blocks mb
            WHERE 1=1
--                AND sh.plant_code = nvl(:plantCode, sh.plant_code)
--                AND sh.line_number = nvl(:lineNumber, sh.line_number)
                AND sh.active_rotation = 'Y'
                AND sh.day_of_rotation = 1
            ORDER BY sh.plant_code, sh.line_number, sh.day_of_rotation, sh.hour_of_day, mb.minute_block
            ) a
        ) b
    WHERE shift_id <> lag_shift_id
) y
WHERE y.plant_code = z.plant_code
  AND y.line_number = z.line_number
  AND y.the_rank = 1
  AND y.plant_code = fs.plant_code
  AND z.shift_id = fs.shift_id
  and x.plant_code = z.plant_code
  and x.legacy_shift_id = z.shift_id
  and a.plant_code = z.plant_code
  and a.area_name = z.line_number
  and t.plant_code = z.plant_code
  and t.team_name = 'DEFAULT';

commit;

