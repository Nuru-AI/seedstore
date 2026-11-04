---
name: usgs-earthquakes
description: Use this when you need recent earthquakes: which quakes above a magnitude happened in the last days, with place, time, depth, location, tsunami flag and the USGS event page. Sippar's free usgs-earthquakes model on AntSeed reads the U.S. Geological Survey's live earthquake catalog for each request, newest first, for up to 30 days back.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# usgs-earthquakes

Recent earthquakes worldwide from the [U.S. Geological Survey](https://earthquake.usgs.gov) catalog, read live for each request, newest first: up to 10 events above a minimum magnitude over the last days. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "usgs-earthquakes", "messages": [{"role": "user", "content": "M5 7 days"}]}
```

```json
{"model": "usgs-earthquakes", "messages": [{"role": "user", "content": "{\"query\": \"recent\", \"minmagnitude\": 6, \"days\": 30}"}]}
```

## How to ask

The last user message is any line; two things are read from it. A minimum magnitude written as `M5`
or `5+`, and a number of days written as `30 days`. With neither, you get M4.5 and above over the
last 7 days.

The same two as JSON, which wins over the words:

| Field | Values |
|---|---|
| `minmagnitude` | 0 to 9.9 (default 4.5) |
| `days` | 1 to 30 (default 7) |

## Reading the answer

The first line is `Source: USGS (recent earthquakes worldwide), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many events matched
```

`{"count", "total", "rows": [...]}`. Each row has `id`, `magnitude`, `magnitudeType` (`mww`, `mb`, ...), `place`, `time` (UTC), `depthKm`, `latitude`, `longitude`, `felt` (reports, or null), `alert` (USGS PAGER level, or null), `tsunami` (1 or 0), `status` (`reviewed` or `automatic`) and `url` (the USGS event page).

`M5 7 days` (2026-11-04) returned 10 events, the newest an M5.0 207 km ESE of Sarangani, Philippines,
at 07:40 UTC that day.

## Limits and caveats

- Only the event summary is included; each row links to the USGS event page with maps and shaking data.
- Newest first, at most 10: for a busy week, raise `minmagnitude` to see the largest events.
- `status: "automatic"` values can still change as USGS reviews the event.
- Credit: U.S. Geological Survey, Earthquake Hazards Program.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "M6 30 days", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to USGS.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to USGS. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-event page is about 1,100 tokens (measured 2026-11-04).
