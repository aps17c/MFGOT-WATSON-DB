/* --------------------------------------------------------------------------- */
/* WatsonSchedulingDeployment.sql
 * ---------------------------------------------------------------------------
 * Initial deployment script to publish all required Oracle objects related to
 * the WATSON_SCHEDULING project (SCHD).  This script will also populate ALL
 * core lookup tables as well as the initial data population of the calendars.
 *
 * This script is built to allow for redeployments to same database.
 * All objects will be recreated and populated.  If any data is to be saved OFF
 * prior to re-deploying this code set, it must be done manually.
 *
 * ---------------------------------------------------------------------------
 */
WHENEVER SQLERROR EXIT;
-- set dir to your repository path for WATSON_SCHEDULING
define dir = C:\GitHub Repos\MFGOT-WATSON-DB-COMPONENTS\WATSON_SCHEDULING

WHENEVER SQLERROR CONTINUE;
-- core lookup tables
@&dir\tables\create_table_schd_shift.sql
@&dir\indexes\create_index_schd_shift_u01.sql
@&dir\Triggers\create_trigger_biu_schd_shift.sql
@&dir\DML\load_schd_shift.sql

@&dir\tables\create_table_schd_area.sql
@&dir\indexes\create_index_schd_area_u01.sql
@&dir\Triggers\create_trigger_biu_schd_area.sql
@&dir\DML\load_schd_area.sql

@&dir\tables\create_table_schd_team.sql
@&dir\indexes\create_index_schd_team_u01.sql
@&dir\Triggers\create_trigger_biu_schd_team.sql
@&dir\DML\load_schd_team.sql

-- required views
@&dir\views\create_view_v_schd_shift_xref.vw
@&dir\views\create_view_v_schd_shift_teams.vw

@&dir\tables\create_table_schd_cal_setup.sql
@&dir\triggers\create_trigger_biud_schd_cal_setup.trg
@&dir\indexes\create_index_schd_cal_setup_u01.sql

@&dir\tables\create_table_schd_cal_break_setup.sql
@&dir\triggers\create_trigger_biud_schd_cal_break_setup.trg
@&dir\indexes\create_index_schd_cal_break_setup_u01.sql

@&dir\tables\create_table_schd_cal_shift.sql
@&dir\triggers\create_trigger_biud_schd_cal_shift.trg
@&dir\indexes\create_index_schd_cal_shift_u01.sql

@&dir\tables\create_table_schd_cal_break.sql
@&dir\triggers\create_trigger_biud_schd_cal_break.trg
@&dir\indexes\create_index_schd_cal_break_u01.sql

@&dir\Packages\schd_pak.pks
@&dir\Packages\schd_pak.pkb

-- DMBS_JOBS
@dir\Jobs\job_gen_schd_cal.sql
-- Now load Calendars (to ensure all is good and right with the world. :-) )
@&dir\DML\load_schd_cal_shift.sql
@&dir\DML\load_schd_cal_break.sql
