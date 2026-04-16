# Scaleway Stories - Feature 02 Immutable Archiving

Feature source: [02-immutable-archiving.md](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)

## Scaleway components

- Object Storage archive bucket
- Object Lock
- Versioning
- Lifecycle Rules
- Standard One Zone or Glacier
- SSE-ONE or SSE-C
- Key Manager

## Stories

- `SCW-02-01` Archive bucket with versioning, encryption and immutable defaults.
- `SCW-02-02` Object Lock retention enforcement on archived records.
- `SCW-02-03` Checksum verification path for stored objects.
- `SCW-02-04` Policy-driven lifecycle transition from hot storage to lower-cost tiers.
- `SCW-02-05` Restore and rehydration flow for Glacier-backed retrieval.
- `SCW-02-06` Replication and recovery design within compliance boundaries.
- `SCW-02-07` Evidence model for storage status, retention state and lifecycle history.

## Acceptance focus

- archived objects cannot be casually overwritten or deleted
- hot and cold lifecycle rules preserve governance
- storage state is explainable per document
