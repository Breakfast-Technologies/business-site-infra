# bft_infra

Bicep infrastructure for the Breakfast Technologies business site, deployed to Azure at the subscription scope.

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
