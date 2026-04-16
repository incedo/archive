# Ralph Wiggum Loop Plan

## Doel

Dit document vertaalt de vastgelegde requirements naar een herhaalbare implementatieloop.

De bedoeling van deze loop is:

- klein beginnen
- per iteratie een werkende slice opleveren
- compliance- en beheerrisico vroeg toetsen
- stories pas provider-specifiek maken wanneer de featuregrenzen duidelijk zijn

## Uitgangspunt

De bron voor deze loop is:

- [FEATURES.md](/Users/kees/data/projects/archive/FEATURES.md)
- de featurebestanden onder [features](/specs/FEATURES.md)
- [AWS_REFERENCE_ARCHITECTURE.md](/Users/kees/data/projects/archive/AWS_REFERENCE_ARCHITECTURE.md)
- [SCALEWAY_REFERENCE_ARCHITECTURE.md](/Users/kees/data/projects/archive/SCALEWAY_REFERENCE_ARCHITECTURE.md)
- [SECURITY_BASELINE.md](/Users/kees/data/projects/archive/SECURITY_BASELINE.md)

## De Loop

Elke iteratie gebruikt dezelfde vaste cyclus:

1. Selecteer een feature-slice
2. Definieer de minimale acceptance criteria
3. Maak provider-specifieke stories
4. Implementeer een thin vertical slice
5. Verifieer gedrag, security, operations en kosten
6. Leg beslissingen en gaps vast
7. Bepaal de eerstvolgende afhankelijke slice

## Stap 1 - Selecteer een feature-slice

Kies steeds een kleine slice uit precies een featurebestand.

Regels:

- begin met basisfeatures voordat afhankelijke features aan de beurt komen
- pak eerst capabilities die andere features unblocken
- houd de slice klein genoeg om in een iteratie te bouwen en te verifiëren
- vermijd combinaties van meerdere grote features in dezelfde iteratie

Voorbeeld van een goede slice:

- `01-ingest` alleen upload, hash, metadata-vastlegging en audit-event

Voorbeeld van een slechte slice:

- ingest, retrieval, legal hold en reporting tegelijk

## Stap 2 - Definieer minimale acceptance criteria

Per slice leg je eerst vast:

- welk probleem wordt opgelost
- wat het minimale gedrag is
- welke input en output verwacht worden
- welke audit events verplicht zijn
- welke security controls minimaal nodig zijn
- welke operationele signalen zichtbaar moeten zijn

Elke slice krijgt minimaal:

- functionele acceptance criteria
- security criteria
- audit criteria
- operations criteria
- cost impact notitie

## Stap 3 - Maak provider-specifieke stories

Vertaal daarna de slice naar stories per cloud provider.

Per story leg je vast:

- feature reference, bijvoorbeeld `01.1` of `04.8`
- provider, bijvoorbeeld `aws` of `scaleway`
- componenten uit de referentiearchitectuur
- infrastructuurwijzigingen
- applicatiewijzigingen
- test- en verificatieverwachting

Story-vorm:

- `story id`
- `feature reference`
- `why`
- `scope`
- `out of scope`
- `acceptance criteria`
- `cloud components`
- `risks`
- `evidence to collect`

## Stap 4 - Implementeer een thin vertical slice

Bouw niet eerst alle infrastructuur en daarna pas alle applicatielogica.

Bouw per iteratie een dunne end-to-end slice:

- ingest of API entry point
- control-plane logica
- metadata-vastlegging
- opslag of retrievalgedrag
- audit-event
- minimale beheer- of observabilityhaak

Dat dwingt af dat het systeem niet alleen technisch bestaat, maar ook bestuurbaar en toetsbaar is.

## Stap 5 - Verifieer gedrag, security, operations en kosten

Elke iteratie sluit af met een vaste check.

### Functioneel

- doet de slice precies wat de feature beschrijft
- zijn randgevallen en foutpaden meegenomen

### Security

- is toegang beperkt tot de juiste rol of workload
- is encryptie aanwezig waar vereist
- wordt immutable gedrag niet doorbroken

### Audit

- zijn verplichte events vastgelegd
- is provenance of besluitvorming herleidbaar

### Operations

- zijn retries, failure states en alerts duidelijk
- is beheer mogelijk zonder handmatige workarounds

### Cost

- verandert deze slice materieel iets aan storage, search, logs, compute of retrieval
- moet de calculator worden bijgewerkt

## Stap 6 - Leg beslissingen en gaps vast

Per iteratie leg je minimaal vast:

- wat gebouwd is
- wat bewust nog niet gebouwd is
- welke aannames zijn gemaakt
- welke open punten er zijn
- welke requirement of architectuurtekst aangepast moet worden

Dit voorkomt dat stories losraken van de productbasis.

## Stap 7 - Bepaal de eerstvolgende afhankelijke slice

Na elke iteratie kies je de volgende slice op basis van:

- dependency in de featurestructuur
- risicoverlaging
- leerwaarde
- kostenimpact
- operationele noodzaak

Niet de technisch leukste slice eerst, maar de slice die het systeem het meest volwassen maakt.

## Aanbevolen loopvolgorde

Volg deze hoofdvolgorde, tenzij een blocker of risico een andere volgorde afdwingt:

1. [Feature 01 - Ingest](/Users/kees/data/projects/archive/features/01-ingest.md)
2. [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)
3. [Feature 03 - Administration and Operations](/Users/kees/data/projects/archive/features/03-administration-and-operations.md)
4. [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
5. [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
6. [Feature 08 - Security and Access Control](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)
7. [Feature 06 - Legal Hold](/Users/kees/data/projects/archive/features/06-legal-hold.md)
8. [Feature 09 - Search and Retrieval](/Users/kees/data/projects/archive/features/09-search-and-retrieval.md)
9. [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
10. [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
11. [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

## Eerste concrete loops

### Loop 1 - Minimal ingest to immutable archive

Doel:

- een document ontvangen
- metadata basis vastleggen
- checksum berekenen
- immutable opslaan
- audit-event schrijven

Featurebasis:

- `01-ingest`
- `02-immutable-archiving`
- minimale delen van `03-administration-and-operations`

Exit criteria:

- upload werkt end-to-end
- document staat immutable opgeslagen
- basis metadata is zichtbaar
- ingest is auditeerbaar

### Loop 2 - Administrative control baseline

Doel:

- policies en basisbeheer zichtbaar en wijzigbaar maken
- operationele status van ingest en archivering tonen
- exceptions kunnen zien

Featurebasis:

- `03-administration-and-operations`
- koppeling met `01` en `02`

Exit criteria:

- beheer kan ingest en archive status volgen
- basisconfiguratie is niet hardcoded in code alleen
- fouten en retries zijn zichtbaar

### Loop 3 - Metadata system of record

Doel:

- metadata model expliciet maken
- wijzigbare en niet-wijzigbare metadata scheiden
- zoekprofiel voor metadata-index vastleggen

Featurebasis:

- `04-metadata-management`

Exit criteria:

- metadata store is leidend
- indexed search properties zijn expliciet vastgelegd
- documentinhoud is niet de standaard zoekindex

### Loop 4 - Audit and security baseline

Doel:

- auditeerbaarheid en toegang afdwingen als productcapability

Featurebasis:

- `07-audit-trail`
- `08-security-and-access-control`

Exit criteria:

- kritieke acties hebben audit events
- basis RBAC werkt
- encryptie en sleutelgebruik volgen de security baseline

### Loop 5 - Retrieval baseline

Doel:

- metadata-first zoeken
- documentdetail tonen
- gecontroleerde retrieval en download

Featurebasis:

- `09-search-and-retrieval`
- afhankelijkheden uit `04`, `07` en `08`

Exit criteria:

- zoeken werkt op business keys en geselecteerde metadata-eigenschappen
- retrieval respecteert autorisatie
- cold-storage restore status is zichtbaar indien van toepassing

## Definition of Done per loop

Een loop is alleen klaar als alles hieronder waar is:

- de slice werkt end-to-end
- de acceptance criteria zijn gehaald
- security baseline is nageleefd
- auditgedrag is aantoonbaar
- operations en beheer zijn niet vergeten
- kostenimpact is beoordeeld
- requirements of architectuurdocs zijn bijgewerkt als de werkelijkheid is veranderd

## Niet doen

- meteen provider-abstracties bouwen zonder eerste werkende slice
- full-text search als baseline nemen
- AI vroeg in de loop trekken terwijl metadata-basis nog niet stabiel is
- retention en legal hold uitstellen tot na operationele opslagkeuzes
- beheerfunctionaliteit als later probleem behandelen

## Praktische werkregel

Gebruik voor elke iteratie deze ene zin als stuurregel:

`Kies de kleinste slice die een echte capability oplevert, auditbaar is, beheerbaar is en de volgende feature unblockt.`
