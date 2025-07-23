# Python Dependency Manager Companion MCP Server

> README updated on 2025-07-23 by [@KemingHe](https://github.com/KemingHe)

Official docs from `pip`, `poetry`, `uv`, and `conda` + automated weekly updates = zero maintenance overhead for developers using VSCode/Cursor with AI assistants. [[Demo]](https://www.loom.com/share/a80f6041dc374c07b95b2397ee4e8ca1?sid=1209cdce-7239-447e-8b20-49eae454cc9a)

## 🚀 Quick Start for Agentic IDEs

**1. Pull latest Docker image**:

```shell
docker pull keminghe/py-dep-man-companion:latest
```

**2. Add to your IDE's `mcp.json`**:

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

**3. Query official docs directly in your AI chat** - guaranteed fresh from weekly automated updates.

## 🔄 Auto-Update Architecture

```plaintext
┌───────────────────────────┐
│  ⏰ Every Tuesday 6pm ET  │
└─────────────┬─────────────┘
              ▼
┌───────────────────────────┐
│  📚 Sync Official Docs    │
└─────────────┬─────────────┘
              ▼
┌───────────────────────────┐
│  🔍 Rebuild Search Index  │
└─────────────┬─────────────┘
              ▼
┌───────────────────────────┐
│  🐳 Publish Latest Image  │
└───────────────────────────┘
```

**Zero maintenance**: Documentation automatically synced weekly from official sources. Docker `:latest` tag guarantees you always get current docs without manual updates.

## 🤝 Contributing

**Use as template**: [[Create from template]](https://github.com/new?template_name=python-dependency-manager-companion-mcp-server&template_owner=KemingHe) for your own MCP server projects.

**Contribute back**: Fork and follow [CONTRIBUTING.md](https://github.com/KemingHe/python-dependency-manager-companion-mcp-server/blob/main/CONTRIBUTING.md) for development setup.

## 🗺️ Roadmap

- [ ] Add support for `pipenv`, `pdm`, `pixi`
- [ ] Add comprehensive tests with 100% coverage  
- [ ] Add indexing support for PDF and CSV files

## 📄 License

This project is licensed under the [MIT License](https://github.com/KemingHe/python-dependency-manager-companion-mcp-server/blob/main/LICENSE) - a permissive license that allows free use, modification, and distribution with attribution.

## 📞 Support

Open a [GitHub issue](https://github.com/KemingHe/python-dependency-manager-companion-mcp-server/issues) for bug reports and feature requests.
