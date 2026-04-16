# AWS Stories - Feature 06 Legal Hold

Feature source: [06-legal-hold.md](/Users/kees/data/projects/archive/features/06-legal-hold.md)

## AWS components

- S3 Object Lock legal holds
- DynamoDB
- Lambda
- Step Functions

## Stories

- `AWS-06-01` Legal hold registration on document and document-set scope.
- `AWS-06-02` Hold enforcement that blocks disposition and surfaces status in metadata.
- `AWS-06-03` Controlled legal hold release flow with review and authorization checks.
- `AWS-06-04` Legal hold on search result sets and related document groups.
- `AWS-06-05` Governance controls for who may place or remove holds.

## Acceptance focus

- legal hold overrides normal disposition
- hold actions are tightly authorized and audited
- hold state is visible in archive workflows
