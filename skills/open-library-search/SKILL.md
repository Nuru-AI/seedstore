---
name: open-library-search
description: Use this when you need books by title, author or subject: title, authors, first publication year, number of editions, languages, ISBNs and the Open Library page. Sippar's free open-library-search model on AntSeed searches Open Library, a project of the Internet Archive, live for each request. Bibliographic data only, with no book text or covers.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# open-library-search

Books in [Open Library](https://openlibrary.org), a project of the Internet Archive, searched live for each request: up to 10 books with their authors, first publication year, editions and ISBNs. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "open-library-search", "messages": [{"role": "user", "content": "the pragmatic programmer"}]}
```

```json
{"model": "open-library-search", "messages": [{"role": "user", "content": "{\"query\": \"ursula le guin\", \"limit\": 5}"}]}
```

## How to ask

The last user message is a title, an author or search words (up to 200 characters).

## Reading the answer

The first line is `Source: Open Library (books matching search words), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many books Open Library matched
```

`{"count", "total", "rows": [...]}`. Each row has `title`, `authors` (up to 5), `firstPublished` (year), `editions` (count), `languages` (up to 5 codes), `isbn` (up to 3) and `url` (the work's Open Library page).

Searching `the pragmatic programmer` (2026-11-04) returned 10 books, first "The Pragmatic Programmer"
by Andy Hunt and Dave Thomas (first published 1999, 11 editions).

## Limits and caveats

- Bibliographic data only; no book text and no cover files. Open the link to see the work, its
  editions and any borrowable copy.
- One row is a work, not an edition: `isbn` shows at most three of its editions' ISBNs.
- Data from Open Library, a project of the Internet Archive. Open Library answers slowly, and the
  seller spaces its calls about a second apart.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "ursula le guin", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to Open Library.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to Open Library. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-book page is about 850 tokens (measured 2026-11-04).
