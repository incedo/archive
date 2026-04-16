# Infrastructure as Code Strategy

## Besluit

Dit project gebruikt `OpenTofu` als standaard `Infrastructure as Code` tool.

## Korte aanbeveling

Voor `AWS + Scaleway` is een gedeelde `IaC`-aanpak op hoofdniveau goed, maar niet als volledig geabstraheerde multi-cloud laag.

De pragmatische keuze is:

- gebruik `OpenTofu` als gemeenschappelijke `IaC` tool
- houd per cloud aparte root-stacks en modules
- deel alleen conventies, naming, tagging, policies en mapstructuur
- abstraheer niet geforceerd naar één generiek cloudmodel

## Waarom niet volledig abstraheren

`Terraform` abstraheert de taal en workflow, maar niet de cloud zelf.

Voorbeelden:

- `AWS S3 Object Lock` heeft geen 1-op-1 equivalent ontwerp in elke andere cloud
- `IAM Identity Center`, `KMS`, `CloudTrail`, `EventBridge` en `Step Functions` zijn AWS-specifieke bouwstenen
- Scaleway heeft andere primitives, andere providerdekking en andere operationele patronen

Als je te vroeg alles probeert te vangen in één generieke modulelaag, krijg je meestal:

- lowest-common-denominator ontwerp
- onduidelijke modules
- veel conditionele logica
- lastig beheer en lastig debuggen

## Aanbevolen aanpak

### 1. Eén IaC-tool, meerdere cloud-specifieke stacks

Gebruik één tool voor consistentie:

- `OpenTofu` als open source default

Maar structureer de code per cloud:

- `infra/live/aws/...`
- `infra/live/scaleway/...`
- `infra/modules/aws/...`
- `infra/modules/scaleway/...`

### 2. Deel patronen, niet resources

Deel op hoofdniveau:

- mapstructuur
- moduleconventies
- omgevingsnamen
- tagging/labels
- policy naming
- CI/CD workflow
- state management aanpak

Maak cloud-specifiek:

- storage
- identity
- encryption
- eventing
- logging/audit
- networking

### 3. Gebruik per cloud eigen modules

Voorbeeld:

- `modules/aws/archive_storage`
- `modules/aws/control_plane`
- `modules/aws/access_plane`
- `modules/scaleway/object_storage`
- `modules/scaleway/networking`

Dus wel één repository en één werkwijze, maar geen kunstmatige "universele archive bucket module" voor alle clouds.

## Waarom OpenTofu

Redenen:

- open source governance
- compatibel met het bestaande provider-ecosysteem
- goede fit voor een nieuwe greenfield opzet

Volgens de OpenTofu FAQ werkt OpenTofu met de huidige Terraform providers en gebruikt het hetzelfde brede provider-ecosysteem, via een eigen registry-model.

## Advies voor jouw situatie

Voor `AWS + Scaleway` zou ik kiezen voor:

- `OpenTofu` als IaC engine
- cloud-specifieke modules per provider
- een gedeelde repositorystructuur
- een gedeelde CI-aanpak

## State management

State is belangrijker dan veel teams in het begin denken.

Voor AWS-stacks:

- gebruik bij voorkeur een remote state backend op AWS
- klassiek is `S3` voor state en `DynamoDB` voor locking

Voor Scaleway-stacks:

- gebruik niet blind een S3-compatibele bucket als state store zonder lock-strategie

Scaleway documenteert expliciet dat Object Storage als `S3 backend` gebruikt kan worden, maar dat daar geen locking mechanisme op zit. Zij noemen een managed database als alternatief als je locking nodig hebt.

Praktisch betekent dat:

- of je gebruikt een centrale state-oplossing buiten Scaleway
- of je gebruikt een platform met ingebouwde state/locking
- of je zorgt per stack voor een expliciete lock-strategie

## Wanneer wél abstraheren

Abstractie is wel nuttig voor:

- naming conventions
- labels/tags
- omgevingselectie
- standaard inputs zoals regio, project, cost center, environment
- CI validation en policy checks

Abstractie is meestal niet nuttig voor:

- IAM versus Scaleway IAM-achtige rechtenmodellen
- eventing-services
- archive storage controls
- audit- en compliance-mechanismen

## Beslisregel

Gebruik deze simpele regel:

- zelfde businessdoel, andere cloudservice: aparte modules
- zelfde workflow of conventie: gedeelde tooling of templates

## Repository-structuur

```text
infra/
  modules/
    aws/
      archive_storage/
      control_plane/
      access_plane/
      observability/
    scaleway/
      object_storage/
      networking/
      observability/
  live/
    aws/
      prod/
      test/
    scaleway/
      prod/
      test/
```

Deze basisstructuur is in de repository aangemaakt.

## Concrete aanbeveling

Voor jouw situatie zou ik dus niet kiezen voor:

- één volledig geabstraheerde multi-cloud modulelaag

Wel zou ik kiezen voor:

- één `IaC` tool
- één repositorystructuur
- cloud-specifieke implementaties
- gedeelde standaarden op hoofdniveau

## Automation rule

Voor dit project geldt aanvullend deze harde regel:

- er wordt geen cloud-infrastructuur handmatig aangemaakt via console-clicks voor AWS of Scaleway
- namen, identifiers, endpoints en deployment-targets worden niet handmatig opgezocht en overgetypt als structurele werkwijze
- provisioning gebeurt via `OpenTofu`
- deployment-automation leest waar mogelijk uit `IaC` outputs, gegenereerde env-bestanden of pipeline-configuratie die uit `IaC` is afgeleid
- handmatige invoer is alleen acceptabel voor bootstrap-secrets of credentials die bewust buiten versiebeheer moeten blijven

Concreet betekent dit:

- `ECR`, `ECS`, netwerken, security groups, registries, runtime services en vergelijkbare bouwstenen horen in `IaC`
- hetzelfde geldt later voor Scaleway Container Registry, Serverless Containers, netwerken en secrets-wiring
- workflow-inputs mogen tijdelijk bestaan voor bootstrap of break-glass scenario's, maar zijn niet de gewenste steady-state
- de steady-state is: `IaC` apply -> outputs -> automation consumeert die outputs

Dat geeft je consistentie zonder dat je de echte verschillen tussen `AWS` en `Scaleway` probeert weg te modelleren.

## Bronnen

- [OpenTofu FAQ](https://opentofu.org/faq/)
- [OpenTofu provider compatibility and registry docs](https://opentofu.org/docs/v1.9/language/providers/requirements/)
- [Scaleway Terraform documentation](https://www.scaleway.com/en/terraform/)
- [AWS CDK overview](https://aws.amazon.com/cdk/)
