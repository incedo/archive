# Feature 02 - Immutable Archiving

## Doel

Documenten duurzaam, versleuteld en onveranderbaar opslaan gedurende de geldende retentionperiode.

## Waarom deze feature bestaat

Voor contracts en invoices moet het archive de integriteit en bewaarplicht ondersteunen. Dat vereist opslag die niet zomaar overschreven of verwijderd kan worden.

## Basisfeatures

### 2.1 Object storage archivering

- Het systeem slaat documenten op in een archiefgeschikte object store.
- Elk documentrecord verwijst naar een opslaglocatie.
- Opslag is losgekoppeld van de metadata store.
- Het systeem onderscheidt primaire archiefopslag en cold/archive storage tiers.

### 2.2 Immutable opslag

- Het systeem ondersteunt WORM of een equivalent immutable opslagmechanisme.
- Een gearchiveerd document kan niet vrij worden overschreven.
- Een gearchiveerd document kan niet vrij worden verwijderd binnen actieve retention.
- Immutable garanties blijven behouden wanneer een document naar een lagere storage tier doorstroomt.

### 2.3 Encryptie at rest

- Het systeem slaat documenten versleuteld op.
- Sleutelgebruik is beheerst en herleidbaar.

### 2.4 Integriteitscontrole op opslag

- Het systeem kan vaststellen dat het opgeslagen document overeenkomt met de geregistreerde checksum.
- Het systeem kan afwijkingen signaleren.

### 2.5 Lifecycle naar cold storage

- Het systeem ondersteunt lifecycle rules voor doorstroom van documenten naar goedkopere storage tiers.
- Lifecycle regels zijn policy-driven en niet hardcoded per bucket of container.
- Lifecycle regels houden rekening met documenttype, leeftijd, toegangspatroon en bewaarplicht.
- Het systeem ondersteunt configureerbare tijdsvensters, bijvoorbeeld jaren in hot storage, jaren in cold storage en totale retentionduur.
- Cold storage mag retrieval vertragen, maar mag vindbaarheid en governance niet doorbreken.
- Het systeem maakt zichtbaar in welke storage tier een document zich bevindt.

## Afhankelijke features

### 2.6 Tiering en lifecycle storage

Afhankelijk van:

- 2.1 Object storage archivering
- 2.2 Immutable opslag
- 2.5 Lifecycle naar cold storage

Features:

- Het systeem kan oudere documenten verplaatsen naar goedkopere storage tiers.
- Tiering mag retention en retrieval niet doorbreken.
- Het systeem ondersteunt meerdere lifecycle-stappen, bijvoorbeeld van primaire storage naar archive storage.

### 2.7 Retrieval uit cold storage

Afhankelijk van:

- 2.5 Lifecycle naar cold storage

Features:

- Het systeem ondersteunt gecontroleerde restore of rehydration uit cold storage waar de cloudprovider dat vereist.
- Het systeem maakt restore-status en verwachte toegangslatency inzichtelijk.
- Het systeem logt restore- en retrievalacties uit cold storage voor auditdoeleinden.

### 2.8 Replicatie en recovery

Afhankelijk van:

- 2.1 Object storage archivering
- 2.3 Encryptie at rest

Features:

- Het systeem ondersteunt herstelbaarheid van archiefdata.
- Het systeem ondersteunt replicatie volgens compliance- en continuiteitseisen.

### 2.9 Bewijsbare opslagstatus

Afhankelijk van:

- 2.2 Immutable opslag
- 2.4 Integriteitscontrole op opslag
- 2.5 Lifecycle naar cold storage

Features:

- Het systeem kan aantonen dat een document immutable is opgeslagen.
- Het systeem kan aantonen onder welke bewaarbeperkingen een document valt.
- Het systeem kan aantonen welke lifecycle policy op een document van toepassing is of is geweest.

## Resultaat van deze feature

Een document is duurzaam opgeslagen op een manier die integriteit, encryptie en bewaarbeperkingen ondersteunt.

## Afhankelijk van

- [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)
- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)

## Levert input aan

- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 09 - Search and Retrieval](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)
- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
