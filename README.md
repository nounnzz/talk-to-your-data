# Talk to Your Data - Secure Per-User AI Q&A over Azure SQL

Let external users ask an AI agent questions about **their own data** — and guarantee
each user only ever sees their own rows, enforced in the **database**, not the app or the
AI agent. Works even when your users are **not in Microsoft Entra ID**.

This is a small, runnable reference for a common pattern: a "talk to your data" AI
assistant over multi-tenant data (balances, orders, records) where **data isolation and
per-user audit are hard requirements** (e.g. financial services, healthcare).

## The problem this solves

Most Azure AI samples assume your users live in Entra ID. Many real apps don't — they use
their own identity store (e.g. ASP.NET Identity). So: how do you carry a non-Entra user's
identity all the way to the database, filter data per-user, and log it — **without trusting
the AI agent** (which could be jailbroken or bypassed)?

## How it works (the airport-badge analogy)

```mermaid
flowchart LR
    U["External user<br/>(your own identity store,<br/>not Entra)"]
    APP["Your app<br/>mints a SIGNED token<br/>claim: userId"]
    AG["AI Agent<br/>(just a messenger)"]
    DAB["Data API Builder<br/>1. validates signature<br/>2. sets SESSION_CONTEXT"]
    SQL[("Azure SQL<br/>Row-Level Security<br/>filters by userId")]
    AUD["Audit log<br/>who asked, when"]

    U -->|"'what's my balance?'"| APP
    APP -->|"carries JWT"| AG
    AG -->|"calls data + JWT"| DAB
    DAB -->|"sp_set_session_context"| SQL
    SQL -->|"ONLY this user's rows"| AG
    AG -->|"answer"| U
    SQL -.logs.-> AUD
