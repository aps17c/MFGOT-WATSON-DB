/* =======================================================
 * | SCHD_AREA
 * | --------------
 * | Purpose......: 
 * | 
 * | 
 * |  History:
 * |  ----------------------------------------------------
 * |  DATE          WHO     DESCRITPION
 * |  ----------    ------  ------------------------------
 * |  2022-07-08    aps17c  Original version
 * |  ----------------------------------------------------
 */

CREATE TABLE WATSON.SCHD_AREA
(
    PLANT_CODE      VARCHAR2( 3 CHAR )
  , AREA_ID         NUMBER GENERATED ALWAYS AS IDENTITY
  , AREA_TYPE       VARCHAR2( 25 CHAR )
  , AREA_NAME       VARCHAR2( 25 CHAR )
  , AREA_DESC       VARCHAR2( 100 CHAR )
  , ASSOC_TABLE     VARCHAR2( 60 CHAR )
);

COMMENT ON TABLE WATSON.SCHD_AREA IS 'Houses AREAS for which TEAMS/SHIFTS are to work';
COMMENT ON COLUMN WATSON.SCHD_AREA.PLANT_CODE IS 'MES Site Code';
COMMENT ON COLUMN WATSON.SCHD_AREA.AREA_TYPE IS 'Type of AREA this entry belongs';
COMMENT ON COLUMN WATSON.SCHD_AREA.AREA_NAME IS 'Name of AREA';
COMMENT ON COLUMN WATSON.SCHD_AREA.AREA_DESC IS 'Description of AREA_NAME';
COMMENT ON COLUMN WATSON.SCHD_AREA.ASSOC_TABLE IS 'Which Table did data come from';

ALTER TABLE WATSON.SCHD_AREA ADD CONSTRAINT SCHD_AREA_PK PRIMARY KEY( PLANT_CODE, AREA_ID );

CREATE UNIQUE INDEX WATSON.SCHD_AREA_U01 ON WATSON.SCHD_AREA( PLANT_CODE, AREA_NAME );

ALTER TABLE WATSON.SCHD_AREA
   ADD ( ACTIVATION_DT DATE DEFAULT SYSDATE
       , ACTIVE_FLAG   VARCHAR2( 1 CHAR ) DEFAULT 'Y'
       , INS_DT        DATE
       , INS_USER      VARCHAR2( 14 CHAR ) 
       , UPD_DT        DATE
       , UPD_USER      VARCHAR2( 14 CHAR )
      );
      
COMMENT ON COLUMN WATSON.SCHD_AREA.ACTIVATION_DT IS 'Date when this record starts being active in the system.  Use along with ACTIVE_FLAG';
COMMENT ON COLUMN WATSON.SCHD_AREA.ACTIVE_FLAG   IS 'Y/N flag indicating if record is currently active in system. Use along with ACTIVATION_DT';
COMMENT ON COLUMN WATSON.SCHD_AREA.INS_DT        IS 'Date/Time when record was initially created';
COMMENT ON COLUMN WATSON.SCHD_AREA.INS_USER      IS 'User who initially created record';
COMMENT ON COLUMN WATSON.SCHD_AREA.UPD_DT        IS 'Date/Time when record was last edited';
COMMENT ON COLUMN WATSON.SCHD_AREA.UPD_USER      IS 'User who last edited record';      

ALTER TABLE WATSON.SCHD_AREA ADD CONSTRAINT SCHD_AREA_C01 CHECK (ACTIVE_FLAG IN ('Y','N')) ENABLE;

CREATE OR REPLACE TRIGGER WATSON.BIU_SCHD_AREA
    BEFORE INSERT OR UPDATE
    ON WATSON.SCHD_AREA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
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
