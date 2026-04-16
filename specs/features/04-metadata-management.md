# Feature 04 - Metadata Management

## Doel

Metadata centraal vastleggen als system of record voor vindbaarheid, beheer, compliance en beleidstoepassing.

## Waarom deze feature bestaat

Het blob-object is niet het systeem van waarheid voor zoekbaarheid en governance. De metadata store is dat wel.

## Basisfeatures

### 4.1 Metadata store

- Het systeem beheert metadata los van het fysieke document.
- Het systeem houdt technische, business- en compliance metadata bij.
- Het systeem maakt metadata querybaar.

### 4.2 Technische metadata

- Het systeem registreert `document_id`.
- Het systeem registreert `checksum`.
- Het systeem registreert `object_storage_uri`.
- Het systeem registreert `version`.
- Het systeem registreert `source_system`.

### 4.3 Business metadata

- Het systeem registreert documenttype-specifieke metadata.
- Het systeem ondersteunt minimaal invoices en contracts.
- Het systeem valideert de aanwezigheid van verplichte business metadata.
- Het systeem ondersteunt een vast gedefinieerde subset van metadata die expliciet gebruikt mag worden voor zoeken en filteren.

### 4.4 Compliance metadata

- Het systeem registreert `retention_until`.
- Het systeem registreert `legal_hold_flag`.
- Het systeem registreert lifecycle status.
- Het systeem registreert classificatie- en vertrouwelijkheidscontext.

## Afhankelijke features

### 4.5 Wijzigbare versus niet-wijzigbare metadata

Afhankelijk van:

- 4.1 Metadata store
- 4.4 Compliance metadata

Features:

- Het systeem onderscheidt correcteerbare metadata van vaststaande metadata.
- Het systeem voorkomt ongecontroleerde wijziging van governance-kritieke velden.

### 4.6 Documentrelaties

Afhankelijk van:

- 4.1 Metadata store
- 4.3 Business metadata

Features:

- Het systeem ondersteunt relaties tussen documenten.
- Het systeem ondersteunt bijvoorbeeld contract en addendum, invoice en attachment, of dossierverbanden.

### 4.7 Metadata provenance

Afhankelijk van:

- 4.2 Technische metadata
- 4.3 Business metadata

Features:

- Het systeem legt vast of metadata handmatig, automatisch of uit een bronintegratie komt.
- Het systeem maakt zichtbaar welke metadata later is aangepast.

### 4.8 Searchable metadata profile

Afhankelijk van:

- 4.3 Business metadata
- 4.7 Metadata provenance

Features:

- Het systeem definieert per documenttype welke metadata-eigenschappen in de zoekindex terechtkomen.
- Het systeem indexeert primair een beperkte set eigenschappen, bijvoorbeeld ongeveer tien velden per document.
- Het systeem ondersteunt daarbij voorbeelden zoals klantnummer, adres, subscription details, invoice number en contract number.
- Het systeem voorkomt dat volledige documentinhoud impliciet onderdeel wordt van de standaard zoekindex.

### 4.9 Confidence en review status

Afhankelijk van:

- 4.3 Business metadata
- 4.7 Metadata provenance
- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

Features:

- Het systeem kan per metadata-veld een confidence of kwaliteitsindicatie vastleggen.
- Het systeem kan per metadata-veld vastleggen of de waarde voorgesteld, bevestigd of gecorrigeerd is.
- Het systeem ondersteunt reviewstatussen voor automatisch bepaalde metadata.

## Minimale metadata

### Invoices

- document_id
- document_type
- invoice_number
- supplier_name
- supplier_id
- customer_legal_entity
- invoice_date
- booking_date
- vat_number
- currency
- gross_amount
- net_amount
- status
- source_system
- retention_until
- legal_hold_flag
- checksum
- object_storage_uri

### Contracts

- document_id
- document_type
- contract_number
- counterparty
- legal_entity
- contract_type
- effective_date
- expiration_date
- termination_date
- owner_department
- confidentiality_class
- related_amendments
- source_system
- retention_until
- legal_hold_flag
- checksum
- object_storage_uri

## Resultaat van deze feature

Alle verdere capabilities kunnen vertrouwen op een centraal, querybaar en beheersbaar metadatamodel, inclusief een expliciet beheerd zoekprofiel voor retrieval.

## Afhankelijk van

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)

## Levert input aan

- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 06 - Legal Hold](/Users/kees/data/projects/archive/features/06-legal-hold.md)
- [Feature 09 - Search and Retrieval](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)
- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)
