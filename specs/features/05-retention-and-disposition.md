# Feature 05 - Retention and Disposition

## Doel

Bewaartermijnen policy-driven toepassen en gecontroleerde disposition uitvoeren wanneer retention is verstreken en geen blokkades actief zijn.

## Waarom deze feature bestaat

Bewaren zonder aantoonbare retentionlogica en zonder gecontroleerde disposition is geen volwaardig archive.

## Basisfeatures

### 5.1 Retention policy model

- Het systeem ondersteunt retention policies per documenttype en context.
- Een policy definieert triggerdatum, duur en eventuele uitzonderingen.
- Een policy kan ook lifecycle-fasen definiëren, zoals periode in primaire opslag en periode in cold storage binnen de totale retentionduur.
- Policies zijn beheerbaar zonder codewijziging.

### 5.2 Retention berekening

- Het systeem berekent `retention_until`.
- Het systeem gebruikt documenttype en triggercontext voor de berekening.
- Het systeem kan berekening herleiden naar de toegepaste policy.

### 5.3 Retention monitoring

- Het systeem signaleert documenten die retention naderen.
- Het systeem signaleert documenten waarvan retention is verstreken.

### 5.4 Disposition gating

- Het systeem staat geen directe delete toe.
- Het systeem bepaalt of een document in aanmerking komt voor disposition.
- Het systeem blokkeert disposition bij actieve legal hold of andere blokkade.

## Afhankelijke features

### 5.5 Disposition workflow

Afhankelijk van:

- 5.3 Retention monitoring
- 5.4 Disposition gating

Features:

- Het systeem ondersteunt een gecontroleerde disposition-aanvraag.
- Het systeem ondersteunt beoordeling en besluitvorming.
- Het systeem legt disposition-besluit en context vast.

### 5.6 Policy exceptions

Afhankelijk van:

- 5.1 Retention policy model
- 5.5 Disposition workflow

Features:

- Het systeem ondersteunt uitzonderingen op standaard retention policies.
- Het systeem maakt policy overrides expliciet en auditeerbaar.

### 5.7 Disposition execution evidence

Afhankelijk van:

- 5.5 Disposition workflow

Features:

- Het systeem kan aantonen waarom disposition wel of niet is uitgevoerd.
- Het systeem kan dispositionresultaten rapporteren voor auditdoeleinden.

## Resultaat van deze feature

Retention en disposition zijn reproduceerbaar, uitlegbaar en controleerbaar.

## Afhankelijk van

- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 06 - Legal Hold](/Users/kees/data/projects/archive/features/06-legal-hold.md)

## Levert input aan

- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
