# Python Dependency Manager MCP Server

> Updated on 2025-07-15 by @KemingHe

Local MCP server providing unified search across Python dependency manager documentation.

## 📋 Overview

Unified search for pip, poetry, uv, and conda docs via Docker with weekly auto-updates. Built with FastMCP and Tantivy.

## 🚀 Getting Started

### Step 1: Pull Docker Image

```shell
docker pull keminghe/py-dep-man-companion:latest
```

### Step 2: Configure Your IDE

Add to VSCode User Settings (JSON):

```json
{
  "mcp": {
    "servers": {
      "python-deps": {
        "command": "docker",
        "args": ["run", "-i", "--rm", "keminghe/py-dep-man-companion:latest"]
      }
    }
  }
}
```

### Step 3: Start Searching

Query latest and unified documentation across all supported Python dependency managers directly from your AI assistant.

## 📁 Project Structure

```plaintext
python-dep-manager-companion-mcp-server/
├── .github/workflows/
│   ├── auto-update.yml       # Orchestrator: Tuesday 6pm ET
│   └── auto-update-docs.yml  # Modular: Doc fetching workflow
├── docs/                     # Project documentation
├── src/
│   ├── server.py             # FastMCP server implementation
│   ├── index.py              # Tantivy search engine
│   └── assets/               # Local documentation files
│       ├── pip/              # Pip documentation .md files
│       ├── poetry/           # Poetry documentation .md files  
│       ├── uv/               # UV documentation .md files
│       └── conda/            # Conda documentation .md files
├── Dockerfile                # Container build configuration
└── pyproject.toml            # Project dependencies and metadata
```

## 🛠️ Development

**Transport Support**: Stdio (default) and HTTP modes following MCP standards.

**Environment Variables**:

- `TRANSPORT_MODE`: `stdio` or `http` (default: `stdio`)
- `TRANSPORT_PORT`: HTTP server port (default: `8080`)
- `TRANSPORT_HOST`: Host binding (default: `127.0.0.1`)

**Local Development**:

```shell
# Clone and setup
git clone <repo-url>
cd python-dep-manager-companion-mcp-server
uv sync

# Run server
uv run python src/server.py stdio
```

**Roadmap**: Adding support for pipenv, pdm, pixi, and additional Python package managers.

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - a permissive license that allows free use, modification, and distribution with attribution.

## 📞 Support

Open GitHub issues for bug reports and feature requests. Weekly documentation updates run automatically every Tuesday at 6pm ET with signed commits by `github-actions[bot]`.
