`.gitignore` is in place — the guardrail is set. (That `â€"` is just PowerShell mis-rendering the em-dash in the comment; harmless, ignore it.)

## Step 3 — Build the SQL scripts

Now the heart of the repo. We'll create **4 SQL files** in the `sql\` folder — the same pattern you ran live, but generic (Contoso/Fabrikam instead of Acme/Globex, no customer refs). You'll create each, and I'll explain what it teaches so the repo is self-documenting.

### File 1 — `sql\01-schema.sql`

Open it:
```powershell
code sql\01-schema.sql
```

Paste this, then **save**:
```sql
-- =====================================================================
-- Talk to Your Data — 01 Schema
-- Per-customer data model for a secure AI Q&A scenario.
-- The external user's identity (CustomerId) is carried into the DB
-- via SESSION_CONTEXT and enforced by Row-Level Security (see 02).
-- =====================================================================

IF SCHEMA_ID('app') IS NULL EXEC('CREATE SCHEMA app');
GO

CREATE TABLE app.Customers (
    CustomerId   NVARCHAR(128) NOT NULL PRIMARY KEY,   -- = the user identity claim
    DisplayName  NVARCHAR(200) NOT NULL,
    CreatedUtc   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE app.Accounts (
    AccountId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CustomerId   NVARCHAR(128) NOT NULL REFERENCES app.Customers(CustomerId),
    AccountName  NVARCHAR(200) NOT NULL,
    AccountType  NVARCHAR(50)  NOT NULL,
    Currency     CHAR(3)       NOT NULL DEFAULT 'USD'
);

CREATE TABLE app.Balances (
    BalanceId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountId    INT           NOT NULL REFERENCES app.Accounts(AccountId),
    CustomerId   NVARCHAR(128) NOT NULL REFERENCES app.Customers(CustomerId),  -- used by RLS
    AsOfDate     DATE          NOT NULL,
    Amount       DECIMAL(19,4) NOT NULL
);
GO
```

### Success check
```powershell
Get-ChildItem sql
```
Should list `01-schema.sql`.

---

**What changed from your live version (and why):** nothing structural — this is the same schema, just with neutral comments and no customer-specific naming. The key teaching comment is on `Balances.CustomerId`: *"used by RLS"* — signaling why we denormalize it onto the row (so the security predicate is simple and fast, as you learned).

Create and save `01-schema.sql`, confirm it's listed, and tell me — then I'll give you **File 2 (the RLS policy)**, the star of the repo, with the explanation comments that make it genuinely useful to strangers reading it.