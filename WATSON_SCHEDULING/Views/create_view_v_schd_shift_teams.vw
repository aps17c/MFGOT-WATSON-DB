CREATE OR REPLACE FORCE VIEW WATSON.V_SCHD_SHIFT_TEAMS
AS SELECT ST.PLANT_CODE
     , SS.SHIFT_SCHEDULE_ID
     , SS.SHIFT_ID
     , ST.TEAM_ID
     , TRIM(SUBSTR(ST.TEAM_NAME,1,INSTR(ST.TEAM_NAME,' - ',1))) LINE_NUMBER
     , TRIM(SUBSTR(ST.TEAM_NAME,INSTR(ST.TEAM_NAME,' - ',1)+3,99)) SHIFT_NAME
     , ST.TEAM_NAME
     , SS.START_DATE
     , SS.END_DATE
     , to_number(to_char(ss.start_date,'D')) - 1 shift_start_dow
     , to_number(to_char(ss.start_date,'HH24')) shift_start_hod
     , to_number(to_char(ss.start_date,'MI')) shift_start_moh
     , floor((ss.end_date - ss.start_date) * 24 * 60 * 60) shift_dur_secs
     , ST.EFFECTIVE_DATE
     , ST.SHIFT_SCHEDULE_TYPE
     , SS.BREAK_START_TIME_1
     , SS.BREAK_END_TIME_1
     , to_number(to_char(ss.BREAK_START_TIME_1,'D')) - 1 b1_start_dow
     , to_number(to_char(ss.BREAK_START_TIME_1,'HH24')) b1_start_hod
     , to_number(to_char(ss.BREAK_START_TIME_1,'MI')) b1_start_moh
     , floor((ss.BREAK_END_TIME_1 - ss.BREAK_START_TIME_1) * 24 * 60 * 60) b1_dur_secs
     , SS.BREAK_START_TIME_2
     , SS.BREAK_END_TIME_2
     , to_number(to_char(ss.BREAK_START_TIME_2,'D')) - 1 b2_start_dow
     , to_number(to_char(ss.BREAK_START_TIME_2,'HH24')) b2_start_hod
     , to_number(to_char(ss.BREAK_START_TIME_2,'MI')) b2_start_moh
     , floor((ss.BREAK_END_TIME_2 - ss.BREAK_START_TIME_2) * 24 * 60 * 60) b2_dur_secs
     , SS.BREAK_START_TIME_3
     , SS.BREAK_END_TIME_3
     , to_number(to_char(ss.BREAK_START_TIME_3,'D')) - 1 b3_start_dow
     , to_number(to_char(ss.BREAK_START_TIME_3,'HH24')) b3_start_hod
     , to_number(to_char(ss.BREAK_START_TIME_3,'MI')) b3_start_moh
     , floor((ss.BREAK_END_TIME_3 - ss.BREAK_START_TIME_3) * 24 * 60 * 60) b3_dur_secs
     , SS.BREAK_START_TIME_4
     , SS.BREAK_END_TIME_4
     , to_number(to_char(ss.BREAK_START_TIME_4,'D')) - 1 b4_start_dow
     , to_number(to_char(ss.BREAK_START_TIME_4,'HH24')) b4_start_hod
     , to_number(to_char(ss.BREAK_START_TIME_4,'MI')) b4_start_moh
     , floor((ss.BREAK_END_TIME_4 - ss.BREAK_START_TIME_4) * 24 * 60 * 60) b4_dur_secs     
     , SS.BREAK_START_TIME_5
     , SS.BREAK_END_TIME_5
     , to_number(to_char(ss.BREAK_START_TIME_5,'D')) - 1 b5_start_dow
     , to_number(to_char(ss.BREAK_START_TIME_5,'HH24')) b5_start_hod
     , to_number(to_char(ss.BREAK_START_TIME_5,'MI')) b5_start_moh
     , floor((ss.BREAK_END_TIME_5 - ss.BREAK_START_TIME_5) * 24 * 60 * 60) b5_dur_secs     
  FROM WATSON.SHIFT_SCHEDULE@WATSONP.WORLD SS, WATSON.SHIFT_TEAMS@WATSONP.WORLD ST
 WHERE ST.SHIFT_ID = SS.SHIFT_ID AND ST.TEAM_ID = SS.TEAM_ID;
