# Infraestrutura da Loja Demo (VULNERÁVEL DE PROPÓSITO - só para o laboratório)

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "faturas" {
  bucket = "loja-demo-faturas"
}

resource "aws_s3_bucket_acl" "faturas" {
  bucket = aws_s3_bucket.faturas.id
  acl    = "public-read"
}

resource "aws_security_group" "api" {
  name        = "loja-api"
  description = "Acesso a API"

  ingress {
    description = "SSH para debug"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "encomendas" {
  identifier          = "loja-encomendas"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "SuperSecreta123!"
  publicly_accessible = true
  storage_encrypted   = false
  skip_final_snapshot = true
}
