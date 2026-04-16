#  Codex Skills Required

## Doel

Dit document beschrijft welke implementatieskills Codex nodig heeft om deze archive-oplossing gestructureerd te kunnen bouwen.

De skills zijn bedoeld als triggerbare werkmodi voor implementatie, niet als productfeatures.

## Waarom eerst de skills

Eerst de skills definiëren en daarna de stories uitwerken is voor dit project de juiste volgorde.

Waarom:

- stories worden daardoor uitvoerbaar in plaats van alleen beschrijvend
- elke story kan aan een primaire skill en ondersteunende skills worden gekoppeld
- platformspecifieke verschillen blijven schoon gescheiden
- implementatie, test, beheer en cloudkeuzes lopen minder snel door elkaar

## Skillgroepen

- generieke implementatieskills
- AWS-platformskills
- Scaleway-platformskills
- latere optionele skills

## Generieke implementatieskills

### architecture

Doel:

- bounded parts bepalen
- servicegrenzen definiëren
- event- en processtromen ontwerpen
- keuzes tussen sync en async gedrag maken

Typische inzet:

- control plane
- storage plane
- access plane
- lifecycle van document en metadata

### backend

Doel:

- API's en servicegedrag bouwen
- business rules implementeren
- retention, legal hold en retrievallogica afdwingen

Typische inzet:

- upload API
- retrieval API
- admin API
- evidence export

### persistence

Doel:

- metadata store modelleren
- audit store structureren
- mutability rules vastleggen
- relaties en querypatronen modelleren

Typische inzet:

- metadata system of record
- searchable properties
- policy state
- provenance

### serverless

Doel:

- event-driven verwerking opzetten
- retries, DLQ's en workflowgrenzen bepalen
- orchestration logica klein en beheersbaar houden

Typische inzet:

- ingest chain
- retention jobs
- restore flows
- async exceptions

### infrastructure-as-code

Doel:

- OpenTofu modules en live stacks ontwerpen
- cloud resources reproduceerbaar beheren
- policies, permissions en storageconfiguratie codificeren

Typische inzet:

- buckets
- queues
- IAM
- observability
- environment wiring

### security

Doel:

- least privilege afdwingen
- encryptie correct toepassen
- key usage beheersen
- admin en gevoelige paden beschermen

Typische inzet:

- RBAC
- scope-based access
- service permissions
- legal hold governance

### testing

Doel:

- functionele, integratie- en contracttests bepalen
- workflow- en policygedrag verifiëren
- regressierisico op compliancegedrag verkleinen

Typische inzet:

- ingest validation
- policy application
- search behavior
- restore and disposition flows

### observability

Doel:

- metrics, logs, traces en alerts ontwerpen
- backlog, failures en retries zichtbaar maken
- operations en audit evidence ondersteunen

Typische inzet:

- ingest operations
- lifecycle jobs
- exception queues
- admin dashboards

### ux-admin

Doel:

- beheerconsole en reviewflows bruikbaar maken
- complexe governance-acties begrijpelijk en veilig presenteren

Typische inzet:

- policy administration
- legal hold screens
- metadata review
- restore status

### search

Doel:

- metadata-first zoekgedrag ontwerpen
- indexprofielen bepalen
- querypatronen en retrievalflows modelleren

Typische inzet:

- business-key search
- indexed property profile
- search result filters
- restore-aware retrieval

### document-processing

Doel:

- document intake, validatie en checksuming ontwerpen
- malware scan hooks en extractiestappen structureren

Typische inzet:

- ingest
- migration backfill
- metadata extraction

### finops

Doel:

- architectuurkeuzes spiegelen aan kosten
- lifecycle, logging, search en retrieval als cost drivers bewaken

Typische inzet:

- calculator updates
- storage tiering keuzes
- logging discipline
- migration planning

## AWS-platformskills

### aws-serverless

Doel:

- AWS serverless bouwstenen correct inzetten

Scope:

- API Gateway
- Lambda
- Step Functions
- EventBridge
- SQS

### aws-storage

Doel:

- AWS-opslaggedrag correct modelleren voor archive use cases

Scope:

- S3
- Object Lock
- Versioning
- Lifecycle
- Glacier Flexible Retrieval
- Glacier Deep Archive

### aws-security

Doel:

- AWS identity en sleutelbeheer correct toepassen

Scope:

- IAM
- IAM Identity Center
- KMS
- bucket policies

### aws-data

Doel:

- metadata, audit en search correct op AWS modelleren

Scope:

- DynamoDB
- OpenSearch Service
- data access patterns

### aws-observability

Doel:

- AWS monitoring en auditability goed inrichten

Scope:

- CloudWatch
- CloudTrail
- alarms
- dashboards

### aws-compliance

Doel:

- AWS primitives correct vertalen naar archive controls

Scope:

- immutability
- retention
- legal hold
- disposition evidence
- recovery boundaries

## Scaleway-platformskills

### scaleway-serverless

Doel:

- Scaleway serverless bouwstenen correct inzetten

Scope:

- Serverless Functions
- Serverless Containers
- Queues
- optioneel NATS

### scaleway-storage

Doel:

- Scaleway-opslaggedrag correct modelleren voor archive use cases

Scope:

- Object Storage
- Object Lock
- Versioning
- Lifecycle Rules
- Standard One Zone
- Glacier

### scaleway-security

Doel:

- Scaleway identity en sleutelbeheer correct toepassen

Scope:

- IAM
- Key Manager
- Secret Manager
- bucket policies
- SSE-ONE
- SSE-C

### scaleway-data

Doel:

- metadata, audit en search correct op Scaleway modelleren

Scope:

- Managed PostgreSQL
- OpenSearch
- data access patterns

### scaleway-observability

Doel:

- Scaleway monitoring en auditability goed inrichten

Scope:

- Cockpit
- Audit Trail
- logs
- metrics
- dashboards

### scaleway-compliance

Doel:

- Scaleway primitives correct vertalen naar archive controls

Scope:

- immutability
- retention
- legal hold
- restore-aware retrieval
- recovery boundaries

## Latere optionele skills

### ai-governance

Doel:

- AI veilig en herleidbaar inzetten zonder governance te doorbreken

Typische inzet:

- metadata suggestion
- confidence thresholds
- mandatory review
- provenance

### migration-engineering

Doel:

- historische import en backfill gestructureerd uitvoeren

Typische inzet:

- throughput planning
- import batches
- metadata backfill
- index backfill

## Minimale skillset voor fase 1

Voor de eerste werkende archive-slices is minimaal nodig:

- architecture
- backend
- persistence
- serverless
- infrastructure-as-code
- security
- testing
- observability
- document-processing

En per platform:

- AWS: `aws-serverless`, `aws-storage`, `aws-security`, `aws-data`
- Scaleway: `scaleway-serverless`, `scaleway-storage`, `scaleway-security`, `scaleway-data`

## Gebruik in stories

Elke story hoort later minimaal deze skillvelden te krijgen:

- `primary skill`
- `supporting skills`
- `platform skill`
- `optional skills`

Daarmee worden stories direct triggerbaar voor implementatie.
