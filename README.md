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
# Without direnv (remote)
nix run -f https://github.com/azuwis/fence-agent.nix/archive/master.tar.gz
nix run -f https://github.com/azuwis/fence-agent.nix/archive/master.tar.gz fence-pi
nix run -f https://github.com/azuwis/fence-agent.nix/archive/master.tar.gz fence-claude.shell

# Without direnv (local)
nix run -f .                                          # run Claude Code (default)
nix run -f . fence-pi                                 # run pi-coding-agent
nix run -f . fence-claude.shell                       # open a sandboxed shell

# or via nix-build for scripting / passing arguments
"$(nix-build --no-out-link)"/bin/fence-claude <claude_args> -- <fence_args>
"$(nix-build --no-out-link -A fence-claude.shell)"/bin/fence-shell <fence_args>

# With direnv

direnv allow
fence-claude <claude_args> -- <fence_args>
fence-pi <agent_args> -- <fence_args>
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
