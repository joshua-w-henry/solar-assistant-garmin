# Contributing

Contributions are welcome.

## Ground rules

- Never commit real URLs, tokens, private IP addresses, or signing keys.
- Keep complication IDs `0` through `3` stable unless a migration plan is included.
- Preserve the battery sign convention: positive charging, negative discharging.
- Test changes in the simulator and, when possible, on physical hardware.
- State the Garmin device and firmware used for device-specific changes.

## Before opening a pull request

```bash
./scripts/check-secrets.sh
xmllint --noout manifest.xml resources/complications.xml \
  resources/drawables/drawables.xml resources/strings/strings.xml
```

Describe:

- What changed
- Which device targets were tested
- Whether foreground, background, glance, and complication behavior were tested
