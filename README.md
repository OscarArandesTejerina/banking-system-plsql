# Banking System (Oracle SQL & PL/SQL)

A small relational banking system built in Oracle SQL and PL/SQL. It covers the full flow of a simple bank: creating customers and accounts, and handling deposits, withdrawals, and transfers between accounts, with balance integrity, overdraft protection, and authorization checks enforced at the database level through triggers, functions, and stored procedures.

## Overview

The system is built entirely inside the database. Business rules are enforced by triggers and procedures rather than application code, so the data stays consistent regardless of how it is accessed. It follows an **action-modeling** approach: the operations to withdraw, deposit, and transfer money are each represented by their own dedicated table.

## Tables

| Table | Purpose |
|-------|---------|
| `customer` | Bank customers, identified by a personal ID number, with login password |
| `account_type` | Account categories and their current interest rate |
| `interest_change` | History of interest-rate changes per account type |
| `account` | Individual accounts with balance and creation date |
| `account_owner` | Links customers to the accounts they own (many-to-many) |
| `deposition` | Deposit transactions |
| `withdrawal` | Withdrawal transactions |
| `transfer` | Transfers between two accounts |

## Features

- **Password validation** – a trigger ensures every password is exactly six characters before insert or update.
- **Automatic primary keys** – a shared sequence (`pk_seq`) supplies key values through per-table triggers.
- **Authentication** – the `log_in` function validates a customer's ID and password.
- **Authorization** – the `get_authority` function checks whether a customer may operate on a given account; used by both withdrawals and transfers.
- **Balance integrity** – triggers automatically update account balances after every deposit, withdrawal, and transfer.
- **Overdraft protection** – triggers block any withdrawal or transfer that exceeds the available balance.
- **Stored procedures** – `do_new_customer`, `do_deposition`, `do_withdrawal`, and `do_transfer` provide a clean interface for the main operations.

## Setup

Run the scripts in order:

1. `01_create_tables.sql` – tables and constraints
2. `02_triggers_pk.sql` – sequence and primary-key triggers
3. `03_functions.sql` – `log_in`, `get_balance`, `get_authority`
4. `04_triggers_business.sql` – balance and overdraft triggers
5. `05_procedures.sql` – stored procedures
6. `06_seed_data.sql` – sample customers, account types, accounts, and owners

> **Note:** the order matters — functions must exist before the triggers and procedures that call them.

## Testing

The `tests/` folder contains scripts that exercise the system: a login test, an overdraft attempt, an unauthorized-access attempt, and successful deposits, withdrawals, and transfers, each followed by a balance check to confirm the result.

## Repository Contents

```
banking-system-plsql/
├── README.md
├── bankingsystem.sql     # Full script: tables, triggers, functions, procedures, and test cases
└── walkthrough.pdf        # Step-by-step walkthrough of the system's design and implementation   

```

## Tech

Oracle Database · SQL (DDL & DML) · PL/SQL (triggers, functions, stored procedures)
