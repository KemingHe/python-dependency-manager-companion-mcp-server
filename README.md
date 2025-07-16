# Python Dependency Manager MCP Server

> Updated on 2025-07-15 by @KemingHe

Local MCP server providing unified search across Python dependency manager documentation.

## 📋 Overview

Unified search for pip, poetry, uv, and conda docs via Docker with automated weekly updates. Built with FastMCP and Tantivy for simple, AI-less full-text search.

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
├── .github/workflows/        # Automation workflows (see workflows/README.md)
├── docs/                     # Project documentation
├── src/
│   ├── server.py             # FastMCP server implementation
│   ├── index.py              # Tantivy search engine
│   └── assets/               # Auto-updated documentation files
├── Dockerfile                # Container build configuration
└── pyproject.toml            # Project dependencies and metadata
```

## 🛠️ Development

**Transport Support:** Stdio (default) and HTTP modes following MCP standards.

**Environment Variables:**

- `TRANSPORT_MODE`: `stdio` or `http` (default: `stdio`)
- `TRANSPORT_PORT`: HTTP server port (default: `8080`)
- `TRANSPORT_HOST`: Host binding (default: `127.0.0.1`)

**Local Development:**

```shell
# Clone and setup
git clone <repo-url>
cd python-dep-manager-companion-mcp-server
uv sync

# Run server
uv run python src/server.py stdio
```

**Roadmap:** Adding support for pipenv, pdm, pixi, and additional Python package managers.

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - a permissive license that allows free use, modification, and distribution with attribution.

## 📞 Support

Open GitHub issues for bug reports and feature requests. Documentation is automatically updated weekly via workflows (see [.github/workflows/README.md](.github/workflows/README.md)).
