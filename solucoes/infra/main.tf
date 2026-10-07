# Infraestrutura da Loja Demo (versão corrigida)

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "faturas" {
  bucket = "loja-demo-faturas"
}

resource "aws_s3_bucket_public_access_block" "faturas" {
  bucket                  = aws_s3_bucket.faturas.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "faturas" {
  description         = "Chave das faturas"
  enable_key_rotation = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "faturas" {
  bucket = aws_s3_bucket.faturas.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.faturas.arn
    }
  }
}

resource "aws_security_group" "api" {
  name        = "loja-api"
  description = "Acesso a API"

  # Sem SSH: acesso administrativo via AWS SSM Session Manager (identidade + auditoria)

  ingress {
    description = "API via load balancer interno"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_db_instance" "encomendas" {
  identifier                          = "loja-encomendas"
  engine                              = "postgres"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 20
  username                            = "loja_app"
  manage_master_user_password         = true # password gerida e rodada pelo Secrets Manager
  iam_database_authentication_enabled = true
  publicly_accessible                 = false
  storage_encrypted                   = true
  skip_final_snapshot                 = true
}
