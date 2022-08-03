/* non-rotating schedule query */

INSERT INTO watson.schd_cal_setup (plant_code
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
      SELECT z.plant_code
           , a.area_id
           , a.area_name
           , x.shift_id
           , x.shift_name
           , t.team_id
           , t.team_name
           , z.start_time                                start_dt
           , z.day_of_week                               start_dow
           , z.hour_of_day                               start_hod
           , z.minute_block                              start_moh
           ,   TRUNC (z.start_time)
             + NVL (z.end_hour_of_day, y.hour_of_day) / 24
             + NVL (z.end_minute_block, y.minute_block) / 1440
             + CASE
                   WHEN z.day_of_week = NVL (z.end_day_of_week, y.day_of_week)
                   THEN
                       0
                   ELSE
                       1
               END                                       end_dt
           , NVL (z.end_day_of_week, y.day_of_week)      end_dow
           , NVL (z.end_hour_of_day, y.hour_of_day)      end_hod
           , NVL (z.end_minute_block, y.minute_block)    end_moh
           , ROUND (
                   (  (  TRUNC (z.start_time)
                       + NVL (z.end_hour_of_day, y.hour_of_day) / 24
                       + NVL (z.end_minute_block, y.minute_block) / 1440
                       + CASE
                             WHEN z.day_of_week =
                                  NVL (z.end_day_of_week, y.day_of_week)
                             THEN
                                 0
                             ELSE
                                 1
                         END)
                    - z.start_time)
                 * 24
                 * 60
                 * 60
               , 0)                                      dur_secs
           , 'N'                                         rotation_flag
           , z.day_of_rotation                           rotation_day
           , z.days_in_rotation                          rotation_days
           , SYSDATE                                     activation_dt
           , 'Y'                                         active_flag
        FROM fill_shifts@watsonp.world fs
           , watson.schd_area         a
           , watson.schd_team         t
           , watson.v_schd_shift_xref x
           , (SELECT plant_code
                   , line_number
                   , shift_id
                   ,   NEXT_DAY (TRUNC (SYSDATE), 'SUNDAY')
                     - 7
                     + day_of_week
                     + hour_of_day / 24
                     + minute_block / 1440                                         start_time
                   , day_of_week + 1                                               day_of_rotation
                   , 7                                                             days_in_rotation
                   , day_of_week
                   , hour_of_day
                   , minute_block
                   , LEAD (day_of_week)
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    end_day_of_week
                   , LEAD (hour_of_day)
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    end_hour_of_day
                   , LEAD (minute_block)
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    end_minute_block
                FROM (SELECT LAG (shift_id)
                                 OVER (
                                     PARTITION BY plant_code, line_number
                                     ORDER BY
                                         day_of_week, hour_of_day, minute_block)    lag_shift_id
                           , a.*
                        FROM (WITH
                                  minute_blocks
                                  AS
                                      (    SELECT LEVEL * 10 - 10     minute_block
                                             FROM DUAL
                                       CONNECT BY LEVEL < 7)
                                SELECT mb.minute_block
                                     , mb.minute_block + 10    minute_block_end
                                     , CASE
                                           WHEN mb.minute_block = 0
                                           THEN
                                               minute_block_0
                                           WHEN mb.minute_block = 10
                                           THEN
                                               minute_block_10
                                           WHEN mb.minute_block = 20
                                           THEN
                                               minute_block_20
                                           WHEN mb.minute_block = 30
                                           THEN
                                               minute_block_30
                                           WHEN mb.minute_block = 40
                                           THEN
                                               minute_block_40
                                           WHEN mb.minute_block = 50
                                           THEN
                                               minute_block_50
                                           ELSE
                                               -999
                                       END                     shift_id
                                     , sh.*
                                  FROM fill_shift_schedule sh, minute_blocks mb
                                 WHERE 1 = 1
                                   AND sh.plant_code =
                                       NVL ( :plantcode, sh.plant_code)
                              --                AND sh.line_number = nvl(:lineNumber, sh.line_number)
                              ORDER BY sh.plant_code
                                     , sh.line_number
                                     , sh.day_of_week
                                     , sh.hour_of_day
                                     , mb.minute_block) a) b
               WHERE shift_id <> lag_shift_id) z
           , ( /*  "y" query is used to get the first shift of the entire rotation.  this start day/hour/minute is the end time for the last shift in the "z" shift schedule*/
              SELECT plant_code
                   , line_number
                   , shift_id
                   ,   NEXT_DAY (TRUNC (SYSDATE), 'SUNDAY')
                     - 7
                     + day_of_week
                     + hour_of_day / 24
                     + minute_block / 1440                                         start_time
                   , day_of_week + 1                                               day_of_rotation
                   , 7                                                             days_in_rotation
                   , day_of_week
                   , hour_of_day
                   , minute_block
                   , LEAD (day_of_week)
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    end_day_of_week
                   , LEAD (hour_of_day)
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    end_hour_of_day
                   , LEAD (minute_block)
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    end_minute_block
                   , RANK ()
                         OVER (PARTITION BY plant_code, line_number
                               ORDER BY day_of_week, hour_of_day, minute_block)    the_rank
                FROM (SELECT LAG (shift_id)
                                 OVER (
                                     PARTITION BY plant_code, line_number
                                     ORDER BY
                                         day_of_week, hour_of_day, minute_block)    lag_shift_id
                           , a.*
                        FROM (WITH
                                  minute_blocks
                                  AS
                                      (    SELECT LEVEL * 10 - 10     minute_block
                                             FROM DUAL
                                       CONNECT BY LEVEL < 7)
                                SELECT mb.minute_block
                                     , mb.minute_block + 10    minute_block_end
                                     , CASE
                                           WHEN mb.minute_block = 0
                                           THEN
                                               minute_block_0
                                           WHEN mb.minute_block = 10
                                           THEN
                                               minute_block_10
                                           WHEN mb.minute_block = 20
                                           THEN
                                               minute_block_20
                                           WHEN mb.minute_block = 30
                                           THEN
                                               minute_block_30
                                           WHEN mb.minute_block = 40
                                           THEN
                                               minute_block_40
                                           WHEN mb.minute_block = 50
                                           THEN
                                               minute_block_50
                                           ELSE
                                               -999
                                       END                     shift_id
                                     , sh.*
                                  FROM fill_shift_schedule sh, minute_blocks mb
                                 WHERE 1 = 1 --                AND sh.plant_code = nvl(:plantCode, sh.plant_code)
                                             --                AND sh.line_number = nvl(:lineNumber, sh.line_number)
                                             AND sh.day_of_week = 0
                              ORDER BY sh.plant_code
                                     , sh.line_number
                                     , sh.day_of_week
                                     , sh.hour_of_day
                                     , mb.minute_block) a) b
               WHERE shift_id <> lag_shift_id) y
       WHERE y.plant_code = z.plant_code
         AND y.line_number = z.line_number
         AND y.the_rank = 1
         AND y.plant_code = fs.plant_code
         AND z.shift_id = fs.shift_id
         AND x.plant_code = z.plant_code
         AND x.legacy_shift_id = fs.shift_id
         AND a.plant_code = z.plant_code
         AND a.area_name = z.line_number
         AND t.plant_code = z.plant_code
         AND t.team_name = 'DEFAULT'
         AND NOT EXISTS
                 (SELECT 1
                    FROM watson.schd_cal_setup c
                   WHERE c.plant_code = z.plant_code
                     AND c.area_id = a.area_id
                     AND c.shift_id = x.shift_id
                     AND c.team_id = t.team_id
                     AND c.rotation_flag = 'Y')
         AND a.plant_code = 'COL'
         AND a.area_name = 'LINE 1'
    --and z.start_time between to_date('08/02/2022','MM/DD/YYYY') AND TO_DATE('08/10/2022','MM/DD/YYYY')
    ORDER BY 1, 3, 8;
