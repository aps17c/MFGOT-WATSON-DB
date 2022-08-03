CREATE OR REPLACE PACKAGE watson.schd_pak
AS
    /* ================================================================================================
     * PACKAGE........: SCHD_PAK
     *
     * PURPOSE........: Houses routines related to new scheduling logic
     *
     * AUTHOR.........: Andrew Scott
     *
     * REVISION HISTORY
     * ------------------------------------------------------------------------------------------------
     * DATE         WHO     DESCRIPTION
     * ------------------------------------------------------------------------------------------------
     * 07-06-2022   APS17C  Origional Source Code
     * 07-28-2022   APS17C  Added gen_sched()
     * ================================================================================================
     */

    /* package level global type for combining start/end dates */
    TYPE gtyp_shift IS RECORD
    (
        start_dt    DATE
      , end_dt      DATE
      , dur_sec     NUMBER (6)
    );

    TYPE gtyp_dhm IS RECORD
    (
        dow    NUMBER (1)
      , hod    NUMBER (2)
      , moh    NUMBER (2)
    );


    PROCEDURE set_logging (p_enable_disable_flag IN VARCHAR2:= 'Y');

    FUNCTION validate_nbr_range (p_value         IN NUMBER
                               , p_limit_start   IN NUMBER
                               , p_limit_end     IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_plt (p_plant_code IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION validate_dow (p_dow IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_hod (p_hod IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_moh (p_moh IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_som (p_som IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_setup_id (p_plant_code   IN VARCHAR2
                              , p_setup_id     IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_break_id (p_plant_code   IN VARCHAR2
                              , p_setup_id     IN NUMBER
                              , p_break_id     IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION validate_dhm (p_dhm IN gtyp_dhm)
        RETURN BOOLEAN;

    FUNCTION get_shift_dt (p_dow        IN NUMBER
                         , p_hod        IN NUMBER
                         , p_moh        IN NUMBER
                         , p_dur_secs   IN NUMBER
                         , p_cal_dt     IN DATE := SYSDATE)
        RETURN gtyp_shift;

    /* global function to return a date/time using cal_dt + HOD + MOH */
    FUNCTION get_dt (p_cal_dt IN DATE, p_hod IN NUMBER, p_moh IN NUMBER)
        RETURN DATE;

    PROCEDURE gen_sched (p_plant_code      IN VARCHAR2
                       , p_start_dt        IN DATE
                       , p_end_dt          IN DATE
                       , p_setup_id        IN NUMBER := NULL
                       , p_break_id        IN NUMBER := NULL
                       , p_area_id         IN NUMBER := NULL
                       , p_shift_id        IN NUMBER := NULL
                       , p_team_id         IN NUMBER := NULL
                       , p_rotation_flag   IN VARCHAR2 := NULL
                       , p_override_flag   IN VARCHAR2 := 'N');
END schd_pak;
/
