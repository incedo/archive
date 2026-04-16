# Scaleway Stories - Feature 05 Retention and Disposition

Feature source: [05-retention-and-disposition.md](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)

## Scaleway components

- Serverless Containers
- Queues
- Managed PostgreSQL
- Object Lock
- Functions

## Stories

- `SCW-05-01` Retention policy model with trigger date, duration and lifecycle phases.
- `SCW-05-02` Retention calculation service that derives `retention_until` reproducibly.
- `SCW-05-03` Monitoring for upcoming and expired retention windows.
- `SCW-05-04` Disposition gating that blocks direct delete and checks hold state.
- `SCW-05-05` Controlled disposition workflow with review and decision capture.
- `SCW-05-06` Policy exception handling with auditable overrides.
- `SCW-05-07` Evidence generation for disposition outcomes and non-execution reasons.

## Acceptance focus

- retention remains policy-driven
- delete is never a direct business path
- disposition evidence is exportable
