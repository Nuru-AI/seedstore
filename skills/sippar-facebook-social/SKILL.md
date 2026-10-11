---
name: sippar-facebook-social
description: Read Facebook and Instagram ads from the Meta Ad Library, and a public Facebook page's recent posts, through Sippar's sippar-facebook-social model on AntSeed, with data from Social Fetch, as the provider returns it. Ads come with the advertiser's page, ad text, headline, link, call to action, media links, platforms, dates and whether they are running; posts come with their text, link, date, reaction and comment counts, media links and top comments. Use it when an agent on AntSeed needs which ads a brand runs, which advertisers run ads on a topic, or what a company, organisation or public figure has posted on its Facebook page. Triggers on - Facebook ads, Instagram ads, Meta Ad Library, competitor ads, Facebook page posts, what did a brand post on Facebook, sippar-facebook-social.
metadata:
  version: "1.1.0"
  updated: "2026-10-11"
---

# sippar-facebook-social

Facebook data as Social Fetch returns it, in three kinds of request: a keyword search of Meta's
Ad Library (the public record of the ads running across Meta's apps) across all advertisers, the
ads one company or page runs, or the recent posts of one public Facebook page. Each request is one
of these; a page's posts and its ads are separate requests. Transport (pin, request shape, the
8-in-flight limit) is in the `sippar-antseed-buyer` skill; read it first. Model string:
`sippar-facebook-social`.

## How to ask

The last user message is the request. Plain text is a keyword search of the Ad Library across all
advertisers:

```json
{"model": "sippar-facebook-social",
 "messages": [{"role": "user", "content": "running shoes"}]}
```

For the ads one company or page runs, send the message text as JSON with `"by": "company"` and
the name in `query`:

```json
{"model": "sippar-facebook-social",
 "messages": [{"role": "user", "content": "{\"query\": \"Stripe\", \"by\": \"company\"}"}]}
```

For a public page's recent posts, send `"by": "page"` with the page's facebook.com link in
`query`:

```json
{"model": "sippar-facebook-social",
 "messages": [{"role": "user", "content": "{\"query\": \"https://www.facebook.com/NASA\", \"by\": \"page\"}"}]}
```

The link must be a page or profile (`https://www.facebook.com/<name>` or
`https://www.facebook.com/profile.php?id=<number>`). A group, event, photo, video, marketplace or
single-post link is refused before anything is bought, with the reason.

Every option goes **inside the message text, as a JSON string**: the `content` itself becomes
`{"query": …, …}`. Fields placed anywhere else (beside `content`, or at the top level of the body)
do not reach the seller and are silently lost. In Python:
`content=json.dumps({"query": "Stripe", "by": "company", "country": "US"})`.

| Field | What it does |
|---|---|
| `by` | `keyword` (the default), `company`, or `page` (with a facebook.com page link) |
| `country` | a two-letter country code such as `US` or `GB`, or `ALL` |
| `status` | `active`, `inactive` or `all` (lowercase) |
| `sortBy` | `impressions` or `most-recent` |
| `mediaType` | `image`, `video`, `meme`, `image-and-meme`, `none` or `all` |
| `startDate`, `endDate` | `YYYY-MM-DD` |
| `cursor` | the next page after an earlier answer: the cursor its closing line gives |

A page request takes only `cursor`; the other filters are for Ad Library requests, and sending one
with `"by": "page"` is refused before anything is bought.

US ads that are running now:

```json
{"model": "sippar-facebook-social",
 "messages": [{"role": "user", "content": "{\"query\": \"meal kit delivery\", \"country\": \"US\", \"status\": \"active\"}"}]}
```

A value outside these lists (`"status": "ACTIVE"`, `"country": "United States"`) is refused
before anything is bought. Field names are case-sensitive: `sortBy`, `mediaType`, `startDate`.

**There is no count option.** Every Ad Library page measured carried 30 ads; every page-posts read
carried 3 posts. For more, follow the cursor: the closing line of each page gives the next message
ready to copy, with your filters repeated.

Do not send `x-antseed-required-parameters` on this model. It announces no parameters, so
requiring any name refuses every call.

## Reading the page

The page opens with one source line naming Social Fetch, the endpoint, when it was retrieved and
the request that was sent. `Request sent` uses Social Fetch's own names (a company request shows as
`{"companyName": "Stripe"}`): ask with `query` and `by` as above, never with `companyName`. Then a blank line, Social Fetch's JSON exactly as it arrived, then a
closing line (the next-page message, the options) and a disclaimer. Parse the second block:

```python
import json
data = json.loads(page.split("\n\n")[1])
ads = data["data"].get("ads")      # an Ad Library request
posts = data["data"].get("posts")  # a page request
next_page = data["data"]["page"]   # {"nextCursor": "…", "hasMore": true}
```

### Ads

Each ad carries:

- `id`: the Ad Library id; `url`: the ad's entry in Meta's Ad Library
  (`https://www.facebook.com/ads/library?id=…`). Cite this link; it is the public record. `adId`
  was `null` on every ad measured.
- `page`: the advertiser, with `name`, `url` (its Facebook page), `id`, `isDeleted` and
  `profilePictureUrl`.
- `creative`: `bodyText` (the ad text), `title` (the headline), `caption` (usually the domain),
  `linkUrl` (where the ad sends people), `linkDescription` (often `null`), `callToAction` (`Sign up`, `Shop now`, …), `displayFormat`
  (`IMAGE`, `VIDEO`, `DCO` for dynamic creative), and media links: `images` (each a `url`),
  `videos` (`hdUrl`, `sdUrl`, `previewImageUrl`) and `cards` (carousel cards, each with its own
  title, body and link). Media are links, not files; they can expire.
- `isActive`: whether the ad is running now. `startedAt` and `endedAt` are dates; on the page
  measured, all 30 ads were active and every one still carried an `endedAt`, so read `isActive`
  for whether an ad is running.
- `publisherPlatforms`: where it runs (`FACEBOOK`, `INSTAGRAM`, `MESSENGER`, …).
- `categories`, a list (`["UNKNOWN"]` on the commercial ads measured), and `countries` (empty on every ad
  measured).
- `campaign.collationCount`: how many near-identical versions of the ad Meta grouped together;
  `null` on some ads measured (not zero).
- `impressions` and `spend`: Meta publishes these for political and issue ads; on the commercial
  ads measured they were empty (`{"text": null, "index": -1}` and `null`). Empty is not zero.

`lookupStatus` is `found` when the company or search matched. A field the provider did not return
is `null` or empty, never filled in.

Check `page.name` and `page.url` on each ad before attributing it: a keyword search returns ads
from many advertisers, and a company request matches by name.

Ads are what Meta's library showed at retrieval time; quote them with the retrieval time. Each ad
belongs to its advertiser.

### Posts

`Request sent` shows `{"url": "…"}`, Social Fetch's name for the link. Each post carries:

- `text`: the post as published (it can be empty, e.g. a photo-only post), `url` (the post on
  facebook.com), `id`, `createdAt` and `publishTime`.
- `authorDisplayName`, `authorShortName` and `authorId`: the page that posted.
- `reactionCount` and `commentCount`. `videoViewCount` was `null` on every post measured, video
  posts included: empty is not zero.
- Media links: `imageUrl`, sometimes `imageUrls`, and on video posts `videoHdUrl`, `videoSdUrl` and
  `videoThumbnailUrl`. They are links, not files, and they can expire.
- `topComments`: a few comments as Facebook shows them, each with the commenter's
  `authorDisplayName`, `authorUrl`, `authorId`, `text` and `createdAt`. These are the commenters'
  own words: quote them as theirs.

Posts come newest first. Each post belongs to its author and each comment to its commenter. Not
affiliated with Meta.

## Cost

Per output token at the rate on the peer record. Ad Library pages are long: every one measured on
2026-10-11 carried 30 ads, 18,136 to 79,502 tokens, median 30,917 (eleven reads, keyword searches
and company requests alike). A buyer whose per-request budget is set below the cost of a long page
should raise it, or narrow the request with `country`, `status`, `mediaType` or dates. Page-posts
reads are short: 2,288 to 3,482 tokens for three posts (four reads). A request refused before buying
bills nothing.

## Changes

- 1.1.0 (2026-10-11): a public page's recent posts, `"by": "page"` with its link.
- 1.0.0 (2026-10-11): first publish.
