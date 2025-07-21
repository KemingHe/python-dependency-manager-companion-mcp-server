# Contributing to Python Dependency Manager MCP Server

> Updated on 2025-07-21 by @KemingHe

Thank you for your interest in contributing! This document provides development setup instructions and guidelines.

## 🛠️ Development Setup

**Transport**: Stdio only (MCP standard for local tools).

### Local Development

```shell
# Clone and setup
git clone <repo-url>
cd python-dep-manager-companion-mcp-server
uv sync

# Run server locally
uv run --with fastmcp --with tantivy fastmcp run src/mcp_server.py

# Build Docker image
docker build -t py-dep-man-companion .
```

### Local Testing with MCP Client

For testing the server locally during development, add this configuration to your VSCode/Cursor `mcp.json`:

```json
{
  "mcp": {
    "servers": {
      "py-dep-man-companion-native": {
        "command": "uv",
        "args": [
          "run",
          "--directory",
          "/path/to/your/python-dependency-manager-companion-mcp-server",
          "--with",
          "fastmcp>=2.10.5",
          "--with",
          "tantivy>=0.24.0",
          "fastmcp",
          "run",
          "src/mcp_server.py"
        ]
      }
    }
  }
}
```

>[!IMPORTANT]
> Replace `/path/to/your/python-dependency-manager-companion-mcp-server` with the absolute path to your local repository.

## 🗺️ Roadmap

Adding support for pipenv, pdm, pixi, and additional Python package managers.

## 📝 Development Guidelines

- Follow existing code style and structure
- Test your changes locally using the native configuration above
- Update documentation when adding new features
- Submit pull requests with clear descriptions of changes

## 🔄 Automated Updates

This repository includes automated workflows that:

- Update documentation weekly from official sources
- Rebuild search indexes automatically
- Publish multi-architecture Docker images

See [.github/workflows/README.md](.github/workflows/README.md) for workflow details.
