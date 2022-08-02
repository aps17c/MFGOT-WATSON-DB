WHENEVER SQLERROR CONTINUE;

/* =======================================================
 * | SCHD_SHIFT
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

CREATE TABLE WATSON.SCHD_SHIFT
(
    PLANT_CODE      VARCHAR2( 3 CHAR )
  , SHIFT_ID        NUMBER GENERATED ALWAYS AS IDENTITY
  , SHIFT_TYPE      VARCHAR2( 10 CHAR )
  , SHIFT_NAME      VARCHAR2( 25 CHAR )
  , SHIFT_DESC      VARCHAR2( 100 CHAR )
  , SHIFT_COMMENT   VARCHAR2( 250 CHAR )
  , ASSOC_TABLE     VARCHAR2 ( 60 CHAR )
);

COMMENT ON TABLE WATSON.SCHD_SHIFT IS 'Houses all the SHIFT HEADER information for a site';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.PLANT_CODE IS 'MES Site Code.';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.SHIFT_TYPE IS 'Type of SHIFT this entry belongs';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.SHIFT_NAME IS 'Name of SHIFT';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.SHIFT_DESC IS 'Description of SHIFT_NAME';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.SHIFT_DESC IS 'COMMENT on SHIFT';
COMMENT ON COLUMN WATSON.SCHD_AREA.ASSOC_TABLE IS 'Which Table did data come from';


ALTER TABLE WATSON.SCHD_SHIFT
    ADD CONSTRAINT SCHD_SHIFT_PK PRIMARY KEY( PLANT_CODE, SHIFT_ID );

ALTER TABLE WATSON.SCHD_SHIFT
   ADD ( ACTIVATION_DT DATE DEFAULT SYSDATE
       , ACTIVE_FLAG   VARCHAR2( 1 CHAR ) DEFAULT 'Y'
       , INS_DT        DATE
       , INS_USER      VARCHAR2( 14 CHAR ) 
       , UPD_DT        DATE
       , UPD_USER      VARCHAR2( 14 CHAR )
      );
      
COMMENT ON COLUMN WATSON.SCHD_SHIFT.ACTIVATION_DT IS 'Date when this record starts being active in the system.  Use along with ACTIVE_FLAG';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.ACTIVE_FLAG   IS 'Y/N flag indicating if record is currently active in system. Use along with ACTIVATION_DT';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.INS_DT        IS 'Date/Time when record was initially created';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.INS_USER      IS 'User who initially created record';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.UPD_DT        IS 'Date/Time when record was last edited';
COMMENT ON COLUMN WATSON.SCHD_SHIFT.UPD_USER      IS 'User who last edited record';      

ALTER TABLE WATSON.SCHD_SHIFT
ADD CONSTRAINT SCHD_SHIFT_C01 CHECK (ACTIVE_FLAG IN ('Y','N')) ENABLE;


