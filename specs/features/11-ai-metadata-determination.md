# Feature 11 - AI Metadata Determination

## Doel

Automatisch metadata bepalen of voorstellen op basis van documentinhoud, context en bestaande archiefgegevens.

## Waarom deze feature bestaat

Voor migraties en eenvoudige invoerflows is handmatige metadataregistratie vaak te duur of te foutgevoelig. AI kan helpen om metadata sneller en lichter vast te leggen, zolang governance en controle behouden blijven.

## Basisfeatures

### 11.1 Metadata suggestie

- Het systeem kan metadata voorstellen op basis van documentinhoud.
- Het systeem kan metadata voorstellen op basis van broncontext of eerder bekende gegevens.
- Het systeem ondersteunt voorstellen voor zowel technische als business metadata waar relevant.

### 11.2 Ondersteuning voor eenvoudige invoer

- Het systeem kan de hoeveelheid verplichte handmatige invoer verminderen door metadata vooraf voor te stellen.
- Het systeem ondersteunt een gebruikersflow waarin voorgestelde metadata bevestigd of gecorrigeerd wordt.

### 11.3 Ondersteuning voor migraties

- Het systeem kan bestaande documentcollecties verrijken met automatisch afgeleide metadata.
- Het systeem ondersteunt verwerking van grote aantallen documenten met beperkte handmatige interventie.

### 11.4 Herleidbaarheid van AI-uitkomsten

- Het systeem markeert welke metadata door AI is voorgesteld of afgeleid.
- Het systeem kan vastleggen op basis van welke input een voorstel is gedaan.
- Het systeem maakt onderscheid tussen voorgestelde, bevestigde en gecorrigeerde metadata.

## Afhankelijke features

### 11.5 Confidence-based review

Afhankelijk van:

- 11.1 Metadata suggestie
- 11.4 Herleidbaarheid van AI-uitkomsten

Features:

- Het systeem kan per voorstel een confidence of kwaliteitsinschatting vastleggen.
- Het systeem kan voorstellen met lage confidence markeren voor verplichte review.
- Het systeem kan voorstellen met hogere confidence sneller laten bevestigen.

### 11.6 AI-assisted classificatie

Afhankelijk van:

- 11.1 Metadata suggestie
- [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)

Features:

- Het systeem kan AI gebruiken om documenttype te suggereren.
- Het systeem kan classificatievoorstellen combineren met ingest- en validatieregels.

### 11.7 Continue verbetering

Afhankelijk van:

- 11.4 Herleidbaarheid van AI-uitkomsten
- 11.5 Confidence-based review

Features:

- Het systeem kan correcties op AI-voorstellen vastleggen voor kwaliteitsverbetering.
- Het systeem ondersteunt evaluatie van nauwkeurigheid per documenttype of migratiestroom.

## Domeinregels

- AI bepaalt metadata niet oncontroleerbaar; het archive moet herleidbaar blijven.
- Governance-kritieke metadata mag niet blind worden overschreven door AI.
- AI-uitkomsten moeten auditeerbaar zijn.
- AI is een ondersteunende capability en vervangt het metadatamodel niet.

## Resultaat van deze feature

Het archive kan metadata sneller en gebruiksvriendelijker vastleggen, zonder controle over provenance, kwaliteit en governance te verliezen.

## Afhankelijk van

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)

## Levert input aan

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 09 - Search and Retrieval](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)
