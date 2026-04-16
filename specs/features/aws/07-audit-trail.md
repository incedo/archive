# AWS Stories - Feature 07 Audit Trail

Feature source: [07-audit-trail.md](/Users/kees/data/projects/archive/features/07-audit-trail.md)

## AWS components

- CloudTrail
- CloudWatch Logs
- DynamoDB or append-only audit store
- Lambda

## Stories

- `AWS-07-01` Uniform audit event schema for document, governance and access events.
- `AWS-07-02` Capture of uploads, views, downloads, metadata changes, retention actions and hold actions.
- `AWS-07-03` Independent audit storage protected from uncontrolled modification.
- `AWS-07-04` Event correlation by document, actor, workflow and dossier.
- `AWS-07-05` Audit evidence export per document, dossier or time range.

## Acceptance focus

- critical actions are reconstructable
- audit storage is separate from operational retrieval indexes
- evidence export is possible without manual log digging
