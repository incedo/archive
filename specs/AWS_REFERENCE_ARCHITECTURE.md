# AWS Reference Architecture

## Doel

Deze referentiearchitectuur beschrijft een AWS-variant van het compliance archive voor contracts en invoices.

De architectuur is:

- feature-gedreven
- cloud-specifiek voor AWS
- nog niet implementatie-specifiek op storyniveau

## Architectuurprincipes

- S3 is de archieflaag voor documenten.
- Immutable storage is een harde eis voor records.
- Metadata is leidend voor beheer, search en compliance.
- Governance loopt via policies, legal holds, audit trail en RBAC.
- Event-driven verwerking verdient de voorkeur boven synchrone ketens.
- AI voor metadata is optioneel en later toevoegbaar.

## Hoofdkeuze

Deze AWS-referentiearchitectuur gebruikt primair:

- Amazon S3 met Object Lock als archiefopslag
- AWS KMS voor encryptiesleutels
- Amazon DynamoDB als metadata store
- Amazon OpenSearch Service als zoekindex
- AWS Lambda voor applicatielogica
- AWS Step Functions voor orkestratie
- Amazon EventBridge voor event routing
- Amazon SQS voor asynchrone buffering en retry-afhandeling
- Amazon API Gateway voor externe API-toegang
- AWS CloudTrail en Amazon CloudWatch voor audit en operations
- AWS IAM Identity Center en IAM voor workforce access en workload authorization
- Amazon Textract als optionele OCR/AI-verrijking

## Logische lagen

### 1. Ingress and Integration Layer

Componenten:

- Amazon API Gateway
- AWS Lambda
- Amazon S3 ingest bucket
- Amazon SQS
- Amazon EventBridge

Taken:

- upload API aanbieden
- integraties met ERP, contract management en bulkimport ontvangen
- initiële validatie starten
- events publiceren voor verdere verwerking

### 2. Processing and Control Layer

Componenten:

- AWS Step Functions
- AWS Lambda
- Amazon SQS dead-letter queues
- Amazon EventBridge

Taken:

- ingest orchestreren
- checksum, classificatie en metadata-extractie uitvoeren
- retention policy koppelen
- legal hold en dispositionprocessen aansturen
- uitzonderingen en herverwerking afhandelen

### 3. Archive Storage Layer

Componenten:

- Amazon S3 archive bucket
- S3 Object Lock
- S3 Versioning
- S3 Lifecycle policies
- optioneel S3 Replication
- AWS KMS

Taken:

- immutable opslag van records
- versleutelde opslag
- retention en legal hold afdwingen op objectniveau
- lifecycle-gedreven tiering naar goedkopere storage classes
- replicatie voor recovery of tweede regio

### 4. Metadata and Index Layer

Componenten:

- Amazon DynamoDB
- Amazon OpenSearch Service

Taken:

- metadata als system of record vastleggen
- query- en filtermogelijkheden bieden
- een beperkte metadata-zoekindex voeden voor retrieval

### 5. Access and Administration Layer

Componenten:

- Amazon API Gateway
- AWS Lambda
- optioneel admin UI op AWS-hostinglaag
- AWS IAM Identity Center
- AWS IAM

Taken:

- search en retrieval API's aanbieden
- beheerfunctionaliteit aanbieden
- RBAC en scope-based access afdwingen
- admin workflows voor policies, metadataregels en uitzonderingen ondersteunen

### 6. Compliance and Observability Layer

Componenten:

- AWS CloudTrail
- Amazon CloudWatch
- optioneel AWS Config

Taken:

- audit events vastleggen
- API calls en beheeracties herleidbaar maken
- operationele metrics, alarms en dashboards bieden
- compliance drift signaleren

## Referentieflow

## Document lifecycle on AWS

Een document doorloopt in deze referentiearchitectuur logisch deze fasen:

1. `Ingested`
   Het document wordt ontvangen, gevalideerd, geclassificeerd en van metadata voorzien.
2. `Archived in hot storage`
   Het document staat in primaire S3-opslag voor directe toegang in de eerste periode van de lifecycle.
3. `Transitioned to cold storage`
   Na een configureerbare periode, bijvoorbeeld `2 jaar`, verplaatst lifecycle-beleid het document naar een cold tier zoals `Glacier Flexible Retrieval` of `Glacier Deep Archive`.
4. `Restored for access`
   Indien nodig wordt een tijdelijke restore uitgevoerd voor retrieval van een document uit cold storage.
5. `Retention expired`
   Na afloop van de totale bewaartermijn, bijvoorbeeld `7 jaar`, komt het document in aanmerking voor disposition mits geen legal hold actief is.
6. `Disposed`
   Verwijdering of disposition wordt alleen via een gecontroleerde workflow uitgevoerd.

### Ingest flow

1. Een bron levert een document aan via API Gateway of bulkimport.
2. Het document wordt tijdelijk ontvangen in een ingest bucket of direct verwerkt.
3. EventBridge of S3-events starten een Step Functions workflow.
4. Lambda-functies voeren validatie, malware scan-integratie, hashing en classificatie uit.
5. Metadata wordt vastgelegd in DynamoDB.
6. Het document wordt opgeslagen in de archive bucket met Object Lock en encryptie.
7. Een zoekbaar documentrecord wordt gepubliceerd naar OpenSearch.
8. Audit events worden vastgelegd voor ingest en archivering.

De standaard zoekindex op AWS bevat hierbij primair geselecteerde metadata-eigenschappen, bijvoorbeeld klantnummer, adres, subscription details en document business keys, en niet de volledige documentinhoud.

### Lifecycle to cold storage flow

1. Een lifecycle policy bepaalt na hoeveel tijd documenten uit hot storage naar een lagere S3 storage class moeten doorstromen en hoe dat zich verhoudt tot de totale retentionduur.
2. S3 Lifecycle transition rules verplaatsen documenten bijvoorbeeld van `S3 Standard` naar `S3 Glacier Flexible Retrieval` of `S3 Glacier Deep Archive`.
3. Metadata blijft beschikbaar in DynamoDB en OpenSearch, inclusief storage tier status.
4. Retrieval van gearchiveerde objecten kan een restore-stap vereisen voordat toegang mogelijk is.
5. Restore- en retrievalacties worden vastgelegd in audit- en operationele logs.

### Retrieval flow

1. Een gebruiker of systeem zoekt via search API.
2. De applicatielaag leest metadata uit DynamoDB en/of OpenSearch.
3. Autorisatie wordt gecontroleerd via IAM-gerelateerde applicatielogica.
4. Het document wordt opgehaald uit S3.
5. View of download wordt als audit event vastgelegd.

### Retention and disposition flow

1. Policies en triggerregels worden beheerd in de beheerlaag.
2. Een geplande workflow beoordeelt documenten op `retention_until`.
3. Legal hold en andere blokkades worden gecontroleerd.
4. Gekwalificeerde records gaan naar een disposition workflow.
5. Besluit, uitvoering en bewijs worden auditeerbaar vastgelegd.

## Referentiecomponenten per feature

### Feature 01 - Ingest

- API Gateway
- Lambda
- S3 ingest bucket
- EventBridge
- SQS
- Step Functions

### Feature 02 - Immutable Archiving

- S3 archive bucket
- S3 Object Lock
- S3 Versioning
- S3 Lifecycle
- AWS KMS
- S3 Glacier Flexible Retrieval or S3 Glacier Deep Archive for cold/archive tiers

### Feature 03 - Administration and Operations

- API Gateway
- Lambda
- admin UI
- CloudWatch dashboards and alarms
- CloudTrail

### Feature 04 - Metadata Management

- DynamoDB
- Lambda
- Step Functions

### Feature 05 - Retention and Disposition

- Step Functions
- DynamoDB
- S3 Object Lock
- EventBridge

### Feature 06 - Legal Hold

- S3 Object Lock legal holds
- DynamoDB
- Lambda
- Step Functions

### Feature 07 - Audit Trail

- CloudTrail
- CloudWatch Logs
- DynamoDB of append-only audit store, afhankelijk van detailniveau

### Feature 08 - Security and Access Control

- IAM Identity Center
- IAM
- KMS
- API authorization in applicatielaag

### Feature 09 - Search and Retrieval

- OpenSearch Service
- DynamoDB
- API Gateway
- Lambda
- S3

De OpenSearch-index blijft in deze referentiearchitectuur beperkt tot een beheerst metadata-profiel per documenttype. Full-text indexering kan later als aanvullende capability worden toegevoegd, maar is geen baseline.

### Feature 10 - Reporting and Compliance

- DynamoDB
- OpenSearch
- CloudTrail
- CloudWatch

### Feature 11 - AI Metadata Determination

- Amazon Textract
- Lambda
- Step Functions
- DynamoDB

## Bounded parts op AWS

### A. Archive Control Plane

AWS invulling:

- Step Functions
- Lambda
- EventBridge
- DynamoDB

Capabilities:

- retention policy management
- legal hold orchestration
- classificatie- en metadataregels
- disposition workflow
- audit-triggering

### B. Archive Storage Plane

AWS invulling:

- S3 archive bucket
- Object Lock
- Lifecycle policies
- Replication
- KMS

Capabilities:

- immutable object storage
- encryptie
- tiering
- recovery

### C. Archive Access Plane

AWS invulling:

- API Gateway
- Lambda
- OpenSearch
- DynamoDB
- IAM Identity Center

Capabilities:

- search
- retrieval
- admin actions
- reporting en evidence exports

## Aanbevolen AWS account- en omgevingsmodel

- Gebruik een multi-account opzet via AWS Organizations.
- Scheid minimaal `prod`, `non-prod` en `log archive/security`.
- Beperk directe menselijke toegang tot productie.
- Laat workforce access via IAM Identity Center lopen.
- Houd KMS-sleutels, auditlogs en archiefstorage extra strikt gescheiden.

## Aanbevolen data-opslagmodel

### Document object

Opslag in S3:

- origineel document
- versiebeheer actief
- object lock actief
- encryptie via KMS

### Metadata record

Opslag in DynamoDB:

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

## Waarom DynamoDB als metadata store

Deze referentiearchitectuur kiest DynamoDB als default metadata store omdat het goed past bij:

- hoge schaal en lage operationele overhead
- event-driven verwerking
- key-based lookup op `document_id`
- voorspelbare performance voor operationele metadata

Als sterk relationele queries, complexe joins of zwaar transactioneel beheer dominant worden, kan een relationele variant later nog apart worden uitgewerkt. Voor deze referentiearchitectuur is DynamoDB de pragmatische AWS-default.

## Waarom OpenSearch naast DynamoDB

DynamoDB is hier niet de primaire zoekengine voor samengestelde filters en vrije zoekvragen. Daarom:

- DynamoDB blijft system of record voor metadata
- OpenSearch wordt de zoekindex voor retrieval en filtering

Dat houdt governance en zoekfunctionaliteit gescheiden.

## Beheerfunctionaliteit op AWS

Beheer wordt in deze referentiearchitectuur expliciet ondersteund via:

- admin API's en optionele admin UI
- policybeheer in control plane services
- lifecyclebeheer voor cold storage tiers
- beheer van metadataregels en classificatieregels
- operationele dashboards in CloudWatch
- foutafhandeling via queues, dead-letter queues en herverwerking
- audit van beheeracties via CloudTrail en applicatie-audit

## Security baseline

- S3 buckets zijn niet publiek.
- Encryptie at rest gebruikt KMS.
- Encryptie in transit is verplicht.
- IAM-rollen gebruiken least privilege.
- Menselijke toegang verloopt via IAM Identity Center.
- Gevoelige acties zoals export, legal hold en disposition krijgen aparte autorisatiepaden.
- Auditlogs en archiefdata zijn logisch gescheiden.

## Lifecycle en cold storage op AWS

Deze referentiearchitectuur gebruikt `S3 Lifecycle` als standaard mechanisme om objecten door te laten stromen naar goedkopere storage classes.

Relevante AWS-eigenschappen:

- S3 Lifecycle ondersteunt transition actions en expiration actions op bucketniveau via rules.
- Voor archivering zijn `S3 Glacier Flexible Retrieval` en `S3 Glacier Deep Archive` de relevante cold tiers.
- Gearchiveerde objecten zijn niet direct real-time beschikbaar; een restore van een tijdelijke kopie kan nodig zijn.
- AWS documenteert dat lifecycle transition requests kosten hebben.
- AWS documenteert ook dat objecten kleiner dan `128 KB` sinds de huidige default niet meer standaard naar een andere storage class transitionen, tenzij je dit expliciet toestaat via lifecycle-configuratie.

Architectuurimplicatie:

- lifecycle rules moeten expliciet rekening houden met kleine objecten zoals eenvoudige invoices
- lifecycle-configuratie moet tijdsvensters ondersteunen, bijvoorbeeld `2 jaar hot` en daarna `5 jaar cold` binnen een totale bewaartermijn van `7 jaar`
- cold storage moet als retrieval-state in metadata worden gemodelleerd, niet alleen als storage-implementatiedetail
- restore-status moet zichtbaar zijn in access- en retrievalflows

## AI-uitbreiding op AWS

Voor latere AI-verrijking:

- gebruik Textract voor OCR, forms, tables en invoice-gerichte extractie
- orkestreer verwerking via Step Functions
- sla AI-provenance, confidence en reviewstatus op in DynamoDB
- laat AI nooit governance-kritieke metadata ongecontroleerd overschrijven

## Belangrijkste AWS-beslissingen

- Gebruik `S3 Object Lock` in `compliance mode` voor echte immutable archivering.
- Gebruik `DynamoDB` als metadata system of record.
- Gebruik `OpenSearch Service` voor metadata-first retrieval.
- Gebruik `Step Functions` voor stateful governance workflows.
- Gebruik `EventBridge` en `SQS` voor losse koppeling en fouttolerante verwerking.
- Gebruik `IAM Identity Center` voor workforce access.

## Open ontwerpkeuzes voor de volgende stap

- Wordt de admin UI volledig serverless of draait die als aparte webapplicatie?
- Komt OCR/full-text direct in scope of pas in fase 2?
- Is cross-region replicatie verplicht voor compliance of alleen voor disaster recovery?
- Wordt auditdetail uitsluitend via CloudTrail aangevuld, of komt er een apart audit event store?
- Welke metadata-entiteiten krijgen een eigen configuratiemodel in DynamoDB?

## Bronverwijzingen

Gebruikte AWS-documentatie:

- [Amazon S3 Object Lock overview](https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lock-overview.html)
- [Managing the lifecycle of objects](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)
- [Transitioning objects using Amazon S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html)
- [Configuring S3 Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock-configure.html)
- [S3 Object Lock considerations and replication](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock-managing.html)
- [S3 Lifecycle rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/intro-lifecycle-rules.html)
- [AWS KMS overview](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)
- [AWS CloudTrail user guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
- [Amazon OpenSearch Service overview](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/what-is.html)
- [Amazon DynamoDB overview](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
- [AWS Step Functions overview](https://docs.aws.amazon.com/step-functions/latest/apireference/Welcome.html)
- [Amazon S3 and EventBridge integration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/EventBridge.html)
- [AWS IAM getting started](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started.html)
- [What is IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [What is Amazon Textract](https://docs.aws.amazon.com/textract/latest/dg/what-is.html)
