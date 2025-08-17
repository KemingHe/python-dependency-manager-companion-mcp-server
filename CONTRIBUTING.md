# Contributing to Python Dependency Manager MCP Server

> Updated on 2025-07-23 by @KemingHe

Thank you for your interest in contributing! This guide covers development workflow and setup.

## 🔄 Contribution Workflow

> [!IMPORTANT]
> **Issue-first approach**: No issue, no PR. No PR, no merge.

1. **Raise issue** - Bug report or feature request
2. **Get assigned** - Wait for maintainer assignment  
3. **Create PR** - Link to assigned issue
4. **Review & approval** - Address feedback
5. **Merge** - Maintainer merges approved PR

## 🛠️ Development Setup

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

### Local Testing

Add to your VSCode/Cursor's `mcp.json` for testing:

> [!IMPORTANT]
> Replace `/path/to/your/repo` with **absolute path** to your local repository.

```json
{
  "mcp": {
    "servers": {
      "py-dep-man-companion-development": {
        "command": "uv",
        "args": [
          "run", "--directory", "/path/to/your/repo",
          "--with", "fastmcp>=2.10.5", "--with", "tantivy>=0.24.0",
          "fastmcp", "run", "src/mcp_server.py"
        ]
      }
    }
  }
}
```

## 📝 Development Standards

### Git Workflow

- **Branching**: `type/feature-or-bug-scope/GitHubUsername`
- **Types**: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`
- **Commits**: Use `prompts/prompt-commit-msg-gen.md` for consistency

### Quality Tools

Available templates and prompts for consistent contributions:

> [!TIP]
> Use these tools for consistent, high-quality contributions that reduce review cycles.

```plaintext
.github/
├── ISSUE_TEMPLATE/
│   ├── bug-report.md             # Bug report template
│   └── feature-request.md        # Feature request template
└── pull_request_template.md

prompts/
├── prompt-commit-msg-gen.md      # Generate uniform commit messages
├── prompt-issue-gen.md           # Create well-structured issues
├── prompt-pull-request-gen.md    # Write comprehensive PR descriptions
└── prompt-readme-gen.md          # Maintain documentation standards
```

## 🤖 Automated Systems

The repository auto-updates weekly (Tuesday 06:00pm ET):

1. Syncs official documentation
2. Rebuilds search indexes
3. Publishes Docker images

See [.github/workflows/README.md](.github/workflows/README.md) for technical details.
