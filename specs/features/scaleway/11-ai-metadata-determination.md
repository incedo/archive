# Scaleway Stories - Feature 11 AI Metadata Determination

Feature source: [11-ai-metadata-determination.md](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

## Scaleway components

- Serverless Functions
- Serverless Containers
- Managed PostgreSQL
- optional external OCR or AI service integration

## Stories

- `SCW-11-01` Metadata suggestion pipeline from document content and source context.
- `SCW-11-02` Simplified ingest flow with confirm-or-correct UX for suggested metadata.
- `SCW-11-03` Migration enrichment flow for large historical document sets.
- `SCW-11-04` Provenance model for AI-derived values and prompt or source context.
- `SCW-11-05` Confidence-based review routing and required validation thresholds.
- `SCW-11-06` AI-assisted classification suggestions integrated with ingest controls.
- `SCW-11-07` Feedback capture for continuous quality improvement.

## Acceptance focus

- AI augments metadata capture without bypassing governance
- confidence and review state are explicit
- AI output never silently overwrites governance-critical metadata
