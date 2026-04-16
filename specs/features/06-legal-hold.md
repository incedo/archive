# Feature 06 - Legal Hold

## Doel

Verwijdering of disposition van documenten tijdelijk blokkeren wanneer juridische of toezichthoudende redenen dat vereisen.

## Waarom deze feature bestaat

Een archive voor contracts en invoices moet kunnen voorkomen dat documenten verdwijnen terwijl ze nog nodig zijn voor geschillen, onderzoeken of audits.

## Basisfeatures

### 6.1 Legal hold registratie

- Het systeem kan een legal hold registreren op document of documentset.
- Het systeem koppelt een reden, actor en tijdstip aan de legal hold.

### 6.2 Legal hold effect

- Het systeem blokkeert disposition zolang een legal hold actief is.
- Het systeem maakt legal hold status zichtbaar in metadata en beheerprocessen.

### 6.3 Legal hold opheffen

- Het systeem ondersteunt gecontroleerde verwijdering van een legal hold.
- Het systeem herstelt daarna normale retention- en dispositionregels.

## Afhankelijke features

### 6.4 Legal hold op sets en dossiers

Afhankelijk van:

- 6.1 Legal hold registratie
- 4.6 Documentrelaties

Features:

- Het systeem ondersteunt legal hold op samenhangende documentsets.
- Het systeem ondersteunt hold op basis van zoekresultaat, dossier of relatiegroep.

### 6.5 Legal hold governance

Afhankelijk van:

- 6.1 Legal hold registratie
- 6.3 Legal hold opheffen

Features:

- Het systeem ondersteunt controle op wie holds mag plaatsen of opheffen.
- Het systeem ondersteunt verantwoording en review van actieve holds.

## Resultaat van deze feature

Juridische blokkades zijn afdwingbaar en zichtbaar binnen het archive.

## Afhankelijk van

- [Feature 04 - Metadata Management](/Users/kees/data/projects/archive/features/04-metadata-management.md)
- [Feature 07 - Audit Trail](/Users/kees/data/projects/archive/features/07-audit-trail.md)
- [Feature 08 - Security and Access Control](/Users/kees/data/projects/archive/features/08-security-and-access-control.md)

## Levert input aan

- [Feature 05 - Retention and Disposition](/Users/kees/data/projects/archive/features/05-retention-and-disposition.md)
- [Feature 10 - Reporting and Compliance](/Users/kees/data/projects/archive/features/10-reporting-and-compliance.md)
