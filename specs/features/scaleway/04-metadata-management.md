# Scaleway Stories - Feature 04 Metadata Management

Feature source: [04-metadata-management.md](/Users/kees/data/projects/archive/features/04-metadata-management.md)

## Scaleway components

- Managed PostgreSQL
- Serverless Functions or Containers
- OpenSearch

## Stories

- `SCW-04-01` Metadata system of record in PostgreSQL for technical, business and compliance fields.
- `SCW-04-02` Document-type metadata validation for invoices and contracts.
- `SCW-04-03` Governance metadata handling for retention, legal hold and lifecycle status.
- `SCW-04-04` Rules for mutable versus immutable metadata fields.
- `SCW-04-05` Document relation model for attachments, addenda and dossier links.
- `SCW-04-06` Metadata provenance model for manual, integrated and derived values.
- `SCW-04-07` Searchable metadata profile with limited indexed properties per document type.
- `SCW-04-08` Confidence and review state model for auto-determined metadata.

## Acceptance focus

- metadata is authoritative over object naming
- search index only receives approved metadata properties
- governance-critical fields are protected from uncontrolled change
