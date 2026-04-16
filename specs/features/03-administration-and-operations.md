# Feature 03 - Administration and Operations

## Doel

Het archive beheersbaar en operationeel bestuurbaar maken voor administrators, compliance-beheerders en operations teams.

## Waarom deze feature bestaat

Een archive-oplossing is niet alleen ingest, storage en retrieval. Zonder expliciete beheerfunctionaliteit worden policies, uitzonderingen, operationele controles en dagelijkse administratie versnipperd of handmatig uitgevoerd.

## Basisfeatures

### 3.1 Policy administration

- Het systeem ondersteunt beheer van retention policies.
- Het systeem ondersteunt beheer van classificatieregels.
- Het systeem ondersteunt beheer van documenttypeconfiguratie.
- Het systeem ondersteunt beheer van lifecycle- en tiering policies voor cold storage.

### 3.2 Toegangs- en rolbeheer

- Het systeem ondersteunt beheer van rollen en rechten binnen het archive.
- Het systeem ondersteunt beheer van scopes zoals legal entity of vertrouwelijkheidsniveau.
- Het systeem maakt wijzigingen in autorisatiebeheer controleerbaar.

### 3.3 Beheer van metadataregels

- Het systeem ondersteunt beheer van verplichte metadata per documenttype.
- Het systeem ondersteunt beheer van validatieregels voor metadata.
- Het systeem ondersteunt beheer van wijzigbaarheid van metadata-velden.

### 3.4 Operationeel inzicht

- Het systeem ondersteunt inzicht in ingeststromen, foutmeldingen en achterstanden.
- Het systeem ondersteunt inzicht in archiefstatus, jobs en verwerking.
- Het systeem ondersteunt inzicht in uitzonderingen die opvolging vereisen.
- Het systeem ondersteunt inzicht in cold storage populatie, restore-verzoeken en lifecycle-uitzonderingen.
- Het systeem ondersteunt inzicht in deploymentstatus, releaseversies, omgevingsverschillen en rollback-situaties.

## Afhankelijke features

### 3.5 Beheerconsole

Afhankelijk van:

- 3.1 Policy administration
- 3.2 Toegangs- en rolbeheer
- 3.3 Beheer van metadataregels
- 3.4 Operationeel inzicht

Features:

- Het systeem ondersteunt een beheerinterface voor administrators en operations.
- Het systeem groepeert governance-, configuratie- en operationele beheertaken.

### 3.6 Uitzonderingsbeheer

Afhankelijk van:

- 3.1 Policy administration
- 3.4 Operationeel inzicht

Features:

- Het systeem ondersteunt afhandeling van ingestfouten, metadata-uitzonderingen en policy-afwijkingen.
- Het systeem ondersteunt gecontroleerde herverwerking of correctie van mislukte processen.

### 3.7 Beheer van AI-configuratie

Afhankelijk van:

- 3.3 Beheer van metadataregels
- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)

Features:

- Het systeem ondersteunt beheer van AI-gebruik per documenttype of proces.
- Het systeem ondersteunt beheer van reviewdrempels, confidence-regels en verplichte validatie.

### 3.8 Operationele runbooks en recovery-ondersteuning

Afhankelijk van:

- 3.4 Operationeel inzicht
- [Feature 02 - Immutable Archiving](/Users/kees/data/projects/archive/features/02-immutable-archiving.md)

Features:

- Het systeem ondersteunt operationele herstelacties binnen toegestane governancegrenzen.
- Het systeem ondersteunt beheerprocessen voor storingen, retries en recovery-situaties.

### 3.9 CI/CD en release management

Afhankelijk van:

- 3.4 Operationeel inzicht
- 3.8 Operationele runbooks en recovery-ondersteuning

Features:

- Het systeem ondersteunt een reproduceerbare CI-pipeline voor build, test en artifact-validatie.
- Het systeem ondersteunt deployment pipelines per omgeving zoals `dev`, `test` en `prod`.
- Het systeem gebruikt immutable release-artifacts zodat dezelfde build naar meerdere omgevingen en providers kan worden gepromoveerd.
- Het systeem ondersteunt gecontroleerde rollout, rollback en herdeploy van eerder gevalideerde releases.
- Het systeem maakt pipeline-uitkomsten, deploymentstatus en falende stappen zichtbaar voor operations.
- Het systeem houdt provider-specifieke deployment-details buiten de softwarecore en binnen de runtime- en infrastructuurlaag.

### 3.10 Runtime-configuratie en secret delivery

Afhankelijk van:

- 3.2 Toegangs- en rolbeheer
- 3.4 Operationeel inzicht
- 3.9 CI/CD en release management

Features:

- Het systeem ondersteunt een eenduidig configuratiecontract voor containerized services.
- Het systeem ondersteunt veilige levering van secrets en omgevingsconfiguratie zonder gevoelige waarden in code of pipeline-definities op te nemen.
- Het systeem ondersteunt per omgeving expliciete configuratie voor database, object storage, queues, zoekindex, identity en feature flags waar relevant.
- Het systeem ondersteunt validatie van verplichte runtime-configuratie voordat een deployment als geslaagd wordt beschouwd.
- Het systeem maakt configuratiedrift en ontbrekende secrets operationeel zichtbaar.

### 3.11 Deployment governance en promotie

Afhankelijk van:

- 3.9 CI/CD en release management
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
- [Feature 08 - Security and Access Control](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)

Features:

- Het systeem ondersteunt scheiding tussen build, release en deployment-goedkeuring.
- Het systeem ondersteunt promotie van dezelfde artifactversie tussen omgevingen zonder rebuild.
- Het systeem ondersteunt auditability van wie welke release naar welke omgeving heeft gepromoveerd.
- Het systeem ondersteunt policy-controls op deployments, bijvoorbeeld branch-protectie, omgevingsgoedkeuring en secret-scoping.
- Het systeem ondersteunt provider-portable deploymentgovernance waarbij AWS- en Scaleway-uitrol dezelfde release-identiteit gebruiken.

## Resultaat van deze feature

Het archive is niet alleen functioneel, maar ook bestuurbaar, configureerbaar en operationeel beheersbaar.

## Aanbevolen implementatievolgorde voor CI/CD en deployment

Voor de uitwerking van `3.9` tot en met `3.11` geldt deze volgorde:

1. definieer het gedeelde release-contract voor container images, versie-identiteit, omgevingen en promotie
2. definieer het runtime-configuratiecontract voor services zoals `archive-api`
3. implementeer de generieke CI-baseline voor build, test en artifact-validatie
4. implementeer image publishing en artifactregistratie met immutable tags en digests
5. implementeer deployment-automation voor `dev`
6. voeg promotieflows toe voor `test` en `prod` zonder rebuild
7. voeg rollout-observability, rollback-routines en runbooks toe
8. breid daarna uit naar aanvullende deployment units zoals workers en `archive-web`

Beslisregels:

- dezelfde artifactversie moet tussen omgevingen en providers gepromoveerd kunnen worden zonder rebuild
- provider-specifieke deploylogica hoort in infra- en workflowlagen, niet in de softwarecore
- secrets en runtime-configuratie moeten gevalideerd worden vóór succesvolle deploymentmarkering
- rollback moet een expliciete operationele capability zijn, geen handmatige noodprocedure buiten het platform om
- cloud-resources en deployment-targets voor AWS en Scaleway worden via IaC geprovisioneerd; handmatige console-creatie is geen toegestane steady-state
- deployment-automation hoort namen en identifiers uit IaC-afgeleide configuratie of outputs te gebruiken, niet uit handmatig overgetypte waarden

## Afhankelijk van

- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
- [Feature 08 - Security and Access Control](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)

## Levert input aan

- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 06 - Legal Hold](/Users/kees/data/projects/archive/features/06-legal-hold.md)
- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
- [Feature 11 - AI Metadata Determination](/Users/kees/data/projects/archive/features/11-ai-metadata-determination.md)
