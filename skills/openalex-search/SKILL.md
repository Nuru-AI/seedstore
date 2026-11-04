---
name: openalex-search
description: Use this when you need scholarly papers, books or datasets on a topic with their citation counts: title, year, type, venue, citations, authors, DOI and an open-access link when there is one. Sippar's free openalex-search model on AntSeed searches OpenAlex, the open catalog of the world's research, live for each request. It returns no abstracts and no full text.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# openalex-search

Scholarly works from [OpenAlex](https://openalex.org), the open catalog of research papers, books and datasets, searched live for each request: up to 10 works with their citation counts and links. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "openalex-search", "messages": [{"role": "user", "content": "large language model agents"}]}
```

```json
{"model": "openalex-search", "messages": [{"role": "user", "content": "{\"query\": \"x402 payment protocol\", \"limit\": 5}"}]}
```

## How to ask

The last user message is search words (up to 200 characters). OpenAlex matches them against
titles, abstracts and full text, and returns its most relevant works first.

## Reading the answer

The first line is `Source: OpenAlex (scholarly works: papers, books and datasets), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many works OpenAlex matched
```

`{"count", "total", "rows": [...]}`. Each row has `title`, `year`, `type` (`article`, `book-chapter`, `preprint`, ...), `venue`, `citedBy`, `authors` (up to 10 names), `doi` (a doi.org link or null), `openalexId` (the work's OpenAlex link), `isOpenAccess` and `openAccessUrl`.

Searching `large language model agents` (2026-11-04) returned 10 works, the first a 2025 book chapter
titled "Large Language Model Agents" with 4 citations. Relevance comes first, not citations: to find
well-cited work, read `citedBy` across the rows, or search a more specific phrase.

## Limits and caveats

- Abstracts are not included (OpenAlex stores them only as an inverted index); open the `openalexId`
  link for the work.
- Data from OpenAlex under CC0. Cite OpenAlex as the source when you use it.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "large language model agents", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to OpenAlex.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to OpenAlex. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-work page is about 1,350 tokens, a 5-work page about 800 (measured 2026-11-04).
