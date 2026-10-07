-- =====================================================================
-- Talk to Your Data — 03 Seed data (two customers, so isolation is visible)
-- NOTE: because RLS BLOCK is active, we must "act as" each customer
-- (set SESSION_CONTEXT) before inserting that customer's rows.
-- This is exactly what Data API Builder does per request in production.
-- =====================================================================

INSERT INTO app.Customers (CustomerId, DisplayName) VALUES
    (N'cust-contoso',  N'Contoso Ltd'),
    (N'cust-fabrikam', N'Fabrikam Inc');
GO

-- ---- Act as Contoso, insert Contoso's data ----
EXEC sys.sp_set_session_context @key = N'userId', @value = N'cust-contoso';

INSERT INTO app.Accounts (CustomerId, AccountName, AccountType, Currency) VALUES
    (N'cust-contoso', N'Contoso Operating', N'Operating', 'USD'),
    (N'cust-contoso', N'Contoso Reserve',   N'Reserve',   'USD');

INSERT INTO app.Balances (AccountId, CustomerId, AsOfDate, Amount)
SELECT AccountId, CustomerId, '2026-01-01',
       CASE AccountName WHEN N'Contoso Operating' THEN 1250000.00
                        WHEN N'Contoso Reserve'   THEN 4800000.00 END
FROM app.Accounts WHERE CustomerId = N'cust-contoso';
GO

-- ---- Act as Fabrikam, insert Fabrikam's data ----
EXEC sys.sp_set_session_context @key = N'userId', @value = N'cust-fabrikam';

INSERT INTO app.Accounts (CustomerId, AccountName, AccountType, Currency) VALUES
    (N'cust-fabrikam', N'Fabrikam Operating',  N'Operating',  'USD'),
    (N'cust-fabrikam', N'Fabrikam Investment', N'Investment', 'USD');

INSERT INTO app.Balances (AccountId, CustomerId, AsOfDate, Amount)
SELECT AccountId, CustomerId, '2026-01-01',
       CASE AccountName WHEN N'Fabrikam Operating'  THEN 875000.00
                        WHEN N'Fabrikam Investment' THEN 9600000.00 END
FROM app.Accounts WHERE CustomerId = N'cust-fabrikam';
GO
