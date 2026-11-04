---
name: sec-edgar-search
description: Use this when you need US company filings that mention a phrase: 10-Ks, 10-Qs, 8-Ks, proxy statements and more, from the SEC's EDGAR full-text search, with company, CIK, form, filing date, period and a link to the filing on sec.gov. Sippar's free sec-edgar-search model on AntSeed searches EDGAR live for each request, optionally limited to some form types. Filing documents are linked, not copied.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# sec-edgar-search

US company filings from the SEC's [EDGAR full-text search](https://efts.sec.gov/LATEST/search-index), live for each request: up to 10 filings whose text holds an exact phrase, each with a link to the filing on sec.gov. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sec-edgar-search", "messages": [{"role": "user", "content": "stablecoin reserves"}]}
```

```json
{"model": "sec-edgar-search", "messages": [{"role": "user", "content": "{\"query\": \"artificial intelligence\", \"forms\": \"10-K\", \"limit\": 5}"}]}
```

## How to ask

The last user message is a **phrase** (up to 200 characters). EDGAR returns filings whose text holds
that exact phrase, so send the words you expect in the filing, not a question: `stablecoin reserves`
finds filings, "which companies mention stablecoin reserves?" finds none.

To keep only some form types, send JSON with `forms`, comma-separated:

```json
{"model": "sec-edgar-search",
 "messages": [{"role": "user", "content": "{\"query\": \"stablecoin reserves\", \"forms\": \"10-K,10-Q\"}"}]}
```

## Reading the answer

The first line is `Source: SEC EDGAR (US company filings whose text holds a phrase), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many filings EDGAR matched
```

`{"count", "total", "rows": [...]}`. Each row has `company` (EDGAR's display name with the CIK), `cik`, `form` (such as `10-K`, `8-K`, `497K`), `filed` (date), `periodOfReport` (null for some forms), `accessionNumber` and `url` (the filing's index page on sec.gov).

Searching `stablecoin reserves` with no form filter (2026-11-04) returned fund prospectus supplements
(`497K`) first; the same phrase with `"forms": "10-K"` returned annual reports from Circle, BitGo,
Fiserv and others.

## Limits and caveats

- The filing documents are not included; each row links to the filing's index on sec.gov.
- Full-text search covers filings since 2001.
- Data from the U.S. Securities and Exchange Commission. Not investment advice.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "stablecoin reserves", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to SEC EDGAR.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to SEC EDGAR. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-filing page is about 1,050 tokens (measured 2026-11-04).
