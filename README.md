
## 📌 Hospital Management System 
[![CI](https://github.com/brian-labs/Hospital-System/actions/workflows/ci.yml/badge.svg)](https://github.com/brian-labs/Hospital-System/actions/workflows/ci.yml)

A Spring Boot backend for a hospital management system covering patient care, pharmacy, laboratory, billing and HR. The design priorities are data integrity, explicit transaction boundaries, and putting each business rule at the layer that can enforce it reliably.

## Status

- **Built:** relational design (38 tables) and ERD, versioned Flyway migrations, application foundation with a common exception hierarchy and API response types.
- **Designed, implementation in progress:** HR business rules in the service layer, payroll settlement, licence-expiry worker, role-based access control.
- **Planned:** REST API per module, integration test suite.

## Architecture

![Module map](docs/architecture/full.png)

Eight modules: Identity, Outpatient, Inpatient, Pharmacy, Laboratory, Finance, HR and System. The full schema is in the [ERD](docs/architecture/full.png).

Requests flow through three layers:

- **Controller:** request validation and DTO mapping only, no business logic.
- **Service:** owns the transaction boundary and the business rules.
- **Repository:** persistence and queries.

Failures use one exception hierarchy that is translated into a single, consistent API response shape, so clients never receive ad-hoc errors or stack traces.

## Data model and integrity

**Staff is the base table.** Every employee has a `Staff` row, and `Doctors` extends it with clinical details. This avoids storing one person in two unrelated places. Staff who never log in (security, cleaners) have no linked user account. The cost is an extra join for doctor queries; the gain is a single source of truth for employment, roster and payroll.

**Rule placement follows one test:** if a rule must hold for every caller and involves a single row, the database enforces it. If it depends on other rows or other modules, the service layer enforces it inside a transaction.

| Database (constraints)                               | Service layer (transactions)                      |
| ---------------------------------------------------- | ------------------------------------------------- |
| Valid staff types, unique employee numbers           | Leave overlap and leave balance                   |
| One roster entry per staff, shift and date           | No rostering during approved leave                |
| Leave end date not before start date                 | Block new appointments for expired licences       |
| Clock-out not before clock-in                        | Minimum ward staffing when publishing a roster    |
| One payroll run per month                            | Disable the login when staff are terminated       |
| Net pay = basic + allowances + overtime - deductions | Mark payroll Paid and record the expense together |

## Concurrency and consistency

Rules like leave overlap and leave balance are check-then-write, so two concurrent requests for the same person can both pass the check. The design serialises them: the service takes a row lock on the staff record inside the transaction, so competing requests for one person queue while other staff are unaffected. Unique constraints remain as the final backstop.

Marking a payroll run as Paid is one transaction that updates the run and creates the salaries expense in Finance. The status change is conditional (only a run that is still open can be marked Paid), so a retry or double click cannot record the expense twice. Paid runs are locked, and corrections go into the next run.

## Migrations

Schema changes are versioned Flyway migrations. They are forward-only: an applied migration is never edited, and fixes ship as a new version. Reference data such as shifts, leave types and departments is seeded through migrations, so every environment starts from the same state.

## Time-based rules

A scheduled job flags licences that expire within 60 days. It is safe to re-run because it only sets a flag, and it reads from an index on the expiry date. Doctors get a warning at 60 days and are blocked from new appointments at expiry.

## Security and audit

Each staff category maps to a system role under least privilege. Salary data is visible only to HR, Accountants and the staff member concerned. An audit log records important user actions.

## Testing approach

Integration tests run against a real PostgreSQL instance, so constraints, locking and migrations behave as they do in production. Each database rule has a deliberately failing insert (invalid staff type, duplicate employee number, wrong net pay, second payroll run in a month). Service rules get unit tests.

## Tech stack

Java, Spring Boot, PostgreSQL, Flyway

## Run locally

Requires a JDK and PostgreSQL.

```bash
createdb hospital
# set the database URL, user and password in the application configuration
# Flyway applies the migrations when the application starts
```

## Roadmap

- [x] Schema design and ERD
- [x] Flyway migrations
- [x] Exception hierarchy and API response types
- [ ] Domain services and REST API, module by module
- [ ] Authentication and role-based access control
- [ ] Licence-expiry job
- [ ] Integration test suite

## Author

Brian Muigai - [portfolio](https://brianmuigai.vercel.app) - [LinkedIn](https://www.linkedin.com/in/brian-muigai/)
