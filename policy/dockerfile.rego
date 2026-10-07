package docker

import rego.v1

# Políticas como código para Dockerfiles.
# Correr: conftest test app/Dockerfile -p policy --namespace docker

# Regra (fornecida): o contentor não pode correr como root - tem de existir uma instrução USER.
deny contains msg if {
	not has_user
	msg := "Dockerfile: falta a instrução USER - o contentor vai correr como root."
}

has_user if {
	some instr in input
	instr.Cmd == "user"
}

# Regra (fornecida): não guardar secrets em ENV (ficam gravados nas camadas da imagem).
deny contains msg if {
	some instr in input
	instr.Cmd == "env"
	regex.match(`(?i)(secret|password|token|key)`, instr.Value[0])
	msg := sprintf("Dockerfile: possível secret em ENV (%s). Injetar em runtime via secret manager.", [instr.Value[0]])
}
