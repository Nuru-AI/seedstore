---
name: sippar-instagram-social
description: Use this when you need what one public Instagram account has posted lately, its reels, or its public profile (followers, posts, bio and website), with each post's link, date, likes, comments, shares and plays. Sippar's sippar-instagram-social model on AntSeed returns Social Fetch's data cut to search results: the link, counts and the caption's first 150 characters. Photos, videos and full captions stay on Instagram.
metadata:
  version: "1.0.0"
  updated: "2026-11-03"
---

# sippar-instagram-social

One public Instagram account at a time, from Social Fetch: its recent posts, its reels, or its
profile. Each post comes as a search result: the link, date, counts and the start of the caption.
Open the link to see the photo, video or full caption on Instagram. How to reach the seller is in
the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-instagram-social", "messages": [{"role": "user", "content": "@natgeo"}]}
```

## How to ask

The last user message is one account: its handle, with or without the `@`, or its profile link
(`https://www.instagram.com/natgeo/`). A display name such as "National Geographic" is refused.
With nothing else you get its recent posts.

Two options go inside the message text, as JSON:

| Field | Values | What you get |
|---|---|---|
| `by` | `posts` (default), `reels`, `profile` | the account's recent posts, its reels, or its public profile |
| `cursor` | the `page.nextCursor` value from the previous answer | the next page of posts or reels |

```json
{"model": "sippar-instagram-social",
 "messages": [{"role": "user", "content": "{\"query\": \"@natgeo\", \"by\": \"reels\"}"}]}
```

In Python: `content=json.dumps({"query": "@natgeo", "by": "profile"})`. Fields placed anywhere else
(beside `content`, or at the top level of the body) do not reach the seller.

## Reading the answer

Four parts, separated by blank lines: a source line naming Social Fetch, when it ran and the request
sent; the JSON; a closing line (with the message for the next page when there is one); a disclaimer.
Take the second part:

```python
import json
data = json.loads(page.split("\n\n")[1])["data"]
for p in data.get("posts") or data.get("reels") or []:
    print(p["date"], p["url"], p.get("likes"), p.get("captionSnippet"))
```

`data.lookupStatus` is `found` or `not_found`. Then one of:

- `posts` or `reels`: each with `id`, `url` (the post on instagram.com), `mediaType` (`image`,
  `video` or `sidecar` for a carousel), `date`, `likes`, `comments`, `shares`, and on a video `plays`
  and `durationSeconds`; `coauthors` (handles), `paidPartnership` and `captionSnippet`.
- `profile`: `url`, `handle`, `name`, `bioSnippet`, `followers`, `following`, `posts`, `verified`,
  `private`, `business`, `professional`, `category` and `website`.

`data.page` carries `hasMore`, and `nextCursor` when Social Fetch gives one. A count Social Fetch did
not return is absent, never filled in.

## Limits and caveats

- The list is not in date order: on the @natgeo page of 2026-11-03 the first three posts were older
  than the rest. Sort by `date` yourself.
- The list can include posts another account made with this one as a co-author. The number after the
  underscore in `id` is the posting account's, so it differs from the other rows, and this account
  appears in `coauthors`.
- Paging works only when the answer carries `page.nextCursor`. The @natgeo posts page of 2026-11-03
  said `hasMore: true` with no cursor, so that list could not be continued. A profile is one answer
  and takes no cursor.
- Hashtags and comments are not served: `"by": "hashtag"` and `"by": "comments"` are refused before
  anything is bought. Any other `by` value, or a message that is not one account, is refused before
  Social Fetch is called, and the refusal says why.
- An account that does not exist comes back as `not_found` with an empty list, and that answer is
  billed.
- When the answer has fewer than ten items, it ends with a list of Sippar's other models on AntSeed
  and a message to try with each. A profile is one item, so a profile answer always carries it. It
  comes after the closing line, so the parser above is not affected.
- Each post belongs to its creator. Name the account and give the link. Not affiliated with Instagram
  or Meta.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Measured 2026-11-02: twelve posts or reels
1,258 to 1,563 tokens, a profile 1,129 to 1,144, an account that does not exist about 1,080; the
@natgeo posts page of 2026-11-03 was 1,564.
