# Authentication & Authorization — OIDC + Ory

**Status**: AGREED
**Last Updated**: 2026-04-09
**Depends On**: architecture/tech-stack.md, architecture/module-structure.md

---

## 1. Overview

Authentication and authorization use **OpenID Connect (OIDC)** backed by the **Ory** open-source identity stack. This externalizes identity management from the CRM application — the CRM never stores passwords or manages login flows directly. Instead, it validates OIDC tokens issued by Ory Hydra and reads user identity from Ory Kratos.

### Why Ory?
- Open-source, self-hosted — no vendor lock-in
- Kratos handles identity (registration, login, recovery, profile)
- Hydra handles OAuth2/OIDC (token issuance, consent)
- Clean separation: CRM is just an OIDC relying party
- Docker-native — easy local development

---

## 2. Ory Component Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Browser                                    │
│                                                                   │
│  ┌─────────────────────┐       ┌───────────────────────────────┐ │
│  │  CRM Frontend        │       │  Ory Account UI               │ │
│  │  (Compose/WASM)      │       │  (Login, Register, Recovery)  │ │
│  └──────────┬──────────┘       └──────────┬────────────────────┘ │
└─────────────┼──────────────────────────────┼─────────────────────┘
              │ REST + Bearer token           │ Kratos flows
              ▼                               ▼
┌──────────────────────┐       ┌───────────────────────────┐
│  CRM Backend          │       │  Ory Kratos                │
│  (Ktor)               │       │  Identity Management       │
│                       │       │  - User registration       │
│  Validates OIDC       │       │  - Login flows             │
│  tokens from Hydra    │       │  - Profile management      │
│                       │       │  - Password recovery       │
│  Reads user info      │       │  - Identity schemas        │
│  from Kratos          │       └─────────┬─────────────────┘
└──────────┬───────────┘                  │
           │                              │
           │ Token validation             │ Identity storage
           ▼                              ▼
┌──────────────────────┐       ┌───────────────────────────┐
│  Ory Hydra             │       │  PostgreSQL                │
│  OAuth2/OIDC Server    │       │  (Kratos DB + Hydra DB)    │
│  - Token issuance      │       └───────────────────────────┘
│  - OIDC discovery      │
│  - Consent management  │
└────────────────────────┘
```

---

## 3. Component Responsibilities

### Ory Kratos — Identity Management
- **What it does**: Manages user identities (create, login, logout, recovery, profile)
- **What the CRM uses it for**: Source of truth for user identity data (name, email, role)
- **Identity schema**: Custom schema defining CRM user traits (name, email, role)
- **Self-service flows**: Login, registration, recovery, settings — all handled by Kratos
- **Admin API**: CRM backend uses this to manage users programmatically (create, list, update roles)

### Ory Hydra — OAuth2/OIDC Provider
- **What it does**: Issues OAuth2 access tokens and OIDC ID tokens
- **What the CRM uses it for**: Token-based authentication for API requests
- **OIDC flows**: Authorization Code Flow with PKCE (for browser SPA)
- **Token format**: JWT access tokens with user claims (sub, email, role)
- **Discovery**: `/.well-known/openid-configuration` endpoint

### CRM Backend — Relying Party
- **Validates tokens**: Checks JWT signature against Hydra's JWKS endpoint
- **Extracts claims**: Reads `sub` (user ID), `email`, `role` from token
- **Authorization**: Checks role claims against endpoint requirements
- **No password handling**: Never stores or verifies passwords

### CRM Frontend — OIDC Client
- **Login redirect**: Redirects to Hydra's authorization endpoint
- **Token exchange**: Exchanges auth code for tokens via PKCE
- **Token storage**: Stores access token in memory (not localStorage)
- **Token refresh**: Uses refresh token to get new access tokens
- **API calls**: Attaches `Authorization: Bearer <token>` to all requests

---

## 4. OIDC Login Flow

```
User clicks "Login" in CRM Frontend
    │
    ▼
Frontend redirects to Hydra /oauth2/auth
(with client_id, redirect_uri, scope, code_challenge)
    │
    ▼
Hydra checks: is user authenticated?
    │
    ├── No → Redirect to Kratos login flow
    │         │
    │         ▼
    │     Kratos shows login UI (email + password)
    │         │
    │         ▼
    │     User authenticates with Kratos
    │         │
    │         ▼
    │     Kratos confirms identity → Hydra consent
    │
    ├── Yes → Hydra consent screen (or auto-approve for first-party)
    │
    ▼
Hydra issues authorization code
    │
    ▼
Redirect back to CRM Frontend callback URL
    │
    ▼
Frontend exchanges code for tokens (PKCE, no client secret)
    │
    ▼
Frontend stores tokens in memory
    │
    ▼
Frontend calls CRM API with Authorization: Bearer <access_token>
    │
    ▼
Backend validates JWT against Hydra JWKS
    │
    ▼
Backend extracts claims → processes request
```

---

## 5. Kratos Identity Schema

The identity schema defines what user data Kratos stores. CRM-specific traits are embedded here.

```json
{
  "$id": "https://crm.local/schemas/user.schema.json",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CRM User",
  "type": "object",
  "properties": {
    "traits": {
      "type": "object",
      "properties": {
        "email": {
          "type": "string",
          "format": "email",
          "title": "Email",
          "ory.sh/kratos": {
            "credentials": {
              "password": { "identifier": true }
            },
            "verification": { "via": "email" }
          }
        },
        "name": {
          "type": "string",
          "title": "Full Name",
          "minLength": 1,
          "maxLength": 150
        },
        "role": {
          "type": "string",
          "title": "Role",
          "enum": ["ADMIN", "MANAGER", "USER"],
          "default": "USER"
        }
      },
      "required": ["email", "name"],
      "additionalProperties": false
    }
  }
}
```

---

## 6. Token Claims

### Access Token (JWT)
```json
{
  "sub": "kratos-identity-uuid",
  "iss": "http://hydra:4444/",
  "aud": ["crm-api"],
  "exp": 1712700000,
  "iat": 1712696400,
  "scope": "openid profile email",
  "ext": {
    "email": "user@example.com",
    "name": "John Doe",
    "role": "ADMIN"
  }
}
```

### ID Token (OIDC)
```json
{
  "sub": "kratos-identity-uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "ADMIN",
  "email_verified": true
}
```

> The `role` claim is added via Hydra's consent flow — the consent handler reads the user's role from Kratos traits and includes it in the token.

---

## 7. Backend Integration

### Token Validation (Ktor)

The CRM backend validates tokens on every protected request:

```kotlin
// Ktor Authentication plugin config
install(Authentication) {
    jwt("oidc") {
        realm = "crm-api"
        verifier(
            jwkProvider = JwkProviderBuilder(hydraJwksUrl).build(),
            issuer = hydraIssuerUrl
        )
        validate { credential ->
            val role = credential.payload.getClaim("ext")
                ?.asMap()?.get("role")?.toString()
            if (role != null) {
                CrmPrincipal(
                    userId = credential.payload.subject,
                    email = credential.payload.getClaim("ext")
                        ?.asMap()?.get("email")?.toString() ?: "",
                    role = UserRole.valueOf(role)
                )
            } else null
        }
    }
}
```

### Authorization

```kotlin
fun Route.requireRole(vararg roles: UserRole, build: Route.() -> Unit) {
    authenticate("oidc") {
        intercept(ApplicationCallPipeline.Call) {
            val principal = call.principal<CrmPrincipal>()
            if (principal == null || principal.role !in roles) {
                call.respond(HttpStatusCode.Forbidden)
                finish()
            }
        }
        build()
    }
}

// Usage in routes:
requireRole(UserRole.ADMIN) {
    post("/api/v1/users") { /* create user via Kratos admin API */ }
}
```

### User Management via Kratos Admin API

The CRM backend doesn't store users — it uses Kratos Admin API:

| Operation | Kratos Admin API | CRM Endpoint |
|-----------|-----------------|--------------|
| Create user | `POST /admin/identities` | `POST /api/v1/users` (ADMIN) |
| List users | `GET /admin/identities` | `GET /api/v1/users` (ADMIN) |
| Get user | `GET /admin/identities/{id}` | `GET /api/v1/users/{id}` |
| Update role | `PUT /admin/identities/{id}` (update traits) | `PUT /api/v1/users/{id}/role` (ADMIN) |
| Deactivate | `PATCH /admin/identities/{id}` (set state=inactive) | `PUT /api/v1/users/{id}/deactivate` (ADMIN) |
| Delete | `DELETE /admin/identities/{id}` | `DELETE /api/v1/users/{id}` (ADMIN) |

---

## 8. Frontend Integration

### OIDC Client Setup

```kotlin
// Frontend OIDC configuration
object OidcConfig {
    val authority = "http://localhost:4444/"  // Hydra
    val clientId = "crm-frontend"
    val redirectUri = "http://localhost:8080/callback"
    val postLogoutRedirectUri = "http://localhost:8080/"
    val scope = "openid profile email offline_access"
    val responseType = "code"
    // PKCE enabled — no client secret needed for SPA
}
```

### Auth Flow in Compose

```
App.kt
  └─ AuthState (manages tokens)
       ├─ isAuthenticated: Boolean
       ├─ accessToken: String?
       ├─ user: UserInfo?
       ├─ login() → redirect to Hydra
       ├─ handleCallback(code) → exchange for tokens
       ├─ logout() → redirect to Hydra logout
       └─ refreshToken() → use refresh token
```

---

## 9. Impact on Domain Events

With Ory handling identity, the CRM's user events change:

### Events the CRM Still Emits
| Event | Tags | Trigger | Notes |
|-------|------|---------|-------|
| UserRoleChanged | `["user:{kratosId}"]` | Admin changes role via CRM | CRM manages roles as a trait in Kratos |
| UserDeactivated | `["user:{kratosId}"]` | Admin deactivates via CRM | Sets Kratos identity state to inactive |

### Events the CRM Does NOT Emit
| Removed | Reason |
|---------|--------|
| UserCreated | Handled by Kratos registration flow |
| UserAuthenticated | Handled by Kratos login flow |
| PasswordChanged | Handled by Kratos settings flow |

### Events the CRM Syncs FROM Kratos (via webhook)
| Kratos Event | CRM Action |
|-------------|------------|
| Identity created (registration) | Emit UserRegistered event with Kratos ID, sync traits |
| Identity updated (profile change) | Emit UserProfileUpdated event |

> Kratos can be configured with webhooks that call the CRM backend when identities change. This keeps the event store in sync.

---

## 10. Read Model for Users

Since identity lives in Kratos, the CRM's user read model is a sync:

| Read Model | Source | Key Fields | Purpose |
|-----------|--------|------------|---------|
| UserView | Kratos Admin API + CRM events | id (Kratos UUID), email, name, role, active, lastLoginAt | User list/detail queries |

The projection either:
- **Option A**: Queries Kratos Admin API on demand (simpler, slightly slower)
- **Option B**: Syncs via Kratos webhooks into the CRM event store → projection (faster queries, more complex)

---

## 11. Open Questions

- **Q-1**: Kratos webhook sync vs. on-demand Kratos API queries for user data? — **Decision**: Webhook sync (Kratos webhooks → CRM events)
- **Q-2**: Should the Ory Account UI be custom (embedded in CRM frontend) or use Ory's default self-service UI? — **Decision**: Ory self-service UI (themed, redirect-based)
- **Q-3**: Multi-factor authentication (TOTP, WebAuthn) via Kratos? — **Decision**: Not for V1 (can enable TOTP/WebAuthn later via Kratos config)
- **Q-4**: Token lifetime — how long before refresh is required? — **Decision**: 1h access token, 30d refresh token
