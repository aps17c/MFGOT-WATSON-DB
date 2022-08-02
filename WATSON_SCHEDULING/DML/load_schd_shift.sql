
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