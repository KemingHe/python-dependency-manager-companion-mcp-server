# Python Dependency Manager MCP Server

> Updated on 2025-07-15 by @KemingHe

Local stdio MCP server providing unified search across Python dependency managers' latest and official documentation.

## 📋 Overview

Unified search for pip, poetry, uv, and conda docs via Docker with automated weekly updates. Built with FastMCP and Tantivy for simple, AI-less full-text search.

## 🚀 Getting Started

### Step 1: Pull Docker Image

```shell
docker pull keminghe/py-dep-man-companion:latest
```

### Step 2: Configure Your IDE

Add to VSCode/Cursor `mcp.json`:

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

Query latest and unified documentation across all supported Python dependency managers directly within your agentic chat.

## 📁 Project Structure

```plaintext
python-dep-manager-companion-mcp-server/
├── .github/workflows/            # Automation workflows
│   ├── auto-update-docs.yml      # Weekly docs update
│   ├── auto-update-index.yml     # Search index rebuild
│   ├── auto-update-publish.yml   # Multi-arch Docker publish
│   ├── auto-update.yml           # Combined automation
│   └── README.md                 # Workflow documentation
├── src/
│   ├── assets/               # Documentation source files
│   │   ├── conda/            # conda docs  
│   │   ├── pip/              # pip docs
│   │   ├── poetry/           # poetry docs
│   │   └── uv/               # uv docs
│   ├── index/                # Pre-built search index
│   ├── build_index.py        # Tantivy index builder
│   └── mcp_server.py         # FastMCP stdio server
├── Dockerfile                # Container build configuration
├── pyproject.toml            # Project dependencies and metadata
└── uv.lock                   # Locked dependencies
```

## 🛠️ Development

**Transport**: Stdio only (MCP standard for local tools).

**Local Development**:

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

**Roadmap**: Adding support for pipenv, pdm, pixi, and additional Python package managers.

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - a permissive license that allows free use, modification, and distribution with attribution.

## 📞 Support

Open GitHub issues for bug reports and feature requests. Documentation is automatically updated weekly via workflows (see [.github/workflows/README.md](.github/workflows/README.md)).
