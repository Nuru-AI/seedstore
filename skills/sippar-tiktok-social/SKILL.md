---
name: sippar-tiktok-social
description: Use this when you need what one public TikTok creator has posted lately, or one TikTok video's numbers, with each video's link, date, views, likes, comments, shares, saves and length. Sippar's sippar-tiktok-social model on AntSeed returns Social Fetch's data cut to search results: the link, counts and the caption's first 150 characters. Videos and full captions stay on TikTok.
metadata:
  version: "1.0.0"
  updated: "2026-11-03"
---

# sippar-tiktok-social

One public TikTok creator's latest videos, or one video, from Social Fetch. Each video comes as a
search result: the link, date, counts and the start of the caption. Open the link to watch it on
TikTok. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-tiktok-social", "messages": [{"role": "user", "content": "@nasa"}]}
```

## How to ask

The last user message is one creator: `@handle` or a profile link (`https://www.tiktok.com/@nasa`).
With nothing else you get their latest videos, up to ten. A `vm.tiktok.com` short link is not
accepted; open it first and send the profile or video link it leads to.

Two options go inside the message text, as JSON:

| Field | Values | What you get |
|---|---|---|
| `by` | `profile` (default), `video` | the creator's latest videos, or one video by its link |
| `cursor` | the `page.nextCursor` value from the previous answer | the creator's next videos |

```json
{"model": "sippar-tiktok-social",
 "messages": [{"role": "user", "content": "{\"query\": \"https://www.tiktok.com/@nasa/video/7699974130153590029\", \"by\": \"video\"}"}]}
```

For the next page, the closing line gives the message ready to copy, such as
`{"query":"@nasa","cursor":"1791478543000"}`. In Python:
`content=json.dumps({"query": "@nasa", "cursor": cursor})`. Fields placed anywhere else (beside
`content`, or at the top level of the body) do not reach the seller.

## Reading the answer

Four parts, separated by blank lines: a source line naming Social Fetch, when it ran and the request
sent; the JSON; a closing line (with the message for the next page when there is one); a disclaimer.
Take the second part:

```python
import json
data = json.loads(page.split("\n\n")[1])["data"]
rows = data.get("videos") or ([data["video"]] if data.get("video") else [])
for v in rows:
    print(v["date"], v["url"], v.get("views"), v.get("captionSnippet"))
```

`data.lookupStatus` is `found` or `not_found`. Then `videos` (a creator's list) or `video` (one
video), each with `id`, `url` (the video on tiktok.com), `date`, `views`, `likes`, `comments`,
`shares`, `saves`, `durationSeconds`, `pinned`, `ad` and `captionSnippet`. One video also carries
`account` (`handle`, `name`, `verified`). `data.page` carries `nextCursor` and `hasMore` when more
videos exist. A count Social Fetch did not return is absent, never filled in.

## Limits and caveats

- The list is newest first after any pinned videos: on the @nasa page of 2026-11-03 a pinned video
  from July came first. Check `pinned`, or sort by `date`.
- A list can include a paid post by another account (`"ad": true`; on the @nasa page, one by
  @google). The handle in its `url` shows whose it is.
- A photo post has a `/photo/` link and `durationSeconds` 0.
- Search, hashtags, comments and sounds are not served: `"by": "search"`, `"hashtag"`, `"comments"`
  and `"sound"` are refused before anything is bought. Any other `by` value, or a message that is not
  a creator or (with `"by": "video"`) a video link, is refused before Social Fetch is called, and the
  refusal says why.
- A creator or video that does not exist comes back as `not_found`, and that answer is billed.
- When the answer has fewer than ten items, it ends with a list of Sippar's other models on AntSeed
  and a message to try with each. One video is one item, so a video answer always carries it. It
  comes after the closing line, so the parser above is not affected.
- Each video belongs to its creator. Name the account and give the link. Not affiliated with TikTok.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Twelve answers measured 2026-11-02 (ten
creators' lists, a creator and a video that do not exist) were 1,029 to 1,331 tokens, median 1,242;
the @nasa page of 2026-11-03 was 1,289.
