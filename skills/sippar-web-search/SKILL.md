---
name: sippar-web-search
description: Use this when you need the first page of Google's results for a search, in Google's own order, such as a company's official site, the top pages on a subject, or what ranks for a phrase. Sippar's sippar-web-search model on AntSeed returns up to ten results with their links, titles and Google's descriptions, read live by an Apify Actor. It returns links and titles, not page text.
metadata:
  version: "1.0.0"
  updated: "2026-11-03"
---

# sippar-web-search

The first page of Google's results for one search, read live by an Apify Actor (Google Search
Results, by ScraperLink) and passed on as the Actor returns it. Each result has its position, link,
title and the description Google shows under it. How to reach the seller is in the
`sippar-antseed-buyer` skill.

For twenty results and an answer written from them, use `tavily-web-search`. This model gives you
Google's ranking and the links.

## Try it

```json
{"model": "sippar-web-search", "messages": [{"role": "user", "content": "best running shoes"}]}
```

## How to ask

The last user message is the search, as you would type it into Google: 2 to 200 characters. To
find a company's own site, send its name with "official website".

There are no options. Every search is the first page of Google's US results.

## Reading the answer

Four parts, separated by blank lines: a source line naming Google and the Actor, when it ran and
the search; the Actor's JSON; a closing line; a disclaimer. Take the second part:

```python
import json
data = json.loads(page.split("\n\n")[1])
for r in data["results"]:
    print(r["position"], r["title"], r["url"])
panel = data.get("knowledge_panel")
```

The JSON carries:

- `results`: the organic results in Google's order, each with `position`, `url`, `title` and
  `description`, and where Google shows them a `date` and `sitelinks` (each with `title` and `url`).
- `knowledge_panel`: Google's panel on the subject, present only when Google shows one.
- `related_keywords`: Google's related searches, and `spelling_suggestion` (`null` when Google has
  none).
- `search_term` and `page_number` (always 1).

A real result, from "best running shoes" on 2026-11-03:

```json
{"position": 2, "url": "https://www.runnersworld.com/gear/a19663621/best-running-shoes/",
 "title": "The 15 Best Running Shoes of 2026, Tested by Runner's World",
 "description": "Oct 22, 2026 · For new runners we recommend a shoe like the Brooks Ghost ...",
 "date": "Oct 22, 2026"}
```

## Limits and caveats

- Up to ten results. Twelve test searches returned six to ten, and "best running shoes" nine. The
  source line says "ten results" either way, so count `results`.
- One call is one page. The JSON shows `next_page` and `next_start`, but you cannot send them back;
  change the search for other results.
- `date` is Google's text, not a parsed date. It can read "6 days ago", or on a shop result a rating
  and review count run together, such as `"4.75.5K"`. Trust it only when it looks like a date.
- A sitelink's `url` can be a path on Google, such as `/search?q=...`, not a full link. Skip those.
- The descriptions are Google's snippets, cut at about two lines. Open the link to read the page.
- When a search finds fewer than five results, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the closing line, so the parser above is
  not affected.
- A search under 2 or over 200 characters is refused before Google is searched, and the refusal says
  why.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A page is one search's results, so its width
is Google's: twelve searches measured 919 to 1,496 tokens (2026-11-02), and "best running shoes"
1,402 (2026-11-03).
