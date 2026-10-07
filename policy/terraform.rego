package terraform

import rego.v1

# Políticas como código para o Terraform da Loja Demo.
# Correr: conftest test infra/main.tf -p policy --namespace terraform

# Regra 1 (fornecida): nenhum security group pode abrir SSH (22) à Internet.
deny contains msg if {
	some name, sg in input.resource.aws_security_group
	some rule in sg[_].ingress
	rule.from_port <= 22
	rule.to_port >= 22
	"0.0.0.0/0" in rule.cidr_blocks
	msg := sprintf("aws_security_group.%s: SSH (porta 22) aberto a 0.0.0.0/0. Usar SSM/bastion ou restringir o CIDR.", [name])
}

# Regra 2 (fornecida): nenhum bucket S3 pode ser público.
deny contains msg if {
	some name, acl in input.resource.aws_s3_bucket_acl
	acl[_].acl in {"public-read", "public-read-write"}
	msg := sprintf("aws_s3_bucket_acl.%s: ACL pública torna o bucket acessível a qualquer pessoa.", [name])
}

# Regra 3 (EXERCÍCIO): nenhuma base de dados RDS pode ser publicamente acessível.
# Dica: o recurso é input.resource.aws_db_instance e o atributo é publicly_accessible.
# Siga o padrão da Regra 2. Escreva aqui a sua regra:

