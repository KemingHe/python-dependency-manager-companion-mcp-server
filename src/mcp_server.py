#!/usr/bin/env python3
"""
FastMCP server for Python dependency manager documentation search.

Provides fuzzy search capabilities across pip, conda, poetry, and uv documentation
using a pre-built Tantivy index. Supports package filtering and handles typos
through fuzzy matching.
"""

import logging
from pathlib import Path
from typing import Annotated, Literal
from fastmcp import FastMCP
from pydantic import Field
import tantivy

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Project paths
INDEX_DIR = Path("src/index")

# Global index and searcher for reuse across tool calls
_index = None
_searcher = None


def _get_search_components():
    """Get or initialize the Tantivy index and searcher."""
    global _index, _searcher

    if _index is None:
        if not INDEX_DIR.exists():
            raise RuntimeError(
                f"Search index not found at {INDEX_DIR}. "
                "Please run 'python src/build_index.py' first to create the index."
            )

        logger.info(f"Loading search index from {INDEX_DIR}")
        _index = tantivy.Index.open(str(INDEX_DIR))
        _searcher = _index.searcher()
        logger.info("Search index loaded successfully")

    return _index, _searcher


def _reconstruct_github_link(source_repo: str, docs_path: str, path: str) -> str:
    """Reconstruct GitHub link from metadata."""
    if source_repo == "unknown" or not source_repo:
        return ""

    # Clean the path to remove package prefix (e.g., "uv/guides/..." -> "guides/...")
    cleaned_path = "/".join(path.split("/")[1:]) if "/" in path else path

    return f"https://github.com/{source_repo}/tree/main/{docs_path}/{cleaned_path}"


def _create_content_preview(content: str, query: str, max_length: int = 1800) -> str:
    """Create a relevant preview of content around query terms with adaptive length."""
    # Adaptive length based on content type
    if any(
        keyword in content.lower()
        for keyword in ["tutorial", "guide", "workflow", "step", "example"]
    ):
        max_length = 2200  # Longer for tutorials/guides
    elif any(
        keyword in content.lower() for keyword in ["command", "syntax", "reference"]
    ):
        max_length = 1400  # Shorter for command references

    if len(content) <= max_length:
        return content

    # Try to find query terms and show context around them
    query_terms = query.lower().split()
    content_lower = content.lower()

    best_start = 0
    for term in query_terms:
        pos = content_lower.find(term)
        if pos != -1:
            # Start preview 150 chars before the term (or at beginning)
            best_start = max(0, pos - 150)
            break

    # Extract preview and add ellipsis if truncated
    preview = content[best_start : best_start + max_length]
    if best_start > 0:
        preview = "..." + preview
    if best_start + max_length < len(content):
        preview = preview + "..."

    return preview


# Create FastMCP server
app = FastMCP("Python Dependency Manager Companion")


@app.tool
def search_py_dep_man_docs(
    query: Annotated[
        str,
        Field(
            description="Search intent: 'workflow tutorial', 'command reference', 'best practices', 'troubleshooting', or 'comparison'"
        ),
    ],
    package_filter: Annotated[
        Literal["pip", "conda", "poetry", "uv"] | None,
        Field(
            description="Focus on specific tool when comparing or learning tool-specific workflows"
        ),
    ] = None,
    top_n: Annotated[
        int,
        Field(
            description="Number of top results to return - use more (7-10) for broad/ambiguous requests, fewer (3-5) for specific questions",
            ge=1,
            le=10,
        ),
    ] = 5,
) -> str:
    """Find comprehensive answers from latest official Python dependency manager documentation.

    🎯 CORE VALUE: Access to authoritative, up-to-date official docs that general knowledge can't provide.

    ⚡ EXECUTION STRATEGY (85%+ first-call success):
    - MANDATORY: Multi-call progress report format:
      ```markdown
      ### 📊 [Topic] Research - Progress Report [X]

      - ✅ **Gathered**: [key findings]
      - 🔄 **Next**: [specific gap]
      - 🎯 **Goal**: [deliverable]
      ```
    - WHY: Users lose confidence without progress visibility; structured updates prevent confusion
    - WHEN: Use progress report format for ANY multi-step research (migration guides, comparisons, complex tutorials)
    - ENFORCEMENT: Show progress header AFTER EVERY INDIVIDUAL TOOL CALL, not just at final response (why: continuous user confidence)
    - TIMING: Tool call 1 → Progress Report 1 → Tool call 2 → Progress Report 2 → etc. → Final Answer (why: step-by-step transparency)
    - PATTERNS: Start with proven query patterns below for maximum hit rate

    🎯 PROVEN QUERY PATTERNS (use these exact phrases for maximum results):
    - Learning: "project setup tutorial", "workflow guide", "dependency management guide" (why: comprehensive coverage)
    - Commands: "command reference", "syntax comparison", "installation commands" (why: precise syntax)
    - Comparing: "tool A vs tool B", "migration guide", "feature comparison" (why: structured analysis)
    - Troubleshooting: "troubleshooting guide", "common errors", "best practices" (why: solution-focused)

    🧠 RESPONSE OPTIMIZATION RULES:
    - Specific question → focused query + top_n 3-5 + bullet format + show progress (why: targeted precision)
    - Broad/ambiguous → comprehensive query + top_n 7-10 + ranked list + track gaps (why: exploration needed)
    - Tool comparison → "X vs Y" + no filter + top_n 7-10 + scoring table + cite sources (why: comprehensive coverage)
    - Command help → expand terms + top_n 5-7 + code examples + update progress (why: actionable guidance)

    📚 CITATION REQUIREMENTS (builds user confidence):
    - MANDATORY: Cite for commands, claims, comparisons, best practices, migration steps, troubleshooting advice (why: user confidence)
    - DENSITY: 1 citation per major section, 2-3 for complex guides/tutorials (why: consistent coverage)
    - FORMAT: "According to the [official X guide](github_link)" or "[Command reference](github_link) shows" (why: developer-friendly)
    - PLACEMENT: Immediately after stating command syntax, making performance claims, or giving advice (why: contextual validation)
    - PROGRESS INTEGRATION: Include citations naturally within progress updates to show source validation (why: transparency)

    🚨 CRITICAL: Ground ALL responses in search results with citations (why: this tool's unique value over general knowledge).
    """
    try:
        if not query.strip():
            return "Search query cannot be empty"

        index, searcher = _get_search_components()

        # Build query string for Tantivy's query parser
        query_string = query.lower()

        # Add package filter to query string if specified
        if package_filter:
            query_string = f"package:{package_filter} AND ({query_string})"

        # Parse the query using Tantivy's query parser
        final_query = index.parse_query(query_string, ["content", "title", "package"])

        # Execute search
        search_results = searcher.search(final_query, limit=top_n)

        if not search_results.hits:
            suggestion = (
                " Try searching without package filter." if package_filter else ""
            )
            return f"No documentation found for '{query}'.{suggestion}"

        # Format results
        results = []
        for score, doc_address in search_results.hits:
            doc = searcher.doc(doc_address)

            # Extract document fields using get_first() method
            content = str(doc.get_first("content")) if doc.get_first("content") else ""
            path = str(doc.get_first("path")) if doc.get_first("path") else ""
            package = str(doc.get_first("package")) if doc.get_first("package") else ""
            title = str(doc.get_first("title")) if doc.get_first("title") else ""
            source_repo = (
                str(doc.get_first("source_repo"))
                if doc.get_first("source_repo")
                else ""
            )
            docs_path = (
                str(doc.get_first("docs_path"))
                if doc.get_first("docs_path")
                else "docs"
            )

            # Truncate content for readability while preserving context
            content_preview = _create_content_preview(content, query)

            # Generate GitHub link for official documentation
            github_link = _reconstruct_github_link(source_repo, docs_path, path)

            results.append(
                {
                    "score": float(score),
                    "package": package,
                    "title": title,
                    "path": path,
                    "source_repo": source_repo,
                    "github_link": github_link,
                    "content_preview": content_preview,
                }
            )

        # Format results as text
        output = f"Found {len(results)} result(s) for '{query}'"
        if package_filter:
            output += f" (filtered by {package_filter})"
        output += ":\n\n"

        for i, result in enumerate(results, 1):
            output += f"**Result {i} (Score: {result['score']:.2f})**\n"
            output += f"Package: {result['package']}\n"
            output += f"Title: {result['title']}\n"
            output += f"Path: {result['path']}\n"
            output += f"Source: {result['source_repo']}\n"
            if result["github_link"]:
                output += f"GitHub: {result['github_link']}\n"
            output += "\n"
            output += f"Content:\n{result['content_preview']}\n"
            output += "-" * 80 + "\n\n"

        return output

    except Exception as e:
        logger.error(f"Search error: {e}")
        return f"Search failed: {str(e)}"


def main():
    """Run the MCP server."""
    try:
        logger.info("Starting Python Dependency Manager Documentation MCP Server...")
        logger.info(
            "Server provides fuzzy search across pip, conda, poetry, and uv documentation"
        )

        # Initialize index on startup to catch errors early
        _get_search_components()

        # Run the server
        app.run()

    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Server error: {e}")
        raise


if __name__ == "__main__":
    main()
