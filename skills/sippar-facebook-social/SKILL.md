---
name: sippar-facebook-social
description: Use this when you need the ads a brand runs on Facebook and Instagram, which advertisers run ads on a topic, or what a company, organisation or public figure posted on its Facebook page. Sippar's sippar-facebook-social model on AntSeed returns Meta Ad Library ads by keyword or by company, or a public page's recent posts, from Social Fetch.
metadata:
  version: "1.3.0"
  updated: "2026-11-11"
---

# sippar-facebook-social

Facebook data from Social Fetch, three ways: a keyword search of Meta's Ad Library (the public
record of ads running across Meta's apps), the ads one company or page runs, or the recent posts of
one public Facebook page. A page's posts and its ads are separate requests. How to reach the seller
is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-facebook-social", "messages": [{"role": "user", "content": "running shoes"}]}
```

## How to ask

Plain text is a keyword search of the Ad Library across all advertisers. For one company's ads, or
a page's posts, send the message text as JSON:

```json
{"model": "sippar-facebook-social",
 "messages": [{"role": "user", "content": "{\"query\": \"Stripe\", \"by\": \"company\"}"}]}
```

```json
{"model": "sippar-facebook-social",
 "messages": [{"role": "user", "content": "{\"query\": \"https://www.facebook.com/NASA\", \"by\": \"page\"}"}]}
```

A page link must be a page or profile (`https://www.facebook.com/<name>` or
`https://www.facebook.com/profile.php?id=<number>`). A group, event, photo, video, marketplace or
single-post link is refused before anything is bought.

| Field | What it does |
|---|---|
| `by` | `keyword` (the default), `company`, or `page` (with a facebook.com page link) |
| `country` | a two-letter country code such as `US` or `GB`, or `ALL` |
| `status` | `active`, `inactive` or `all` (lowercase) |
| `sortBy` | `impressions` or `most-recent` |
| `mediaType` | `image`, `video`, `meme`, `image-and-meme`, `none` or `all` |
| `startDate`, `endDate` | `YYYY-MM-DD` |
| `cursor` | the next page: the cursor the previous answer's closing line gives |
| `limit` | Ad Library only: serve only the first N ads, 3 to 50; a smaller answer bills less |

A page request takes only `cursor` (a `limit` there is accepted but changes nothing: a page-posts
read is already 3 posts); the other filters are for the Ad Library. Field names are
case-sensitive (`sortBy`, `mediaType`, `startDate`), and a value outside these lists
(`"status": "ACTIVE"`, `"country": "United States"`) is refused before anything is bought. In
Python: `content=json.dumps({"query": "Stripe", "by": "company", "country": "US"})`.

Each Ad Library page carries 30 ads and each page-posts read carries 3 posts. For a smaller, cheaper
answer, add `limit`: `{"query": "Nike", "limit": 5}` serves the first 5 ads in Social Fetch's order,
and the first line says how many were kept of how many returned. 3 is the smallest `limit`. For
more, follow the cursor: the closing line gives the next message ready to copy, with your filters
and `limit` repeated. The cursor continues after all 30 ads of the page, so with `limit` the rest of
that page is skipped; leave `limit` out to get every ad.

## Reading the answer

The first line names Social Fetch, when it ran and the request sent, in Social Fetch's own names (a
company request shows as `{"companyName": "Stripe"}`; ask with `query` and `by` as above). Then a
blank line, Social Fetch's JSON, a closing line and a disclaimer.

```python
import json
data = json.loads(page.split("\n\n")[1])
ads = data["data"].get("ads")      # an Ad Library request
posts = data["data"].get("posts")  # a page request
next_page = data["data"]["page"]   # {"nextCursor": "...", "hasMore": true}
```

Each ad:

- `id`, and `url`, the ad's entry in Meta's Ad Library. Cite this link; it is the public record.
- `page`: the advertiser, with `name`, `url`, `id`, `isDeleted` and `profilePictureUrl`.
- `creative`: `bodyText` (the ad text), `title` (the headline), `caption`, `linkUrl` (where the ad
  sends people), `linkDescription`, `callToAction`, `displayFormat` (`IMAGE`, `VIDEO`, `DCO`), and
  media links: `images`, `videos` (`hdUrl`, `sdUrl`, `previewImageUrl`) and carousel `cards`.
- `isActive`, `startedAt`, `endedAt`, `publisherPlatforms` (`FACEBOOK`, `INSTAGRAM`, ...),
  `categories`, `countries`, `campaign.collationCount` (how many near-identical versions Meta
  grouped), and `impressions` and `spend` (published for political and issue ads).
- `lookupStatus` is `found` when the company or search matched.

Each page post:

- `text` (it can be empty on a photo-only post), `url`, `id`, `createdAt`, `publishTime`.
- `authorDisplayName`, `authorShortName`, `authorId`: the page that posted.
- `reactionCount`, `commentCount`, `videoViewCount`.
- Media links (`imageUrl`, sometimes `imageUrls`, and on video posts `videoHdUrl`, `videoSdUrl`,
  `videoThumbnailUrl`) and `topComments`, each with the commenter's name, link, text and date.

## Limits and caveats

- A field the provider did not return is `null` or empty, never filled in. Empty is not zero:
  `impressions` and `spend` were empty on every commercial ad we read, and `videoViewCount` was
  `null` on every post, video posts included. `adId` was always `null`.
- Read `isActive` for whether an ad is running: every active ad we read still carried an `endedAt`.
- Check `page.name` and `page.url` before attributing an ad. A keyword search returns many
  advertisers, and a company request matches by name.
- Media are links, not files, and they can expire. Ads are what Meta's library showed at the
  retrieval time; quote them with that time. Each ad belongs to its advertiser, each post to its
  author and each comment to its commenter. Not affiliated with Meta.
- An answer where Social Fetch returned fewer than five ads or posts ends with a list of Sippar's
  other models on AntSeed and a message to try with each, after the JSON. A page-posts read carries
  3 posts, so it always ends with that list. Rows you leave out with `limit` do not count: a 30-ad
  page cut to 3 has no list.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Ad Library pages are long: 18,000 to
80,000 tokens, median about 31,000 (eleven reads, measured 2026-10-11). If your per-request budget
is lower than that, add `limit` (3 ads is a few thousand tokens) or narrow the request with
`country`, `status`, `mediaType` or dates.
Page-posts reads are short: about 2,300 to 3,500 tokens. A request refused before buying bills
nothing.
