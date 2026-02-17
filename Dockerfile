# -------- Base stage --------
FROM python:3.12-slim AS base

# Evita geração de arquivos .pyc e ativa stdout imediato
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Diretório de trabalho
WORKDIR /app

# Instala dependências do sistema mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# -------- Dependencies stage --------
FROM base AS deps

COPY requirements-dev.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements-dev.txt

# -------- Final stage --------
FROM base

# Cria usuário não-root
RUN useradd --create-home appuser

WORKDIR /home/appuser/app

COPY --from=deps /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=deps /usr/local/bin /usr/local/bin

COPY pyproject.toml README.md ./
COPY src/ ./src/

# Ajusta permissões
RUN chown -R appuser:appuser /home/appuser/app

# Agora troca usuário
USER appuser

RUN pip install --no-cache-dir .

CMD ["python"]
