# -------- Base --------
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instala dependências do sistema mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instala Poetry
ENV POETRY_VERSION=1.8.3
RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

WORKDIR /app

# -------- Dependencies --------
FROM base AS deps

COPY pyproject.toml poetry.lock ./

# Configura Poetry para não criar venv dentro do container
RUN poetry config virtualenvs.create false \
    && poetry install --only main --no-interaction --no-ansi

# -------- Final --------
FROM base

# Cria usuário não-root
RUN useradd --create-home appuser

WORKDIR /home/appuser/app

# Copia dependências já instaladas
COPY --from=deps /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=deps /usr/local/bin /usr/local/bin

# Copia código
COPY src/ ./src/
COPY pyproject.toml README.md ./

# Ajusta permissões
RUN chown -R appuser:appuser /home/appuser/app

USER appuser

CMD ["python"]
