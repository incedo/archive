# Scaleway Reference Architecture

## Doel

Deze referentiearchitectuur beschrijft een Scaleway-variant van het compliance archive voor contracts en invoices.

De architectuur is:

- feature-gedreven
- cloud-specifiek voor Scaleway
- nog niet implementatie-specifiek op storyniveau

## Architectuurprincipes

- Object Storage is de archieflaag voor documenten.
- Immutable storage is ook op Scaleway een harde eis voor records.
- Metadata is leidend voor beheer, search en compliance.
- Governance loopt via policies, legal holds, audit trail en IAM.
- Event-driven verwerking verdient de voorkeur boven strak gekoppelde synchrone ketens.
- AI voor metadata is optioneel en later toevoegbaar.

## Hoofdkeuze

Deze Scaleway-referentiearchitectuur gebruikt primair:

- Scaleway Object Storage met `Object Lock`, `Versioning` en `Lifecycle Rules`
- `SSE-ONE` of `SSE-C` voor encryptie van objecten
- Scaleway `Managed Database for PostgreSQL` als metadata store
- Scaleway `Cloud Essentials for OpenSearch` als zoekindex
- Scaleway `Serverless Functions` voor lichte verwerkingsstappen
- Scaleway `Serverless Containers` voor zwaardere of langer lopende control-plane services
- Scaleway `Queues` en optioneel `NATS` voor asynchrone verwerking
- Scaleway `IAM` voor identity en authorization
- Scaleway `Key Manager` en `Secret Manager` voor sleutel- en secretbeheer
- Scaleway `Audit Trail` en `Cockpit` voor audit, logging en observability
- Scaleway `VPC` en `Private Networks` voor netwerkisolatie

## Logische lagen

### 1. Ingress and Integration Layer

Componenten:

- API-service op `Serverless Containers` of `Serverless Functions`
- Scaleway `Object Storage` ingest bucket
- Scaleway `Queues`
- optioneel `NATS`

Taken:

- upload API aanbieden
- integraties met ERP, contract management en bulkimport ontvangen
- initiële validatie starten
- ingest events publiceren voor verdere verwerking

### 2. Processing and Control Layer

Componenten:

- `Serverless Functions`
- `Serverless Containers`
- `Queues`
- optioneel `NATS`
- geplande jobs via container/function triggers

Taken:

- ingest orchestration uitvoeren
- checksum, classificatie en metadata-extractie uitvoeren
- retention policy koppelen
- legal hold en dispositionprocessen aansturen
- uitzonderingen en herverwerking afhandelen

### 3. Archive Storage Layer

Componenten:

- Scaleway `Object Storage`
- `Object Lock`
- `Versioning`
- `Lifecycle Rules`
- `SSE-ONE` of `SSE-C`

Taken:

- immutable opslag van records
- retention en legal hold afdwingen op objectniveau
- lifecycle-gedreven transition naar goedkopere storage classes
- versleutelde opslag van documenten

### 4. Metadata and Index Layer

Componenten:

- Scaleway `Managed Database for PostgreSQL`
- Scaleway `Cloud Essentials for OpenSearch`

Taken:

- metadata als system of record vastleggen
- query- en filtermogelijkheden bieden
- een beperkte metadata-zoekindex voeden voor retrieval

### 5. Access and Administration Layer

Componenten:

- API-service op `Serverless Containers`
- optionele admin UI
- Scaleway `IAM`
- bucket policies op Object Storage

Taken:

- search en retrieval API's aanbieden
- beheerfunctionaliteit aanbieden
- RBAC en scope-based access afdwingen
- admin workflows voor policies, metadataregels en uitzonderingen ondersteunen

### 6. Compliance and Observability Layer

Componenten:

- Scaleway `Audit Trail`
- Scaleway `Cockpit`

Taken:

- audit events vastleggen
- beheeracties en platform-events herleidbaar maken
- operationele metrics, logs, traces en alerts bieden
- dashboards en operationele opvolging ondersteunen

## Referentieflow

## Document lifecycle on Scaleway

Een document doorloopt in deze referentiearchitectuur logisch deze fasen:

1. `Ingested`
   Het document wordt ontvangen, gevalideerd, geclassificeerd en van metadata voorzien.
2. `Archived in hot storage`
   Het document staat in primaire Object Storage voor directe toegang in de eerste periode van de lifecycle.
3. `Transitioned to cold storage`
   Na een configureerbare periode, bijvoorbeeld `2 jaar`, verplaatst lifecycle-beleid het document naar een lagere tier zoals `Standard One Zone` of `Glacier`, afhankelijk van policy en cloudkeuze.
4. `Restored for access`
   Indien nodig wordt een tijdelijke restore uitgevoerd voor retrieval van een document uit `Glacier`.
5. `Retention expired`
   Na afloop van de totale bewaartermijn, bijvoorbeeld `7 jaar`, komt het document in aanmerking voor disposition mits geen legal hold actief is.
6. `Disposed`
   Verwijdering of disposition wordt alleen via een gecontroleerde workflow uitgevoerd.

### Ingest flow

1. Een bron levert een document aan via API of bulkimport.
2. Het document komt binnen in een ingest bucket of via een ingest-service.
3. Een queue- of event-trigger start de verwerkingsketen.
4. Functions of containers voeren validatie, hashing, classificatie en metadata-extractie uit.
5. Metadata wordt vastgelegd in PostgreSQL.
6. Het document wordt opgeslagen in de archive bucket met `Object Lock`, encryptie en versioning.
7. Een zoekbaar documentrecord wordt gepubliceerd naar OpenSearch.
8. Audit- en operationele events worden vastgelegd in Audit Trail en Cockpit.

De standaard zoekindex op Scaleway bevat hierbij primair geselecteerde metadata-eigenschappen, bijvoorbeeld klantnummer, adres, subscription details en document business keys, en niet de volledige documentinhoud.

### Lifecycle to cold storage flow

1. Een lifecycle policy bepaalt na hoeveel tijd documenten uit hot storage naar een lagere Scaleway storage class moeten doorstromen en hoe dat zich verhoudt tot de totale retentionduur.
2. Lifecycle rules transitionen objecten bijvoorbeeld van `Standard Multi-AZ` of `Standard One Zone` naar `Glacier` waar ondersteund.
3. Metadata blijft beschikbaar in PostgreSQL en OpenSearch, inclusief storage tier status.
4. Retrieval van objecten in `Glacier` vereist eerst een restore voordat het object beschikbaar is.
5. Restore- en retrievalacties worden vastgelegd in Audit Trail en applicatie-audit.

### Retrieval flow

1. Een gebruiker of systeem zoekt via search API.
2. De applicatielaag leest metadata uit PostgreSQL en/of OpenSearch.
3. Autorisatie wordt gecontroleerd via IAM-gedreven applicatielogica en relevante bucket policies.
4. Het document wordt opgehaald uit Object Storage.
5. View of download wordt vastgelegd als audit event.

### Retention and disposition flow

1. Policies en triggerregels worden beheerd in de beheerlaag.
2. Een geplande workflow beoordeelt records op `retention_until`.
3. `Object Lock`, `legal hold` en andere blokkades worden gecontroleerd.
4. Gekwalificeerde records gaan naar een disposition workflow.
5. Besluit, uitvoering en bewijs worden auditeerbaar vastgelegd.

## Referentiecomponenten per feature

### Feature 01 - Ingest

- Serverless Functions
- Serverless Containers
- Object Storage ingest bucket
- Queues
- optioneel NATS

### Feature 02 - Immutable Archiving

- Object Storage archive bucket
- Object Lock
- Versioning
- Lifecycle Rules
- SSE-ONE of SSE-C
- Glacier as cold/archive tier where applicable

### Feature 03 - Administration and Operations

- admin API op Serverless Containers
- optionele admin UI
- Cockpit dashboards and alerts
- Audit Trail

### Feature 04 - Metadata Management

- Managed PostgreSQL
- Serverless Functions or Containers

### Feature 05 - Retention and Disposition

- Serverless Containers
- Managed PostgreSQL
- Object Lock
- Queues

### Feature 06 - Legal Hold

- Object Storage legal holds
- Managed PostgreSQL
- Serverless Containers

### Feature 07 - Audit Trail

- Audit Trail
- Cockpit Logs
- append-only applicatie-auditlaag in PostgreSQL of object storage export

### Feature 08 - Security and Access Control

- IAM
- bucket policies
- Key Manager
- Secret Manager

### Feature 09 - Search and Retrieval

- Cloud Essentials for OpenSearch
- Managed PostgreSQL
- Serverless Containers
- Object Storage

De OpenSearch-index blijft in deze referentiearchitectuur beperkt tot een beheerst metadata-profiel per documenttype. Full-text indexering kan later als aanvullende capability worden toegevoegd, maar is geen baseline.

### Feature 10 - Reporting and Compliance

- Managed PostgreSQL
- OpenSearch
- Audit Trail
- Cockpit

### Feature 11 - AI Metadata Determination

- externe AI/OCR service of later te bepalen AI-component
- Serverless Containers
- Serverless Functions
- Managed PostgreSQL

## Bounded parts op Scaleway

### A. Archive Control Plane

Scaleway invulling:

- Serverless Containers
- Serverless Functions
- Queues
- optioneel NATS
- Managed PostgreSQL

Capabilities:

- retention policy management
- legal hold orchestration
- classificatie- en metadataregels
- disposition workflow
- audit-triggering

### B. Archive Storage Plane

Scaleway invulling:

- Object Storage archive bucket
- Object Lock
- Lifecycle Rules
- Versioning
- SSE-ONE of SSE-C

Capabilities:

- immutable object storage
- versleutelde blobs
- tiering
- retention en legal hold op objectniveau

### C. Archive Access Plane

Scaleway invulling:

- Serverless Containers
- OpenSearch
- Managed PostgreSQL
- IAM

Capabilities:

- search
- retrieval
- admin actions
- reporting en evidence exports

## Aanbevolen Scaleway account- en omgevingsmodel

- Gebruik aparte `Projects` voor minimaal `prod` en `non-prod`.
- Scheid waar mogelijk ook auditgevoelige of beheergevoelige resources logisch.
- Beperk directe menselijke productietoegang via IAM groups en applications.
- Gebruik aparte identities voor CI/CD, runtime services en beheerders.

## Aanbevolen data-opslagmodel

### Document object

Opslag in Object Storage:

- origineel document
- versioning actief
- object lock actief
- encryptie via `SSE-ONE` of `SSE-C`

### Metadata record

Opslag in Managed PostgreSQL:

- `document_id`
- `document_type`
- `tenant`
- `legal_entity`
- `source_system`
- `business_key`
- `parties`
- `document_date`
- `retention_until`
- `legal_hold_flag`
- `object_storage_uri`
- `checksum`
- `lifecycle_status`
- `access_classification`

### Search document

Opslag in OpenSearch:

- query- en filtervelden
- genormaliseerde zoekvelden
- optioneel OCR/full-text velden

## Waarom PostgreSQL als metadata store

Deze referentiearchitectuur kiest `Managed PostgreSQL` als default metadata store omdat het goed past bij:

- rijk relationeel metadatamodel
- policy- en governance-query's
- documentrelaties
- audit- en beheerflows met meer relationele complexiteit

Voor Scaleway is dit pragmatischer dan zoeken naar een volledig serverless metadata store met vergelijkbare volwassenheid.

## Waarom OpenSearch naast PostgreSQL

PostgreSQL blijft hier system of record voor metadata, maar niet de primaire zoekengine voor retrieval op schaal.

Daarom:

- PostgreSQL beheert de waarheid
- OpenSearch verzorgt zoekindex en retrieval-ervaring

Dat houdt governance en zoekfunctionaliteit gescheiden.

## Beheerfunctionaliteit op Scaleway

Beheer wordt in deze referentiearchitectuur expliciet ondersteund via:

- admin API's en optionele admin UI
- policybeheer in control plane services
- lifecyclebeheer voor cold storage tiers
- beheer van metadataregels en classificatieregels
- operationele dashboards en alerts in Cockpit
- foutafhandeling via queues en herverwerking
- audit van beheeracties via Audit Trail en applicatie-audit

## Security baseline

- Buckets zijn niet publiek tenzij expliciet nodig.
- Gebruik `IAM` als primaire access control.
- Gebruik bucket policies voor aanvullende fine-grained Object Storage-toegang.
- Gebruik `Private Networks` voor interne communicatie tussen relevante services.
- Gebruik `Secret Manager` voor credentials en service secrets.
- Gebruik `Key Manager` voor klantbeheerde cryptografische workflows waar nodig.
- Encryptie in transit is verplicht.
- Gevoelige acties zoals export, legal hold en disposition krijgen aparte autorisatiepaden.

## Immutable storage op Scaleway

Scaleway ondersteunt hiervoor expliciet `Object Lock` met een WORM-model.

Belangrijke eigenschappen uit de documentatie:

- `Object Lock` moet bij bucketcreatie worden ingeschakeld.
- `Versioning` wordt dan automatisch geactiveerd en kan niet worden uitgeschakeld.
- Er zijn `Governance` en `Compliance` retention modes.
- `Legal hold` is beschikbaar op objectniveau.
- Lifecycle expiration negeert objecten die gelockt zijn of een legal hold hebben.

Architectuurimplicatie:

- maak aparte archive buckets die vanaf het begin met object lock zijn aangemaakt
- voorkom dat operationele of tijdelijke buckets dezelfde governance-eisen krijgen

## Lifecycle en cold storage op Scaleway

Deze referentiearchitectuur gebruikt `Lifecycle Rules` als standaard mechanisme om objecten door te laten stromen naar goedkopere storage classes.

Relevante Scaleway-eigenschappen uit de huidige documentatie:

- Scaleway ondersteunt lifecycle `transition` en `expiration` acties.
- Ondersteunde transitions zijn momenteel `Standard Multi-AZ -> Standard One Zone`, `Standard Multi-AZ -> Glacier` en `Standard One Zone -> Glacier`.
- `Glacier` is een archive storage class die eerst restored moet worden voordat objecten weer toegankelijk zijn.
- De huidige lifecycle documentatie noemt minimale bewaartijden voor bepaalde transitions, waaronder `30 dagen` voor overgang naar `Standard One Zone` en `90 dagen` voor overgang naar `Glacier` in bepaalde regio's en voor rules die na de genoemde data zijn gemaakt of bijgewerkt.
- Lifecycle expiration mag governance niet doorbreken; gelockte objecten of objecten met legal hold moeten in governance-ontwerp als beschermd blijven gelden.

Architectuurimplicatie:

- lifecycle policies moeten region-awareness hebben, omdat cold-tier gedrag en minimale durations region- en datumafhankelijk kunnen zijn
- lifecycle-configuratie moet tijdsvensters ondersteunen, bijvoorbeeld `2 jaar hot` en daarna `5 jaar cold` binnen een totale bewaartermijn van `7 jaar`
- restore uit `Glacier` moet als expliciete retrieval-state in de metadata- en accesslaag worden gemodelleerd
- cold storage policy’s moeten samen ontworpen worden met object lock, legal hold en retention policies

## Encryptiekeuze op Scaleway

Voor objecten zijn er twee praktische opties:

- `SSE-ONE`
  Dit is de eenvoudigste standaardoptie voor encryptie at rest met door Scaleway beheerde sleutels.

- `SSE-C`
  Dit is relevant als je meer sleutelcontrole wilt houden, maar het legt sleutelverantwoordelijkheid ook nadrukkelijker bij de applicatie of het platformteam.

Belangrijke nuance:

`Scaleway Key Manager` bestaat expliciet als product voor cryptografische sleutels en sleuteloperaties. De nuance zit hier in de integratie met `Object Storage`: de huidige Object Storage documentatie beschrijft voor object-encryptie vooral `SSE-ONE` en `SSE-C`, niet dezelfde directe `S3 SSE-KMS`-achtige bucket-encryptie-ervaring als op AWS.

Architectuurimplicatie:

- gebruik `Key Manager` voor bredere platform- of applicatiecryptografie waar relevant
- modelleer object-encryptie in deze referentiearchitectuur primair via `SSE-ONE` of `SSE-C`
- behandel een eventuele latere directe `Key Manager`-integratie met Object Storage als aparte ontwerpkeuze, niet als huidige baseline

## AI-uitbreiding op Scaleway

Voor latere AI-verrijking:

- orkestreer extractie via containers of functions
- sla AI-provenance, confidence en reviewstatus op in PostgreSQL
- laat AI nooit governance-kritieke metadata ongecontroleerd overschrijven

Omdat de definitieve OCR/AI-keten op Scaleway hier nog niet vastligt, blijft dit in deze referentiearchitectuur bewust logisch en niet product-hardcoded.

## Belangrijkste Scaleway-beslissingen

- Gebruik `Object Storage Object Lock` voor immutable archivering.
- Gebruik `Managed PostgreSQL` als metadata system of record.
- Gebruik `Cloud Essentials for OpenSearch` voor metadata-first retrieval.
- Gebruik `Serverless Functions` voor kleine eventgedreven stappen.
- Gebruik `Serverless Containers` voor zwaardere control-plane en API-services.
- Gebruik `Queues` en waar passend `NATS` voor asynchrone loskoppeling.
- Gebruik `IAM`, `bucket policies`, `Secret Manager`, `Key Manager`, `Audit Trail` en `Cockpit` als security- en operations-baseline.

## Open ontwerpkeuzes voor de volgende stap

- Wordt de admin UI een aparte webapplicatie of onderdeel van een containerized admin service?
- Gebruiken we alleen `Queues`, of ook `NATS` voor event streaming en replay?
- Welke OpenSearch-capaciteit is nodig voor compliance-heavy zoekgedrag?
- Kiezen we voor `SSE-ONE` als default, of wordt `SSE-C` een harde eis voor gevoelige archiefstromen?
- Welke AI/OCR-keten past het best als fase-2 uitbreiding op Scaleway?

## Bronverwijzingen

Gebruikte Scaleway-documentatie:

- [Object Storage documentation](https://www.scaleway.com/en/docs/object-storage/)
- [Object Storage concepts](https://www.scaleway.com/en/docs/object-storage/concepts/)
- [How to manage lifecycle rules](https://www.scaleway.com/en/docs/object-storage/how-to/manage-lifecycle-rules/)
- [Setting up object lock](https://www.scaleway.com/en/docs/object-storage/api-cli/object-lock/)
- [How to use bucket versioning](https://www.scaleway.com/en/docs/object-storage/how-to/use-bucket-versioning/)
- [Bucket policies overview](https://www.scaleway.com/en/docs/object-storage/api-cli/bucket-policy/)
- [Enabling SSE-ONE](https://www.scaleway.com/en/docs/object-storage/api-cli/enable-sse-one/)
- [Enabling SSE-C](https://www.scaleway.com/en/docs/object-storage/api-cli/enable-sse-c/)
- [Managed Database for PostgreSQL and MySQL](https://www.scaleway.com/en/docs/managed-databases-for-postgresql-and-mysql/)
- [Cloud Essentials for OpenSearch](https://www.scaleway.com/en/docs/opensearch/how-to/connect-to-opensearch-deployment/)
- [Queues documentation](https://www.scaleway.com/en/docs/queues/)
- [NATS documentation](https://www.scaleway.com/en/docs/nats/)
- [Serverless Functions use cases](https://www.scaleway.com/en/docs/serverless-functions/reference-content/functions-use-cases/)
- [Serverless Containers documentation](https://www.scaleway.com/en/docs/serverless-containers/)
- [VPC documentation](https://www.scaleway.com/en/docs/vpc/)
- [IAM](https://www.scaleway.com/en/iam/)
- [Audit Trail concepts](https://www.scaleway.com/en/docs/audit-trail/concepts)
- [How to use Audit Trail](https://www.scaleway.com/en/docs/audit-trail/how-to/use-audit-trail/)
- [Key Manager](https://www.scaleway.com/en/docs/key-manager/faq/)
- [Scaleway Key Manager product page](https://www.scaleway.com/en/key-manager/)
- [Secret Manager](https://www.scaleway.com/en/docs/secret-manager/)
- [Cockpit concepts](https://www.scaleway.com/en/docs/cockpit/concepts/)
