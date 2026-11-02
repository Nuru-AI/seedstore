---
name: sippar-x-social
description: Use this when you need what people are posting on X (Twitter) about anything, such as a brand, a product launch, a match, a person or the news, or what one account posted. Sippar's sippar-x-social model on AntSeed returns public posts for a search with their text, author, engagement counts and link, as glim.sh returns them.
metadata:
  version: "1.1.0"
  updated: "2026-11-02"
---

# sippar-x-social

Public X posts for a search, from glim.sh. How to reach the seller is in the
`sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-x-social", "messages": [{"role": "user", "content": "Formula 1 since:2026-10-01"}]}
```

## How to ask

The last user message is the search. Send keywords or names, not a question: a question is matched
word by word and brings back loosely related posts.

X's search operators go inside the message:

| Operator | Works |
|---|---|
| `from:handle` | yes: only that account's posts (`from:F1`) |
| `"exact phrase"` | yes (`"best pizza"`) |
| `lang:en` | yes |
| `since:YYYY-MM-DD` | yes |
| `min_faves:N` | no: posts under the threshold still come back |
| `-word` (exclude) | no: posts with the word still come back |

Posts come in X's Top order, popular first, so older posts mix in. Add `since:` for recent ones.

Named things (a brand, a product, a team, an event) return focused pages. A single generic word
does not: a coin ticker such as `USDC` comes back as mostly giveaway posts, and no filter removes
them. Narrow with `from:`, an exact phrase or more words.

## Reading the answer

The first line names glim.sh, when the search ran and the request sent (`Request sent: {"query": ...}`),
and ends with "glim.sh's response, unchanged." Then glim.sh's JSON, then a closing line and a
disclaimer. The request echo on the first line also has braces, so start parsing after that
ending:

```python
import json
start = page.index("{", page.index("response, unchanged."))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

- `tweets`: usually 13 to 20 posts, each with `url`, `text`, `created_at`, `lang`, `author`
  (`username`, `name`, follower counts under `public_metrics`), `public_metrics` (`like_count`,
  `retweet_count`, `reply_count`, `quote_count`, `impression_count`, `bookmark_count`) and
  `engagement_rate`, plus `media`, `entities` or
  `quoted_tweet` when the post has them.
- `count`, `summary` (totals for the page) and `topics` (top hashtags, domains and mentioned
  accounts).
- `has_more` and `next_cursor`. This model has no next page: the cursor cannot be sent back. For
  other posts, narrow or widen the search, for example with `since:` or `from:`.

## Limits and caveats

- Some results are spam or off topic. Open a post's `url` before you rely on it. Posts belong to
  their authors.
- A post can be only a link, with `lang` set to `zxx`. Its text tells you nothing.
- Leave out the `x-antseed-required-parameters` header (see the `sippar-antseed-buyer` skill).
  This model takes no options outside the message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Most of a page is post text and author
details: 5,500 to 17,500 tokens, typically 6,000 to 11,000 (measured 2026-10-08). A search that
fails is refused and, on an open payment channel, bills nothing.
