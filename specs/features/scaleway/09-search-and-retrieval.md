# Scaleway Stories - Feature 09 Search and Retrieval

Feature source: [09-search-and-retrieval.md](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)

## Scaleway components

- OpenSearch
- Managed PostgreSQL
- Serverless Containers
- Object Storage

## Stories

- `SCW-09-01` Metadata-first search API on approved indexed properties only.
- `SCW-09-02` Business-key search for invoice number, contract number and customer attributes.
- `SCW-09-03` Document detail view with metadata, hold and lifecycle state.
- `SCW-09-04` Controlled retrieval and download of original archived objects.
- `SCW-09-05` Related-document navigation and dossier retrieval.
- `SCW-09-06` Optional full-text extension without replacing metadata search.
- `SCW-09-07` Export of document sets with audit logging.
- `SCW-09-08` Restore-aware retrieval flow for Glacier-backed documents.

## Acceptance focus

- search index remains limited to approved metadata fields
- retrieval respects authorization and storage tier state
- restore latency is visible to the user when applicable
