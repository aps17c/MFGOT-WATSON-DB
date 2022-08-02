/* ---------------------------------------------------------------------
 *     Purpose:  Use this script load tables for SCHD project.
 * -------------------------------------------------------------------*/

/* LOAD LEGACY DATA FOR SHIFT */

INSERT INTO WATSON.SCHD_SHIFT( PLANT_CODE
                             , SHIFT_TYPE
                             , SHIFT_NAME
                             , SHIFT_DESC
                             , ASSOC_TABLE )
    SELECT PLANT_CODE
         , 'LINE'
         , SHIFT_NAME
         , SHIFT_COMMENT
         , 'FILL_SHIFTS'
      FROM WATSON.FILL_SHIFTS@WATSONP.WORLD;

/* LOAD SCHD_TEAM DATA FROM LEGACY */

INSERT INTO WATSON.SCHD_TEAM( PLANT_CODE
                            , TEAM_TYPE
                            , TEAM_NAME
                            , TEAM_DESC )
    SELECT PLANT_CODE
         , 'DEFAULT'
         , 'DEFAULT'
         , 'Default TEAM'
      FROM watson.locations@WATSONP.WORLD;

/* LOAD SCHD_AREA FROM LEGACY TABLES */

INSERT INTO watson.schd_area( PLANT_CODE
                            , AREA_TYPE
                            , AREA_NAME
                            , AREA_DESC
                            , ASSOC_TABLE )
    SELECT L.PLANT_CODE
         , 'LINE'
         , L.LINE_NUMBER
         , L.DISPLAY_NAME
         , 'FILL_LINES'
      FROM WATSON.FILL_LINES@WATSONP.WORLD L;

INSERT INTO watson.schd_area( PLANT_CODE
                            , AREA_TYPE
                            , AREA_NAME
                            , AREA_DESC
                            , ASSOC_TABLE )
    SELECT P.PLANT_CODE
         , 'LINE'     AREA_TYPE
         , P.LINE_NUMBER
         , P.LINE_NUMBER
         , 'POWDER_LINES'
      FROM WATSON.POWDER_LINES@WATSONP.WORLD P
     WHERE NOT EXISTS
               (SELECT 1
                  FROM WATSON.SCHD_AREA S
                 WHERE S.PLANT_CODE = P.PLANT_CODE
                   AND S.AREA_TYPE = 'LINE'
                   AND S.AREA_NAME = P.LINE_NUMBER);

INSERT INTO watson.schd_area( PLANT_CODE
                            , AREA_TYPE
                            , AREA_NAME
                            , AREA_DESC
                            , ASSOC_TABLE )
    SELECT DISTINCT R.PLANT_CODE
                  , 'ROBOT'                      AREA_TYPE
                  , R.EQUIPMENT
                  , R.EQUIPMENT
                  , 'ROBOT_EQUIPMENT_STATUS'     ASSOC_TABLE
      FROM WATSON.ROBOT_EQUIPMENT_STATUS@WATSONP.WORLD R
     WHERE NOT EXISTS
               (SELECT 1
                  FROM WATSON.SCHD_AREA S
                 WHERE S.PLANT_CODE = R.PLANT_CODE
                   AND S.AREA_TYPE = 'ROBOT'
                   AND S.AREA_NAME = R.EQUIPMENT);

/* only commit in script */
COMMIT;