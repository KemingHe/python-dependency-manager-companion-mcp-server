# CodeQL Security Analysis

> Updated on 2025-07-21 by @KemingHe

## Overview

Comprehensive security analysis via GitHub's CodeQL with automated vulnerability detection.

## Configuration

- **File**: [`codeql.yml`](./codeql.yml)
- **Schedule**: Weekly (Mondays 1:24 AM UTC)
- **Triggers**: Push to main, pull requests
- **Bot Protection**: Skips analysis on `github-actions[bot]` commits

## Language Support

- **Active**: Actions workflows, Python code
- **Available**: Full CodeQL matrix (C/C++, C#, Go, Java/Kotlin, JavaScript/TypeScript, Ruby, Swift, Rust)
- **Build Mode**: Automatic detection for compiled languages
