---
name: nasa-power-weather
description: Use this when you need daily weather or solar data for a place and a date range: mean, maximum and minimum temperature, precipitation, solar irradiance and wind speed, for a latitude and longitude over up to 31 days. Sippar's free nasa-power-weather model on AntSeed reads NASA Langley Research Center's POWER project data live for each request. It takes coordinates, not place names.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# nasa-power-weather

Daily weather and solar data for one point from NASA Langley Research Center's [POWER](https://power.larc.nasa.gov) project (satellite and model data), read live for each request: one row per day, up to 31 days. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "nasa-power-weather", "messages": [{"role": "user", "content": "32.08 34.78 2026-10-01 2026-10-07"}]}
```

## How to ask

The last user message is four values separated by spaces: latitude, longitude, start date and end
date, e.g. `32.08 34.78 2026-10-01 2026-10-07` (Tel Aviv, one week). Dates are `YYYY-MM-DD`, at most
31 days apart.

**Coordinates, not place names.** `weather in Tel Aviv` is refused with HTTP 400 and the form above;
look up the coordinates first. The same four as JSON: `latitude` (-90 to 90), `longitude` (-180 to
180), `start` and `end`.

## Reading the answer

The first line is `Source: NASA POWER (daily weather and solar data for a point), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many days came back
```

`{"count", "total", "rows": [...]}`. Each row has `date` and six values: `T2M`, `T2M_MAX` and `T2M_MIN` (temperature at 2 m, degrees C), `PRECTOTCORR` (precipitation, mm a day), `ALLSKY_SFC_SW_DWN` (solar irradiance on a horizontal surface, kWh per square metre a day) and `WS2M` (wind speed at 2 m, m/s).

`32.08 34.78 2026-10-01 2026-10-07` (2026-11-04) returned 7 days; 1 October read `T2M` 23.58,
`T2M_MAX` 28.65, `T2M_MIN` 20.39, `PRECTOTCORR` 0.38.

## Limits and caveats

- POWER marks a value it does not have as `-999`; the last few days are often not available yet.
- These data were obtained from the NASA Langley Research Center (LaRC) POWER Project funded through
  the NASA Earth Science/Applied Science Program.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "32.08 34.78 2026-10-01 2026-10-07", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to NASA POWER.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to NASA POWER. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 7-day page is about 650 tokens (measured 2026-11-04).
