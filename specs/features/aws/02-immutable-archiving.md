# AWS Stories - Feature 02 Immutable Archiving

Feature source: [02-immutable-archiving.md](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)

## AWS components

- S3 archive bucket
- S3 Object Lock
- S3 Versioning
- S3 Lifecycle
- Glacier Flexible Retrieval or Deep Archive
- KMS

## Stories

- `AWS-02-01` Archive bucket with versioning, encryption and immutable defaults.
- `AWS-02-02` Object Lock retention enforcement on archived records.
- `AWS-02-03` Checksum verification path for stored objects.
- `AWS-02-04` Policy-driven lifecycle transition from hot storage to cold tiers.
- `AWS-02-05` Restore and rehydration flow for cold-tier retrieval.
- `AWS-02-06` Replication and recovery design within compliance boundaries.
- `AWS-02-07` Evidence model for storage status, retention state and lifecycle history.

## Acceptance focus

- archived objects cannot be casually overwritten or deleted
- hot and cold lifecycle rules preserve governance
- storage state is explainable per document
