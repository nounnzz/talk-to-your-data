## File 4 — `sql\04-demo.sql` (the proof)

```powershell
code sql\04-demo.sql
```
Paste, **save**:
```sql
-- =====================================================================
-- Talk to Your Data — 04 Demo: prove per-user isolation
-- Run each block. The ONLY thing that changes is the userId.
-- No WHERE clause on CustomerId — RLS does the filtering.
-- =====================================================================

-- Act as Contoso
EXEC sys.sp_set_session_context @key = N'userId', @value = N'cust-contoso';
SELECT AccountName, AccountType FROM app.Accounts;
SELECT SUM(Amount) AS TotalCash FROM app.Balances;   -- expect 6,050,000.00
GO

-- Act as Fabrikam — same query, different identity
EXEC sys.sp_set_session_context @key = N'userId', @value = N'cust-fabrikam';
SELECT AccountName, AccountType FROM app.Accounts;
SELECT SUM(Amount) AS TotalCash FROM app.Balances;   -- expect 10,475,000.00
GO

-- Try to cheat: ask for Contoso's data while acting as Fabrikam
EXEC sys.sp_set_session_context @key = N'userId', @value = N'cust-fabrikam';
SELECT * FROM app.Balances WHERE CustomerId = N'cust-contoso';   -- expect 0 rows
GO

-- Fail-closed: no identity at all
EXEC sys.sp_set_session_context @key = N'userId', @value = NULL;
SELECT COUNT(*) AS RowsVisible FROM app.Balances;   -- expect 0
GO
```

### Success check
```powershell
Get-ChildItem sql
```
Should list all **four**: `01-schema`, `02-rls-policy`, `03-seed`, `04-demo`.

---

Note I generalized the identities to **Contoso/Fabrikam** (Microsoft's standard sample names) — clean for a public repo, zero customer trace. The expected results are in comments, so anyone can verify they ran it right.

Create both files, confirm all four are listed, and say go — then **Step 4**: the sanitized `dab-config.sample.json` + `.env.example`, and then the **README with the diagram** (the centerpiece).