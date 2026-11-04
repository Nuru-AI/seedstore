---
name: country-indicators
description: Use this when you need a country's economic or development figures by year: GDP, GDP per capita, GDP growth, population, inflation, unemployment, life expectancy, or any World Bank indicator by its code. Sippar's free country-indicators model on AntSeed reads World Bank Open Data live for each request: one indicator for one country, newest year first.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# country-indicators

One indicator for one country, by year, from [World Bank Open Data](https://data.worldbank.org), read live for each request, newest year first. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "country-indicators", "messages": [{"role": "user", "content": "IL gdp"}]}
```

```json
{"model": "country-indicators", "messages": [{"role": "user", "content": "USA NY.GDP.PCAP.CD"}]}
```

```json
{"model": "country-indicators", "messages": [{"role": "user", "content": "{\"query\": \"DE inflation\", \"limit\": 5}"}]}
```

## How to ask

The last user message is a country code and an indicator: `IL gdp`, `USA NY.GDP.PCAP.CD`.

- **Country**: a 2 or 3 letter World Bank code (`IL`, `ISR`, `USA`, `DE`), or a region code such as
  `WLD` for the world.
- **Indicator**: a World Bank indicator code, or one of these words:

| Word | Indicator code |
|---|---|
| `gdp` | `NY.GDP.MKTP.CD` (current US$) |
| `gdp per capita` | `NY.GDP.PCAP.CD` |
| `gdp growth` | `NY.GDP.MKTP.KD.ZG` (annual %) |
| `population` | `SP.POP.TOTL` |
| `inflation` | `FP.CPI.TOTL.ZG` (consumer prices, annual %) |
| `unemployment` | `SL.UEM.TOTL.ZS` (% of labour force) |
| `life expectancy` | `SP.DYN.LE00.IN` |

As JSON: `country` and `indicator`. Any other indicator code works too; the World Bank's own catalog
lists them.

## Reading the answer

The first line is `Source: World Bank (one development indicator for one country, by year), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many years the World Bank holds
```

`{"count", "total", "rows": [...]}`. Each row has `country`, `countryCode`, `indicator` (its name), `indicatorId`, `year`, `value`, `unit`, `observationStatus` and `url` (the indicator for that country on data.worldbank.org).

`IL gdp` (2026-11-04) returned 10 years, newest first: 2025, 610,777,842,873.6 (current US$).

## Limits and caveats

- A year with no value is shown as `null`, as the World Bank returns it.
- Indicator values only; no other World Bank site material.
- Data from World Bank Open Data, CC BY 4.0. Credit the World Bank when you use it.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "IL gdp growth", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to World Bank.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to World Bank. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-year page is about 1,000 tokens (measured 2026-11-04).
