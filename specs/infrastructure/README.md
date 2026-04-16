# Infrastructure Specs

This folder contains infrastructure-as-code requirements and slice specs.

Use these specs when the primary work is about:

- object storage
- queues and workflow primitives
- IAM and policy wiring
- encryption and key management
- observability plumbing
- deployment/runtime composition

Do not use this folder for:

- domain behavior
- commands and queries
- decision models
- query views
- UI behavior

Those belong in software specs.

## Structure

- `requirements/` — infra slices that can be implemented iteratively

## Rule

Every infra requirement should:

- describe the capability in provider-neutral terms first
- map the capability to AWS and Scaleway second
- link to the related software spec when one exists

## Execution Order

Infrastructure work follows software work.

The intended sequence is:

1. software requirement is defined first
2. the software-facing contract is clear
3. shared/provider-neutral infra requirement is defined next
4. provider-specific realization is then done for:
   - AWS
   - Scaleway

Infra should not invent domain behavior. It should realize and protect software capabilities that are already defined.

## Workflow Rule

Infrastructure work follows this order:

1. update the infra spec first
2. commit the spec change
3. implement against the committed spec

The infra implementation should start from an explicit committed spec baseline.
