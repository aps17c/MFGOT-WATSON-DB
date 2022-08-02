BEGIN
    FOR lrec_plt IN (SELECT *
                       FROM watson.locations)
    LOOP
        BEGIN
            DBMS_OUTPUT.put_line (
                   'Processing Plant: '
                || lrec_plt.plant_name
                || '-('
                || lrec_plt.plant_code
                || ')');
            watson.schd_pak.gen_sched (
                p_plant_code      => lrec_plt.plant_code
              , p_start_dt        => TRUNC (SYSDATE) + :p_days_out
              , p_end_dt          => TRUNC (SYSDATE) + :p_days_out + 14
              , p_setup_id        => NULL
              , p_break_id        => NULL
              , p_area_id         => NULL
              , p_shift_id        => NULL
              , p_team_id         => NULL
              , p_rotation_flag   => NULL
              , p_override_flag   => 'N');
        END;
    END LOOP;

    COMMIT;
END;
