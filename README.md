# RED Ghana Portal

Apigee X proxy bundles and developer portal for the RED MTN Ghana API Platform.

## Live Portal

https://red-apigee-portal-redghanaportal.apigee.io

## Environments

| Environment | Hostname | Purpose |
|-------------|----------|---------|
| eval | 34.110.219.0.nip.io | Dev — automatic on merge to main |
| preprod | preprod.34.110.219.0.nip.io | Prod — manual approval required |

## Proxies

| Proxy | Base Path |
|-------|-----------|
| oauth-v1 | /oauth/v1 |
| customer-accountholders-v1 | /customer/accountholders/v1 |
| customer-consent-validation-v1 | /customer/consent/v1 |
| payment-momo-withdrawals-v1 | /payment/withdrawals/v1 |
| payment-payments-v1 | /payment/payments/v1 |

## Getting a Token

```bash
curl -s -u APP_KEY:APP_SECRET \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -X POST https://34.110.219.0.nip.io/oauth/v1/token \
  -d grant_type=client_credentials
```

---

## API Testing Guide

### Customer AccountHolders V1

**GET /accountholders/233244000001**
- Header: x-authorization: test-auth
- Expected: 200 — Kwame Mensah, ACTIVE, GHS, MOMO account

**GET /accountholders/233244000001/validate**
- Header: X-Authorization: test-auth
- Expected: 200 — validationStatus: VALID, validationType: MOMO

**POST /accountholders/233244000001/verify**
- Header: transactionId: TXN-TEST-001
- Body: {"accountholderids": ["233244000001"], "resource": "test"}
- Expected: 200 — verificationStatus: VERIFIED, balance: 500 GHS

---

### Customer Consent Validation V1

**POST /consent/preapproval**
- Header: transactionId: TXN-TEST-001
- Body: {"customerId": "233244000001", "currency": "GHS", "amount": 100, "message": "test"}
- Expected: 200 — preapprovalId: PRE-233244000001-001, status: APPROVED

**POST /consent/cancelPreapproval**
- Header: transactionId: TXN-TEST-001
- Body: {"preapprovalId": "PRE-233244000001-001"}
- Expected: 200 — status: CANCELLED

**POST /consent/233244000001**
- Body: {"flowType": "ussd", "callbackUrl": "https://example.com", "confirmationMessage": "Confirm?"}
- Expected: 200 — sent: true, consentStatus: PENDING

**POST /consent/233244000001/generateotp**
- Body: {"notificationChannel": "sms"}
- Expected: 200 — otpKey: OTP-KEY-233244000001-abc123

**POST /consent/233244000001/verifyotp?otp=123456**
- Expected: 200 — verified: true

---

### Payment MoMo Withdrawals V1

**POST /withdraw**
- Header: transactionId: TXN-TEST-001
- Body: {"correlatorId":"test-001","callingSystem":"AYO","externalReference":"ext-001","customerId":"233244000001","status":"Pending","amount":{"amount":50,"units":"GHS"}}
- Expected: 200 — providerTransactionId: FT-233244000001-001, newBalance: 450 GHS, status: Approved

---

### Payment Payments V1

**POST /payments**
- Header: countryCode: GH
- Body: {"correlatorId":"test-001","amount":{"amount":100,"units":"GHS"}}
- Expected: 200 — status: SUCCESSFUL, 100 GHS

**POST /reverse-payment**
- Header: transactionId: TXN-2026-001, countryCode: GH, authorizationData: test-auth
- Body: {"correlatorId":"test-001","status":"pending"}
- Expected: 200 — status: REVERSED, 100 GHS

**GET /status/TXN-2026-001**
- Expected: 200 — status: SUCCESSFUL, 100 GHS

**POST /fee**
- Body: {"amount":{"amount":100,"units":"GHS"}}
- Expected: 200 — fee: 1.50 GHS, tax: 0.20 GHS, totalFee: 1.70 GHS

---

## Known Limitations

- Trial org limited to 2 environments — prod not provisioned
- Preprod SSL certificate provisioning in progress
- All responses are mock data — no real MTN Ghana backend
- Payments API shows 15 endpoints — only 4 implemented for demo

## Repository Structure

```
proxies/
  customer-accountholders-v1/
  customer-consent-validation-v1/
  payment-momo-withdrawals-v1/
  payment-payments-v1/
sharedflows/
  security-common/
specs/
tests/
  smoke-test.sh
azure-pipelines.yml
```