# MagSafe LED

Turn off the green/orange light on your MacBook's MagSafe connector, or lock it to one color. It runs from the menu bar.

macOS has no setting for this. The LED is driven by the SMC key `ACLC`, and macOS takes it back on every replug, charge change and reboot. A small root daemon puts your choice back every 2 seconds.

## Install

Requires Apple Silicon and the Xcode Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/gbretas/magsafe-led
cd magsafe-led
./install.sh
```

A bolt icon shows up in the menu bar. Pick one of:

- **Apagada**: LED off
- **Padrão do sistema**: macOS decides, same as stock
- **Sempre verde** / **Sempre laranja**: forced color

## How it works

| Part | What it does |
|------|--------------|
| `daemon/magsafeledd.c` | Runs as root via launchd. Reads `/Users/Shared/MagSafeLED/mode` and writes `ACLC` over IOKit. |
| `app/MagSafeLED.swift` | Menu bar app. Writes the chosen mode to that file. |

`ACLC` values: `0` system, `1` off, `3` green, `4` orange.

Without the app, from the terminal:

```sh
echo off > /Users/Shared/MagSafeLED/mode
```

## Uninstall

```sh
./uninstall.sh
```

## Disclaimer

This writes to the SMC, which Apple does not document. It only touches the LED key, but use it at your own risk.

## License

MIT
