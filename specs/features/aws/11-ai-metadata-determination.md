# AWS Stories - Feature 11 AI Metadata Determination

Feature source: [11-ai-metadata-determination.md](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

## AWS components

- Textract
- Lambda
- Step Functions
- DynamoDB

## Stories

- `AWS-11-01` Metadata suggestion pipeline from document content and source context.
- `AWS-11-02` Simplified ingest flow with confirm-or-correct UX for suggested metadata.
- `AWS-11-03` Migration enrichment flow for large historical document sets.
- `AWS-11-04` Provenance model for AI-derived values and prompt or source context.
- `AWS-11-05` Confidence-based review routing and required validation thresholds.
- `AWS-11-06` AI-assisted classification suggestions integrated with ingest controls.
- `AWS-11-07` Feedback capture for continuous quality improvement.

## Acceptance focus

- AI augments metadata capture without bypassing governance
- confidence and review state are explicit
- AI output never silently overwrites governance-critical metadata
