WHENEVER SQLERROR CONTINUE;

/* =======================================================
 * | SCHD_TEAM
 * | --------------
 * | Purpose......: 
 * | 
 * | 
 * |  History:
 * |  ----------------------------------------------------
 * |  DATE          WHO     DESCRITPION
 * |  ----------    ------  ------------------------------
 * |  2022-07-05    aps17c  Original version
 * |  ----------------------------------------------------
 */

CREATE TABLE watson.schd_team
(
    plant_code       VARCHAR2 (3 CHAR)
  , team_id          NUMBER GENERATED ALWAYS AS IDENTITY
  , team_type        VARCHAR2 (25 CHAR)
  , team_name        VARCHAR2 (25 CHAR)
  , team_desc        VARCHAR2 (100 CHAR)
  , activation_dt    DATE DEFAULT SYSDATE
  , active_flag      VARCHAR2 (1 CHAR) DEFAULT 'Y'
  , ins_dt           DATE
  , ins_user         VARCHAR2 (14 CHAR)
  , upd_dt           DATE
  , upd_user         VARCHAR2 (14 CHAR)
  , CONSTRAINT schd_team_pk PRIMARY KEY (plant_code, team_id)
  , CONSTRAINT schd_team_c01 CHECK (active_flag IN ('Y', 'N'))
);

COMMENT ON TABLE watson.schd_team IS 'Houses various TEAMS for a given plant';
COMMENT ON COLUMN watson.schd_team.plant_code IS 'MES Site Code.';
COMMENT ON COLUMN watson.schd_team.team_type IS  'Type of TEAM this entry belongs';
COMMENT ON COLUMN watson.schd_team.team_name IS 'Name of TEAM';
COMMENT ON COLUMN watson.schd_team.team_desc IS 'Description of TEAM_NAME';
COMMENT ON COLUMN watson.schd_team.activation_dt IS 'Date when this record starts being active in the system.  Use along with ACTIVE_FLAG';
COMMENT ON COLUMN watson.schd_team.active_flag IS 'Y/N flag indicating if record is currently active in system. Use along with ACTIVATION_DT';
COMMENT ON COLUMN watson.schd_team.ins_dt IS 'Date/Time when record was initially created';
COMMENT ON COLUMN watson.schd_team.ins_user IS 'User who initially created record';
COMMENT ON COLUMN watson.schd_team.upd_dt IS 'Date/Time when record was last edited';
COMMENT ON COLUMN watson.schd_team.upd_user IS 'User who last edited record';
