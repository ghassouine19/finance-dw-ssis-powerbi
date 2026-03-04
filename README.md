# Finance DW + SSIS + Power BI (Actual vs Budget)

End-to-end mini BI project using **SQL Server (DW)** + **SSIS (ETL)** + **Power BI (Reporting)**.

> Repo: `ghassouine19/finance-dw-ssis-powerbi`

---

## 1) Project Overview

This project builds a small **Finance Data Warehouse** (`FinanceDW`) and loads **General Ledger (GL)** data for:
- **ACTUAL** amounts
- **BUDGET** amounts

Then a Power BI report compares:
- Actual vs Budget
- Variance and Variance %

---

## 2) Tech Stack

- **SQL Server Express**: `SQLEXPRESS_BI`
- **SSIS** (Visual Studio / SSDT)
- **Power BI Desktop**
- **GitHub** for versioning

---

## 3) Repository Structure

```text
.
├─ ssis/                # SSIS solution / packages (ETL)
├─ sql/                 # SQL scripts (schemas + validation queries)
├─ ssas/                # (optional) SSAS model (currently empty/placeholder)
├─ data/                # (optional) source files / samples
└─ docs/                # documentation / screenshots (optional)
```

---

## 4) Data Warehouse Model (Star Schema)

### Dimensions
- `dw.dimDate` (DateKey, Year, Month, MonthName, Quarter, ...)
- `dw.dimCompany`
- `dw.dimCostCenter`
- `dw.dimGLAccount`

### Fact
- `dw.factGL`
  - Keys: DateKey, CompanyKey, CostCenterKey, AccountKey
  - Measures: Amount
  - Attributes: Scenario (`ACTUAL`, `BUDGET`)
  - Audit: LoadedAt

### Relationships (Power BI / DW)
- `dw.dimDate[DateKey]` → `dw.factGL[DateKey]`
- `dw.dimCompany[CompanyKey]` → `dw.factGL[CompanyKey]`
- `dw.dimCostCenter[CostCenterKey]` → `dw.factGL[CostCenterKey]`
- `dw.dimGLAccount[AccountKey]` → `dw.factGL[AccountKey]`

---

## 5) How to Run (Local)

### 5.1 Requirements
- SQL Server installed (Express is fine)
- Visual Studio + SSIS/SSDT installed
- Power BI Desktop installed

### 5.2 Create Schemas / Validate (SQL)
Open SSMS and run:
- `sql/01_schemas.sql`
- (After ETL) `sql/99_validation.sql`

> If your staging table names are different than in `99_validation.sql`, update the script accordingly.

### 5.3 Run SSIS ETL
1. Open the SSIS solution under `ssis/`
2. Update connection managers to match your environment:
   - SQL Server instance (example): `DESKTOP-GASS\SQLEXPRESS_BI`
   - Database: `FinanceDW`
3. Execute packages in this order:
   1. **Staging load** (raw → `stg.*`)
   2. **Load Dimensions** (`dw.dim*`)
   3. **Load Fact** (`dw.factGL`)

> Tip: if you have a master package, run the master package.

### 5.4 Build Power BI Report
1. Open Power BI Desktop
2. Connect to SQL Server:
   - Server: `DESKTOP-GASS\SQLEXPRESS_BI`
   - Database: `FinanceDW`
3. Import tables:
   - `dw.factGL`
   - `dw.dimDate`
   - `dw.dimCompany`
   - `dw.dimCostCenter`
   - `dw.dimGLAccount`

#### Recommended DAX Measures
```DAX
Total Amount = SUM('dw factGL'[Amount])

Actual Amount =
CALCULATE([Total Amount], 'dw factGL'[Scenario] = "ACTUAL")

Budget Amount =
CALCULATE([Total Amount], 'dw factGL'[Scenario] = "BUDGET")

Variance = [Actual Amount] - [Budget Amount]

Variance % = DIVIDE([Variance], [Budget Amount])
```

#### Recommended Date Columns (sorting)
If your date table does not have a full Date column, create:
```DAX
YearMonthSort = 'dw dimDate'[Year] * 100 + 'dw dimDate'[Month]

YearMonth =
FORMAT(DATE('dw dimDate'[Year], 'dw dimDate'[Month], 1), "yyyy-MM")
```

Then sort `YearMonth` by `YearMonthSort`.

---

## 6) Report Layout (1 page)

- KPI Cards:
  - Actual Amount
  - Budget Amount
  - Variance
  - Variance %
- Line Chart:
  - Axis: `YearMonth`
  - Values: `Total Amount`
  - Legend: `Scenario`
- Matrix:
  - Rows: Cost Center (and optionally GL Account)
  - Columns: Scenario
  - Values: Total Amount
- Slicer:
  - CompanyCode

---

## 7) Notes / Best Practices

- `.vs/`, `bin/`, `obj/` are excluded via `.gitignore`
- Git does not track empty folders: use `.gitkeep` if needed
- Power BI `.pbix` files can be large; consider Git LFS if needed

---

## 8) Next Improvements (Optional)
- Add ETL logging table (`dw.etl_audit`)
- Add data quality checks / reject tables
- Add incremental loads
- Add a screenshot of the star schema + report page in `docs/`

---

## License
Choose a license (MIT) if you want this repo to be publicly reusable.
