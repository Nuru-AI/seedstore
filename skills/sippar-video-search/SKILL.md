---
name: sippar-video-search
description: Search public YouTube videos, or read one video's details, through Sippar's sippar-video-search model on AntSeed. Search rows come from ScrapeMole and video details from Social Fetch, with YouTube's own embed check for a missing video. Use it when an agent on AntSeed needs the videos that match a search (title, link, channel, views, length, the age YouTube shows) or one video's publish time, views, likes, comment count, genre, keywords, chapters, caption languages and related videos. It returns no description, transcript or comment text. Triggers on - video search on AntSeed, YouTube videos about X, find a review video, most viewed videos on a subject, recent videos, long videos, a video's chapters, a video's view count, related videos, sippar-video-search.
metadata:
  version: "1.0.0"
  updated: "2026-10-12"
---

# sippar-video-search

Public YouTube videos, two ways. Send search words and you get up to 20 matching videos, each with
its title, link, channel, channel link, views, length in seconds, the age YouTube shows and
whether it is a video, a Short or a live stream. Send one video's link and you get that video's
details: publish time, length, genre, keywords, channel, views, likes, comment count, chapters,
caption languages and the related videos YouTube lists beside it. There is no description,
transcript or comment text on any page: open the link to watch. Transport (pin, request shape,
the 8-in-flight limit) is in the `sippar-antseed-buyer` skill; read it first. Model string:
`sippar-video-search`.

## How to ask

The last user message is one plain line: search words, or one video's link.

```json
{"model": "sippar-video-search",
 "messages": [{"role": "user", "content": "home espresso machine review"}]}
```

```json
{"model": "sippar-video-search",
 "messages": [{"role": "user", "content": "https://www.youtube.com/watch?v=7HIGdYy5of4"}]}
```

- **A video link asks for that video's details.** `youtube.com/watch?v=…` and `youtu.be/…` both
  worked; `/shorts/…`, `/live/…` and `/embed/…` links are accepted too (we did not send one).
  Anything else is a search. A bare 11-character video id is searched as a word, not looked up.
- **Filters go inside the message text, as JSON.** `query` carries the search words, beside any of
  `sort` (`relevance`, `date`, `views`, `rating`), `uploaded` (`hour`, `today`, `week`, `month`,
  `year`) and `duration` (`short`, `medium`, `long`):
  `{"query": "home espresso machine review", "sort": "views", "uploaded": "year"}`.
  Do not put them at the top level of the request body: this model announces no parameters.
- **A narrow search with a date filter can come back full of unrelated videos.**
  `{"query": "lever espresso machine spring rebuild", "uploaded": "week"}` returned 20 videos
  from the past week, and none of them was about espresso machines: mountain-bike wheels, drama
  series, a full-length film. The page is filled to 20 whether the videos match or not. Check every title against
  your words before you use a row.
- **For recent videos, use `uploaded`. `sort: date` did nothing on our searches.** Twice, the
  first rows were six to nine years old. `uploaded: year` held: every video was 11 months old or
  less. `duration: long` held too: every video ran over 20 minutes. `sort: views` leaned toward
  high view counts, but loosely (1,143,178, 806,751, 805,408, 763,403, then 812,787), and that
  page also held coffee videos that were not espresso machine reviews.
- **A filter on a video link is answered with a short page that starts `Not sent`, says why,
  and is billed.** A link takes no filters. A channel or playlist link, or a line shorter than two
  characters, is refused with an error and bills nothing. Up to 200 characters of search words.

Do not send `x-antseed-required-parameters` on this model. It announces no parameters, so
requiring any name refuses every call.

## Reading the page

The page opens with one source line: `Source: <provider> (public YouTube videos), GET <endpoint>,
retrieved <time>. Request sent: {…}.` The provider is ScrapeMole for a search, Social Fetch for a
video's details, and YouTube when YouTube's embed check found no such video. Then a blank line,
the JSON on one line, a closing line on how to ask, and a disclaimer. The first `{` on the page is
the request echo, so parse the first JSON value after the blank line:

```python
import json
# page = the answer text, e.g. response.choices[0].message.content
if page.startswith("Not sent"):
    raise ValueError(page.split("\n")[0])  # a filter on a link: the reason, no JSON
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
if "videos" in data:                       # a search
    videos = [v for v in data["videos"] if v["url"]]
else:                                      # a video's details
    video = data["video"]                  # None when data["status"] is not "found"
```

### A search

`{"query": …, "count": …, "videos": [...]}`. `count` is how many videos came back. A bought
search always lists 20 slots: a slot with nothing in it has every field `null`, and the source
line says how many came back. Every search we ran came back with 20 filled. A search that finds
nothing comes back as a short page with `"videos": []`, about 270 tokens (measured before
launch). Each video:

- `title`, `url` (always `https://www.youtube.com/watch?v=<id>`), `channel` and `channelUrl`.
- `views`: the exact count as YouTube showed it at the retrieval time.
- `durationSeconds`: the length.
- `published`: the age YouTube shows (`6 days ago`, `11 months ago`), not a date. Quote it as
  "about 11 months ago".
- `kind`: `video`, `short` or `live`. Every row we read was `video`.

**The order is YouTube's, and relevance is loose.** A search for espresso machine reviews held
one news segment and several channels' buying guides; the same channel can appear three times.
Results can be in other languages: a Python tutorial search held courses in Hindi, Tamil and
Malayalam.

### A video's details

`{"status": …, "video": {...}}`. `status` is `found`, `not_found` or `private`. On `found`:

- `title`, `url`, `channel`, `channelUrl`.
- `publishedAt`: the real publish time with YouTube's offset (`2020-09-18T04:00:02-07:00`).
- `durationSeconds`, `genre` (YouTube's category, such as `Entertainment` or `People & Blogs`),
  `keywords` (the creator's tags, up to 30) and `paidPromotion` (`true` when the creator declared
  paid promotion).
- `views` (exact), `likes` (exact) and `comments` (a round figure on both videos we read: 4,100
  and 1,500).
- `chapters`: `{startSeconds, title}` in order. Titles are as served, spelling included: one
  video's chapters read `ranchero Silvia` for Rancilio Silvia and `Gadget Classic Pro` for Gaggia
  Classic Pro.
- `captionLanguages`: language codes such as `en` and `en-GB`. The caption text is not included.
- `related`: 12 slots, the videos YouTube lists beside this one, in the search row shape. But
  views are rounded (`24000`, `2200000`) and the age is short (`1d ago`, `3mo ago`, `5y ago`). Related videos can be off the subject: one espresso video's
  list held a news clip. A slot with nothing in it has every field `null`; both videos we read
  had 12 filled.

**A missing video costs the short page only.** Before buying a video's details, Sippar asks
YouTube's public embed check whether the video exists. A missing or private video is answered from
that check and nothing is bought from a supplier: the source line names YouTube and the JSON is
`{"status": "not_found", "video": null}` (or `"private"`). If YouTube cannot confirm the video
right then, nothing is bought and you get a short `Not sent` page saying so, billed like the
filter case above; send the link again.

Videos belong to their creators. Name the channel and give the link when you use a row. Not
affiliated with YouTube. Not advice.

## Cost

Per output token at the rate on the peer record. Measured 2026-10-12 through the network (the
token counts add up to the buyer's own ledger): a search page 1,810 to 1,989 tokens; a video's details 1,460 to 1,508; a
missing video 275; a filter on a video link 249. A refused line bills nothing.

## Changes

- 1.0.0 (2026-10-12): first publish.
