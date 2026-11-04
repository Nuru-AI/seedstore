---
name: arxiv-search
description: Use this when you need research preprints on arXiv about a topic, with their abstracts: title, authors, dates, primary category, abstract, and links to the paper and its PDF. Sippar's free arxiv-search model on AntSeed queries arXiv's open API live for each request and returns preprints matching every search word. The papers themselves are linked, never copied.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# arxiv-search

Preprints on [arXiv](https://arxiv.org), queried live through arXiv's open API: up to 10 preprints matching every search word, each with its abstract and links to the paper and its PDF on arXiv. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

Thank you to arXiv for use of its open access interoperability. This service was not reviewed or approved by, nor does it necessarily express or reflect the policies or opinions of, arXiv.

## Try it

```json
{"model": "arxiv-search", "messages": [{"role": "user", "content": "protein structure prediction"}]}
```

```json
{"model": "arxiv-search", "messages": [{"role": "user", "content": "{\"query\": \"diffusion models protein design\", \"limit\": 5}"}]}
```

## How to ask

The last user message is search words (up to 200 characters). arXiv returns preprints that match
**every** word, most relevant first, so two or three precise words work better than a sentence.

## Reading the answer

The first line is `Source: arXiv (preprints), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many preprints arXiv matched
```

`{"count", "total", "rows": [...]}`. Each row has `title`, `authors`, `published` and `updated` (ISO times), `primaryCategory` (such as `cs.CR`), `abstract`, `url` (the abstract page), `pdfUrl`, `doi` and `journalRef` (both null unless the authors gave them).

Each row carries the preprint's own abstract, so the page answers "what is this paper about" without
opening it; follow `pdfUrl` for the paper.

## Limits and caveats

- The papers themselves are not included; each row links to the paper and its PDF on arXiv.
- Every word must match, so a long sentence often finds nothing. Use the key terms.
- Results come most relevant first. There is no option to sort by date: for the newest work, read
  `published` across the rows, or search the field's broader name (a narrow term can match only a few
  preprints).
- arXiv asks callers to space requests; the seller waits about 3 seconds between calls to arXiv, so a
  burst of calls answers more slowly.
- Metadata from arXiv under CC0.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "protein structure prediction", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to arXiv.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to arXiv. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-preprint page is about 3,350 tokens, since it carries the abstracts; an empty search about 1,100 (measured 2026-11-04).
