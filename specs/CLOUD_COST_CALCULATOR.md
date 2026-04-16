# Cloud Cost Calculator

## Doel

Deze calculator is bedoeld om snel cloudkeuzes te ondersteunen voor het archive-platform.

De calculator is:

- feature-gedreven
- richtinggevend voor architectuurkeuzes
- niet bedoeld als definitieve offerte of budgetcommitment

## Status

Versie: `v0.1`

Peildatum prijsbronnen: `2026-03-13`

## Belangrijke notities

- `AWS` prijzen in dit document zijn in `USD`.
- `Scaleway` prijzen in dit document zijn in `EUR`.
- Vergelijk clouds alleen goed na normalisatie naar dezelfde valuta.
- `AWS` is hier concreter, omdat er al een AWS-referentiearchitectuur ligt.
- `Scaleway` is inmiddels gekoppeld aan een eerste referentiearchitectuur, maar pricing voor de exacte search-, database- en orchestration-capaciteit blijft nog indicatief.

## Waar de kosten echt vandaan komen

Voor dit type archive komen de kosten meestal niet primair uit opslag alleen.

De grootste cost drivers zijn meestal:

1. zoekindex en querylaag
2. audit/logging en observability
3. OCR/AI metadata extractie
4. compute voor ingest en workflows
5. retrieval en exportvolume
6. pas daarna pure archiefopslag

## Gedeelde workload-inputs

Gebruik deze inputs voor beide clouds.

| Input | Eenheid | Betekenis |
|---|---:|---|
| `documents_ingested_per_month` | aantal | Nieuwe documenten per maand |
| `avg_document_size_mb` | MB | Gemiddelde documentgrootte |
| `pages_per_document` | aantal | Gemiddeld aantal pagina's per document |
| `active_storage_gb` | GB/maand | Documenten die in primaire opslag blijven |
| `cold_archive_storage_gb` | GB/maand | Documenten in cold/archive tier |
| `retrieval_gb_per_month` | GB | Gedownloade of gerestorede data |
| `api_calls_per_month` | aantal | Externe API-calls naar upload/search/retrieve/admin |
| `workflow_executions_per_month` | aantal | Aantal ingest/governance workflows |
| `workflow_state_transitions_per_exec` | aantal | Gemiddeld aantal workflowstappen |
| `function_invocations_per_month` | aantal | Serverless compute invocations |
| `function_avg_memory_gb` | GB | Gemiddeld toegewezen geheugen per functie |
| `function_avg_duration_seconds` | seconden | Gemiddelde duur per functie-executie |
| `metadata_read_requests_per_month` | aantal | Reads op metadata store |
| `metadata_write_requests_per_month` | aantal | Writes op metadata store |
| `search_index_storage_gb` | GB/maand | Zoekindex grootte |
| `search_query_hours_per_month` | uur | Richtgetal voor actieve query/index capaciteit |
| `kms_or_keymanager_key_count` | aantal | Aantal klantbeheerde sleutels |
| `kms_or_keymanager_requests_per_month` | aantal | Encrypt/decrypt/sign calls |
| `audit_management_events_per_month` | aantal | Audit management events |
| `audit_data_events_per_month` | aantal | Audit data events |
| `custom_logs_gb_per_month` | GB | Applicatie- en custom log volume |
| `ocr_or_ai_pages_per_month` | aantal pagina's | Pagina's voor OCR/AI metadata extractie |

## Basisformules

### Document volume

```text
monthly_ingest_gb =
  documents_ingested_per_month * avg_document_size_mb / 1024
```

### Function compute

```text
function_gb_seconds_per_month =
  function_invocations_per_month
  * function_avg_memory_gb
  * function_avg_duration_seconds
```

### Workflow transitions

```text
workflow_state_transitions_per_month =
  workflow_executions_per_month * workflow_state_transitions_per_exec
```

## Feature-to-cost mapping

| Feature | Grootste cost drivers |
|---|---|
| Ingest | API calls, workflow orchestration, functions, scan/OCR |
| Immutable Archiving | object storage, retrieval, replication, lifecycle |
| Administration and Operations | dashboards, logs, admin API usage |
| Metadata Management | metadata store reads/writes, index sync |
| Retention and Disposition | workflow runs, audit events |
| Legal Hold | metadata updates, governance workflows |
| Audit Trail | management/data events, log ingestion, storage |
| Security and Access Control | keys, key operations, identity overhead |
| Search and Retrieval | search cluster/serverless search, retrieval GB |
| Reporting and Compliance | queries, export volume, dashboards |
| AI Metadata Determination | OCR/AI page processing, review workflows |

## AWS Calculator

Region-aanname voor richtprijzen in voorbeelden: `US East (N. Virginia)` waar expliciet genoemd.

### AWS service-lijnen

| Cost line | Formule | Starter rate | Bron |
|---|---|---:|---|
| `S3 GET requests` | `get_requests / 1000 * rate` | `$0.0004 per 1,000 GET` | [S3 pricing example](https://aws.amazon.com/s3/pricing/) |
| `Lambda requests` | `function_invocations_per_month / 1,000,000 * rate` | `$0.20 per 1M requests` | [AWS Lambda pricing](https://aws.amazon.com/lambda/pricing/) |
| `Lambda compute` | `function_gb_seconds_per_month * rate` | `$0.0000167 per GB-second` | [S3 pricing example using Lambda](https://aws.amazon.com/s3/pricing/) |
| `API Gateway HTTP` | tiered by request volume | `$1.00 per 1M` for first 300M in example | [API Gateway pricing](https://aws.amazon.com/api-gateway/pricing/) |
| `API Gateway REST` | `api_calls_per_month / 1,000,000 * rate` | `$3.50 per 1M requests` | [API Gateway pricing](https://aws.amazon.com/api-gateway/pricing/) |
| `Step Functions` | `workflow_state_transitions_per_month * rate` | `$0.000025 per state transition`, first `4,000` free | [Step Functions pricing](https://aws.amazon.com/step-functions/pricing/) |
| `DynamoDB storage` | `metadata_storage_gb * rate` | example shows `$0.25/GB` | [DynamoDB pricing](https://aws.amazon.com/dynamodb/pricing/on-demand/) |
| `DynamoDB writes` | `write_request_units_million * rate` | example shows `$0.625 per million replicated writes` | [DynamoDB pricing](https://aws.amazon.com/dynamodb/pricing/on-demand/) |
| `KMS key storage` | `kms_or_keymanager_key_count * rate` | `$1 per key/month` | [AWS KMS pricing](https://aws.amazon.com/kms/pricing/) |
| `KMS requests` | `max(0, kms_requests_per_month - 20,000) / 10,000 * rate` | `$0.03 per 10,000 requests` after free tier | [AWS KMS pricing](https://aws.amazon.com/kms/pricing/) |
| `CloudTrail management events` | copies beyond first free copy | `$2.00 per 100,000 events` | [AWS CloudTrail pricing](https://aws.amazon.com/cloudtrail/pricing/) |
| `CloudTrail data events` | `audit_data_events_per_month / 100,000 * rate` | `$0.10 per 100,000 events` | [AWS CloudTrail pricing](https://aws.amazon.com/cloudtrail/pricing/) |
| `CloudWatch Logs ingestion` | `custom_logs_gb_per_month * rate` | example shows `$0.50/GB` | [CloudWatch pricing examples](https://aws.amazon.com/cloudwatch/pricing/) |
| `OpenSearch Serverless storage` | `search_index_storage_gb * rate` | `$0.02/GB-month` in example | [OpenSearch pricing](https://aws.amazon.com/opensearch-service/pricing/) |
| `OpenSearch Serverless OCU` | `search_query_hours_per_month * rate` | `$0.24 per OCU-hour` in example | [OpenSearch pricing](https://aws.amazon.com/opensearch-service/pricing/) |
| `Textract forms` | `ocr_or_ai_pages_per_month * rate` | `$0.05/page` example for forms | [Textract pricing](https://aws.amazon.com/textract/pricing/) |
| `Textract tables` | `ocr_or_ai_pages_per_month * rate` | `$0.015/page` example for tables | [Textract pricing](https://aws.amazon.com/textract/pricing/) |

### AWS snelle rekenregels

```text
aws_lambda_requests_cost =
  function_invocations_per_month / 1,000,000 * 0.20

aws_lambda_compute_cost =
  function_gb_seconds_per_month * 0.0000167

aws_step_functions_cost =
  max(0, workflow_state_transitions_per_month - 4000) * 0.000025

aws_kms_key_cost =
  kms_or_keymanager_key_count * 1.00

aws_kms_request_cost =
  max(0, kms_or_keymanager_requests_per_month - 20000) / 10000 * 0.03

aws_cloudtrail_data_cost =
  audit_data_events_per_month / 100000 * 0.10

aws_cloudwatch_logs_cost =
  custom_logs_gb_per_month * 0.50

aws_opensearch_storage_cost =
  search_index_storage_gb * 0.02

aws_opensearch_ocu_cost =
  search_query_hours_per_month * 0.24
```

### AWS observaties

- Voor een archive-oplossing is `OpenSearch` vaak duurder dan `S3`.
- `CloudTrail data events` kunnen snel oplopen als je veel object- of data-level auditing aanzet.
- `KMS` lijkt klein, maar decrypt/encrypt-volume op retrieval en ingest kan verrassend aantikken.
- `Textract` kan bij migraties een grote maar tijdelijke cost spike veroorzaken.

## Scaleway Calculator

Regio-aanname voor richtprijzen: `Paris`, waar zichtbaar op de pricing pages.

### Waarschuwing

Deze calculator is nog minder precies dan AWS.

Reden:

- de Scaleway referentiearchitectuur is nu wel uitgewerkt, maar nog niet gekwantificeerd naar vaste plans
- vooral search, governance workflows en audit-opslag moeten nog specifieker gemapt worden naar gekozen services en capaciteiten

### Scaleway service-lijnen

| Cost line | Formule | Starter rate | Bron |
|---|---|---:|---|
| `Object Storage Standard Multi-AZ` | `active_storage_gb * rate` | `€0.0146/GB-month` | [Scaleway Storage pricing](https://www.scaleway.com/en/pricing/storage/) |
| `Object Storage Standard One Zone` | `active_storage_gb * rate` | `€0.00752/GB-month` | [Scaleway Storage pricing](https://www.scaleway.com/en/pricing/storage/) |
| `Object Storage Glacier` | `cold_archive_storage_gb * rate` | `€0.00254/GB-month` | [Scaleway Storage pricing](https://www.scaleway.com/en/pricing/storage/) |
| `Object Storage egress` | `max(0, retrieval_gb_per_month - 75) * rate` | `€0.01/GB` after first 75 GB | [Scaleway Storage pricing](https://www.scaleway.com/en/pricing/storage/) |
| `Glacier restore` | `restored_gb * rate` | `€0.009/GB` | [Scaleway Storage pricing](https://www.scaleway.com/en/pricing/storage/) |
| `Serverless Functions requests` | `function_invocations_per_month / 1,000,000 * rate` | `€0.15 per 1M requests`, first `1M` free | [Scaleway Serverless pricing](https://www.scaleway.com/en/pricing/serverless/) |
| `Serverless Functions compute` | `function_gb_seconds_per_month * rate` | `€1.2 per 100,000 GB-s`, first `400,000 GB-s` free | [Scaleway Serverless pricing](https://www.scaleway.com/en/pricing/serverless/) |
| `Key Manager keys` | `kms_or_keymanager_key_count * rate` | `€0.04 per key version/month` | [Scaleway Security pricing](https://www.scaleway.com/en/pricing/security-and-account/) |
| `Key Manager requests` | `kms_or_keymanager_requests_per_month / 10,000 * rate` | `€0.03 per 10,000 requests` | [Scaleway Security pricing](https://www.scaleway.com/en/pricing/security-and-account/) |
| `Cockpit custom logs` | `custom_logs_gb_per_month * rate` | `€0.35/GB` | [Scaleway Cockpit pricing](https://www.scaleway.com/en/docs/cockpit/reference-content/cockpit-pricing/) |
| `Cockpit custom metrics` | `custom_metric_samples_million * rate` | `€0.15 per million samples` | [Scaleway Cockpit pricing](https://www.scaleway.com/en/docs/cockpit/reference-content/cockpit-pricing/) |
| `Managed DB / Search / Compute` | fixed plan component | `TBD per selected plan` | [Scaleway pricing overview](https://www.scaleway.com/en/pricing/) |

### Scaleway snelle rekenregels

```text
scw_object_standard_multi_az_cost =
  active_storage_gb * 0.0146

scw_object_glacier_cost =
  cold_archive_storage_gb * 0.00254

scw_egress_cost =
  max(0, retrieval_gb_per_month - 75) * 0.01

scw_functions_request_cost =
  max(0, function_invocations_per_month - 1000000) / 1000000 * 0.15

scw_functions_compute_cost =
  max(0, function_gb_seconds_per_month - 400000) / 100000 * 1.2

scw_keymanager_key_cost =
  kms_or_keymanager_key_count * 0.04

scw_keymanager_request_cost =
  kms_or_keymanager_requests_per_month / 10000 * 0.03

scw_cockpit_logs_cost =
  custom_logs_gb_per_month * 0.35
```

### Scaleway observaties

- `Object Storage` is eenvoudig en scherp geprijsd.
- `Serverless Functions` kunnen voor ingest/control logic aantrekkelijk zijn bij lager volume.
- `Key Manager` bestaat wel degelijk als aparte dienst; de voornaamste ontwerpvraag is hoe je die combineert met object-encryptie en applicatiecryptografie.
- `Cockpit` is gunstig als je veel native Scaleway-data monitort; custom logs/traces tellen wel door.
- De grootste onzekerheid zit nu niet in storage, maar in de uiteindelijke keuze voor metadata store, search en governance-orchestration.

## Snelle scenariovergelijking

### Scenario A: Storage-heavy archive, weinig retrieval

Typisch:

- veel documenten
- lage zoekdruk
- weinig downloads
- weinig AI/OCR

Waarschijnlijke conclusie:

- `Scaleway` kan hier op pure storage + eenvoudige serverless laag financieel aantrekkelijk zijn
- `AWS` wint hier minder op ruwe opslagprijs en meer op volwassen governance-capabilities

### Scenario B: Compliance-heavy archive

Typisch:

- sterke audit-eisen
- legal hold
- retention workflows
- veel metadata-zoekwerk
- fijnmazige toegangscontrole

Waarschijnlijke conclusie:

- `AWS` is hier waarschijnlijk sneller verdedigbaar door de combinatie van `S3 Object Lock`, `CloudTrail`, `KMS`, `Step Functions` en volwassen search/integration services
- `Scaleway` kan nog steeds werken, maar vraagt waarschijnlijk meer ontwerpwerk en meer eigen platformlogica

### Scenario C: Migration-heavy archive met AI metadata extractie

Typisch:

- grote historische bulk
- OCR nodig
- automatische metadata extractie gewenst

Waarschijnlijke conclusie:

- `AWS` is hier relatief sterk door de directe fit met `Textract`
- de storagekosten zijn dan vaak niet het eerste probleem; tijdelijke AI/OCR kosten domineren

## Eerste beslisregels

- Als `governance`, `auditability` en `immutability` de hoogste prioriteit hebben, heeft `AWS` nu de voorsprong.
- Als `lage storagekosten` en `eenvoudige Europese hosting` domineren, is `Scaleway` interessant.
- Als `search`, `workflow orchestration` en `AI metadata extraction` zwaar wegen, is `AWS` waarschijnlijk eerder de pragmatische keuze.

## Wat nog ontbreekt voor een betere vergelijking

- een `Scaleway` referentiearchitectuur op hetzelfde detailniveau als AWS
- een gekozen regio per cloud
- 2 of 3 echte workloadprofielen
- een keuze of search `managed service`, `serverless` of `self-managed` wordt
- een keuze of AI-metadata in fase 1 of pas later actief is

## Aanbevolen volgende stap

Maak nu drie rekenprofielen:

1. `MVP`
2. `Compliance-heavy`
3. `Migration-heavy`

En reken die daarna voor beide clouds door op basis van dezelfde inputset.

Dat geeft veel sneller bruikbare besluitvorming dan direct proberen een "exacte" universele calculator te maken.

## Bronnen

AWS:

- [Amazon S3 pricing](https://aws.amazon.com/s3/pricing/)
- [AWS Lambda pricing](https://aws.amazon.com/lambda/pricing/)
- [Amazon API Gateway pricing](https://aws.amazon.com/api-gateway/pricing/)
- [Amazon DynamoDB pricing](https://aws.amazon.com/dynamodb/pricing/on-demand/)
- [AWS KMS pricing](https://aws.amazon.com/kms/pricing/)
- [AWS CloudTrail pricing](https://aws.amazon.com/cloudtrail/pricing/)
- [Amazon OpenSearch Service pricing](https://aws.amazon.com/opensearch-service/pricing/)
- [Amazon Textract pricing](https://aws.amazon.com/textract/pricing/)
- [AWS Step Functions pricing](https://aws.amazon.com/step-functions/pricing/)
- [Amazon CloudWatch pricing](https://aws.amazon.com/cloudwatch/pricing/)

Scaleway:

- [Scaleway Storage pricing](https://www.scaleway.com/en/pricing/storage/)
- [Scaleway Serverless pricing](https://www.scaleway.com/en/pricing/serverless/)
- [Scaleway Security and Account pricing](https://www.scaleway.com/en/pricing/security-and-account/)
- [Scaleway Cockpit pricing documentation](https://www.scaleway.com/en/docs/cockpit/reference-content/cockpit-pricing/)
- [Scaleway pricing overview](https://www.scaleway.com/en/pricing/)
