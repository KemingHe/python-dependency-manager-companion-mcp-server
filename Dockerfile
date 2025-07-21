# Optimized uv-based Alpine Docker image for MCP stdio transport
# - Uses uv pre-built images for faster dependency management
# - Multi-stage build for minimal final image size
# - Non-root user for security
# - Includes Rust support for tantivy dependency
# - Configured for stdio transport (no HTTP endpoints)

# ==============================================================================
# Stage 1: Dependencies builder
# ==============================================================================
FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

# Set environment variables for uv
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv

# Install system dependencies required for building Python packages
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    rust \
    cargo

# Set working directory
WORKDIR /app

# Copy dependency specification files
COPY pyproject.toml ./
COPY uv.lock ./

# Create virtual environment and install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# Copy application code and install project
COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# ==============================================================================
# Stage 2: Runtime
# ==============================================================================
FROM ghcr.io/astral-sh/uv:python3.12-alpine AS runtime

# Set environment variables for Python and stdio mode
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    PYTHONPATH="/app" \
    TMPDIR="/tmp/app"

# Install runtime dependencies for Rust extensions
RUN apk add --no-cache libgcc

# Create non-root user and directories
RUN addgroup -g 1000 appuser \
    && adduser -u 1000 -G appuser -D appuser \
    && mkdir -p /tmp/app \
    && chown -R appuser:appuser /tmp/app

# Copy application and virtual environment from builder
COPY --from=builder --chown=appuser:appuser /app /app

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# NOTE: No healthcheck for stdio MCP containers
# Stdio containers are ephemeral and client-initiated - they start on-demand when
# MCP clients connect, process requests via stdin/stdout, then exit when disconnected.
# Traditional health checks don't apply to this usage pattern.

# Start MCP server in stdio mode (default)
CMD ["uv", "run", "--with", "fastmcp>=2.10.5", "--with", "tantivy>=0.24.0", "fastmcp", "run", "src/mcp_server.py"]
