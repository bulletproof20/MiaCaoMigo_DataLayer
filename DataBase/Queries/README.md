# Queries (reference SQL)

Ad-hoc `SELECT` and exploration scripts. **Not** loaded by Bootstrap and **not** part of CI.

Prefer the public API (`svc_*` in `Services/*/99_Public_API*`) for application integration. Use QA (`01_Integrity/`, `ci.ps1`) for automated rule validation.

## Layout

| Path | Status |
|------|--------|
| `01_Module1/01_Auth_Analysis.sql` | Reference — auth session inspection |
| `01_Module1/02_User_Analysis.sql` | Placeholder (reserved) |
| `01_Module1/03_Employee_Analysis.sql` | Reference |
| `01_Module1/04_Client_Analysis.sql` | Placeholder (reserved) |
| `01_Module1/05_Employee_Roles_Analysis.sql` | Reference |
| `02_Module2/01_Animal_Exploration.sql` | Reference — requires DemoData or equivalent |
| `03_Module3/queries_03Module.sql` | Deprecated banner — prefer `svc_*` / views |
| `04_Module4/07_Simple_Queries_4theAPI_Mod4.sql` | API-oriented samples |
| `04_Module4/Appointments/appointmentQueries.sql` | Appointment samples |

## Related

- Workflows: `QA/05_Manual/`
- Public API: `Services/README.md`
