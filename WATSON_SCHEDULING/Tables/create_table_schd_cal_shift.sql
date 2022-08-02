WHENEVER SQLERROR CONTINUE;

drop table watson.schd_cal_shift;

CREATE TABLE watson.schd_cal_shift
(
    schd_cal_shift_id          NUMBER 
  , schd_cal_setup_id          NUMBER
  , schd_cal_break_setup_id    NUMBER
  , break_type                 NUMBER (1, 0)
  , plant_code                 VARCHAR2 (3 CHAR)
  , area_id                    NUMBER
  , area_name                  VARCHAR2 (25 CHAR)
  , shift_id                   NUMBER
  , shift_name                 VARCHAR2 (25 CHAR)
  , team_id                    NUMBER
  , team_name                  VARCHAR2 (25 CHAR)
  , start_dt                   DATE
  , start_dow                  NUMBER (1, 0)
  , start_hod                  NUMBER (2, 0)
  , start_moh                  NUMBER (2, 0)
  , end_dt                     DATE
  , end_dow                    NUMBER (1, 0)
  , end_hod                    NUMBER (2, 0)
  , end_moh                    NUMBER (2, 0)
  , dur_secs                   NUMBER (8, 0)
  , rotation_day               NUMBER (2, 0)
  , rotation_days              NUMBER (2, 0)
  , rotation_flag              VARCHAR2 (1 CHAR)
  , edited_flag                VARCHAR2 (1 CHAR) DEFAULT 'N'
  , activation_dt              DATE DEFAULT SYSDATE
  , active_flag                VARCHAR2 (1 CHAR) DEFAULT 'Y'
  , ins_dt                     DATE
  , ins_user                   VARCHAR2 (14 CHAR)
  , upd_dt                     DATE
  , upd_user                   VARCHAR2 (14 CHAR)
  , CONSTRAINT schd_cal_shift_pk   PRIMARY KEY (plant_code, schd_cal_shift_id)
  , CONSTRAINT schd_cal_shift_ck00 CHECK       (active_flag IN ('Y', 'N'))
  , CONSTRAINT schd_cal_shift_ck01 CHECK       (edited_flag in ('Y','N')) 
);

COMMENT ON TABLE watson.schd_cal_shift IS 'Houses Generated/Edited schedule for site/area/shift/team';

COMMENT ON COLUMN watson.schd_cal_shift.schd_cal_shift_id IS 'Unique ID of THIS calendar entry';
COMMENT ON COLUMN watson.schd_cal_shift.plant_code IS 'MES Site Code.';
COMMENT ON COLUMN watson.schd_cal_shift.area_id IS '(unenforced)FKey to WATSONS.SCHD_AREA table';
COMMENT ON COLUMN watson.schd_cal_shift.shift_id IS '(unenforced)FKey to WATSONS.SCHD_SHIFT table';
COMMENT ON COLUMN watson.schd_cal_shift.team_id IS '(unenforced)FKey to WATSONS.SCHD_TEAM table';
COMMENT ON COLUMN watson.schd_cal_shift.start_dt IS 'Calendar Entry Start date/time ';
COMMENT ON COLUMN watson.schd_cal_shift.start_dow is 'Numeric Day of Week for Shift Start.';
COMMENT ON COLUMN watson.schd_cal_shift.start_hod is 'Numeric Hour of Day (24HH) for Shift Start. ';
COMMENT ON COLUMN watson.schd_cal_shift.start_moh is 'Numeric Minute of Hour for Shift Start. ';
COMMENT ON COLUMN watson.schd_cal_shift.end_dt IS 'Calendar Entry End date/time.  ';
COMMENT ON COLUMN watson.schd_cal_shift.end_dow is 'Numeric Day of Week for Shift End. ';
COMMENT ON COLUMN watson.schd_cal_shift.end_hod is 'Numeric Hour of Day (24HH) for Shift End.';
COMMENT ON COLUMN watson.schd_cal_shift.end_moh is 'Numeric Minute of Hour for Shift End.';
COMMENT ON COLUMN watson.schd_cal_shift.dur_secs is 'Duration of Entry in Seconds';
COMMENT ON COLUMN watson.schd_cal_shift.rotation_flag IS 'Y/N flag: Is item a rotating schedule entry';
COMMENT ON COLUMN watson.schd_cal_shift.rotation_day IS 'The rotation sequence for this entry';
COMMENT ON COLUMN watson.schd_cal_shift.rotation_days IS 'The total number rotation days for this entry';
COMMENT ON COLUMN watson.schd_cal_shift.edited_flag is 'Y/N flag if user edited record when = Y. If done by system EDITED_FLAG will = N';
COMMENT ON COLUMN watson.schd_cal_shift.activation_dt IS 'Date when this record starts being active in the system.  Use with ACTIVE_FLAG';
COMMENT ON COLUMN watson.schd_cal_shift.active_flag IS 'Y/N flag indicating if record is currently active in system. Use with ACTIVATION_DT';
COMMENT ON COLUMN watson.schd_cal_shift.ins_dt IS 'Date/Time when record was initially created';
COMMENT ON COLUMN watson.schd_cal_shift.ins_user IS 'User who initially created record';
COMMENT ON COLUMN watson.schd_cal_shift.upd_dt IS 'Date/Time when record was last edited.';
COMMENT ON COLUMN watson.schd_cal_shift.upd_user IS 'User who last edited record';

/* GRANTS */
--GRANT INSERT, UPDATE, DELETE, SELECT ON WATSON.SCHD_CAL_SHIFT TO 

