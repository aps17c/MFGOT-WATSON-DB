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
CREATE TABLE WATSON.SCHD_TEAM
(
    PLANT_CODE      VARCHAR2( 3 CHAR )
  , TEAM_ID         NUMBER GENERATED ALWAYS AS IDENTITY
  , TEAM_TYPE       VARCHAR2( 25 CHAR )
  , TEAM_NAME       VARCHAR2( 25 CHAR )
  , TEAM_DESC       VARCHAR2( 100 CHAR )
  
);

COMMENT ON TABLE WATSON.SCHD_TEAM IS 'Houses various TEAMS for a given plant';
COMMENT ON COLUMN WATSON.SCHD_TEAM.PLANT_CODE IS 'MES Site Code.';
COMMENT ON COLUMN WATSON.SCHD_TEAM.TEAM_TYPE IS 'Type of TEAM this entry belongs';
COMMENT ON COLUMN WATSON.SCHD_TEAM.TEAM_NAME IS 'Name of TEAM';
COMMENT ON COLUMN WATSON.SCHD_TEAM.TEAM_DESC IS 'Description of TEAM_NAME';

ALTER TABLE WATSON.SCHD_TEAM
    ADD CONSTRAINT SCHD_TEAM_PK PRIMARY KEY( PLANT_CODE, TEAM_ID );

CREATE UNIQUE INDEX WATSON.SCHD_TEAM_U01
    ON WATSON.SCHD_TEAM( PLANT_CODE, TEAM_NAME );

ALTER TABLE WATSON.SCHD_TEAM
   ADD ( ACTIVATION_DT DATE DEFAULT SYSDATE
       , ACTIVE_FLAG   VARCHAR2( 1 CHAR ) DEFAULT 'Y'
       , INS_DT        DATE
       , INS_USER      VARCHAR2( 14 CHAR ) 
       , UPD_DT        DATE
       , UPD_USER      VARCHAR2( 14 CHAR )
      );
      
COMMENT ON COLUMN WATSON.SCHD_TEAM.ACTIVATION_DT IS 'Date when this record starts being active in the system.  Use along with ACTIVE_FLAG';
COMMENT ON COLUMN WATSON.SCHD_TEAM.ACTIVE_FLAG   IS 'Y/N flag indicating if record is currently active in system. Use along with ACTIVATION_DT';
COMMENT ON COLUMN WATSON.SCHD_TEAM.INS_DT        IS 'Date/Time when record was initially created';
COMMENT ON COLUMN WATSON.SCHD_TEAM.INS_USER      IS 'User who initially created record';
COMMENT ON COLUMN WATSON.SCHD_TEAM.UPD_DT        IS 'Date/Time when record was last edited';
COMMENT ON COLUMN WATSON.SCHD_TEAM.UPD_USER      IS 'User who last edited record';      

ALTER TABLE WATSON.SCHD_TEAM
ADD CONSTRAINT SCHD_TEAM_C01 CHECK (ACTIVE_FLAG IN ('Y','N')) ENABLE;


CREATE OR REPLACE TRIGGER WATSON.BIU_SCHD_TEAM
    BEFORE INSERT OR UPDATE
    ON WATSON.SCHD_TEAM
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
DECLARE
    l_user VARCHAR2(32) := upper(sys_context( 'userenv', 'os_user' ));
BEGIN
    IF INSERTING
    THEN
        :NEW.INS_DT := SYSDATE;
        :NEW.INS_USER := nvl(:NEW.UPDATE_USER,l_user);
    END IF;

    IF UPDATING
    THEN
        :NEW.UPD_DT := SYSDATE;
        :NEW.UPD_USER := nvl(:NEW.UPDATE_USER,l_user);
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        RAISE;
END; -- END TRIGGER
/
