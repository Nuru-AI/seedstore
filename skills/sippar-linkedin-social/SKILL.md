---
name: sippar-linkedin-social
description: Use this when you need who is posting on LinkedIn about a company, a product, a market, a job topic or a trend, and how much engagement those posts get. Sippar's sippar-linkedin-social model on AntSeed returns public LinkedIn posts for a search, from Social Fetch, each with its link, date, author (name, profile link, followers) and reaction and comment counts, without the post text.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-linkedin-social

Public LinkedIn posts for a search, from Social Fetch: link, date, author and engagement counts.
The post text is not included; open the link to read a post. How to reach the seller is in the
`sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-linkedin-social", "messages": [{"role": "user", "content": "remote work burnout"}]}
```

## How to ask

The last user message is the search. Send keywords or names, not a question.

One call returns up to 10 posts. Two options go inside the message text, as JSON:

| Field | What it does |
|---|---|
| `posts` | collect up to 50 posts in one call. Each ten posts is one more provider call, and the answer is longer |
| `cursor` | the next ten posts: the `next.cursor` value from the previous answer |

```json
{"model": "sippar-linkedin-social",
 "messages": [{"role": "user", "content": "{\"query\": \"climate tech funding\", \"posts\": 30}"}]}
```

```json
{"model": "sippar-linkedin-social",
 "messages": [{"role": "user", "content": "{\"query\": \"remote work burnout\", \"cursor\": \"eyJjIjoiMiJ9\"}"}]}
```

In Python: `content=json.dumps({"query": "climate tech funding", "posts": 30})`. Fields placed
anywhere else (beside `content`, or at the top level of the body) do not reach the seller.

## Reading the answer

The first line names Social Fetch, when the search ran and the request sent, and ends "open the link
to read a post." Then one JSON object, then a closing line (how many posts, how to get more) and a
disclaimer.

```python
import json
start = page.index("{", page.index("open the link to read a post."))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

- `query`: the search as sent.
- `posts`: each one is `url`, `publishedAt`, `author` (`name`, `profileUrl`, `followers`) and
  `metrics` (`reactions`, `comments`). A value the provider did not return is `null`, never invented.
- `next`: `{"cursor": "...", "hasMore": true}` when more posts exist, else `hasMore: false`.

## Limits and caveats

- Posts come in the provider's relevance order, not by date, and a page can span a year or more.
  Sort by `publishedAt` yourself when recency matters.
- The search covers posts a logged-out visitor can open, so the links work without a LinkedIn
  account.
- A post can match a word without being about your subject. Open it before you rely on it. Posts
  belong to their authors. Not affiliated with LinkedIn.
- A bad `posts` or `cursor` value is refused before anything is bought.
- When a search finds fewer than five posts, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A ten-post answer is about 970 to 1,080
tokens, a thirty-post answer about 2,630 to 2,720 (measured 2026-10-09). A failed search is refused
and, on an open payment channel, bills nothing.
