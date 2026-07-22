# Architecture notes

## Components

### Telemetry source

Solar Assistant, Home Assistant, Node-RED, or another system produces current and daily solar values.

### HTTPS bridge

A small external service converts those values into one stable JSON document and protects it with a bearer token. The bridge should expose only read-only summary data.

### Garmin application

The Connect IQ app:

- Requests the summary in the foreground every 30 seconds.
- Caches values in `Application.Storage`.
- Requests a temporal background event every five minutes.
- Publishes four custom complications.
- Shows a glance and two app pages.

## Complication indexes

The complication IDs are fixed:

```text
0 = Current Load
1 = Current PV
2 = PV Produced Today
3 = Battery Voltage
```

Changing these IDs can break existing watch-face subscriptions.

## Staleness

The foreground app shows a status based on the source timestamp. The complication publisher considers cached data stale after ten minutes and publishes unavailable values.

## Battery direction

`live.battery_w` follows this convention:

```text
positive = charging
negative = discharging
```

The complication set currently publishes voltage rather than battery power. Battery power is used by the app and glance.
