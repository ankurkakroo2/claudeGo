# ClaudeGo

<img width="300" height="300" alt="image" src="https://github.com/user-attachments/assets/d26c75de-6f1b-498b-b87a-eb2ff5da3a86" />

## Your phone disconnects. Your Claude session dies. Hours of work gone.

**ClaudeGo fixes this.** One script, zero dependencies, bulletproof sessions.

---

**The mobile Claude Code experience is broken.** SSH drops. Sessions vanish. Your 512MB VPS kills tmux with OOM errors. You spend more time fighting infrastructure than coding.

ClaudeGo is a single, dependency-free bash script that transforms any Linux server into a **rock-solid Claude Code workstation**. Connect from your phone (Termius, Blink Shell, JuiceSSH), close the app, switch networks, put your phone to sleep - your session survives.

## The Problem (You've Lived This)

```
$ tmux ls
no server running on /tmp/tmux-1000/default
```

Sound familiar? Here's what kills your sessions:

1. **OOM Killer** - Your 512MB VPS runs out of memory, Linux kills tmux
2. **Systemd Scope Failures** - Degraded user sessions crash tmux on pane creation
3. **SSH Drops** - Phone goes to sleep, connection dies, attached session dies with it
4. **No Swap** - Memory pressure with nowhere to spill over
5. **Firewall Blocks** - Mosh ports not open, falling back to fragile SSH

## The Solution

```bash
curl -fsSL https://raw.githubusercontent.com/ankurkakroo2/claudeGo/main/claudego | bash
```

Or download and run:

```bash
wget https://raw.githubusercontent.com/ankurkakroo2/claudeGo/main/claudego
chmod +x claudego
./claudego
```

ClaudeGo handles **everything**:

- Detects low RAM and sets up swap (stops OOM kills)
- Installs and configures mosh (survives network changes)
- Configures tmux with systemd-safe wrapper (no more scope failures)
- Opens firewall ports (SSH + mosh)
- Installs Node.js and Claude Code
- Creates helpful aliases (`cg` to start, `cg-status` to check health)
- **Resumes from where it left off** if interrupted

## Features

### Zero Dependencies
Pure bash. No Python, no Ruby, no package managers beyond what's on your system.

### Resume Capability
Script crashed? SSH dropped mid-install? Just run it again. ClaudeGo tracks progress and picks up where it left off.

### Mobile-First Design
Built for the exact pain points of mobile SSH:
- Mosh for connection persistence
- Tmux wrapper that avoids systemd scope issues
- Swap setup for memory-constrained VPS
- Quick aliases for one-handed operation

### Guided Setup
Every step is explained. Every action requires confirmation. No black boxes.

## Quick Start

### On Your Remote Server

```bash
# One-liner install
curl -fsSL https://raw.githubusercontent.com/yourusername/claudego/main/claudego | bash

# Or step by step
wget https://raw.githubusercontent.com/yourusername/claudego/main/claudego
chmod +x claudego
./claudego
```

### In Termius (Example Mobile Client)

1. **Edit your host connection**
2. **Enable "Use Mosh"** in connection settings
3. **Connect** to your server
4. **Run:** `cg`
5. **Work with Claude** as long as you need
6. **Detach:** `Ctrl+b d` before closing Termius
7. **Reconnect anytime:** `cg` to resume exactly where you left off

### Other Mobile SSH Clients

| Client | Platform | Mosh Support | Notes |
|--------|----------|--------------|-------|
| **Termius** | iOS/Android | Yes (toggle in settings) | Most popular, works well |
| **Blink Shell** | iOS | Yes (native) | Best mosh implementation |
| **JuiceSSH** | Android | Plugin | Good alternative |
| **Termux** | Android | Yes (install mosh) | Full Linux environment |

## Commands After Installation

```bash
cg           # Start or attach to Claude session
cg-new       # Force create new session (kills existing)
cg-list      # List all tmux sessions
cg-kill      # Kill Claude session
cg-status    # Show system status (memory, swap, sessions)
cg-help      # Quick reference
```

## Tmux Survival Guide

Inside a tmux session:

| Keys | Action |
|------|--------|
| `Ctrl+b d` | **Detach** (session keeps running) |
| `Ctrl+b [` | Scroll mode (use arrows, `q` to exit) |
| `Ctrl+b c` | Create new window |
| `Ctrl+b n` | Next window |
| `Ctrl+b p` | Previous window |
| `Ctrl+b 1-9` | Jump to window number |

**Golden Rule:** Always detach (`Ctrl+b d`) before closing your terminal app.

## What ClaudeGo Actually Does

### Step 1: System Check
Detects OS, package manager, RAM, existing swap. Warns if your setup is at risk.

### Step 2: Swap Setup
On servers with <512MB RAM, swap is mandatory. ClaudeGo creates a 2GB swapfile and makes it persistent across reboots.

### Step 3: Package Installation
Installs: `tmux`, `mosh`, `curl`, `git`

### Step 4: Node.js Installation
Installs latest LTS via NodeSource. Required for Claude Code.

### Step 5: Mosh Configuration
Verifies mosh-server works. Mosh keeps your session alive when:
- Phone switches from WiFi to cellular
- Connection drops temporarily
- Phone goes to sleep
- IP address changes

### Step 6: Firewall Setup
Opens ports in UFW:
- TCP 22 (SSH - initial handshake)
- UDP 60000-61000 (Mosh - persistent connection)

### Step 7: Tmux Configuration
Creates `~/.tmux.conf` optimized for mobile:
- Extended history (100k lines)
- Mouse support
- Aggressive resize for varying screen sizes

Adds a **safe wrapper** to `~/.bashrc` that prevents systemd scope failures:
```bash
tmux() {
    command env -u DBUS_SESSION_BUS_ADDRESS -u XDG_RUNTIME_DIR /usr/bin/tmux "$@"
}
```

This is crucial. Without it, tmux can fail silently on many VPS configurations.

### Step 8: Claude Code Installation
Installs `@anthropic-ai/claude-code` globally via npm.

### Step 9: Aliases
Adds `cg`, `cg-new`, `cg-list`, `cg-kill`, `cg-status`, `cg-help` to your shell.

### Step 10: Validation
Verifies everything is working:
- Swap present
- Mosh available
- Tmux configured
- Claude installed
- Firewall rules set
- User lingering enabled

## Troubleshooting

### "no server running" after reconnecting

**Cause:** OOM killer terminated tmux, or systemd scope failure.

**Fix:**
```bash
# Check if OOM killed something
sudo journalctl -b | grep -i "oom\|killed process"

# Check swap
free -h
swapon --show

# If no swap, run claudego again to set it up
./claudego
```

### Can't connect with mosh

**Cause:** Firewall blocking UDP ports.

**Fix:**
```bash
# Check firewall
sudo ufw status

# Should show:
# 60000:61000/udp    ALLOW    Anywhere

# If not:
sudo ufw allow 60000:61000/udp
```

### Tmux creates then immediately exits

**Cause:** Systemd user session is degraded.

**Fix:** ClaudeGo's tmux wrapper should prevent this. Verify it's in your bashrc:
```bash
grep "ClaudeGo tmux wrapper" ~/.bashrc
```

If missing, run `./claudego` again.

### Claude command not found

**Cause:** npm global bin not in PATH.

**Fix:**
```bash
# Find where npm installs globals
npm config get prefix

# Add to PATH (replace /usr/local with your prefix)
export PATH="$PATH:/usr/local/bin"

# Or re-run claudego
./claudego
```

## Architecture

```
~/.claudego/
├── state       # Installation progress (for resume)
├── config      # User configuration
└── install.log # Detailed installation log

~/.tmux.conf    # Tmux configuration
~/.bashrc       # Shell aliases and tmux wrapper
```

## Requirements

- Linux (Ubuntu, Debian, RHEL, Fedora, Arch)
- Bash 4+
- sudo access
- Internet connection (for package installation)

Tested on:
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- DigitalOcean droplets (512MB to 8GB)
- AWS EC2
- Google Cloud Compute

## Why Not Just Use...

### "Just use tmux"
Tmux alone doesn't survive OOM kills, doesn't handle systemd scope failures, and doesn't persist through network changes.

### "Just use mosh"
Mosh keeps the connection alive, but the session still dies if the server-side process is killed. You need tmux + mosh together, configured correctly.

### "Just add swap"
Swap helps, but without proper tmux configuration (avoiding systemd scope issues), sessions still die unexpectedly.

### "Just use VS Code Remote"
Great if you have a laptop. ClaudeGo is for when your phone is all you have.

## The Mental Model

```
Your Phone
    │
    │ (mosh - survives network issues)
    ▼
SSH Connection
    │
    │ (initial handshake only)
    ▼
Mosh Server
    │
    │ (persistent UDP connection)
    ▼
Tmux Server
    │
    │ (survives disconnects, protected from systemd issues)
    ▼
Claude Code
    │
    │ (your actual work)
    ▼
Swap Memory (prevents OOM kills when RAM fills)
```

**Each layer protects against different failure modes:**
- Mosh: Network instability
- Tmux: Connection/terminal loss
- Swap: Memory exhaustion
- Wrapper: Systemd scope failures

## Contributing

PRs welcome. Please test on at least one of:
- Ubuntu 22.04 (most common)
- Debian 12
- A 512MB VPS (stress tests the swap/OOM handling)

## License

MIT

---

**Stop losing sessions. Start shipping code.**

```bash
curl -fsSL https://raw.githubusercontent.com/ankurkakroo2/claudeGo/main/claudego | bash
```
