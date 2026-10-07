"""Loja Demo - API interna de encomendas (versão corrigida)."""
import ipaddress
import os
import sqlite3
import subprocess

from flask import Flask, abort, request

app = Flask(__name__)

# Secrets: nada no código. Em produção, a app obtém credenciais de curta duração
# via identidade da carga de trabalho (ex.: IAM role / OIDC) - não há chaves estáticas.
DB_PATH = os.environ.get("DB_PATH", "loja.db")


def get_db():
    return sqlite3.connect(DB_PATH)


@app.route("/encomendas")
def encomendas():
    cliente = request.args.get("cliente", "")
    db = get_db()
    # Query parametrizada: o input nunca é interpretado como SQL
    rows = db.execute("SELECT * FROM encomendas WHERE cliente = ?", (cliente,)).fetchall()
    return {"resultado": rows}


@app.route("/ping")
def ping():
    host = request.args.get("host", "127.0.0.1")
    try:
        ipaddress.ip_address(host)  # allowlist: só aceita IPs válidos
    except ValueError:
        abort(400)
    # Lista de argumentos, sem shell
    out = subprocess.check_output(["ping", "-c", "1", host])
    return out


# /proxy removido: um proxy aberto é SSRF por desenho. Se for mesmo necessário,
# usar uma allowlist fixa de destinos e manter verify=True.

if __name__ == "__main__":
    app.run(host="127.0.0.1", debug=False)
