# AWS Stories - Feature 09 Search and Retrieval

Feature source: [09-search-and-retrieval.md](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)

## AWS components

- OpenSearch Service
- DynamoDB
- API Gateway
- Lambda
- S3

## Stories

- `AWS-09-01` Metadata-first search API on approved indexed properties only.
- `AWS-09-02` Business-key search for invoice number, contract number and customer attributes.
- `AWS-09-03` Document detail view with metadata, hold and lifecycle state.
- `AWS-09-04` Controlled retrieval and download of original archived objects.
- `AWS-09-05` Related-document navigation and dossier retrieval.
- `AWS-09-06` Optional full-text extension without replacing metadata search.
- `AWS-09-07` Export of document sets with audit logging.
- `AWS-09-08` Restore-aware retrieval flow for Glacier-backed documents.

## Acceptance focus

- search index remains limited to approved metadata fields
- retrieval respects authorization and storage tier state
- restore latency is visible to the user when applicable
