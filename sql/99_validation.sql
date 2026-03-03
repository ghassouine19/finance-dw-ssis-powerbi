/* Basic validation queries after running ETL */

-- Row counts
SELECT 'stg.gl_actuals' AS table_name, COUNT(*) AS row_count FROM stg.gl_actuals
UNION ALL
SELECT 'stg.gl_budget', COUNT(*) FROM stg.gl_budget
UNION ALL
SELECT 'dw.dimDate', COUNT(*) FROM dw.dimDate
UNION ALL
SELECT 'dw.dimCompany', COUNT(*) FROM dw.dimCompany
UNION ALL
SELECT 'dw.dimCostCenter', COUNT(*) FROM dw.dimCostCenter
UNION ALL
SELECT 'dw.dimGLAccount', COUNT(*) FROM dw.dimGLAccount
UNION ALL
SELECT 'dw.factGL', COUNT(*) FROM dw.factGL;

-- Fact totals by scenario (expects Scenario values like ACTUAL/BUDGET)
SELECT Scenario, SUM(Amount) AS total_amount
FROM dw.factGL
GROUP BY Scenario
ORDER BY Scenario;

-- Check for orphan keys (should return 0 rows)
SELECT TOP 50 f.*
FROM dw.factGL f
LEFT JOIN dw.dimDate d       ON d.DateKey = f.DateKey
LEFT JOIN dw.dimCompany c    ON c.CompanyKey = f.CompanyKey
LEFT JOIN dw.dimCostCenter cc ON cc.CostCenterKey = f.CostCenterKey
LEFT JOIN dw.dimGLAccount a  ON a.AccountKey = f.AccountKey
WHERE d.DateKey IS NULL
   OR c.CompanyKey IS NULL
   OR cc.CostCenterKey IS NULL
   OR a.AccountKey IS NULL;