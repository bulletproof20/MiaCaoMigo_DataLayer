# Database migrations

Incremental scripts for databases **already** provisioned via Bootstrap.

Fresh environments receive the same rules from `Schema/` (tables + indexes) and `Services/`.

## Apply

```bash
psql -U <user> -d <database> -f DataBase/Migrations/01_Module1/001_employee_ema_emp_active_uniqueness.sql
psql -U <user> -d <database> -f DataBase/Services/01_Module1/00_Core_Mod1/01_Identity.sql
psql -U <user> -d <database> -f DataBase/Services/01_Module1/00_Core_Mod1/02_Validations.sql
```

## Module 1

| File | Description |
|------|-------------|
| `01_Module1/001_employee_ema_emp_active_uniqueness.sql` | Replace `uq_ema_emp` with partial unique index on active rows |
