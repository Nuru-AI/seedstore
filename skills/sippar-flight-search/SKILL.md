---
name: sippar-flight-search
description: Use this when you need live flight options and prices between two airports, one way or round trip, for one to nine adults, with airlines, times, stops and Google's view of whether the price is low, typical or high. Sippar's sippar-flight-search model on AntSeed returns Google Flights results for one route and date, bought from stabletravel.dev.
metadata:
  version: "1.2.0"
  updated: "2026-11-03"
---

# sippar-flight-search

Google Flights results for one route and one date (or date pair), bought from stabletravel.dev and
passed on unchanged. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-flight-search", "messages": [{"role": "user", "content": "JFK LHR 2026-11-12 2026-11-19 2"}]}
```

## How to ask

The last user message is one line in a fixed format:

```
FROM TO DATE [RETURN-DATE] [ADULTS] [OPTIONS]
```

- `FROM` and `TO` are airport codes with scheduled passenger flights: `LHR`, not the city code
  `LON`; `JFK`, not `NYC`. Any other code is refused before anything is bought.
- `DATE` is `YYYY-MM-DD`, today or later, up to about 11 months out. A second date makes it a round
  trip.
- `ADULTS` is 1 to 9 (default 1). Prices are for the whole party, so ask for the party you are
  pricing: seat availability differs at two seats, and doubling a one-seat price can name the wrong
  airline.
- Options, in any order, after the rest: `class:economy|premium|business|first`, `children:N`,
  `infants:N` (own seat), `lap:N` (on a lap; one per adult), `currency:EUR` (any three-letter code;
  default USD). Nine travellers at most. For example
  `JFK LHR 2026-11-12 2026-11-19 2 class:business children:1`.
- The words `to`, `adults` and `pax` are ignored, so `TLV to ATH 2026-10-26 2 adults` works. A
  sentence ("cheap flights to Athens next week") is refused, free, and the refusal shows the format.

One call is one route and one date. For several dates or destinations, send one call per pair.

## Reading the answer

The first line is `Source: Google Flights, retrieved <time>. Request sent: {...}`, ending "the search
response, unchanged." Then the JSON, then a closing line (which names stabletravel.dev and the exact
request URL) and a disclaimer.

```python
import json
start = page.index("{", page.index("search response, unchanged."))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

- `best_flights` (Google's top picks, usually 3) and `other_flights`: typically 10 to 25 itineraries
  in all. Each has `price` (USD, for the whole party, and for a round trip the whole round trip),
  `type`, `total_duration` (minutes), `carbon_emissions`, `layovers` when it stops, and `flights`: one
  entry per segment with departure and arrival airports and local times, `airline`, `flight_number`,
  `airplane`, `travel_class`, `duration`, `legroom`, `extensions` (notes such as Wi-Fi) and flags such
  as `overnight` or `often_delayed_by_over_30_min`.
- `price_insights`: `lowest_price`, `price_level` (`low`, `typical` or `high`) and
  `typical_price_range`. One-way pages also carry `price_history` (about two months of daily lows).
- `search_metadata.google_flights_url`: the same search on Google Flights. Give it to a person who
  wants to book; this model has no booking links of its own.
- `airports` (names, cities and countries) and `search_parameters` (in it, `type` `"1"` is a round
  trip and `"2"` one way).

Price per person is `price` divided by the number of adults; keep the cents ($1,569 for two is
$784.50 each).

## Limits and caveats

- A round trip lists outbound flights only. Each `price` is already the round-trip total, but the
  return flight sits behind a `departure_token` this model cannot send back. Quote the round-trip
  price with the outbound flight and say the return is chosen at booking. To see return options, send
  the return as its own one-way line; those are one-way fares, not part of the round-trip price.
- There is no stops, price or airline filter: `stops:`, `max:` and `airlines:` are refused, free.
  Every itinerary carries its stops, price and airline, so filter the list yourself.
- An empty search exists. When Google finds nothing, the JSON carries `error` and
  `search_information.flights_results_state: "Fully empty"`. Try other dates or the next airport.
- Fares change by the hour. Quote a price with its retrieval time and check again before booking.
  This is not a booking or an airline quote.
- When a search finds fewer than five itineraries, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. One-way pages are about 3,200 to 11,000
tokens (a busy US domestic route is the widest), a round trip for two about 7,300 (measured
2026-10-09). A refused line bills nothing; an empty search is billed.
