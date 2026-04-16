# Software Specs

This folder contains software-only requirements and slice specs.

Use these specs when the primary work is about:

- domain behavior
- commands and queries
- decision models
- projections and read models
- API contracts
- admin/operator UI behavior

Do not use this folder for:

- buckets, queues, IAM, keys, lifecycle rules, observability plumbing
- provider runtime setup
- OpenTofu module design

Those belong in infrastructure specs.

## Structure

- [components.md](/Users/kees/data/projects/archive/specs/software/components.md) — software component boundaries and responsibilities
- `requirements/` — software requirements/slices that can be implemented iteratively

## Rule

Every software requirement should:

- link back to the feature it satisfies
- stay provider-neutral in its domain language
- reference a related infra spec when runtime or platform dependencies matter

## Execution Order

For this repo, software specs come first.

The intended sequence is:

1. define and refine the software slice
2. stabilize its command/query/domain contract
3. only then create or implement the matching infrastructure slice
4. only after that map the infrastructure slice to AWS and Scaleway

This keeps:

- domain language clean
- provider concerns out of the software core
- AWS and Scaleway work anchored to a stable software contract

## Workflow Rule

Software work follows this order:

1. update the software spec first
2. commit the spec change
3. implement against the committed spec

The software spec is the baseline for the first code change, not an afterthought.
