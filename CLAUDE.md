# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Nix-based development environment template that provides a sandboxed setup for Claude Code CLI with reproducible dependencies.

## Development Environment

Enter the development shell:
```bash
# Automatic (with direnv installed)
direnv allow  # First time only, then auto-loads on directory entry
```

Or run directly without direnv:
```bash
"$(nix-build --no-out-link)"/bin/fence-claude <claude_args> -- <fence_args>
```

Open a sandboxed shell (for inspecting/testing the sandbox environment):
```bash
"$(nix-build --no-out-link -A shell)"/bin/fence-shell <fence_args>
```

## Dependency Management

Update pinned dependencies:
```bash
nix-instantiate --option tarball-ttl 1 --strict --eval --arg update true nix/sources.nix > sources.tmp && mv sources.tmp nix/sources.lock
```

## Architecture

- `default.nix` - Main entry point, provides `fence-claude` and `fence-pi` packages
- `nix/fence-agent.nix` - Shared sandbox builder used by `fence-claude.nix` and `fence-pi.nix`
- `nix/fence-claude.nix` - Sandboxed Claude Code (uses `fence-agent`)
- `nix/fence-pi.nix` - Sandboxed pi-coding-agent (uses `fence-agent`)
- `nix/sources.nix` - Declarative dependency fetching (nixpkgs)
- `nix/sources.lock` - Pinned dependency versions with commit hashes and narHashes
- `nix/statusline.jq` - jq script for Claude Code statusline (cwd, model, context usage)
- `.envrc` - direnv configuration for automatic environment loading

The project uses a custom Nix dependency management approach (via `nix/sources.nix`/`nix/sources.lock`) rather than Nix Flakes. When `update=false` (default), `sources.nix` reads pinned revisions from `sources.lock` and fetches tarballs by SHA256; when `update=true`, it fetches latest commits via `builtins.fetchGit` and writes new lock data to stdout.

### Sandbox Mechanism

`nix/fence-agent.nix` is a reusable function that uses [fence](https://github.com/Use-Tusk/fence) with `bubblewrap` to sandbox an agent binary. Both `fence-claude` and `fence-pi` are built from it. The sandbox:

- Limits the tools available to the agent to an explicit allowlist: `bash`, `cacert`, `coreutils`, `curl`, `diffutils`, `fd`, `file`, `findutils`, `gawk`, `gh`, `git`, `gnugrep`, `gnused`, `jq`, `less`, `python3`, `ripgrep`, `tinyxxd`, `unzip`, `which`
- Restricts filesystem access: strict deny-read by default, only the Nix closure and the configured `allowWrite` paths are accessible
- For `fence-claude`: write access to `.`, `~/.claude/`, and `~/.claude.json`; auto-creates `~/.claude.json` with `hasCompletedOnboarding: true` (prevents onboarding errors in the sandbox)
- For `fence-pi`: write access to `.` and `~/.pi`
- No network access by default (can be configured in `~/.config/fence/fence.json` or by uncommenting the `network` section in the respective .nix file)
- Sets `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` for `fence-claude` to reduce unnecessary network usage
- Sets `SSL_CERT_FILE` for HTTPS access
- Uses `bubblewrap` on Linux for namespace isolation (unshares all namespaces) and Apple Sandbox on macOS
- Provides `fence-claude` wrapper: `fence-claude <claude_args> -- <fence_args>`
- Provides `fence-pi` wrapper: `fence-pi <agent_args> -- <fence_args>`
- Provides `fence-claude.shell` and `fence-pi.shell` passthrus: sandboxed bash shells with matching isolation settings

### Managed Dependencies

One source is pinned in `nix/sources.lock`:
- **nixpkgs** (`nixos-26.05` branch) - base package set; `allowUnfreePredicate` enables `claude-code`
