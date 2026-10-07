-- =====================================================================
-- Talk to Your Data — 02 Row-Level Security (the core control)
-- ---------------------------------------------------------------------
-- Enforcement lives in the DATABASE, not the app or the AI agent.
-- DAB sets SESSION_CONTEXT('userId') from the caller's validated token;
-- the predicate below reads it and filters every row automatically.
-- Even a direct/compromised caller only ever sees its own rows.
--
-- Docs:
--   RLS            https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security?view=sql-server-ver17
--   SESSION_CONTEXT https://learn.microsoft.com/en-us/sql/t-sql/functions/session-context-transact-sql?view=sql-server-ver17
-- =====================================================================

IF SCHEMA_ID('sec') IS NULL EXEC('CREATE SCHEMA sec');
GO

-- Predicate: returns a row only when the row's CustomerId matches the
-- userId placed in SESSION_CONTEXT by Data API Builder.
CREATE OR ALTER FUNCTION sec.fn_customer_predicate(@CustomerId NVARCHAR(128))
    RETURNS TABLE
    WITH SCHEMABINDING
AS
    RETURN
        SELECT 1 AS allowed
        WHERE @CustomerId = CAST(SESSION_CONTEXT(N'userId') AS NVARCHAR(128));
GO

-- Policy: FILTER hides rows on read; BLOCK stops cross-customer writes.
-- NOTE: security policies do NOT support CREATE OR ALTER — drop first.
IF OBJECT_ID('sec.CustomerIsolationPolicy') IS NOT NULL
    DROP SECURITY POLICY sec.CustomerIsolationPolicy;
GO

CREATE SECURITY POLICY sec.CustomerIsolationPolicy
    ADD FILTER PREDICATE sec.fn_customer_predicate(CustomerId) ON app.Accounts,
    ADD BLOCK  PREDICATE sec.fn_customer_predicate(CustomerId) ON app.Accounts AFTER INSERT,
    ADD FILTER PREDICATE sec.fn_customer_predicate(CustomerId) ON app.Balances,
    ADD BLOCK  PREDICATE sec.fn_customer_predicate(CustomerId) ON app.Balances AFTER INSERT
    WITH (STATE = ON);
GO
