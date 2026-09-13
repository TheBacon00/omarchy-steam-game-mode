# omarchy-steam-game-mode

A SteamOS-style Gamescope/Big Picture session toggle for [Omarchy](https://omarchy.org/).
Drops from Hyprland into Steam running inside its own standalone `gamescope`
compositor — the same architecture SteamOS, Bazzite, and CachyOS use — and
back again, on a keybinding or a bar-widget click.

## Why this exists

Steam/Proton games render through Xwayland, and Xwayland has no protocol to
carry HDR or colorspace metadata to a Wayland compositor — a structural
limitation shared by every Wayland compositor, not just Hyprland. If HDR or
proper adaptive sync in your games matters to you, running Steam inside its
own compositor (which bridges this a different way) is the actually-supported
path every major SteamOS-like distro uses, rather than something achievable
in a general desktop Wayland session today.

## What it fixes that a naive gamescope setup won't

Gamescope's adaptive sync (VRR) is a runtime ConVar, off by default.
`--adaptive-sync` flips it on at launch — but Steam's own gamepadui resets it
back off a few seconds into its startup, independent of whether its in-UI VRR
toggle is reachable (which itself normally requires spoofing real Steam Deck
hardware — a dead end that doesn't actually fix VRR). This package keeps a
small watcher re-asserting the ConVar via `gamescopectl` for the life of the
session instead of fighting Steam's own preference.

It also detects your display's *actual* maximum refresh rate at each launch
via `modetest` — the kernel's already-fully-negotiated, per-resolution mode
list — rather than trusting a resolution-unaware EDID range descriptor or a
value baked in once at install time. Refresh rate is always correct for
whatever port/cable is connected right now, with no reinstall needed if you
change monitors or cables.

## Installing

```bash
# From AUR (once published):
yay -S omarchy-steam-game-mode-git

# Or build locally:
git clone https://github.com/TheBacon00/omarchy-steam-game-mode.git
cd omarchy-steam-game-mode
makepkg -si
```

Then, as your own user (not root):

```bash
omarchy-steam-game-mode-activate
```

This registers the bar widget, sets a sane default SDDM autologin, and
reloads the shell. Package files are installed either way — this step only
does the per-user parts pacman hooks can't safely do (writing into `$HOME`,
picking up who's actually logging in).

Bind a key yourself (`SUPER + ALT + B` is free by default; `SUPER + ALT + G`
collides with Omarchy's stock "move window out of group" tiling binding):

```lua
-- ~/.config/hypr/bindings.lua
o.bind("SUPER + ALT + B", "Enter Game Mode", "omarchy-launch-floating-terminal-with-presentation omarchy-steamos-session-interactive")
```

## Removing

```bash
omarchy-steam-game-mode-deactivate   # as your own user, first
sudo pacman -R omarchy-steam-game-mode-git
```

## Troubleshooting VRR

```bash
journalctl --user -u omarchy-gamescope-session.service
```

Look for the `vrr_capable` diagnostic line at session start. If it warns that
no connected connector reports `vrr_capable=1`, no setting here can fix it —
check the monitor's FreeSync/G-Sync setting, that it's on DisplayPort (or an
HDMI port/cable actually rated for the bandwidth you want), and your GPU
driver's VRR support.

## Known rough edges

- **NVIDIA**: functional but less mature than AMD/Intel as of writing —
  expect a real performance cost from the WSI layer's extra frame copy, and
  occasional driver-version-specific bugs. `ENABLE_GAMESCOPE_WSI=1` (already
  set here) is the documented unlock for NVIDIA HDR; without it HDR silently
  falls back to SDR.
- **HDR** is the least mature part of this whole stack industry-wide, gamescope
  included. It's requested with `--hdr-enabled` when gamescope supports it,
  but hardware/driver support varies.
- This is a genuinely invasive feature — it introduces a second full session
  type (SDDM autologin switching, a boot-loop-recovery daemon, a sudoers
  grant for passwordless session switching). Read the scripts before trusting
  them on a machine you can't easily recover.

## Architecture

- `usr/lib/steamos/gamescope-session` — the actual gamescope launch script,
  runtime-detects resolution/refresh, runs the `vrr_capable` diagnostic.
- `usr/lib/steamos/gamescope-vrr-force` — the ConVar watcher.
- `usr/lib/steamos/steam-short-session-tracker` — boot-loop protection:
  reverts to the desktop session after 3 short-lived Game Mode sessions.
- `usr/bin/omarchy-steamos-session-select` — the bidirectional switch, called
  by the keybinding and by Steam's own "Switch to Desktop" button (which
  hardcodes calling `/usr/bin/steamos-session-select` — the one filename here
  that genuinely can't be renamed).
- `usr/share/omarchy-steam-game-mode/plugin/` — the Omarchy bar widget,
  installed per-user by `omarchy-steam-game-mode-activate`.

Session lifecycle is adapted from the SteamOS/ChimeraOS `gamescope-session`
model; systemd unit and binary names are prefixed to avoid colliding with
ChimeraOS's own `gamescope-session-git`/`gamescope-session-steam-git` AUR
packages, which claim several of the same filenames for a different session
architecture (one with no desktop to switch back to).
