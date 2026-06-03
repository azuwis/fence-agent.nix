# fence-agent.nix

Nix-based sandboxed environments for AI coding agents using [fence](https://github.com/Use-Tusk/fence) ([bubblewrap](https://github.com/containers/bubblewrap) on Linux, Apple Sandbox on macOS).

## Packages

- **fence-claude** - Sandboxed [Claude Code](https://claude.ai/code) CLI
- **fence-pi** - Sandboxed [pi-coding-agent](https://github.com/Use-Tusk/pi-coding-agent)

## Features

- **Sandboxed execution** - Agents run with restricted filesystem, network, and namespace isolation
- **Explicit tool allowlist** — only approved CLI tools (`bash`, `curl`, `fd`, `file`, `gh`, `git`, `jq`, `python3`, `ripgrep`, etc.) are accessible
- **No network by default** - network access is opt-in via configuration
- **Reproducible** - all dependencies are pinned with Nix
- **Shared builder** - `nix/fence-agent.nix` is a reusable function for sandboxing any agent binary

## Quick Start

```bash
# Add to PATH (with direnv)
direnv allow

# Run Claude Code in the sandbox
fence-claude

# Run pi-coding-agent in the sandbox
fence-pi

# Pass arguments to agent and fence
fence-claude <claude_args> -- <fence_args>
fence-pi <agent_args> -- <fence_args>

# Or run directly without direnv
"$(nix-build --no-out-link)"/bin/fence-claude <claude_args> -- <fence_args>

# Open a sandboxed shell (for inspecting/testing the sandbox)
"$(nix-build --no-out-link -A fence-claude.shell)"/bin/fence-shell <fence_args>
```

## Configuration

### Network Access

By default, network access is denied. To allow access, either configure the `network` section in the respective .nix file or create `~/.config/fence/fence.json`:

```json
{
  "network": {
    "allowedDomains": [
      "*.anthropic.com"
    ],
    "deniedDomains": [
      "statsig.anthropic.com",
      "*.sentry.io"
    ]
  }
}
```

### Filesystem Access

- **fence-claude**: write access to `.` (working directory), `~/.claude/`, `~/.claude.json`
- **fence-pi**: write access to `.` (working directory), `~/.pi/`

All other filesystem access is denied by default.

## Updating Dependencies

```bash
nix-instantiate --option tarball-ttl 1 --strict --eval --arg update true nix/sources.nix > sources.tmp && mv sources.tmp nix/sources.lock
```
