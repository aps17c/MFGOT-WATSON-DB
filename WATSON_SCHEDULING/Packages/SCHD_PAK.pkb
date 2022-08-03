CREATE OR REPLACE PACKAGE BODY watson.schd_pak
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
     * ================================================================================================
     */

    ex_bad_plt                     EXCEPTION;
    ex_bad_plt_nbr        CONSTANT NUMBER := -20001;
    PRAGMA EXCEPTION_INIT (ex_bad_plt, -20001);

    ex_bad_mth                     EXCEPTION;
    ex_bad_mth_nbr        CONSTANT NUMBER := -20002;
    PRAGMA EXCEPTION_INIT (ex_bad_mth, -20002);

    ex_bad_dow                     EXCEPTION;
    ex_bad_dow_nbr        CONSTANT NUMBER := -20003;
    PRAGMA EXCEPTION_INIT (ex_bad_dow, -20003);

    ex_bad_hod                     EXCEPTION;
    ex_bad_hod_nbr        CONSTANT NUMBER := -20004;
    PRAGMA EXCEPTION_INIT (ex_bad_hod, -20004);

    ex_bad_moh                     EXCEPTION;
    ex_bad_moh_nbr        CONSTANT NUMBER := -20005;
    PRAGMA EXCEPTION_INIT (ex_bad_moh, -20005);

    ex_bad_date                    EXCEPTION;
    ex_bad_date_nbr       CONSTANT NUMBER := -20006;
    PRAGMA EXCEPTION_INIT (ex_bad_date, -20006);

    ex_bad_setup_id                EXCEPTION;
    ex_bad_setup_id_nbr   CONSTANT NUMBER := -20007;
    PRAGMA EXCEPTION_INIT (ex_bad_setup_id, -20007);

    ex_bad_break_id                EXCEPTION;
    ex_bad_break_id_nbr   CONSTANT NUMBER := -20008;
    PRAGMA EXCEPTION_INIT (ex_bad_break_id, -20008);

    ex_bad_area_id                 EXCEPTION;
    ex_bad_area_id_nbr    CONSTANT NUMBER := -20009;
    PRAGMA EXCEPTION_INIT (ex_bad_area_id, -20009);

    ex_bad_shift_id                EXCEPTION;
    ex_bad_shift_id_nbr   CONSTANT NUMBER := -20010;
    PRAGMA EXCEPTION_INIT (ex_bad_shift_id, -20010);

    ex_bad_team_id                 EXCEPTION;
    ex_bad_team_id_nbr    CONSTANT NUMBER := -20011;
    PRAGMA EXCEPTION_INIT (ex_bad_team_id, -20011);

    m_logging_enabled              BOOLEAN := TRUE;

    PROCEDURE set_logging (p_enable_disable_flag IN VARCHAR2:= 'Y')
    IS
    BEGIN
        m_logging_enabled :=
            TRIM (UPPER (SUBSTR (p_enable_disable_flag, 1, 1))) IN ('Y', 'E');
    END set_logging;


    PROCEDURE LOG (p_msg IN VARCHAR2)
    IS
    BEGIN
        IF m_logging_enabled
        THEN
            DBMS_OUTPUT.put_line (p_msg);
        END IF;
    END LOG;

    FUNCTION validate_nbr_range (p_value         IN NUMBER
                               , p_limit_start   IN NUMBER
                               , p_limit_end     IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN (p_value BETWEEN p_limit_start AND p_limit_end);
    END validate_nbr_range;

    FUNCTION validate_dow (p_dow IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN validate_nbr_range (p_dow, 1, 7);
    END validate_dow;                                           -- DAY OF WEEK

    FUNCTION validate_hod (p_hod IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN validate_nbr_range (p_hod, 0, 23);
    END validate_hod;                                           -- HOUR OF DAY

    FUNCTION validate_moh (p_moh IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN validate_nbr_range (p_moh, 0, 59);
    END validate_moh;                                        -- MINUTE OF HOUR

    FUNCTION validate_som (p_som IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN validate_nbr_range (p_som, 0, 59);
    END validate_som;                                      -- SECOND OF MINUTE

    FUNCTION validate_dhm (p_dhm IN gtyp_dhm)
        RETURN BOOLEAN
    IS
        lb_ret   BOOLEAN := FALSE;
    BEGIN
        IF validate_dow (p_dhm.dow)
        THEN
            IF validate_hod (p_dhm.hod)
            THEN
                IF validate_moh (p_dhm.moh)
                THEN
                    lb_ret := TRUE;
                END IF;
            END IF;
        END IF;

        RETURN lb_ret;
    END validate_dhm;

    FUNCTION get_dt (p_cal_dt IN DATE, p_hod IN NUMBER, p_moh IN NUMBER)
        RETURN DATE
    AS
        /* ---------------------------------------------------------------------
         *     Purpose: Return a date/time based on params
         *
         *  Parameters: p_cal_dt => Calendar Date (Date)
         *              p_hod    => Hour of Day (number)
         *              p_moh    => Minute of Hour (number)
         *
         *     Returns: Date/Time
         *
         *       Notes: Converts generic hour/min of a shift time into an actual
         *              date/time.
         * -------------------------------------------------------------------*/
        ldt   DATE;
    BEGIN
        IF NOT (validate_hod (p_hod)) OR NOT (validate_moh (p_moh))
        THEN
            raise_application_error (-20009, 'Invalidate Hour/Min supplied');
        END IF;

        IF p_hod IS NULL OR p_moh IS NULL
        THEN
            RETURN NULL;
        END IF;

        ldt :=
            TO_DATE (
                   TO_CHAR (TRUNC (p_cal_dt), 'MM/DD/YYYY')
                || ' '
                || TRIM (TO_CHAR (p_hod, '00'))
                || ':'
                || TRIM (TO_CHAR (p_moh, '00'))
                || ':00'
              , 'MM/DD/YYYY HH24:MI:SS');
        RETURN ldt;
    END get_dt;

    FUNCTION get_shift_dt (p_dow        IN NUMBER
                         , p_hod        IN NUMBER
                         , p_moh        IN NUMBER
                         , p_dur_secs   IN NUMBER
                         , p_cal_dt     IN DATE := SYSDATE)
        RETURN gtyp_shift
    AS
        /* ---------------------------------------------------------------------
         *     Purpose: Returns gtyp_shift structure of dates
         *
         *  Parameters: p_dow      => Day of Week (number, 0 - 6 )
         *              p_hod      => Hour of Day (number, 0-23 )
         *              p_moh      => Minute of Hour (number, 0-59 )
         *              p_dur_secs => Duration in Seconds
         *              p_cal_dt   => Date to use as anchor for calculation
         *
         *     Returns: gtyp_shifts structure (start_dt, end_dt)
         *
         *       Notes:
         * -------------------------------------------------------------------*/
        ltyp_shift   gtyp_shift;
        l_dow        NUMBER := p_dow;
    BEGIN
        /* VALIDATE DOW.  if not valid then use sysdate DOW */
        IF NOT validate_dow (l_dow)
        THEN
            l_dow := TO_NUMBER (TO_CHAR (SYSDATE, 'D'));
        END IF;

        ltyp_shift.start_dt :=
            get_dt (TRUNC (p_cal_dt, 'W') + l_dow, p_hod, p_moh);
        ltyp_shift.end_dt :=
            ltyp_shift.start_dt + (p_dur_secs / 60 / 60 / 24);

        RETURN ltyp_shift;
    END get_shift_dt;

    FUNCTION validate_plt (p_plant_code IN VARCHAR2)
        RETURN BOOLEAN
    AS
        ln_cnt   PLS_INTEGER;
    BEGIN
        SELECT COUNT (1)
          INTO ln_cnt
          FROM watson.locations l
         WHERE l.plant_code = p_plant_code;

        RETURN (ln_cnt > 0);
    END validate_plt;

    FUNCTION validate_setup_id (p_plant_code   IN VARCHAR2
                              , p_setup_id     IN NUMBER)
        RETURN BOOLEAN
    AS
        ln_cnt   PLS_INTEGER;
    BEGIN
        SELECT COUNT (1)
          INTO ln_cnt
          FROM watson.schd_cal_setup l
         WHERE l.plant_code = p_plant_code
           AND l.schd_cal_setup_id = p_setup_id;

        RETURN (ln_cnt > 0);
    END validate_setup_id;

    FUNCTION validate_break_id (p_plant_code   IN VARCHAR2
                              , p_setup_id     IN NUMBER
                              , p_break_id     IN NUMBER)
        RETURN BOOLEAN
    AS
        ln_cnt   PLS_INTEGER;
    BEGIN
        SELECT COUNT (1)
          INTO ln_cnt
          FROM watson.schd_cal_break_setup l
         WHERE l.plant_code = p_plant_code
           AND l.schd_cal_setup_id = p_setup_id
           AND l.schd_cal_break_setup_id = p_break_id;

        RETURN (ln_cnt > 0);
    END validate_break_id;

    PROCEDURE gen_sched (p_plant_code      IN VARCHAR2
                       , p_start_dt        IN DATE
                       , p_end_dt          IN DATE
                       , p_setup_id        IN NUMBER := NULL
                       , p_break_id        IN NUMBER := NULL
                       , p_area_id         IN NUMBER := NULL
                       , p_shift_id        IN NUMBER := NULL
                       , p_team_id         IN NUMBER := NULL
                       , p_rotation_flag   IN VARCHAR2 := NULL
                       , p_override_flag   IN VARCHAR2 := 'N')
    AS
        /* --------------------------------------------------------------- */
        /* | ROUTINE:   gen_sched                                          */
        /* |                                                               */
        /* | PURPOSE:   To generate a schedule entry based on the params   */
        /* |                                                               */
        /* | PARAMS :   p_plant_code   => MES Site code                    */
        /* |            p_start_cal_dt => First DT in generated sched entry*/
        /* |            p_end_cal_dt   => Last DT in generated sched entry */
        /* |            p_setup_id     => (optional) ID of cal_setup entry */
        /* |            p_break_id     => (optional) ID of cal_break entry */
        /* |            p_area_id      => (optional) ID of area            */
        /* |            p_shift_id     => (optional) ID of shift           */
        /* |            p_team_id      => (optional) ID of team            */
        /* |            p_override_flag=> (default N) Y/N flag to over-    */
        /* |                               write existing generated sched  */
        /* |                               entries                         */
        /* |                                                               */
        /* | RETURNS:   Nothing                                            */
        /* |                                                               */
        /* | NOTES..:   Routine will exit normally if all is good.         */
        /* |            Exception will be thrown upon any significant err  */
        /* |                                                               */
        /* --------------------------------------------------------------- */

        lb_valid       BOOLEAN;
        ln_cnt_shift   PLS_INTEGER;
        ln_cnt_break   PLS_INTEGER;
    BEGIN
        lb_valid := FALSE;

        IF NOT (validate_plt (p_plant_code))
        THEN
            RAISE ex_bad_plt;
        END IF;

        IF TRUNC (p_start_dt) <= TRUNC (SYSDATE)
        THEN
            raise_application_error (ex_bad_date_nbr
                                   , 'Start MUST > Today''s Date');
        END IF;

        IF TRUNC (p_start_dt) > TRUNC (p_end_dt)
        THEN
            raise_application_error (ex_bad_date_nbr
                                   , 'Start Date MUST <= End Date');
        END IF;


        IF TRUNC (p_end_dt) <= TRUNC (p_start_dt)
        THEN
            raise_application_error (ex_bad_date_nbr
                                   , 'Start MUST > START Date');
        END IF;

        IF TRUNC (p_end_dt) > TRUNC (p_start_dt) + 30
        THEN
            raise_application_error (
                ex_bad_date_nbr
              , 'Start cannot be > START Date + 30 Days');
        END IF;

        IF p_setup_id IS NOT NULL
        THEN
            IF NOT (validate_setup_id (p_plant_code, p_setup_id))
            THEN
                raise_application_error (
                    ex_bad_setup_id_nbr
                  ,    'Invalid SetupID ['
                    || TO_CHAR (p_setup_id)
                    || ' specified for site ['
                    || p_plant_code
                    || ']');
            END IF;
        END IF;

        IF p_break_id IS NOT NULL
        THEN
            IF NOT (validate_break_id (p_plant_code, p_setup_id, p_setup_id))
            THEN
                raise_application_error (
                    ex_bad_break_id_nbr
                  ,    'Invalid BreakID ['
                    || TO_CHAR (p_break_id)
                    || ' specified for SetUp ID ['
                    || TO_CHAR (p_setup_id)
                    || '] / site ['
                    || p_plant_code
                    || ']');
            END IF;
        END IF;

        -- if we have gotten here, all items are valid and OK to proceed.
        -- load shift calendar entries first.
        DELETE FROM
            watson.schd_cal_shift
              WHERE plant_code = p_plant_code
                AND start_dt BETWEEN TRUNC (p_start_dt) AND TRUNC (p_end_dt)
                AND area_id = NVL (p_area_id, area_id)
                AND shift_id = NVL (p_shift_id, shift_id)
                AND team_id = NVL (p_team_id, team_id)
                AND break_type = 0
                AND ((p_override_flag = 'N' AND edited_flag != 'Y')
                  OR (p_override_flag = 'Y'))
                AND TRUNC (p_start_dt) > SYSDATE;

        LOG (SQL%ROWCOUNT || ' Rows Deleted from SCHD_CAL_SHIFT table');

        DELETE FROM
            watson.schd_cal_break
              WHERE plant_code = p_plant_code
                AND start_dt BETWEEN TRUNC (p_start_dt) AND TRUNC (p_end_dt)
                AND area_id = NVL (p_area_id, area_id)
                AND shift_id = NVL (p_shift_id, shift_id)
                AND team_id = NVL (p_team_id, team_id)
                AND break_type = 1
                AND ((p_override_flag = 'N' AND edited_flag != 'Y')
                  OR (p_override_flag = 'Y'))
                AND TRUNC (p_start_dt) > SYSDATE;

        LOG (SQL%ROWCOUNT || ' Rows Deleted from SCHD_CAL_BREAK table');

        ln_cnt_shift := 0;
        ln_cnt_break := 0;

        FOR lrec_ins
            IN (  SELECT plant_code
                       , schd_cal_setup_id
                       , schd_cal_break_setup_id
                       , break_type
                       , area_id
                       , area_name
                       , shift_id
                       , shift_name
                       , team_id
                       , team_name
                       , next_start_dt                                   start_dt
                       , TO_NUMBER (TO_CHAR (next_start_dt, 'D')) - 1    start_dow
                       , start_hod
                       , start_moh
                       , next_end_dt                                     end_dt
                       , TO_NUMBER (TO_CHAR (next_end_dt, 'D')) - 1      end_dow
                       , end_hod
                       , end_moh
                       , ROUND ((next_end_dt - next_start_dt) * 24 * 60 * 60
                              , 0)                                       dur_secs
                       , rotation_day
                       , rotation_days
                       , rotation_flag
                       , 'N'                                             edited_flag
                       , 'Y'                                             active_flag
                       , SYSDATE                                         activation_dt
                   FROM (SELECT s.*
                              ,   MOD (
                                        TRUNC (d.range_start_dt)
                                      - TRUNC (start_dt)
                                    , rotation_days)
                                - 1                            calc_start_dow
                              ,   TRUNC (d.range_start_dt)
                                + MOD (
                                        TRUNC (d.range_start_dt)
                                      - TRUNC (start_dt)
                                    , rotation_days)
                                + start_hod / 24
                                + start_moh / 24 / 60          next_start_dt
                              ,   (  TRUNC (d.range_start_dt)
                                   + MOD (
                                           TRUNC (d.range_start_dt)
                                         - TRUNC (start_dt)
                                       , rotation_days)
                                   + start_hod / 24
                                   + start_moh / 24 / 60)
                                + (dur_secs / 24 / 60 / 60)    next_end_dt
                              , d.range_start_dt
                              , d.range_end_dt
                           FROM watson.v_schd_cal_setup s
                              , (SELECT TRUNC (p_start_dt) - 1    range_start_dt
                                      , TRUNC (p_end_dt) + 1      range_end_dt
                                   FROM DUAL) d
                          WHERE 1 = 1
                            AND plant_code = p_plant_code
                            AND area_id BETWEEN NVL (p_area_id, 0)
                                            AND NVL (p_area_id, 9999999)
                            AND shift_id BETWEEN NVL (p_shift_id, 0)
                                             AND NVL (p_shift_id, 9999999)
                            AND NVL (schd_cal_setup_id, 0) BETWEEN NVL (
                                                                       p_setup_id
                                                                     , 0)
                                                               AND NVL (
                                                                       p_setup_id
                                                                     , 99999999)
                            AND NVL (schd_cal_break_setup_id, 0) BETWEEN NVL (
                                                                             p_break_id
                                                                           , 0)
                                                                     AND NVL (
                                                                             p_break_id
                                                                           , 99999999)
                            AND rotation_flag LIKE NVL (p_rotation_flag, '%')
                            AND activation_dt <= SYSDATE
                            AND active_flag = 'Y')
                  WHERE next_start_dt BETWEEN range_start_dt AND range_end_dt
                    AND next_end_dt BETWEEN range_start_dt + 1
                                        AND range_end_dt + 1
                    AND break_type IN (0, 1)
               ORDER BY plant_code
                      , area_name
                      , next_start_dt
                      , calc_start_dow
                      , break_type
                      , next_end_dt)
        LOOP
            BEGIN
                CASE
                    WHEN lrec_ins.break_type = 0
                    THEN
                        INSERT INTO watson.schd_cal_shift (
                                        schd_cal_setup_id
                                      , schd_cal_break_setup_id
                                      , break_type
                                      , plant_code
                                      , area_id
                                      , area_name
                                      , shift_id
                                      , shift_name
                                      , team_id
                                      , team_name
                                      , start_dt
                                      , start_dow
                                      , start_hod
                                      , start_moh
                                      , end_dt
                                      , end_dow
                                      , end_hod
                                      , end_moh
                                      , dur_secs
                                      , rotation_day
                                      , rotation_days
                                      , rotation_flag
                                      , edited_flag
                                      , activation_dt
                                      , active_flag)
                             VALUES (lrec_ins.schd_cal_setup_id
                                   , lrec_ins.schd_cal_break_setup_id
                                   , lrec_ins.break_type
                                   , lrec_ins.plant_code
                                   , lrec_ins.area_id
                                   , lrec_ins.area_name
                                   , lrec_ins.shift_id
                                   , lrec_ins.shift_name
                                   , lrec_ins.team_id
                                   , lrec_ins.team_name
                                   , lrec_ins.start_dt
                                   , lrec_ins.start_dow
                                   , lrec_ins.start_hod
                                   , lrec_ins.start_moh
                                   , lrec_ins.end_dt
                                   , lrec_ins.end_dow
                                   , lrec_ins.end_hod
                                   , lrec_ins.end_moh
                                   , lrec_ins.dur_secs
                                   , lrec_ins.rotation_day
                                   , lrec_ins.rotation_days
                                   , lrec_ins.rotation_flag
                                   , lrec_ins.edited_flag
                                   , lrec_ins.activation_dt
                                   , lrec_ins.active_flag);

                        ln_cnt_shift := ln_cnt_shift + 1;
                    WHEN lrec_ins.break_type = 1
                    THEN
                        INSERT INTO watson.schd_cal_break (
                                        schd_cal_setup_id
                                      , schd_cal_break_setup_id
                                      , break_type
                                      , plant_code
                                      , area_id
                                      , area_name
                                      , shift_id
                                      , shift_name
                                      , team_id
                                      , team_name
                                      , start_dt
                                      , start_dow
                                      , start_hod
                                      , start_moh
                                      , end_dt
                                      , end_dow
                                      , end_hod
                                      , end_moh
                                      , dur_secs
                                      , rotation_day
                                      , rotation_days
                                      , rotation_flag
                                      , edited_flag
                                      , activation_dt
                                      , active_flag)
                             VALUES (lrec_ins.schd_cal_setup_id
                                   , lrec_ins.schd_cal_break_setup_id
                                   , lrec_ins.break_type
                                   , lrec_ins.plant_code
                                   , lrec_ins.area_id
                                   , lrec_ins.area_name
                                   , lrec_ins.shift_id
                                   , lrec_ins.shift_name
                                   , lrec_ins.team_id
                                   , lrec_ins.team_name
                                   , lrec_ins.start_dt
                                   , lrec_ins.start_dow
                                   , lrec_ins.start_hod
                                   , lrec_ins.start_moh
                                   , lrec_ins.end_dt
                                   , lrec_ins.end_dow
                                   , lrec_ins.end_hod
                                   , lrec_ins.end_moh
                                   , lrec_ins.dur_secs
                                   , lrec_ins.rotation_day
                                   , lrec_ins.rotation_days
                                   , lrec_ins.rotation_flag
                                   , lrec_ins.edited_flag
                                   , lrec_ins.activation_dt
                                   , lrec_ins.active_flag);

                        ln_cnt_break := ln_cnt_break + 1;
                    ELSE
                        NULL;
                END CASE;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX
                THEN
                    NULL;                                            -- IGNORE
                WHEN OTHERS
                THEN
                    LOG (SQLERRM);
                    RAISE;
            END;
        END LOOP;

        LOG (ln_cnt_shift || ' Rows Added to SCHD_CAL_SHIFT table');
        LOG (ln_cnt_break || ' Rows Added to SCHD_CAL_BREAK table');

        COMMIT;
    EXCEPTION
        WHEN ex_bad_plt
        THEN
            raise_application_error (
                ex_bad_plt_nbr
              ,    $$plsql_unit
                || '::Invalid site ['
                || p_plant_code
                || '] supplied.');
        WHEN ex_bad_date
        THEN
            raise_application_error (ex_bad_date_nbr
                                   , $$pls_unit || '::' || SQLERRM);
        WHEN OTHERS
        THEN
            RAISE;
    END gen_sched;

    PROCEDURE gen_schd (p_plant_code   IN VARCHAR2 := NULL
                      , p_start_dt     IN DATE := TRUNC (SYSDATE) + 7
                      , p_days_out     IN NUMBER := 1)
    AS
    BEGIN
        set_logging ('Y');

        LOG (
               'Processing Date Range: '
            || TO_CHAR (TRUNC (p_start_dt), 'MM/DD/YYYY')
            || ' thru '
            || TO_CHAR (TRUNC (p_start_dt) + p_days_out, 'mm/dd/yyyy'));

        LOG ('---------------------------------');

        FOR lrec_plt
            IN (SELECT *
                 FROM watson.locations
                WHERE plant_code LIKE TRIM (UPPER (NVL (p_plant_code, '%'))))
        LOOP
            BEGIN
                LOG (
                       'Processing Plant: '
                    || lrec_plt.plant_name
                    || '-('
                    || lrec_plt.plant_code
                    || ')');
                gen_sched (p_plant_code      => lrec_plt.plant_code
                         , p_start_dt        => TRUNC (p_start_dt)
                         , p_end_dt          => TRUNC (p_start_dt) + p_days_out
                         , p_setup_id        => NULL
                         , p_break_id        => NULL
                         , p_area_id         => NULL
                         , p_shift_id        => NULL
                         , p_team_id         => NULL
                         , p_rotation_flag   => NULL
                         , p_override_flag   => 'N');
            END;

            LOG ('---------------------------------');
        END LOOP;
    END gen_schd;
END schd_pak;
/
