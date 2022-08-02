WHENEVER SQLERROR CONTINUE;

/* NEED TO DROP CHILD TABLE BEFORE RECREATING THIS TABLE */
DROP TABLE WATSON.SCHD_CAL_BREAK_SETUP CASCADE CONSTRAINTS;

DROP TABLE watson.schd_cal_setup CASCADE CONSTRAINTS;

CREATE TABLE watson.schd_cal_setup
(
    schd_cal_setup_id      NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
  , plant_code             VARCHAR2 (3 CHAR)
  , area_id                NUMBER NOT NULL
  , area_name              VARCHAR2 (25 CHAR)
  , shift_id               NUMBER NOT NULL
  , shift_name             VARCHAR2 (25 CHAR)
  , team_id                NUMBER NOT NULL
  , team_name              VARCHAR2 (25 CHAR)
  , start_dt               DATE
  , start_dow              INTEGER
  , start_hod              INTEGER
  , start_moh              NUMBER
  , end_dt                 DATE
  , end_dow                NUMBER
  , end_hod                NUMBER
  , end_moh                NUMBER
  , dur_secs               NUMBER
  , rotation_flag          CHAR (1 CHAR)
  , rotation_day           INTEGER
  , rotation_days          NUMBER
  , activation_dt          DATE
  , active_flag            VARCHAR2 (1 CHAR)
  , ins_user               VARCHAR2 (14 CHAR)
  , ins_dt                 DATE
  , upd_user               VARCHAR2 (14 CHAR)
  , upd_dt                 DATE
  , CONSTRAINT schd_cal_setup_pk   PRIMARY KEY (plant_code, schd_cal_setup_id)
  , CONSTRAINT schd_cal_setup_fk00 FOREIGN KEY (plant_code)           REFERENCES watson.locations  (plant_code)
  , CONSTRAINT schd_cal_setup_fk05 FOREIGN KEY (plant_code, shift_id) REFERENCES watson.schd_shift (plant_code, shift_id)
  , CONSTRAINT schd_cal_setup_fk10 FOREIGN KEY (plant_code, area_id)  REFERENCES watson.schd_area  (plant_code, area_id)
  , CONSTRAINT schd_cal_setup_fk15 FOREIGN KEY (plant_code, team_id)  REFERENCES watson.schd_team  (plant_code, team_id)
  , CONSTRAINT schd_cal_setup_ck00 CHECK       (active_flag IN ('Y', 'N'))
  , CONSTRAINT schd_cal_setup_ck05 CHECK       (rotation_flag   IN ('Y', 'N'))
);

COMMENT ON TABLE watson.schd_cal_setup IS 'Houses Generated/Edited setup schedule for area/shift/team';

COMMENT ON COLUMN watson.schd_cal_setup.schd_cal_setup_id IS 'Unique ID of THIS calendar setup entry';
COMMENT ON COLUMN watson.schd_cal_setup.plant_code IS 'MES Site Code.';
COMMENT ON COLUMN watson.schd_cal_setup.area_id IS 'FKey to WATSONS.SCHD_AREA table';
COMMENT ON COLUMN watson.schd_cal_setup.shift_id IS 'FKey to WATSONS.SCHD_SHIFT table';
COMMENT ON COLUMN watson.schd_cal_setup.team_id IS 'FKey to WATSONS.SCHD_TEAM table';
COMMENT ON COLUMN watson.schd_cal_setup.start_dt IS 'Entry Start date/time';
COMMENT ON COLUMN watson.schd_cal_setup.start_dow is 'Numeric Day of Week for Shift Start';
COMMENT ON COLUMN watson.schd_cal_setup.start_hod is 'Numeric Hour of Day (24HH) for Shift Start';
COMMENT ON COLUMN watson.schd_cal_setup.start_moh is 'Numeric Minute of Hour for Shift Start';
COMMENT ON COLUMN watson.schd_cal_setup.end_dt IS 'Entry End date/time';
COMMENT ON COLUMN watson.schd_cal_setup.end_dow is 'Numeric Day of Week for Shift End';
COMMENT ON COLUMN watson.schd_cal_setup.end_hod is 'Numeric Hour of Day (24HH) for Shift End';
COMMENT ON COLUMN watson.schd_cal_setup.end_moh is 'Numeric Minute of Hour for Shift End';
COMMENT ON COLUMN watson.schd_cal_setup.dur_secs is 'Duration of Entry in Seconds';
COMMENT ON COLUMN watson.schd_cal_setup.rotation_flag IS 'Is item a rotation entry';
COMMENT ON COLUMN watson.schd_cal_setup.rotation_day IS 'The rotation sequence for this entry';
COMMENT ON COLUMN watson.schd_cal_setup.rotation_days IS 'The total number rotation days for this entry';
COMMENT ON COLUMN watson.schd_cal_setup.activation_dt IS 'Date when this record starts being active in the system.  Use with ACTIVE_FLAG';
COMMENT ON COLUMN watson.schd_cal_setup.active_flag IS 'Y/N flag indicating if record is currently active in system. Use with ACTIVATION_DT';
COMMENT ON COLUMN watson.schd_cal_setup.ins_dt IS 'Date/Time when record was initially created';
COMMENT ON COLUMN watson.schd_cal_setup.ins_user IS 'User who initially created record';
COMMENT ON COLUMN watson.schd_cal_setup.upd_dt IS 'Date/Time when record was last edited';
COMMENT ON COLUMN watson.schd_cal_setup.upd_user IS 'User who last edited record';

