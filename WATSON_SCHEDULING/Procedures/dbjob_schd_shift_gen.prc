CREATE OR REPLACE PROCEDURE watson.dbjob_schd_shift_gen (
    p_plant_code   IN VARCHAR2 := NULL
  , p_start_dt     IN DATE := TRUNC (SYSDATE) + 7
  , p_days_out     IN NUMBER := 1)
AS
BEGIN
    watson.schd_pak.gen_schd (p_plant_code, p_start_dt, p_days_out);
END dbjob_schd_shift_gen;