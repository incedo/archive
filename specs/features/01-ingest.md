# Feature 01 - Ingest

## Doel

Documenten gecontroleerd en reproduceerbaar innemen in het archive, inclusief validatie, classificatie en initiële metadataregistratie.

## Waarom deze feature bestaat

Ingest is het startpunt van de levenscyclus. Zonder gecontroleerde ingest zijn immutable opslag, retention, auditability en retrieval niet betrouwbaar.

## Basisfeatures

### 1.1 Document upload

- Het systeem ondersteunt upload van een individueel document.
- Een upload bevat bestand, documenttype of classificatiehint, en basismetadata.
- Het systeem geeft een uniek `document_id` terug.

### 1.2 Basisvalidatie

- Het systeem valideert bestandsformaat.
- Het systeem valideert bestandsgrootte.
- Het systeem valideert verplichte metadata.
- Het systeem weigert onvolledige of ongeldige uploads.

### 1.3 Ingest statusregistratie

- Het systeem registreert dat een document is ontvangen.
- Het systeem kent een initiële lifecycle status toe.
- Het systeem maakt ingestresultaat inzichtelijk voor opvolgende processen.

### 1.4 Integriteitsvaststelling

- Het systeem berekent een hash of checksum bij ingest.
- Het systeem koppelt de hash aan het documentrecord.
- Het systeem gebruikt deze hash later voor integriteitscontrole.

### 1.5 Malware scanning

- Het systeem voert een virus- of malwarecontrole uit.
- Het systeem blokkeert archivering van verdachte bestanden.
- Het systeem legt scanuitkomsten vast.

## Afhankelijke features

### 1.6 Classificatie

Afhankelijk van:

- 1.1 Document upload
- 1.2 Basisvalidatie

Features:

- Het systeem bepaalt of bevestigt het documenttype.
- Het systeem ondersteunt minimaal invoices, contracts, addenda, credit notes en attachments.
- Het systeem registreert classificatie-uitkomst en herkomst daarvan.

### 1.7 Bronintegraties

Afhankelijk van:

- 1.1 Document upload
- 1.3 Ingest statusregistratie

Features:

- Het systeem ondersteunt ingest vanuit externe systemen.
- Het systeem ondersteunt ingest vanuit bulkimport.
- Het systeem ondersteunt ingest vanuit scan- of mailboxstromen.

### 1.8 Verrijkte metadata-extractie

Afhankelijk van:

- 1.4 Integriteitsvaststelling
- 1.6 Classificatie

Features:

- Het systeem kan metadata extraheren uit document en broncontext.
- Het systeem kan technische en business metadata registreren.
- Het systeem markeert welke metadata automatisch of handmatig is vastgelegd.

### 1.10 AI-assisted ingestverrijking

Afhankelijk van:

- 1.7 Bronintegraties
- 1.8 Verrijkte metadata-extractie
- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

Features:

- Het systeem kan tijdens ingest AI gebruiken om ontbrekende metadata voor te stellen.
- Het systeem kan ingest voor migraties versnellen door metadata-aanvulling op basis van documentinhoud.
- Het systeem kan een eenvoudigere gebruikersinterface ondersteunen door minder handmatige invoer vooraf te vragen.
- Het systeem markeert AI-gegenereerde metadata expliciet als voorstel of afgeleide waarde.

### 1.9 Retention policy binding

Afhankelijk van:

- 1.6 Classificatie
- 1.8 Verrijkte metadata-extractie

Features:

- Het systeem koppelt een retention policy aan het document.
- Het systeem bepaalt de retention trigger context.
- Het systeem levert de benodigde gegevens aan de retention engine.

## Resultaat van deze feature

Na ingest bestaat er een gecontroleerd documentrecord met document-id, classificatie, checksum, initiële metadata en status voor verdere archivering.

## Levert input aan

- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)
