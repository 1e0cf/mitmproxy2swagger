FROM python:3.12-slim-bookworm AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_HTTP_TIMEOUT=100 \
    UV_NO_CACHE=1
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv venv /venv && \
    VIRTUAL_ENV=/venv uv sync --frozen --no-dev
COPY . .
RUN VIRTUAL_ENV=/venv uv pip install --no-deps .

FROM python:3.12-slim-bookworm AS final
ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=builder /venv /venv
ENV PATH="/venv/bin:${PATH}"

ENTRYPOINT [ "mitmproxy2swagger" ]
