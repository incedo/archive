# Archive Solution Features

## Doel

Deze map beschrijft de productfeatures van een compliance archive voor contracts en invoices.

De opzet is bewust gesplitst:

- `FEATURES.md` is de hoofdindex.
- Elke capability heeft een eigen featurebestand.
- Elk featurebestand bouwt op van basisfeatures naar meer afhankelijke features.
- Deze featurebestanden zijn productgericht en cloud-onafhankelijk.
- Stories kunnen later per cloud provider worden afgeleid uit deze featurebestanden.
- De iteratieve implementatie-aanpak is vastgelegd in [RALPH_WIGGUM_LOOP_PLAN.md](/Users/kees/data/projects/archive/RALPH_WIGGUM_LOOP_PLAN.md).
- De benodigde implementatieskills zijn vastgelegd in [CODEX_SKILLS_REQUIRED.md](/Users/kees/data/projects/archive/CODEX_SKILLS_REQUIRED.md) en [SKILL_TO_FEATURE_MAPPING.md](/Users/kees/data/projects/archive/SKILL_TO_FEATURE_MAPPING.md).

## Uitgangspunten

- Het systeem is een compliance archive, geen generieke document storage.
- Metadata is leidend voor vindbaarheid, beheer en compliance.
- Zoekindexering is metadata-first en beperkt zich primair tot een beheerst aantal eigenschappen per document.
- Immutable storage, retention, legal hold, audit trail en RBAC zijn first-class capabilities.
- Implementatiedetails voor AWS, Azure of andere platformen horen niet in deze featurebestanden.

## Scope

Primaire documenttypen:

- Invoices
- Contracts
- Addenda
- Credit notes
- Attachments

## Featurestructuur

### Foundation

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)
- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)
- [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/features/03-administration-and-operations.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)

### Control & Governance

- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 06 - Legal Hold](/Users/kees/data/projects/archive/features/06-legal-hold.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
- [Feature 08 - Security and Access Control](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)

### Access & Compliance

- [Feature 09 - Search and Retrieval](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)
- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)

### Advanced Automation

- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

## Aanbevolen volgorde voor uitwerking naar stories

1. Ingest
2. Immutable Archiving
3. Administration and Operations
4. Metadata Management
5. Audit Trail
6. Security and Access Control
7. Legal Hold
8. Search and Retrieval
9. Retention and Disposition
10. Reporting and Compliance
11. AI Metadata Determination

## Cross-cutting domeinregels

- Documenten mogen niet direct verwijderd worden.
- Disposition verloopt altijd via een gecontroleerd proces.
- Legal hold overschrijft disposition.
- Retention is policy-driven en niet hardcoded in applicatielogica.
- Audit events moeten beschikbaar zijn voor kritieke acties.
- Toegang moet afdwingbaar zijn per rol, documenttype en legal entity.
- Lifecycle naar cold storage moet policy-driven zijn en mag immutable storage, retention en legal hold niet doorbreken.
- Search en retrieval baseren zich primair op metadata zoals klantnummer, adres, subscription details en document business keys, niet op volledige documentindexering.

## Levenscyclusstatussen

- received
- classified
- archived
- on_hold
- retention_expired
- pending_disposition
- disposed

## Minimale metadata

De minimale metadata is beschreven in:

- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)

## Open punten

- Exacte retention policies per documenttype en jurisdictie.
- Welke metadata na ingest wijzigbaar mag zijn.
- Wanneer een document formeel als record wordt gedeclareerd.
- Hoe multi-tenant en multi-entity autorisatie wordt afgedwongen.
- Welke evidence exports auditors exact nodig hebben.
