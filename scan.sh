#!/usr/bin/env bash
# Corre todos os controlos de segurança localmente, via Docker (não é preciso instalar nada).
# Uso: ./scan.sh [secrets|sast|sca|iac|policy|all]   (por omissão: all)
# Para verificar as soluções: TARGET=solucoes ./scan.sh
set -uo pipefail

TARGET="${TARGET:-.}"
STEP="${1:-all}"
FAIL=0

run() {
  echo
  echo "=================================================================="
  echo "  $1"
  echo "=================================================================="
  shift
  "$@" || FAIL=1
}

secrets() {
  run "1. SECRETS  (gitleaks)" \
    docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:latest \
      dir "/repo/$TARGET/app" --no-banner --verbose --redact
}

sast() {
  run "2. SAST  (semgrep)" \
    docker run --rm -v "$PWD:/src" semgrep/semgrep \
      semgrep scan --config p/python --config p/secrets --metrics=off --error "$TARGET/app"
}

sca() {
  run "3. SCA - dependências  (trivy fs)" \
    docker run --rm -v "$PWD:/src" -v trivy-cache:/root/.cache aquasec/trivy:latest \
      fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 "/src/$TARGET/app"
}

iac() {
  run "4. IaC - más configurações  (trivy config)" \
    docker run --rm -v "$PWD:/src" -v trivy-cache:/root/.cache aquasec/trivy:latest \
      config --severity HIGH,CRITICAL --exit-code 1 "/src/$TARGET/infra"
}

policy() {
  run "5a. POLICY AS CODE - Terraform  (conftest/OPA)" \
    docker run --rm -v "$PWD:/project" openpolicyagent/conftest \
      test "$TARGET/infra/main.tf" -p "$TARGET/policy" --namespace terraform
  run "5b. POLICY AS CODE - Dockerfile  (conftest/OPA)" \
    docker run --rm -v "$PWD:/project" openpolicyagent/conftest \
      test "$TARGET/app/Dockerfile" -p policy --namespace docker
}

case "$STEP" in
  secrets) secrets ;;
  sast)    sast ;;
  sca)     sca ;;
  iac)     iac ;;
  policy)  policy ;;
  all)     secrets; sast; sca; iac; policy ;;
  *) echo "Passo desconhecido: $STEP"; exit 2 ;;
esac

echo
if [ "$FAIL" -ne 0 ]; then
  echo "RESULTADO: FALHOU - o pipeline bloquearia este merge."
  exit 1
fi
echo "RESULTADO: PASSOU - pronto para merge."
