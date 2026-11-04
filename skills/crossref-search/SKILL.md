---
name: crossref-search
description: Use this when you need publication records for a topic: journal articles, preprints and books registered with Crossref, each with its DOI, publisher, venue, date, authors and how often it is cited. Sippar's free crossref-search model on AntSeed searches Crossref's metadata live for each request. It returns no abstracts and no full text.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# crossref-search

Publication records registered with [Crossref](https://www.crossref.org), the registry behind most DOIs, searched live for each request: up to 10 records with DOI, publisher and citation count. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "crossref-search", "messages": [{"role": "user", "content": "stablecoin payments"}]}
```

```json
{"model": "crossref-search", "messages": [{"role": "user", "content": "{\"query\": \"zero knowledge proofs\", \"limit\": 5}"}]}
```

## How to ask

The last user message is search words (up to 200 characters). Crossref matches them against its
bibliographic metadata (titles, authors, venues) and returns its most relevant records first.

## Reading the answer

The first line is `Source: Crossref (publication records: journal articles, preprints and books), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many records Crossref matched
```

`{"count", "total", "rows": [...]}`. Each row has `title`, `type` (`journal-article`, `posted-content` for a preprint, `book-chapter`, ...), `published` (date parts: `[year]`, `[year, month]` or `[year, month, day]`), `venue` (null when there is none), `publisher`, `authors` (up to 10 names), `citedBy` (Crossref's is-referenced-by count), `doi` and `url`.

Searching `stablecoin payments` (2026-11-04) returned 10 records, the first a 2026 SSRN preprint,
"Stablecoin Cards and the Emergence of Blockchain Retail Payments" (Elsevier BV, DOI
10.2139/ssrn.6360198).

## Limits and caveats

- Abstracts are not included; open the DOI link for the record.
- Metadata from Crossref. Give the DOI when you cite a record.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "stablecoin payments", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to Crossref.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to Crossref. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-record page is about 1,100 tokens (measured 2026-11-04).
