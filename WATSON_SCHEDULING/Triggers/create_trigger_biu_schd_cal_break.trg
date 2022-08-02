CREATE OR REPLACE TRIGGER WATSON.BIU_SCHD_CAL_BREAK
    BEFORE INSERT OR UPDATE
    ON WATSON.SCHD_CAL_BREAK
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
DECLARE
    l_user VARCHAR2(32) := upper(sys_context( 'userenv', 'os_user' ));
    
BEGIN
    IF INSERTING
    THEN
        :NEW.SCHD_CAL_BREAK_ID := WATSON.SCHD_CAL_BREAK_SEQ.NEXTVAL();
        
        :NEW.INS_DT := SYSDATE;
        :NEW.INS_USER := nvl(:NEW.UPD_USER,l_user);
        
        :NEW.ACTIVE_FLAG := NVL(:NEW.ACTIVE_FLAG,'Y');
        
        /* WANT DATE/TIME, NOT TRUNCATED INCASE ACTIVATION IS TIME SENSITIVE */
        :NEW.ACTIVATION_DT := NVL(:NEW.ACTIVATION_DT, SYSDATE); 
    END IF;

    IF UPDATING
    THEN
        :NEW.UPD_DT := SYSDATE;
        :NEW.UPD_USER := nvl(:NEW.UPD_USER,l_user);
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        RAISE;
END; -- END TRIGGER    
/
