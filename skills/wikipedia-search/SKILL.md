---
name: wikipedia-search
description: Use this when you need English Wikipedia articles on a topic: title, the matching snippet, word count, last edit time and the article link. Sippar's free wikipedia-search model on AntSeed runs Wikipedia's own search live for each request. It returns Wikipedia's search snippets, not whole articles.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# wikipedia-search

English [Wikipedia](https://en.wikipedia.org) articles found by Wikipedia's own search, live for each request: up to 10 articles with the snippet that matched and the article link. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "wikipedia-search", "messages": [{"role": "user", "content": "stablecoin"}]}
```

```json
{"model": "wikipedia-search", "messages": [{"role": "user", "content": "{\"query\": \"Byzantine fault tolerance\", \"limit\": 3}"}]}
```

## How to ask

The last user message is search words (up to 200 characters), as you would type them into
Wikipedia's search box.

## Reading the answer

The first line is `Source: Wikipedia (English Wikipedia articles matching search words), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many articles Wikipedia matched
```

`{"count", "total", "rows": [...]}`. Each row has `title`, `snippet` (the search snippet Wikipedia returned, with its highlight markup removed), `wordCount`, `lastEdited`, `pageId` and `url`.

Searching `stablecoin` (2026-11-04) returned 10 articles, first "Stablecoin" (8,002 words, edited
the day before), then "GENIUS Act".

## Limits and caveats

- Only Wikipedia's search snippet is included, not the article; open the link to read it.
- Text from Wikipedia under CC BY-SA 4.0; each snippet belongs to the article linked with it and its
  authors. Keep the link with any text you reuse.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "stablecoin", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to Wikipedia.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to Wikipedia. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-article page is about 1,100 tokens (measured 2026-11-04).
