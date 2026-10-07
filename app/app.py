"""Loja Demo - API interna de encomendas (VULNERÁVEL DE PROPÓSITO - só para o laboratório)."""
import sqlite3
import subprocess

import requests
from flask import Flask, request

app = Flask(__name__)

# TODO: mover para variáveis de ambiente "mais tarde"...
AWS_ACCESS_KEY_ID = "AKIAQYLPMN5HHHFPZAM2"
AWS_SECRET_ACCESS_KEY = "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"
GITHUB_TOKEN = "ghp_4bQm7Xr2Lk9Tz8Wv3Np6Ys1Hc5Jd0Fg2Ae7R"


def get_db():
    return sqlite3.connect("loja.db")


@app.route("/encomendas")
def encomendas():
    cliente = request.args.get("cliente", "")
    db = get_db()
    # Concatenação direta de input do utilizador numa query SQL
    query = f"SELECT * FROM encomendas WHERE cliente = '{cliente}'"
    return {"resultado": db.execute(query).fetchall()}


@app.route("/ping")
def ping():
    host = request.args.get("host", "localhost")
    # Input do utilizador passado a uma shell
    out = subprocess.check_output("ping -c 1 " + host, shell=True)
    return out


@app.route("/proxy")
def proxy():
    url = request.args.get("url")
    # Sem validação de destino e sem verificação TLS
    return requests.get(url, verify=False).text


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
