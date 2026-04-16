# Scaleway Stories - Feature 01 Ingest

Feature source: [01-ingest.md](/Users/kees/data/projects/archive/features/01-ingest.md)

## Scaleway components

- Serverless Containers
- Serverless Functions
- Object Storage ingest bucket
- Queues
- NATS optional

## Stories

- `SCW-01-01` Upload API for single-document ingest with `document_id` response.
- `SCW-01-02` Validation pipeline for file format, size and required metadata.
- `SCW-01-03` Ingest status tracking with initial lifecycle state and failure handling.
- `SCW-01-04` Checksum generation and persistence in metadata.
- `SCW-01-05` Malware scanning integration before archive write.
- `SCW-01-06` Source integrations for bulk import, mailbox and external systems.
- `SCW-01-07` Metadata extraction and provenance marking during ingest.
- `SCW-01-08` Retention policy binding at ingest handoff.
- `SCW-01-09` Optional AI-assisted metadata suggestion during ingest.

## Acceptance focus

- ingest is reproducible and auditable
- rejected uploads never reach archive storage
- metadata provenance is retained
- output is ready for immutable archiving
