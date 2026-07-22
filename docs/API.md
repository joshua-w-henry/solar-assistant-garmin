# Bridge API contract

The app performs an authenticated HTTP `GET` request to the URL configured in `SolarConfig.API_URL`.

## Request

```http
GET /v1/summary HTTP/1.1
Accept: application/json
Authorization: Bearer YOUR_READ_ONLY_BRIDGE_TOKEN
```

Use HTTPS for any endpoint reachable over the internet.

## Response

A representative response is available at [`examples/summary.json`](../examples/summary.json).

```json
{
  "mqtt_connected": true,
  "updated_at": "2026-07-22T16:30:00Z",
  "date": "2026-07-22",
  "partial_day": true,
  "live": {
    "pv_w": 7420,
    "load_w": 3810,
    "battery_v": 53.2,
    "battery_w": 1210,
    "grid_w": 0
  },
  "today": {
    "pv_kwh": 32.6,
    "load_kwh": 28.4,
    "battery_in_kwh": 12.0,
    "battery_out_kwh": 8.7,
    "grid_in_kwh": 0.0,
    "grid_out_kwh": 0.0
  }
}
```

## Required fields

The following values are required for the four complications:

| JSON path | Type | Meaning |
|---|---|---|
| `mqtt_connected` | boolean | Whether the upstream telemetry source is healthy |
| `live.pv_w` | number | Current PV generation in watts |
| `live.load_w` | number | Current total load in watts |
| `live.battery_v` | number | Battery-bank voltage |
| `today.pv_kwh` | number | PV energy produced since local midnight |

Both `live` and `today` must be JSON objects.

## Optional fields

| JSON path | Type | Meaning |
|---|---|---|
| `updated_at` | ISO-8601 string | Source-data timestamp |
| `date` | string | Label for the daily totals page |
| `partial_day` | boolean | Whether the totals represent an incomplete day |
| `live.battery_w` | number | Battery power; positive charging, negative discharging |
| `live.grid_w` | number | Current grid power |
| `today.load_kwh` | number | Daily load energy |
| `today.battery_in_kwh` | number | Daily battery charge energy |
| `today.battery_out_kwh` | number | Daily battery discharge energy |
| `today.grid_in_kwh` | number | Daily grid import energy |
| `today.grid_out_kwh` | number | Daily grid export energy |

## Failure behavior

- Non-200 responses are treated as failed refreshes.
- If `mqtt_connected` is false, complications are published as unavailable.
- If required values are missing, the background service publishes unavailable values.
- Stored complication values are considered stale after ten minutes.
