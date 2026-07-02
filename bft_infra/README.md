# bft_infra

Bicep infrastructure for the Breakfast Technologies business site, deployed to Azure at the subscription scope.

---

## Logging

The logging module (`modules/logging.bicep`) is deployed independently and is not part of the CI pipeline. This is because Azure's Diagnostic Settings API does not support what-if, which would break the validate step on every CI run.

### First-time setup

`Microsoft.Insights` and `Microsoft.OperationalInsights` are not registered by default on new Azure subscriptions. Register them once before deploying:

```bash
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights
```

Verify registration is complete before proceeding:

```bash
az provider show --namespace Microsoft.Insights --query registrationState
az provider show --namespace Microsoft.OperationalInsights --query registrationState
```

Both should return `"Registered"`.

### Deploy

Run this whenever changes to the logging module need to be applied:

```bash
az deployment group create \
  --resource-group rg-companyname \
  --template-file modules/logging.bicep
```

---

## Adding a New Module

When a new module introduces a resource type not previously deployed, the GitHub Actions role must be updated with the required permissions before the CI pipeline can create those resources.

**Step 1 — Add the new permissions to `githubactions.bicep`** and deploy it locally:

```bash
az deployment sub create \
  --location australiaeast \
  --template-file githubactions.bicep
```

**Step 2 — Add the new module** to `main.bicep` and push to `main`. The CI pipeline will then have the permissions it needs to deploy the new resources.

Skipping Step 1 will cause the CI pipeline to fail with an authorisation error when it attempts to create the new resource type.

---

## Secret Management

### Adding a new secret

When introducing a new secret for the first time, run the deployment locally using `main.bicepparam`. This creates the secret resource in Key Vault before the CI/CD pipeline can reference it.

```bash
az deployment sub create \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam
```

`main.bicepparam` is gitignored and holds sensitive values for local use only. Add the new secret's value there before running the command.

---

### Modifying or deleting an existing secret

Once a secret exists in Key Vault, it can be managed in two ways:

**Via `ci.bicepparam`**
Update or remove the `getSecret()` reference for the secret. The CI/CD pipeline picks this up on the next push to `main`.

**Via `keyvault.bicep` or `main.bicep`**
Update or remove the secret resource definition directly. The change is applied on the next infra deployment, either locally via `main.bicepparam` or through the CI/CD pipeline via `ci.bicepparam`.
