# Feature 09 - Search and Retrieval

## Doel

Gebruikers documenten snel laten vinden en gecontroleerd laten ophalen op basis van metadata en toegangsrechten.

## Waarom deze feature bestaat

Een archive heeft alleen waarde als records vindbaar en reproduceerbaar opvraagbaar zijn zonder de governance te doorbreken.

## Basisfeatures

### 9.1 Metadata search

- Het systeem ondersteunt zoeken op metadata.
- Het systeem ondersteunt filteren op documenttype, partij, legal entity, status en datumvelden.
- Het systeem gebruikt daarvoor primair een beperkte metadata-index en niet de volledige documentinhoud.

### 9.2 Zoeken op business keys

- Het systeem ondersteunt zoeken op invoice number.
- Het systeem ondersteunt zoeken op contract number.
- Het systeem ondersteunt zoeken op aanvullende klant- en abonnementskenmerken zoals customer number, adres en subscription details.

### 9.3 Documentdetail

- Het systeem toont documentmetadata.
- Het systeem toont lifecycle status, retentioninformatie en legal hold status.

### 9.4 Retrieve en download

- Het systeem ondersteunt gecontroleerd ophalen van het originele document.
- Het systeem past autorisatie toe op retrieval en download.
- Het systeem maakt onderscheid tussen directe retrieval en retrieval die eerst restore uit cold storage vereist.

## Afhankelijke features

### 9.5 Dossier- en relatiegebaseerde retrieval

Afhankelijk van:

- 9.1 Metadata search
- 4.6 Documentrelaties

Features:

- Het systeem ondersteunt retrieval van samenhangende documentsets.
- Het systeem ondersteunt navigatie tussen gerelateerde records.

### 9.6 Full-text retrieval support

Afhankelijk van:

- 9.1 Metadata search

Features:

- Het systeem kan full-text search toevoegen als aanvullende retrievalmogelijkheid.
- Full-text search vervangt metadata search niet.
- Full-text search is optioneel en staat los van de standaard metadata-index voor invoices en contracts.

### 9.7 Export van documentsets

Afhankelijk van:

- 9.4 Retrieve en download
- 8.5 Fijnmazige beheerrechten

Features:

- Het systeem ondersteunt export van documentsets of dossiers.
- Het systeem logt exports voor auditdoeleinden.

### 9.8 Restore-aware retrieval

Afhankelijk van:

- 9.4 Retrieve en download
- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)

Features:

- Het systeem kan gebruikers informeren wanneer een document in cold storage zit.
- Het systeem ondersteunt een gecontroleerde restore-aanvraag voor documenten die niet direct beschikbaar zijn.
- Het systeem maakt restore-latency en restore-status zichtbaar in retrievalflows.

## Resultaat van deze feature

Gebruikers kunnen records veilig vinden, inspecteren en ophalen via een metadata-first retrievalmodel met een beheerst indexprofiel.

## Afhankelijk van

- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
- [Feature 08 - Security and Access Control](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)

## Levert input aan

- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
