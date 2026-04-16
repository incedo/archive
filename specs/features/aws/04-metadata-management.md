# AWS Stories - Feature 04 Metadata Management

Feature source: [04-metadata-management.md](/Users/kees/data/projects/archive/features/04-metadata-management.md)

## AWS components

- DynamoDB
- Lambda
- Step Functions
- OpenSearch Service

## Stories

- `AWS-04-01` Metadata system of record in DynamoDB for technical, business and compliance fields.
- `AWS-04-02` Document-type metadata validation for invoices and contracts.
- `AWS-04-03` Governance metadata handling for retention, legal hold and lifecycle status.
- `AWS-04-04` Rules for mutable versus immutable metadata fields.
- `AWS-04-05` Document relation model for attachments, addenda and dossier links.
- `AWS-04-06` Metadata provenance model for manual, integrated and derived values.
- `AWS-04-07` Searchable metadata profile with limited indexed properties per document type.
- `AWS-04-08` Confidence and review state model for auto-determined metadata.

## Acceptance focus

- metadata is authoritative over object naming
- search index only receives approved metadata properties
- governance-critical fields are protected from uncontrolled change
