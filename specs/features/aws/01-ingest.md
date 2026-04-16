# AWS Stories - Feature 01 Ingest

Feature source: [01-ingest.md](/Users/kees/data/projects/archive/features/01-ingest.md)

## AWS components

- API Gateway
- Lambda
- S3 ingest bucket
- EventBridge
- SQS
- Step Functions

## Stories

- `AWS-01-01` Upload API for single-document ingest with `document_id` response.
- `AWS-01-02` Validation pipeline for file format, size and required metadata.
- `AWS-01-03` Ingest status tracking with initial lifecycle state and failure handling.
- `AWS-01-04` Checksum generation and persistence in metadata.
- `AWS-01-05` Malware scanning integration before archive write.
- `AWS-01-06` Source integrations for bulk import, mailbox and external systems.
- `AWS-01-07` Metadata extraction and provenance marking during ingest.
- `AWS-01-08` Retention policy binding at ingest handoff.
- `AWS-01-09` Optional AI-assisted metadata suggestion during ingest.

## Acceptance focus

- ingest is reproducible and auditable
- rejected uploads never reach archive storage
- metadata provenance is retained
- output is ready for immutable archiving
