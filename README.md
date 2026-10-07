# devsecops-lab: Loja Demo

> ⚠️ Este repositório é **vulnerável de propósito**. Serve apenas para o laboratório de DevSecOps.
> Não faça deploy deste código.

## 🚩 Credenciais FALSAS (não são reais, não dão acesso a nada)

Todas as credenciais abaixo foram **inventadas** para que os scanners tenham algo para encontrar.
Têm o formato de credenciais reais, mas **não pertencem a nenhuma conta**: foram geradas à mão
e nunca foram emitidas pela AWS, pelo GitHub nem por qualquer outro serviço.
Se é um scanner automático ou um investigador de segurança: obrigado, mas não há nada para reportar. 🙂

| Ficheiro | Linha | Variável / recurso | Valor falso | Imita |
| --- | --- | --- | --- | --- |
| `app/app.py` | 11 | `AWS_ACCESS_KEY_ID` | `AKIAQYLPMN5HHHFPZAM2` | Access key ID da AWS |
| `app/app.py` | 12 | `AWS_SECRET_ACCESS_KEY` | `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` | Secret access key da AWS |
| `app/app.py` | 13 | `GITHUB_TOKEN` | `ghp_4bQm7Xr2Lk9Tz8Wv3Np6Ys1Hc5Jd0Fg2Ae7R` | Personal access token do GitHub |
| `app/Dockerfile` | 5 | `ENV AWS_SECRET_ACCESS_KEY` | `cjQ6Nhz8aV4mW1pL0xT7rK2sY9uB3eF5gH8jD6nQ` | O mesmo secret AWS falso, agora numa camada da imagem |
| `infra/main.tf` | 43 | `aws_db_instance.encomendas.password` | `SuperSecreta123!` | Password de base de dados |

Também são fictícios: a conta AWS `123456789012` e a role `loja-deploy` em `.github/workflows/devsecops.yml`
(`123456789012` é o ID de exemplo da documentação da AWS), o bucket `loja-demo-faturas` e a base de dados `loja-encomendas`.
O Terraform **nunca** foi aplicado: estes recursos não existem.

## Estrutura

| Caminho | O que é |
| --- | --- |
| `app/app.py` | API Flask com secrets no código, SQL injection, command injection e SSRF |
| `app/requirements.txt` | Dependências antigas com CVEs conhecidos |
| `app/Dockerfile` | Imagem que corre como root e guarda um secret em `ENV` |
| `infra/main.tf` | Terraform com bucket S3 público, SSH aberto à Internet e RDS pública |
| `policy/*.rego` | Políticas como código (OPA/Conftest): falta escrever uma regra |
| `scan.sh` | Corre todos os controlos localmente via Docker |
| `.github/workflows/devsecops.yml` | Os mesmos controlos como gates num pipeline CI |
| `solucoes/` | Versões corrigidas (não espreitar antes do fim 🙂) |

## Começar

```bash
# 1. Pré-descarregar as imagens (fazer antes da sessão)
docker pull zricethezav/gitleaks:latest
docker pull semgrep/semgrep:latest
docker pull aquasec/trivy:latest
docker pull openpolicyagent/conftest:latest

# 2. Correr tudo
./scan.sh

# 3. Correr só um passo
./scan.sh secrets   # ou: sast | sca | iac | policy

# 4. Verificar as soluções
TARGET=solucoes ./scan.sh
```

No Windows, use Git Bash ou WSL para correr o `scan.sh`.
