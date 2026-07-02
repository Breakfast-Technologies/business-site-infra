# Business Site Infrastructure

This repository contains the application code and infrastructure configuration for a business website deployed on Microsoft Azure. It is structured as two directories — one for the web application and one for the cloud infrastructure.

---

## Repository Structure

```
business_site_infra/
├── business_site/          # FastAPI web application
└── bft_infra/              # Azure infrastructure (Bicep)
```

---

## business_site

A business website built with Python and FastAPI, served via Uvicorn and deployed to Azure App Service.

### Stack

- **Framework:** FastAPI (Python 3.11)
- **Templating:** Jinja2
- **Server:** Uvicorn
- **Email:** Transactional email via API (key managed through Azure Key Vault)
- **CAPTCHA:** Cloudflare Turnstile (bot protection on contact form)
- **Rate limiting:** slowapi (per-IP limit on contact form submissions)
- **Styling:** HTML/CSS with DM Sans (Google Fonts) and Font Awesome icons

### Structure

```
business_site/
├── main.py                         # FastAPI app — routes and middleware
├── requirements.txt                # Python dependencies
├── templates/
│   ├── base.html                   # Shared layout (header, nav, footer)
│   ├── home.html                   # Home page (hero, strategy, services, contact form)
│   ├── about.html                  # About page (services detail, tech stack)
│   └── contact.html                # Contact form success page
├── static/
│   ├── style.css                   # Full site stylesheet
│   └── script.js                   # Client-side logic (enables submit button on CAPTCHA pass)
└── .github/
    └── workflows/
        └── deploy-app.yml          # CI/CD pipeline — deploys app to Azure App Service
```

### Routes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Home page |
| GET | `/about` | About page |
| POST | `/contact` | Contact form submission — verifies CAPTCHA, rate-limited to 3/hour per IP, sends email and returns success page |

### CI/CD

`deploy-app.yml` triggers on every push to `main`. It authenticates to Azure via OIDC (no secrets stored in GitHub) and deploys the application to Azure App Service using `azure/webapps-deploy`.

---

## bft_infra

Azure infrastructure defined as code using Bicep, deployed at the subscription scope.

### Architecture

```
Azure Subscription
└── Resource Group
    ├── App Service Plan          (Linux, B1 Basic)
    ├── App Service               (Python 3.11, system-assigned managed identity)
    ├── Key Vault                 (RBAC-enabled, stores email API key and CAPTCHA secret key)
    ├── Managed Certificate       (free TLS certificate for custom domain)
    └── SSL Binding               (SNI-based HTTPS enforcement)
```

### Structure

```
bft_infra/
├── main.bicep                      # Entry point — creates resource group, calls all modules
├── githubactions.bicep             # Custom RBAC role + assignment for GitHub Actions service principal
├── ci.bicepparam                   # CI/CD parameters — pulls secrets from Key Vault at deploy time
├── modules/
│   ├── appservice.bicep            # App Service Plan + App Service with managed identity
│   ├── keyvault.bicep              # Key Vault + secret + role assignment for App Service identity
│   ├── certificates.bicep          # Hostname binding + managed TLS certificate
│   └── ssl-binding.bicep           # SNI SSL binding using certificate thumbprint
└── .github/
    └── workflows/
        └── deploy-infra.yml        # CI/CD pipeline — validates and deploys Bicep on push to main
```

### Key Design Decisions

**Secrets management** — The email API key and CAPTCHA secret key are stored in Azure Key Vault and injected into the App Service at runtime via Key Vault references in app settings. Neither key appears in application code or environment files.

**Managed identity** — The App Service uses a system-assigned managed identity, granted the Key Vault Secrets User role. This means the app authenticates to Key Vault without any credentials — Azure handles it transparently.

**GitHub Actions authentication** — Deployment pipelines authenticate to Azure using OpenID Connect (OIDC) via a federated credential on an Entra ID app registration. No Azure credentials are stored in GitHub. A custom least-privilege role defines exactly what the pipeline is permitted to do.

**TLS** — A free Azure-managed certificate is provisioned for the custom domain. The certificate lifecycle (issuance, renewal) is handled entirely by Azure.

**Bot protection** — The contact form is protected by Cloudflare Turnstile. The widget runs a passive browser challenge and only enables the submit button on success. The token is verified server-side against the Cloudflare API before any email is sent. The CAPTCHA secret key is stored in Key Vault and never exposed in source code.

**Rate limiting** — The `POST /contact` endpoint is rate-limited to 3 requests per hour per IP using slowapi. This is enforced server-side and returns a 429 response once the limit is exceeded, providing a secondary layer of protection independent of the CAPTCHA.

### CI/CD

`deploy-infra.yml` triggers on push to `main` when Bicep files change. It runs a `what-if` validation before deploying to prevent unintended changes from being applied.
