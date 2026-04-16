# AWS Dev Identity Center Stack

This stack is the OpenTofu entry point for AWS IAM Identity Center management in the `dev` environment.

Current purpose:

- verify AWS auth for OpenTofu
- detect IAM Identity Center instances after bootstrap enablement
- provide a stable place for later IaC management of users, groups, permission sets, and assignments

Important rule:

- enabling IAM Identity Center itself is still treated as bootstrap
- ongoing configuration after enablement should move into OpenTofu

Files:

- `dev.tfvars`
- `plan.sh`
- `apply.sh`
- `aws-auth-check.sh`

Typical flow:

```bash
cd infra/live/aws/dev/identity-center
PATH=/Users/kees/data/projects/archive/tools/bin:$PATH TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./aws-auth-check.sh
PATH=/Users/kees/data/projects/archive/tools/bin:$PATH TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./plan.sh
PATH=/Users/kees/data/projects/archive/tools/bin:$PATH TOFU_BIN=/Users/kees/data/projects/archive/tools/opentofu/bin/tofu ./apply.sh
```
