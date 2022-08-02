CREATE OR REPLACE VIEW WATSON.V_SCHD_CAL
AS
  SELECT *
    FROM (SELECT *
            FROM watson.schd_cal_shift
          UNION
          SELECT *
            FROM watson.schd_cal_break)
ORDER BY start_dt;