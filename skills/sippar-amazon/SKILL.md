---
name: sippar-amazon
description: Use this when you need Amazon products for a search or a category's bestsellers, with price (with and without VAT), rating and review count, or one product's buybox offer, other sellers, stock, delivery and top reviews, on amazon.com, .co.uk, .de, .fr, .es or .it. Sippar's sippar-amazon model on AntSeed returns Amazon data from glim.sh.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-amazon

Amazon listings as glim.sh returns them, on six marketplaces: amazon.com, .co.uk, .de, .fr, .es and
.it. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-amazon", "messages": [{"role": "user", "content": "noise cancelling headphones"}]}
```

## How to ask

The last user message is one line, and its shape decides the call:

| Send | You get |
|---|---|
| a search, such as `usb c charger` | up to about 20 ranked products (48 on some marketplaces) |
| `bestsellers:<category>`, such as `bestsellers:electronics` | that category's bestsellers, up to 30 |
| an ASIN from a search result, such as `B08G4GRQYV` | one product: buybox offer, other sellers, stock, delivery, top reviews |
| a product URL, such as `https://www.amazon.de/dp/B0F59XT8QM` | the same, on the marketplace the URL names |

To add options, send the message as JSON with glim.sh's own field names, `query` carrying the line:

```json
{"model": "sippar-amazon",
 "messages": [{"role": "user", "content": "{\"query\": \"electric kettle\", \"tld\": \"co.uk\", \"sort_by\": \"most_reviewed\", \"min_reviews\": 1000}"}]}
```

- `tld`: `com` (default), `co.uk`, `de`, `fr`, `es` or `it`. A product URL sets it from its host.
- For a search only: `page` (1 to 20), `sort_by` (`most_recent`, `price_low_to_high`,
  `price_high_to_low`, `featured`, `average_review`, `bestsellers`, `most_reviewed`), `min_reviews`,
  `include_paid` (adds sponsored results) and `include_suggested`. Sending one of these with a product
  lookup is refused.
- `response_format`: `concise` (default) or `detailed`, which keeps images, variants and the full
  offers list.
- There is no count option. Keep the first N yourself.
- Category slugs differ by marketplace: `electronics` on .com, `elektronik` on .de, `electronique` on
  .fr. An unknown slug is answered with glim.sh's 404 and a suggestion, and costs only that short page.

The answer's `Request sent` shows glim.sh's names (`category_slug`, `asin`); do not copy them into
your request.

## Reading the answer

The first line is `Source: glim.sh (Amazon, amazon.<tld>), POST <endpoint>, retrieved <time>.
Request sent: {...}.` Then a blank line, glim.sh's JSON, a closing line and a disclaimer.

```python
import json
if page.startswith("Not sent to glim.sh:"):
    data = None  # refused before buying: the reason is on the first line
else:
    data = json.loads(page.split("\n\n")[1])
```

A search (`mode` is `query` or `category`):

- `organic`: the products in Amazon's order (`pos`), each with `asin`, `title`, `url`, `price_gross`
  and `price_net` with `currency` and `vat_rate`, `rating`, `reviews_count`, `is_prime`,
  `is_amazons_choice`, `best_seller`, `delivery`, and on some `sales_volume`, `price_strikethrough`,
  `deal`, `stock`, `other_offers_count` and `other_offers_from_price`.
- `paid` (only with `include_paid`), kept apart from `organic`.
- `page`, `has_more` and `last_visible_page` for the next `page`.

A product (`asin` at the top):

- `title`, `brand`, `category`, `bullet_points`, `specifications`, sometimes `description`.
- `price_gross`, `price_net`, `currency`, `vat_rate`, `stock`, `is_prime_eligible`, `delivery`.
- `offers_summary.buybox`: the offer Amazon shows by default, with `condition`, price and `seller`.
- `pricing_count` and `other_offers_from_price` (the cheapest other offer).
- `top_reviews`: customers' reviews with `author`, `rating`, `title`, `body`, `verified_purchase` and
  a date string. `rating` and `reviews_count` are Amazon's totals, not computed from these.

## Limits and caveats

- Take an ASIN from a search result. An ASIN no product carries can come back as an unrelated
  product, and it is billed.
- Read the buybox `seller`: a "New" buybox can be sold by Amazon's returns outlet.
- With `most_reviewed`, colour and size variants share one review count, so one product can fill
  several rows. glim.sh re-ranks only the page it fetched.
- A missing price is `null` or absent, never zero. The marketplaces we read showed reviews on .de and
  .co.uk product pages and none on .com.
- Prices, stock and delivery are what Amazon showed at the retrieval time; quote them with that
  time. Reviews are the customers' own words; quote them as theirs. Sippar does not buy on Amazon for
  you.
- A line the model can tell is wrong before buying opens with `Not sent to glim.sh:` and the reason.
- When a search finds fewer than five products, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Searches are about 430 to 7,300 tokens,
median 2,700; product pages 800 to 2,100, median 1,000, and about twice as wide with reviews
(measured 2026-10-10). A refused line bills nothing.
