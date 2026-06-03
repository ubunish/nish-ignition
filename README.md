# nish-ignition

One `./setup.sh` that builds a full robotics workstation on macOS or Ubuntu: apps, packages, and Nish's own repos — with per-step flags and a reversible uninstall.

The name nods to First Motive — first motion, ignition.

## Quick Start

Prerequisite: `git`.

```bash
git clone https://github.com/ubunish/nish-ignition.git ~/nish-ignition
cd ~/nish-ignition
./setup.sh
```

`setup.sh` detects the OS, then runs the steps listed in `scripts/manifest.sh` for that platform:

```
uname → macOS  → scripts/macos/
      → Ubuntu → scripts/ubuntu/
```

Each step is idempotent: re-running the full setup skips anything already installed.

## How It Works

```
setup.sh
  ├── reads scripts/manifest.sh   step registry + package arrays
  ├── parses flags                --only / --skip / --uninstall / --list
  └── for each enabled step:      bash scripts/<os>/<file> <mode>
                                    mode ∈ check | install | uninstall
```

The manifest is the single source of truth. A step is `id|file|default`; package
lists (`MACOS_FORMULAE`, `MACOS_CASKS`, `UBUNTU_APT`, `UBUNTU_ROS_APT`) live there
too, so nothing is hard-coded inside the step scripts.

Every step script implements the same contract — `do_check`, `do_install`,
`do_uninstall` — and routes on its first argument. So any step is safe to run
standalone:

```bash
bash scripts/macos/10-cli-tools.sh check      # report state, no changes
bash scripts/macos/10-cli-tools.sh install    # install
bash scripts/macos/10-cli-tools.sh uninstall  # reverse where safe
```

## Flags

| Flag | Effect |
|------|--------|
| `--list` | List every step id, its file, and default state, then exit |
| `--only a,b,c` | Run only these step ids; skip everything else |
| `--skip a,b,c` | Run every step except these ids |
| `--uninstall` | Run steps in reverse, reversing installs where reversible |
| `-h`, `--help` | Show usage |

Step ids come from the manifest. Comma-separate or repeat a flag.

```bash
./setup.sh --list                  # see the step ids
./setup.sh --only cli-tools,repos  # one slice of the setup
./setup.sh --skip nvidia,isaac-sim # everything but the heavy GPU bits
```

### Environment

| Variable | Effect |
|----------|--------|
| `NONINTERACTIVE=1` | Skip all prompts. Steps that need a human are flagged, not run |
| `UBUNDI_EMAIL=you@ubundi.co.za` | Preseed the email for the SSH key |
| `CODE_DIR=/path` | Override where repos clone (default `~/code`) |

## Uninstall

```bash
./setup.sh --uninstall              # reverse everything reversible
./setup.sh --uninstall --only apps  # reverse one step
```

Reversal is deliberately conservative. Cleanly reversible items come back out
(brew formulae and casks, `uv` tools, Tailscale, snaps, the SSH service, the
`NOPASSWD` sudoers rule). Destructive or system-level installs are **left in
place** with a notice rather than removed automatically: Homebrew itself, the
NVIDIA driver, the full ROS desktop, base apt packages, SSH keys, and cloned
repos under `~/code`. Deleting a Python venv prompts first.

## Repos Layer

After the apps and packages, two steps clone and wire Nish's own repos:

```
repos            vcs import < repos.yaml  →  ~/code/{nish-aliases,nish-ai,fm-ros2}
repo-installers  delegate to each repo's own entrypoint
```

`repos.yaml` pins the three repos. The `repo-installers` step hands off to each
repo's own installer rather than reimplementing it:

```
nish-aliases/install.sh  {install|uninstall|status}
nish-ai/install.sh       {install|uninstall|status}
fm-ros2/scripts/setup-<os>.sh   (install only — fm-ros2 owns its Docker/colcon)
```

nish-ignition's own modes map onto that contract: `install → install`,
`uninstall → uninstall`, `check → status`.

## Manual Steps

A few things can't be scripted and are flagged inline by the relevant step:

- Create accounts: Google (`@ubundi.co.za`), Claude, Wise
- `gh auth login`, `claude /login`, `huggingface-cli login`, `sudo tailscale up`
- Isaac Sim download (NVIDIA account required)
- Ubuntu installer choices, BIOS, install media

## Layout

```
nish-ignition/
├── setup.sh                # OS-detect entrypoint + flag parsing
├── repos.yaml              # vcstool manifest for ~/code repos
├── scripts/
│   ├── manifest.sh         # step registry + package arrays (source of truth)
│   ├── lib.sh              # helpers: logging, gating, dispatch, repo delegation
│   ├── macos/              # 00-… 10-… … check/install/uninstall steps
│   └── ubuntu/             # 00-… 10-… … check/install/uninstall steps
└── docs/
    ├── macos.md            # reference narrative (manual fallback)
    └── ubuntu.md
```

The `docs/` guides are the hand-written narratives the automation grew out of.
They stay as reference for debugging and the manual-only steps.
