# RED Ghana Portal

Apigee proxy bundles for the RED MTN Ghana Developer Portal.

## Structure
proxies/
customer-accountholders-v1/
customer-consent-validation-v1/
payment-momo-withdrawals-v1/
payment-payments-v1/
sharedflows/
security-common/
specs/
tests/
azure-pipelines.yml

## Environments

| Environment | Hostname | Purpose |
|-------------|----------|---------|
| eval | 34.110.219.0.nip.io | Dev — automatic deployment |
| preprod | preprod.34.110.219.0.nip.io | Prod — approval gate |
