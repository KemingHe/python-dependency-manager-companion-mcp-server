# Python Dependency Manager Companion MCP Server

> Updated on 2025-07-21 by [@KemingHe](https://github.com/KemingHe)

Local stdio MCP server providing unified search across Python dependency managers' latest and official documentation. [[Demo]](https://www.loom.com/share/a80f6041dc374c07b95b2397ee4e8ca1?sid=1209cdce-7239-447e-8b20-49eae454cc9a)

## 📋 Overview

Unified search for pip, poetry, uv, and conda docs via Docker with automated weekly updates. Built with FastMCP and Tantivy for simple, accurate, embedding-free, full-text search.

## 🎯 Use as Template

**General use**: [[Use this repository as a template]](https://github.com/new?template_name=python-dependency-manager-companion-mcp-server&template_owner=KemingHe) for your own MCP server projects.

**Contributing**: Fork to contribute back. See [CONTRIBUTING.md](./CONTRIBUTING.md) for development setup.

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
python-dependency-manager-companion-mcp-server/
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

## 📄 License

This project is licensed under the [MIT License](./LICENSE) - a permissive license that allows free use, modification, and distribution with attribution.

## 📞 Support

Open GitHub issues for bug reports and feature requests. Documentation is automatically updated weekly via workflows (see [.github/workflows/README.md](./.github/workflows/README.md)).
