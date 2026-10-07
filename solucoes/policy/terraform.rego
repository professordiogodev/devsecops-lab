package terraform

import rego.v1

deny contains msg if {
	some name, sg in input.resource.aws_security_group
	some rule in sg[_].ingress
	rule.from_port <= 22
	rule.to_port >= 22
	"0.0.0.0/0" in rule.cidr_blocks
	msg := sprintf("aws_security_group.%s: SSH (porta 22) aberto a 0.0.0.0/0. Usar SSM/bastion ou restringir o CIDR.", [name])
}

deny contains msg if {
	some name, acl in input.resource.aws_s3_bucket_acl
	acl[_].acl in {"public-read", "public-read-write"}
	msg := sprintf("aws_s3_bucket_acl.%s: ACL pública torna o bucket acessível a qualquer pessoa.", [name])
}

# Regra 3 (solução)
deny contains msg if {
	some name, db in input.resource.aws_db_instance
	db[_].publicly_accessible == true
	msg := sprintf("aws_db_instance.%s: base de dados acessível a partir da Internet.", [name])
}

# Bónus: encriptação em repouso obrigatória
deny contains msg if {
	some name, db in input.resource.aws_db_instance
	some cfg in db
	not cfg.storage_encrypted == true
	msg := sprintf("aws_db_instance.%s: storage_encrypted tem de ser true.", [name])
}
