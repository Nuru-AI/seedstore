---
name: sippar-hotel-search
description: Use this when you need places to stay in a city or area (hotels, hostels, apartments, guest houses) with star class, guest rating, amenities, address and a current nightly price, and on request each booking site's price for that night. Sippar's sippar-hotel-search model on AntSeed returns Google Maps data from OpenWeb Ninja.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-hotel-search

Places to stay that Google Maps finds for one search, from OpenWeb Ninja's Local Business Data API.
Hotels, hostels, aparthotels, guest houses and holiday rentals all come through the same search. How
to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-hotel-search", "messages": [{"role": "user", "content": "hostels in Lisbon, Portugal"}]}
```

## How to ask

The last user message is one plain line: the kind of stay and the place.

- Add the country when a city name exists in more than one country (`hotels in Paris, France`). The
  search runs from a US region by default, so a bare name can land on an American town.
- The kind of stay shapes the list: `hotels in`, `hostels in`, `boutique hotels in`, `vacation
  apartments in`, `bed and breakfast in`, `hotels near Times Square, New York`.
- You get up to 10 places. End the line with the word `offers` to get up to 5 places with every
  booking site's price for each (`hotels in Athens, Greece offers`).
- There are no dates, guest counts or price filters. Filter by price, stars or rating from the list
  yourself.
- A line needs at least three letters, and up to 120 characters.

## Reading the answer

The first line is `Source: Google Maps, via OpenWeb Ninja (Local Business Data), retrieved <time>.
Request sent: {...}`, ending with "values unchanged:" and the fields kept for each place. Then the
JSON, a closing line and a disclaimer.

```python
import json
start = page.index("{", page.index("values unchanged:"))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

- `data`: the places, in Google's order. Each has `name`, `type` and `subtypes`, `hotel_stars`,
  `rating` and `review_count`, `hotel_price_for_dates` (a string with the currency, such as
  `"$178"`), `hotel_amenities` (such as `{"Free Wi-Fi": true, "Free breakfast": true}`),
  `full_address`, `latitude`, `longitude`, `place_link` (the Google Maps page), `website`,
  `phone_number`, `business_status` and `photos_sample` (one photo link).
- With `offers`, each place also has `hotel_booking_options`: one entry per booking site
  (Booking.com, Agoda, Expedia, Hotels.com and others) with `source`, `price` and `link`. The list is
  not sorted by price; sort it yourself.
- `parameters` echoes what the search ran with, and `status` is `"OK"` on success.
- A field a place does not have is absent, never filled in. A place with no `hotel_price_for_dates`
  came back without a price; check its website.

## Limits and caveats

- `hotel_price_for_dates` is the price Google showed for its own default stay, not for dates you
  choose. Treat it as the place's current price level. For real dates, open the place's website or a
  booking site from the offers list. Prices change by the hour; quote them with the retrieval time.
- A site's price can sit above `hotel_price_for_dates`, which is Google's own figure.
- A place Google cannot match returns `"data": []`, and that short answer is billed. Try a nearby
  town or a broader kind of stay.
- This is not a booking or a quote from any hotel or site.
- When a search finds fewer than five places, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Ten places are about 2,000 to 2,400 tokens.
With `offers` (five places) an answer is 19,000 to 31,000, because every booking site's link is long;
ask for `offers` only when you need site-by-site prices (measured 2026-10-10). A refused line bills
nothing.
