# Scaleway Stories - Feature 07 Audit Trail

Feature source: [07-audit-trail.md](/Users/kees/data/projects/archive/features/07-audit-trail.md)

## Scaleway components

- Audit Trail
- Cockpit Logs
- append-only audit store
- Serverless Functions or Containers

## Stories

- `SCW-07-01` Uniform audit event schema for document, governance and access events.
- `SCW-07-02` Capture of uploads, views, downloads, metadata changes, retention actions and hold actions.
- `SCW-07-03` Independent audit storage protected from uncontrolled modification.
- `SCW-07-04` Event correlation by document, actor, workflow and dossier.
- `SCW-07-05` Audit evidence export per document, dossier or time range.

## Acceptance focus

- critical actions are reconstructable
- audit storage is separate from operational retrieval indexes
- evidence export is possible without manual log digging
