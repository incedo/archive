# Security Baseline

## Doel

Deze baseline beschrijft de minimale securitymaatregelen voor het archive-platform op AWS en Scaleway.

Het doel is expliciet maken dat `encryptie` noodzakelijk is, maar niet voldoende.

## Kernprincipe

Encryptie alleen garandeert geen veiligheid voor de klant.

Voor deze archive-oplossing ontstaat veiligheid pas door de combinatie van:

- encryptie
- identity en access control
- immutable storage
- retention en legal hold
- audit trail
- veilige lifecycle en disposition
- monitoring en operationele opvolging

## Wat encryptie wel doet

- beschermt data at rest tegen bepaalde vormen van ongeautoriseerde toegang
- verkleint impact van storage-level exposure
- helpt bij compliance-eisen rond vertrouwelijkheid

## Wat encryptie niet oplost

- foutieve of te brede toegangsrechten
- misbruik door geautoriseerde gebruikers
- onjuiste deletes of disposition
- ontbrekende legal hold
- verkeerde lifecycle policies
- ontbrekende audit trail
- onveilige exports
- metadata-lekken buiten de blob-opslag

## Minimale security controls

### 1. Encryptie

- Alle documenten zijn versleuteld at rest.
- Alle netwerkcommunicatie gebruikt TLS.
- Sleutelgebruik is beheerst en auditeerbaar.
- Encryptieconfiguratie is afdwingbaar en geen vrijblijvende instelling.

### 2. Identity en Access Control

- Toegang verloopt via centrale identity.
- Least privilege is verplicht.
- Rollen zijn expliciet gescheiden voor finance, legal, audit en operations.
- Toegang is beperkbaar per legal entity, documenttype en vertrouwelijkheidsniveau.
- Gevoelige acties zoals export, legal hold en disposition hebben aparte rechten.

### 3. Immutable Storage

- Archiefopslag gebruikt WORM of equivalent.
- Records kunnen niet vrij overschreven worden binnen retention.
- Legal hold blokkeert disposition.
- Lifecycle naar cold storage mag immutable gedrag niet doorbreken.

### 4. Key en Secret Management

- Secrets staan niet in code of configuratiebestanden zonder bescherming.
- Sleutels en secrets worden centraal beheerd.
- Gebruik van sleutels is herleidbaar.
- Sleuteltoegang voor workloads en beheerders is gescheiden.

### 5. Audit en Forensics

- Kritieke acties worden gelogd.
- Auditdata is beschermd tegen ongecontroleerde wijziging.
- Er is bewijs over upload, view, metadatawijziging, hold, export en disposition.
- Restore-acties uit cold storage worden ook gelogd.

### 6. Data Governance

- Retention is policy-driven.
- Directe delete bestaat niet.
- Disposition verloopt via een gecontroleerde workflow.
- Lifecycle policies zijn uitlegbaar en beheerbaar.
- Metadata provenance is zichtbaar, inclusief AI-afgeleide metadata.

### 7. Network en Runtime Security

- Productiecomponenten zijn niet publiek toegankelijk tenzij noodzakelijk.
- Interne componenten communiceren waar mogelijk via private netwerken.
- Service identities zijn gescheiden per component.
- Externe integraties worden minimaal geprivilegieerd aangesloten.

### 8. Monitoring en Incident Response

- Fouten, policy-afwijkingen en verdachte toegangspatronen worden gemonitord.
- Alarmen bestaan voor mislukte workflows, restoreproblemen en auditafwijkingen.
- Er is een operationeel pad voor incidentafhandeling.

## AWS baseline

### Minimale AWS invulling

- `S3 Object Lock` voor immutable archivering
- `SSE-KMS` of minimaal afdwingbare server-side encryption op S3
- `KMS` met strikt sleutelbeleid
- `IAM Identity Center` voor workforce access
- `IAM` least-privilege rollen voor workloads
- `CloudTrail` voor audit
- `CloudWatch` voor monitoring en alerting
- bucket policies die encryptie en toegangsbeperkingen afdwingen

### Belangrijke AWS aandachtspunten

- Standaard S3-encryptie is nuttig, maar onvoldoende zonder goede IAM- en KMS-configuratie.
- KMS key policies en IAM policies moeten samen correct ontworpen zijn.
- Data events in CloudTrail zijn belangrijk voor echte traceerbaarheid, maar hebben impact op kosten.
- Restore uit Glacier-tiers moet als gecontroleerde retrievalflow worden behandeld.

## Scaleway baseline

### Minimale Scaleway invulling

- `Object Lock` voor immutable archivering
- `SSE-ONE` of `SSE-C` voor object-encryptie
- `IAM` voor identity en authorization
- `Key Manager` en `Secret Manager` voor cryptografische en secret-gerelateerde controles
- `Audit Trail` voor audit
- `Cockpit` voor logging, monitoring en alerts
- bucket policies voor aanvullende objecttoegang-controles

### Belangrijke Scaleway aandachtspunten

- Encryptie-inrichting op Object Storage moet expliciet gekozen en afgedwongen worden.
- `Key Manager` is een relevante bouwsteen, maar object-storage encryptie moet nog steeds bewust worden ontworpen.
- Restore uit `Glacier` moet als gecontroleerde retrievalflow worden behandeld.
- Lifecycle en Object Lock moeten samen worden ontworpen zodat governance niet verzwakt.

## Geen-goed-genoeg situaties

De oplossing is niet veilig genoeg als:

- encryptie optioneel is
- beheerders directe delete kunnen uitvoeren
- audit events ontbreken voor exports of restores
- lifecycle beleid niet uitlegbaar is
- secrets in code of CI-variabelen zwerven zonder beheerd secretbeleid
- alle gebruikers brede read-access hebben
- legal hold alleen organisatorisch en niet technisch wordt afgedwongen

## Praktische conclusie

Voor dit archive betekent `veilig voor de klant` minimaal:

- versleuteld
- immutable
- strikt geautoriseerd
- volledig auditeerbaar
- policy-driven beheerd
- gecontroleerd in lifecycle, restore en disposition

## Bronnen

AWS:

- [Using server-side encryption with AWS KMS keys](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)
- [Protecting data with server-side encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)

Scaleway:

- [Enabling SSE-ONE on Object Storage](https://www.scaleway.com/en/docs/object-storage/api-cli/enable-sse-one/)
- [Enabling SSE-C on Object Storage](https://www.scaleway.com/en/docs/object-storage/api-cli/enable-sse-c/)
- [Scaleway Key Manager](https://www.scaleway.com/en/key-manager/)
