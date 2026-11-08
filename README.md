# Glowless

**Turn off the MagSafe light.** Sleep in the dark, stop the green dot from staring at you during a movie, or lock it to the color you like.

Glowless lives in your menu bar and in Spotlight (⌘ + Space → *Glowless*). Pick a mode once and it stays that way after replugging, charge changes and reboots.

| Mode | LED |
|------|-----|
| Apagada | off |
| Padrão do sistema | stock macOS behavior |
| Sempre verde | always green |
| Sempre laranja | always orange |

## Install

Requires an Apple Silicon MacBook with MagSafe, macOS 13+, and the Xcode Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/gbretas/glowless
cd glowless
./install.sh
```

It asks for your password once, to install the background service that talks to the hardware.

## Why it needs a background service

macOS has no setting for the MagSafe LED. The light is driven by the SMC key `ACLC`, and macOS takes it back every time you plug in, the charge state changes or the Mac restarts. `glowlessd` runs as root and puts your choice back every 2 seconds.

| Part | What it does |
|------|--------------|
| `daemon/glowlessd.c` | Root launchd daemon. Reads `/Users/Shared/Glowless/mode`, writes `ACLC` over IOKit. |
| `app/Glowless.swift` | Menu bar app and settings window. Writes the chosen mode to that file. |

`ACLC` values: `0` system, `1` off, `3` green, `4` orange.

You can skip the app entirely:

```sh
echo off > /Users/Shared/Glowless/mode
```

## Uninstall

```sh
./uninstall.sh
```

## Disclaimer

Glowless writes to the SMC, which Apple does not document. It only touches the LED key, but use it at your own risk.

## License

MIT
