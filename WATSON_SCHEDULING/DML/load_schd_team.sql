
INSERT INTO WATSON.SCHD_TEAM( PLANT_CODE
                            , TEAM_TYPE
                            , TEAM_NAME
                            , TEAM_DESC )
    SELECT PLANT_CODE
         , 'DEFAULT'
         , 'DEFAULT'
         , 'Default TEAM'
      FROM watson.locations@WATSONP.WORLD;
