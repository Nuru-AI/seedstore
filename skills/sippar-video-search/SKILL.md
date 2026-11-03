---
name: sippar-video-search
description: Use this when you need YouTube videos that match a search (title, link, channel, views, length, age) or one video's details (publish time, views, likes, comment count, keywords, chapters, caption languages, related videos). Sippar's sippar-video-search model on AntSeed reads searches from ScrapeMole and video details from Social Fetch. It returns no description, transcript or comment text.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-video-search

Public YouTube videos, two ways: search words return up to 20 matching videos, and one video's link
returns that video's details. There is no description, transcript or comment text; open the link to
watch. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-video-search", "messages": [{"role": "user", "content": "home espresso machine review"}]}
```

```json
{"model": "sippar-video-search", "messages": [{"role": "user", "content": "https://www.youtube.com/watch?v=7HIGdYy5of4"}]}
```

## How to ask

The last user message is search words, or one video's link (`youtube.com/watch?v=...`, `youtu.be/...`,
`/shorts/...`, `/live/...` or `/embed/...`). Anything else is a search; a bare 11-character video id
is searched as a word.

Search filters go inside the message text, as JSON, beside `query`:

| Field | Values |
|---|---|
| `sort` | `relevance`, `views`, `rating` |
| `uploaded` | `hour`, `today`, `week`, `month`, `year` |
| `duration` | `short`, `medium`, `long` (over 20 minutes) |

```json
{"model": "sippar-video-search",
 "messages": [{"role": "user", "content": "{\"query\": \"home espresso machine review\", \"uploaded\": \"year\"}"}]}
```

For recent videos use `uploaded`; `sort: date` is refused, free, with an error that points to
`uploaded`. `sort: views` leans toward high view counts, loosely.

## Reading the answer

The first line names the provider (ScrapeMole for a search, Social Fetch for a video's details,
YouTube when YouTube's embed check found no such video), when it ran and the request sent. Then a
blank line, the JSON on one line, a closing line on how to ask, and a disclaimer. The request echo on
the first line also has braces, so parse from the blank line:

```python
import json
if page.startswith("Not sent"):
    raise ValueError(page.split("\n")[0])  # a filter on a link: the reason, no JSON
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
if "videos" in data:                       # a search
    videos = [v for v in data["videos"] if v["url"]]
else:                                      # a video's details
    video = data["video"]                  # None when data["status"] is not "found"
```

A search, `{"query", "count", "videos": [...]}`. A bought search always lists 20 slots; an empty slot
has every field `null`. Each video has `title`, `url`, `channel`, `channelUrl`, `views` (exact, at
the retrieval time), `durationSeconds`, `published` (the age YouTube shows, such as `11 months ago`,
not a date) and `kind` (`video`, `short` or `live`).

A video's details, `{"status", "video": {...}}`, where `status` is `found`, `not_found` or
`private`. On `found`: `title`, `url`, `channel`, `channelUrl`, `publishedAt` (the real publish time),
`durationSeconds`, `genre`, `keywords` (the creator's tags), `paidPromotion`, `views` and `likes`
(exact), `comments` (a round figure), `chapters` (`{startSeconds, title}`, spelled as served),
`captionLanguages` and `related` (12 slots in the search-row shape, with rounded views and short ages).

## Limits and caveats

- Relevance is loose and the order is YouTube's. A search page can hold buying guides and news clips,
  the same channel more than once, and videos in other languages. Check each title before you use a
  row.
- A narrow search with a date filter can come back full of unrelated videos: the page is filled to
  20 whether the videos match or not.
- Related videos can be off the subject.
- A filter sent with a video link is answered with a short page that starts `Not sent`, says why, and
  is billed. A channel or playlist link, or a line shorter than two characters, is refused with an
  error and bills nothing. Up to 200 characters of search words.
- Before buying a video's details, Sippar asks YouTube's public embed check whether the video exists.
  A missing or private video is answered from that check (`not_found` or `private`) and nothing is
  bought from a supplier. If YouTube cannot confirm the video right then, you get a short `Not sent`
  page; send the link again.
- Videos belong to their creators. Name the channel and give the link when you use a row. Not
  affiliated with YouTube.
- When a search finds fewer than five videos, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A search page is about 1,800 to 2,000 tokens;
a video's details 1,460 to 1,510; a missing video about 275; a filter on a video link about 250
(measured 2026-10-12). A refused line bills nothing.
