---
name: sippar-reddit-social
description: Use this when you need which Reddit threads discuss a product, a company, a tool, a hobby or a news story, in which subreddits, and how much attention each got. Sippar's sippar-reddit-social model on AntSeed returns public Reddit posts for a search, from glim.sh, each with its title, thread link, subreddit, author, date, score and comment count, without the post text or comments.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-reddit-social

Public Reddit posts for a search, from glim.sh: title, thread link, subreddit, author, date, score
and comment count. The post text and comments are not included; open the link to read a thread.
How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-reddit-social", "messages": [{"role": "user", "content": "home espresso machine"}]}
```

## How to ask

The last user message is the search. Send keywords: Reddit matches the words you send, so a long
question finds little. A question is still accepted and cut down first: small words such as
`what`, `the` or `do` are dropped, and if more than three words remain, three are kept, names and
acronyms first, then longer words. "What do developers think of the x402 payment protocol?" is
searched as `x402 payment protocol`. The answer shows exactly what was searched. A generic extra
word such as `features` or `opinions` narrows the results; leave it out.

One call returns up to 10 posts, sorted by relevance (that cannot be changed). Two options go
inside the message text, as JSON:

| Field | What it does |
|---|---|
| `time` | only posts from the last `hour`, `day`, `week`, `month` or `year`; `all` is the default |
| `cursor` | the next ten posts: the `next.cursor` value from the previous answer |

```json
{"model": "sippar-reddit-social",
 "messages": [{"role": "user", "content": "{\"query\": \"Formula 1\", \"time\": \"week\"}"}]}
```

For the next page, send the query exactly as the previous answer's `query` shows it, with the same
`time` if you set one, plus its cursor. The answer's closing line gives this message ready to copy:

```json
{"model": "sippar-reddit-social",
 "messages": [{"role": "user", "content": "{\"query\": \"x402 payment protocol\", \"cursor\": \"t3_1vwxol6\"}"}]}
```

In Python: `content=json.dumps({"query": "Formula 1", "time": "week"})`. Fields placed anywhere
else (beside `content`, or at the top level of the body) do not reach the seller.

## Reading the answer

The first line names glim.sh, when the search ran and the request sent, and ends "open the link to
read a thread." Then one JSON object, then a closing line (how many posts, the message for the next
page) and a disclaimer.

```python
import json
start = page.index("{", page.index("open the link to read a thread."))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

- `query`: the search as sent.
- `posts`: each one is `title`, `url` (the thread on reddit.com), `subreddit`, `author` (a
  username), `publishedAt`, `score` and `numComments`. A value the provider did not return is
  `null`, never invented; a deleted author is `null`.
- `next`: `{"cursor": "...", "hasMore": true}` when more posts exist, else `hasMore: false`.

## Limits and caveats

- Posts come in relevance order, not by date, and without `time` they can span years. Sort by
  `publishedAt` yourself, or set `time`.
- A post can match a word without being about your subject, and a title alone can mislead. Open the
  thread before you rely on it. Posts belong to their authors. Not affiliated with Reddit.
- A bad `time` or `cursor`, or a search with no words in it, is refused before anything is bought.
- When a search finds fewer than five posts, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A ten-post answer is about 950 to 1,270
tokens (measured 2026-10-10). A search that fails upstream is refused and, on an open payment
channel, bills nothing.
