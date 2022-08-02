DROP SEQUENCE watson.schd_cal_break_seq;

CREATE SEQUENCE watson.schd_cal_break_seq INCREMENT BY 1
                                    START WITH 1
                                    NOMAXVALUE
                                    NOCYCLE;

GRANT SELECT ON watson.schd_cal_break_seq TO PUBLIC;
/