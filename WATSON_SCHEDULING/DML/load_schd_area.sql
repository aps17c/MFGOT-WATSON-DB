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
