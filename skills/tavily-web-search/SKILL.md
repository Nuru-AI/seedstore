---
name: tavily-web-search
description: Use this when you need current information from the web with the pages it came from. Sippar's tavily-web-search model on AntSeed returns a live Tavily search, twenty results with their links and an answer written from them, bought from Tavily directly or through the reseller gedx402 when Tavily refuses.
metadata:
  version: "1.4.0"
  updated: "2026-11-03"
---

# tavily-web-search

A live web search from Tavily, passed on as Tavily returns it. Each call is bought from Tavily
directly; when Tavily's own payment door refuses, it is bought through gedx402, a Tavily reseller,
and the answer says which. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "tavily-web-search", "messages": [{"role": "user", "content": "what changed in the x402 protocol in 2026"}]}
```

## How to ask

The last user message is the query. With nothing else, you get twenty results and the answer
Tavily wrote from them.

This model takes its two options as top-level fields beside `messages`, not inside the message
(through a client that rewrites requests, put them in `metadata.sippar` or send them as
`x-sippar-max-results` and `x-sippar-include-images` headers):

| Field | Values | What you get |
|---|---|---|
| `max_results` | a whole number, 20 to 25 | that many results instead of twenty |
| `include_images` | `true` / `false` | a list of image links |

```json
{"model": "tavily-web-search",
 "messages": [{"role": "user", "content": "stablecoin regulation"}],
 "max_results": 25}
```

A value outside these rules is refused before anything is bought, and the refusal says which rule.

## Reading the answer

Four parts, separated by blank lines: a source line naming Tavily (and gedx402 when the call went
through it), when it ran and the request sent (`Request sent: {"query": ...}`); Tavily's JSON; a
closing line; a disclaimer. Take the second part:

```python
import json
data = json.loads(page.split("\n\n")[1])
```

Tavily's JSON carries `query`, `answer` and `results`, each result with `url`, `title`, `content` and
`score`. An answer bought through gedx402 also carries gedx402's `route`, `provider` and `tavily_ms`.

## Limits and caveats

- The content is third-party web material as Tavily returned it. Check a claim at its linked source.
- `include_images` returns image links on the sites that host them, not image files. Fetch an image
  from its link if you need it.
- Full page text is not served: `"include_raw_content": true` is refused.
- `x-antseed-required-parameters` may name `max_results` and `include_images`; any other name refuses
  every call.

## Cost

Per output token, at the rate on Sippar's peer record. A page is Tavily's results and answer, so its
width is Tavily's: twenty results measured about 7,600 tokens (2026-10-11). A refusal bills nothing
on an open payment channel.
