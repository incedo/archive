# Skill To Feature Mapping

## Doel

Dit document koppelt de benodigde Codex-skills aan de features van het archive.

Het doel is:

- per feature snel te zien welke skill primair leidend is
- generieke en platformskills van elkaar te scheiden
- stories later expliciet triggerbaar te maken

## Leeswijze

Per feature is aangegeven:

- primaire skill
- ondersteunende skills
- AWS-platformskills
- Scaleway-platformskills

## Feature 01 - Ingest

Bron: [01-ingest.md](/Users/kees/data/projects/archive/features/01-ingest.md)

- Primary skill: `document-processing`
- Supporting skills: `backend`, `serverless`, `persistence`, `testing`, `observability`
- AWS platform skills: `aws-serverless`, `aws-storage`
- Scaleway platform skills: `scaleway-serverless`, `scaleway-storage`

## Feature 02 - Immutable Archiving

Bron: [02-immutable-archiving.md](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)

- Primary skill: `infrastructure-as-code`
- Supporting skills: `security`, `persistence`, `observability`, `finops`, `architecture`
- AWS platform skills: `aws-storage`, `aws-security`, `aws-compliance`
- Scaleway platform skills: `scaleway-storage`, `scaleway-security`, `scaleway-compliance`

## Feature 03 - Administration and Operations

Bron: [03-administration-and-operations.md](/Users/kees/data/projects/archive/features/03-administration-and-operations.md)

- Primary skill: `ux-admin`
- Supporting skills: `backend`, `observability`, `security`, `architecture`, `testing`
- AWS platform skills: `aws-observability`, `aws-security`
- Scaleway platform skills: `scaleway-observability`, `scaleway-security`

## Feature 04 - Metadata Management

Bron: [04-metadata-management.md](/Users/kees/data/projects/archive/features/04-metadata-management.md)

- Primary skill: `persistence`
- Supporting skills: `backend`, `search`, `testing`, `architecture`
- AWS platform skills: `aws-data`
- Scaleway platform skills: `scaleway-data`

## Feature 05 - Retention and Disposition

Bron: [05-retention-and-disposition.md](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)

- Primary skill: `backend`
- Supporting skills: `serverless`, `security`, `testing`, `observability`, `architecture`
- AWS platform skills: `aws-serverless`, `aws-compliance`
- Scaleway platform skills: `scaleway-serverless`, `scaleway-compliance`

## Feature 06 - Legal Hold

Bron: [06-legal-hold.md](/Users/kees/data/projects/archive/features/06-legal-hold.md)

- Primary skill: `security`
- Supporting skills: `backend`, `persistence`, `testing`, `ux-admin`
- AWS platform skills: `aws-security`, `aws-compliance`, `aws-storage`
- Scaleway platform skills: `scaleway-security`, `scaleway-compliance`, `scaleway-storage`

## Feature 07 - Audit Trail

Bron: [07-audit-trail.md](/Users/kees/data/projects/archive/features/07-audit-trail.md)

- Primary skill: `observability`
- Supporting skills: `backend`, `persistence`, `security`, `testing`
- AWS platform skills: `aws-observability`
- Scaleway platform skills: `scaleway-observability`

## Feature 08 - Security and Access Control

Bron: [08-security-and-access-control.md](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)

- Primary skill: `security`
- Supporting skills: `backend`, `ux-admin`, `testing`, `architecture`
- AWS platform skills: `aws-security`
- Scaleway platform skills: `scaleway-security`

## Feature 09 - Search and Retrieval

Bron: [09-search-and-retrieval.md](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)

- Primary skill: `search`
- Supporting skills: `backend`, `persistence`, `security`, `testing`, `ux-admin`, `finops`
- AWS platform skills: `aws-data`, `aws-storage`
- Scaleway platform skills: `scaleway-data`, `scaleway-storage`

## Feature 10 - Reporting and Compliance

Bron: [10-reporting-and-compliance.md](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)

- Primary skill: `observability`
- Supporting skills: `backend`, `persistence`, `search`, `ux-admin`, `testing`
- AWS platform skills: `aws-observability`, `aws-data`, `aws-compliance`
- Scaleway platform skills: `scaleway-observability`, `scaleway-data`, `scaleway-compliance`

## Feature 11 - AI Metadata Determination

Bron: [11-ai-metadata-determination.md](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

- Primary skill: `ai-governance`
- Supporting skills: `document-processing`, `backend`, `persistence`, `testing`, `ux-admin`
- AWS platform skills: `aws-serverless`, `aws-data`
- Scaleway platform skills: `scaleway-serverless`, `scaleway-data`

## Loop-start advice

Voor de eerste implementatielus uit [RALPH_WIGGUM_LOOP_PLAN.md](/Users/kees/data/projects/archive/RALPH_WIGGUM_LOOP_PLAN.md) zijn dit de meest actieve skills:

- `document-processing`
- `backend`
- `serverless`
- `persistence`
- `infrastructure-as-code`
- `security`
- `observability`
- `testing`

Met daarbovenop per provider:

- AWS: `aws-serverless`, `aws-storage`, `aws-security`, `aws-data`
- Scaleway: `scaleway-serverless`, `scaleway-storage`, `scaleway-security`, `scaleway-data`
