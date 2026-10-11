---
name: tavily-web-search
description: Buy a live web search with sources from Sippar's tavily-web-search model on AntSeed, served as Tavily returns it, bought through the reseller gedx402. Use it when an agent on AntSeed needs current information from the web with the pages it came from. Triggers on - web search on AntSeed, search the web, find sources for, what does the web say about, tavily-web-search.
metadata:
  version: "1.2.0"
  updated: "2026-10-11"
---

# tavily-web-search

A live web search from Tavily, bought through gedx402 (a Tavily reseller) and served as
Tavily returns it. Transport (pin, request shape, the 8-in-flight limit) is in the `sippar-antseed-buyer` skill; read it first. Model string:
`tavily-web-search`.

## How to ask

The last user message is the query. With nothing else, the search returns twenty results with
the answer Tavily generated from them.

```json
{"model": "tavily-web-search",
 "messages": [{"role": "user", "content": "what changed in the x402 protocol in 2026"}]}
```

Two optional arguments, as top-level keys beside `messages` (or in `metadata.sippar`, or as
`x-sippar-max-results`, `x-sippar-include-images` headers):

| argument | values | what you get |
|---|---|---|
| `max_results` | a whole number, 20 to 25 | that many results instead of twenty |
| `include_images` | `true` / `false` | image links: a list of image URLs, as text |

```json
{"model": "tavily-web-search",
 "messages": [{"role": "user", "content": "stablecoin regulation"}],
 "max_results": 25}
```

A value outside these rules is refused before anything is bought, and the refusal says which
rule. `include_images` returns links, not images: Tavily's `images` field is a list of URLs on
the sites that host them, and no image file comes through AntSeed. Fetch an image from its link
if you need it. Full page text is not served at the moment: `"include_raw_content": true` is
refused.
`x-antseed-required-parameters` may name these two; any other name refuses every call.

## Reading the page

Four parts, in this order: a source line naming Tavily and gedx402, the endpoint, when it was
retrieved, and the request that was sent (`Request sent: {"query": …}`); then Tavily's JSON as
gedx402 delivers it, unfenced; then a closing line; then a disclaimer.

Take the JSON after the line that ends "Tavily's response as gedx402 delivers it, unchanged
(gedx402 adds route, provider and tavily_ms)." A parser that grabs the first `{` on the page gets
the request echo instead. Tavily's JSON carries `query`, `answer`, and `results` with `url`,
`title`, `content` and `score` per result; gedx402 adds `route`, `provider` and `tavily_ms`.
Verify at the linked sources; the content is third-party web material as Tavily returned it.

## Cost

Per output token at the rate on the peer record. A page is Tavily's results and answer, so its
width is Tavily's: twenty results measured 7,603 tokens on 2026-10-11. A refusal bills
nothing on an open channel.

## Changes

- 1.2.0 (2026-10-11): bought through gedx402. Twenty results by default, `max_results` 20 to
  25; `include_raw_content` is not served.
- 1.1.0 (2026-10-10): `max_results`, `include_raw_content` and `include_images` (image links).
- 1.0.1 (2026-10-08): skills referred to by name.
- 1.0.0 (2026-10-08): first publish.
