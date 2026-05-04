#!/bin/bash
EXTERNAL_HOST=$1
TOKEN=$2
PASS=0
FAIL=0

if [ -z "${EXTERNAL_HOST}" ] || [ -z "${TOKEN}" ]; then
  echo "Usage: bash tests/smoke-test.sh <EXTERNAL_HOST> <TOKEN>"
  exit 1
fi

echo "Running smoke tests against ${EXTERNAL_HOST}..."

check() {
  local desc=$1
  local expected=$2
  local actual=$3
  if [ "$actual" = "$expected" ]; then
    echo "PASS: $desc (${actual})"
    PASS=$((PASS+1))
  else
    echo "FAIL: $desc (expected ${expected}, got ${actual})"
    FAIL=$((FAIL+1))
  fi
}

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   -H "Authorization: Bearer ${TOKEN}"   "https://${EXTERNAL_HOST}/customer/accountholders/v1/accountholders/233244000001")
check "AccountHolders valid token -> 200" "200" "$STATUS"

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   "https://${EXTERNAL_HOST}/customer/accountholders/v1/accountholders/233244000001")
check "AccountHolders no token -> 401" "401" "$STATUS"

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   -H "Authorization: Bearer ${TOKEN}"   -H "Content-Type: application/json"   -X POST "https://${EXTERNAL_HOST}/customer/consent/v1/consent/233244000001"   -d '{"flowType":"ussd","callbackUrl":"https://example.com","confirmationMessage":"Confirm?"}')
check "Consent valid token -> 200" "200" "$STATUS"

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   -H "Authorization: Bearer ${TOKEN}"   -H "Content-Type: application/json"   -X POST "https://${EXTERNAL_HOST}/payment/withdrawals/v1/withdraw"   -d '{"correlatorId":"test-001","callingSystem":"AYO","externalReference":"ext-001","customerId":"233244000001","status":"Pending"}')
check "Withdrawals valid token -> 200" "200" "$STATUS"

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   -H "Authorization: Bearer ${TOKEN}"   -H "Content-Type: application/json"   -H "countryCode: GH"   -X POST "https://${EXTERNAL_HOST}/payment/payments/v1/payments"   -d '{"correlatorId":"test-001","amount":{"amount":10,"units":"GHS"}}')
check "Payments valid token -> 200" "200" "$STATUS"

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   -H "Authorization: Bearer ${TOKEN}"   "https://${EXTERNAL_HOST}/customer/accountholders/v1/doesnotexist")
check "Unknown path -> 404" "404" "$STATUS"

STATUS=$(curl -s -o /dev/null -w "%{http_code}"   -X OPTIONS   -H "Origin: https://example.com"   -H "Access-Control-Request-Method: GET"   "https://${EXTERNAL_HOST}/customer/accountholders/v1/accountholders/233244000001")
check "CORS preflight -> 200" "200" "$STATUS"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "${FAIL}" -gt "0" ] && exit 1
echo "SMOKE TEST PASSED"
exit 0
