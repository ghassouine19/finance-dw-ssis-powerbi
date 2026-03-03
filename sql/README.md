# SQL Scripts

- `01_schemas.sql`: creates schemas `stg` and `dw` if missing.
- `99_validation.sql`: validation queries to run after SSIS ETL (row counts, totals, orphan keys).

> Note: table names assumed:
> - stg.gl_actuals
> - stg.gl_budget
> - dw.dimDate, dw.dimCompany, dw.dimCostCenter, dw.dimGLAccount
> - dw.factGL
>
> If your table names differ, update `99_validation.sql`.