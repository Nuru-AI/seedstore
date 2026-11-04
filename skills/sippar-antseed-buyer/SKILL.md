---
name: sippar-antseed-buyer
description: Use this before calling any of Sippar's models on AntSeed (every sippar-* model, plus 3d-model-search, ui-animation-search, the ten free public-data models such as openalex-search and usgs-earthquakes, tavily-web-search, quicknode-blockchain-data, nansen-crypto-screener and crypto-skills), from your own AntSeed buyer or an AntSeed API-key gateway. It covers pinning the Sippar peer, the request shape that keeps your options, the two channels that survive a translating client, the 8-calls-at-once limit, reading the routing line and errors, and confirming the answer came from Sippar. Also use it when an option was ignored, the wrong chain came back, or a call failed with 429, 409 payment_negotiation_failed or connection refused on 8377.
metadata:
  version: "3.3.0"
  updated: "2026-11-04"
---

# Reaching Sippar's models on AntSeed

Sippar sells data as models on AntSeed. Each answer is a provider's data or files, passed on as
the provider returns them, with the source named on its first line. This guide is about getting
there: how a request reaches Sippar with its options intact, and how to tell from the answer that
it did. What each model answers is in its own guide.

## Try it

This call is free:

```bash
curl http://127.0.0.1:8377/v1/chat/completions \
  -H 'content-type: application/json' \
  -H 'x-antseed-pin-peer: 706fca9c0d0684c30f86209aae0c3565ce1aa69f' \
  -d '{"model": "3d-model-search", "messages": [{"role": "user", "content": "cable clip"}]}'
```

Three things decide whether you get what you asked for: the pin (section 1), the
chat-completions path (section 2), and, for the models with top-level options, the routing line
(section 6).

## The models

| Model string | What it answers | Skill |
|---|---|---|
| `sippar-x-social` | public X (Twitter) posts on any subject matching a search, from glim.sh. Send keywords, names or X operators, never a sentence | the `sippar-x-social` skill |
| `sippar-reddit-social` | public Reddit posts matching a search, from glim.sh: title, thread link, subreddit, author, date, score and comment count per post, no post text or comments. Send keywords; `time` and `cursor` go inside the message text as JSON | the `sippar-reddit-social` skill |
| `sippar-linkedin-social` | public LinkedIn posts matching a search, from Social Fetch: link, date, author and counts per post, no post text. Send keywords; `posts` and `cursor` go inside the message text as JSON | the `sippar-linkedin-social` skill |
| `sippar-facebook-social` | Facebook via Social Fetch, as returned: Ad Library ads by keyword, or `"by": "company"` for one company's ads (long pages, about 18,000 to 80,000 tokens), or `"by": "page"` with a facebook.com page link for its recent posts; filters and `cursor` go inside the message text as JSON | the `sippar-facebook-social` skill |
| `sippar-instagram-social` | one public Instagram account from Social Fetch, cut to search results: its recent posts or reels (link, date, counts, the caption's first 150 characters) or its profile; no photos, videos or full captions. Send the account's @name or profile link; `by` and `cursor` go inside the message text as JSON | the `sippar-instagram-social` skill |
| `sippar-tiktok-social` | one public TikTok creator's latest videos, or one video by its link, from Social Fetch, cut to search results (link, date, counts, the caption's first 150 characters); no video files or full captions. Send an @handle or profile link; `by` and `cursor` go inside the message text as JSON | the `sippar-tiktok-social` skill |
| `sippar-news-search` | news from Google News via OpenWeb Ninja, each article cut to headline, publisher, date, link and snippet, no article text. Send one line: a search of the past week, `headlines` for the day's top stories, or `headlines business` (or another of eight topics) | the `sippar-news-search` skill |
| `sippar-video-search` | public YouTube videos: a search's videos from ScrapeMole (title, link, channel, views, length, the age YouTube shows), or one video's details from Social Fetch by its link (publish time, counts, genre, keywords, chapters, caption languages, related videos); no description, transcript or comment text. Send search words or one video link; `sort`, `uploaded` and `duration` go inside the message text as JSON | the `sippar-video-search` skill |
| `3d-model-search` | free: public 3D models on Sketchfab: a search's models (title, link, creator, licence, thumbnail, downloadable or not, counts, download formats), or one model's details by its link (the licence's terms, downloads, materials, textures); no files and no description text. Send search words or one model link; `license`, `downloadable`, `file_format`, `categories`, `sort_by` and `cursor` go inside the message text as JSON | the `3d-model-search` skill |
| `ui-animation-search` | free: animated React components from nine open-source shadcn registries, matched by your words, or one component's source files, keyframes, install line and MIT notice by its id (`@magicui/marquee`). `registry` and `cursor` go inside the message text as JSON | the `ui-animation-search` skill |
| `openalex-search` | free: scholarly works from OpenAlex for search words (title, year, venue, citation count, authors, DOI, open-access link); no abstracts | the `openalex-search` skill |
| `crossref-search` | free: publication records registered with Crossref for search words (title, type, date, venue, publisher, authors, citation count, DOI) | the `crossref-search` skill |
| `arxiv-search` | free: arXiv preprints matching every search word, with abstracts and links to the paper and PDF | the `arxiv-search` skill |
| `sec-edgar-search` | free: US company filings from SEC EDGAR full-text search whose text holds a phrase (company, CIK, form, dates, link); `forms` inside the message text as JSON | the `sec-edgar-search` skill |
| `usgs-earthquakes` | free: recent earthquakes from the USGS catalog, newest first; a magnitude (`M5`) and days (`30 days`) in the line, or `minmagnitude` and `days` as JSON | the `usgs-earthquakes` skill |
| `nasa-power-weather` | free: daily weather and solar data from NASA POWER for one point. Send `LAT LON START END`, e.g. `32.08 34.78 2026-10-01 2026-10-07`, at most 31 days; coordinates, not place names | the `nasa-power-weather` skill |
| `country-indicators` | free: one World Bank Open Data indicator for one country by year. Send a country code and an indicator code or word, e.g. `IL gdp`, `USA NY.GDP.PCAP.CD` | the `country-indicators` skill |
| `wikipedia-search` | free: English Wikipedia articles for search words (title, matching snippet, word count, last edit, link); no article text | the `wikipedia-search` skill |
| `package-search-for-npm` | free: npm registry packages for search words (version, description, licence, last publish, downloads, dependents, links) | the `package-search-for-npm` skill |
| `open-library-search` | free: Open Library books by title, author or words (authors, first year, editions, languages, ISBNs, link) | the `open-library-search` skill |
| `sippar-flight-search` | Google Flights fares for one route and date, via stabletravel.dev. Send one line, `FROM TO DATE [RETURN-DATE] [ADULTS]` with airport codes, never a sentence | the `sippar-flight-search` skill |
| `sippar-hotel-search` | places to stay for one search, from Google Maps via OpenWeb Ninja: type, stars, rating, amenities, address and Google's current nightly price; end the line with `offers` for each booking site's price | the `sippar-hotel-search` skill |
| `sippar-job-search` | job postings from Google for Jobs via OpenWeb Ninja, each cut to title, employer, publishing site, employment type, place, posted time, pay, benefits and links, no description text. Send one line with the role and the place; outside the US end it with `country` and two letters (`marketing manager jobs in Berlin country de`) | the `sippar-job-search` skill |
| `sippar-amazon` | Amazon from glim.sh: products for a search or `bestsellers:<category>` on six marketplaces, or one product's offer, other sellers and top reviews by ASIN or product URL; options in a JSON message | the `sippar-amazon` skill |
| `sippar-web-search` | the first page of Google's US results for one search, via an Apify Actor: position, link, title and Google's description per result, no page text. Send the search as you would type it into Google | the `sippar-web-search` skill |
| `tavily-web-search` | a live web search with sources, from Tavily (directly, or via gedx402) | the `tavily-web-search` skill |
| `sippar-github` | public GitHub from glim.sh: a repository, a folder's file list, a file, an issue or PR, commits, releases, code search. Send a ref (`owner/repo`, a github.com URL) or a GitHub search; `repo`, `kind`, `per_page` and `page` go inside the message text as JSON | the `sippar-github` skill |
| `sippar-skills` | the aggregator: our own, skills.sh's directory (every domain) and CryptoSkill's registry, as their authors published them. Send a skill name, an id (`owner/repo/skill` or `category/name`) or two or three keywords, never a sentence | the `sippar-skills` skill; `sippar-skill-adapter` to run one on AntSeed |
| `quicknode-blockchain-data` | live facts about one EVM chain (Ethereum, Base and dozens more) or Sui, bought from QuickNode when you ask | the `quicknode-blockchain-data` skill |
| `nansen-crypto-screener` | the top token contracts on Solana, Ethereum, Base, BNB and Arbitrum, from Nansen, plus Nansen's perpetuals screener | the `nansen-crypto-screener` skill |
| `crypto-skills` | agent skills: our own, and CryptoSkill's registry of crypto skills, as their authors published them. Send a skill name, an id or two or three keywords as the message, never a sentence | the `crypto-skills` skill |

Two models also answer under their earlier ids, with the same data, arguments and rate:
`sippar-chain-state` (now `quicknode-blockchain-data`) and `onchain-token-rankings` (now
`nansen-crypto-screener`). Use the new ids. `sippar-skills` is not an old id of `crypto-skills`:
it is the aggregator model, and `crypto-skills` the CryptoSkill-only one.

Load only the skill of the model you are calling, not all of them. Paging differs by model, so
never write one "next page" loop for all of them:

- **A cursor you send back:** `sippar-linkedin-social`, `sippar-reddit-social`,
  `sippar-facebook-social`, `sippar-job-search`, `sippar-instagram-social` and `sippar-tiktok-social`
  (`page.nextCursor`, when the answer carries one).
- **A page number:** `sippar-github`, `sippar-amazon`, `crypto-skills`, `sippar-skills`.
- **A cursor you send back:** also `3d-model-search` and `ui-animation-search` (`next.cursor`).
- **One call is one page:** every other model. `sippar-x-social` shows X's `next_cursor`, but you
  cannot send it back; change the search for different posts.

Each model's skill says exactly how.

Seller peer `706fca9c0d0684c30f86209aae0c3565ce1aa69f`, onchain agent 84918, settled in USDC on
Base through your AntSeed payment channel. `3d-model-search`, `ui-animation-search` and the ten
public-data models (`openalex-search` to `open-library-search` above) are free within a daily
allowance per buyer. The rest bill per output token at the rate on the peer
record. Rates change, so read them rather than copying a number:

```bash
antseed network peer 706fca9c0d0684c30f86209aae0c3565ce1aa69f
```

## 1. Pin the peer

Buyer auto-selection does not necessarily route to this seller, so name it. A script or an
agent should pin per request, which needs no CLI and changes nothing shared:

```
x-antseed-pin-peer: 706fca9c0d0684c30f86209aae0c3565ce1aa69f
```

The other ways: put the seller address in the model string
(`"model": "0x706FCA9C0d0684C30F86209AAe0c3565cE1aa69F@quicknode-blockchain-data"`), set a session pin
with the CLI (`antseed buyer connection set --peer 706fca9c…`, bare id without `0x`), or pick
`Sippar Onchain Data` on the desktop app's Discover screen. If your wallet belongs to the desktop
app, most `antseed buyer` commands will not run against it; pin from the app or per request.

Free preflight, which calls no model, and the ledger that says what your calls cost:

```bash
antseed network peer 706fca9c0d0684c30f86209aae0c3565ce1aa69f
antseed buyer connection get
antseed buyer activity
```

A call without a pin can still reach this seller through auto-selection, but nothing guarantees
it. If you leave the pin off, check which seller answered (section 8) before you use the page.

## 2. Send the chat-completions shape

This seller advertises one API protocol, `openai-chat-completions`. Post to
`/v1/chat/completions` on your AntSeed endpoint, which is one of two things:

- **Your own buyer proxy**, the usual setup: `127.0.0.1:8377` by default (`antseed buyer start
  --port` moves it). No key.
- **An AntSeed API-key gateway**, AntSeed's multi-user setup, where one buyer serves many people
  and each has their own key, limits and wallet. Send `Authorization: Bearer <your key>` to the
  gateway's address. If `ANTSEED_BASE_URL` and `ANTSEED_API_KEY` are set in your environment,
  that is your endpoint: post to `$ANTSEED_BASE_URL/chat/completions` with that key, not to
  8377. You need no `antseed` command and no buyer of your own. The pin, the arguments and the
  channels below work unchanged.

Any OpenAI-compatible client works on its chat-completions path.

Arguments are top-level keys in the request body, beside `model` and `messages`:

```bash
curl http://127.0.0.1:8377/v1/chat/completions \
  -H 'content-type: application/json' \
  -H 'x-antseed-pin-peer: 706fca9c0d0684c30f86209aae0c3565ce1aa69f' \
  -d '{
    "model": "quicknode-blockchain-data",
    "network": "base",
    "fields": ["blockNumber", "gasPrice"],
    "messages": [{"role": "user", "content": "chain state"}]
  }'
```

Through a key gateway it is the same body, sent to the gateway with your key:

```bash
curl "$ANTSEED_BASE_URL/chat/completions" \
  -H "Authorization: Bearer $ANTSEED_API_KEY" \
  -H 'content-type: application/json' \
  -H 'x-antseed-pin-peer: 706fca9c0d0684c30f86209aae0c3565ce1aa69f' \
  -d '{"model": "sippar-flight-search", "messages": [{"role": "user", "content": "TLV BER 2026-10-20 1"}]}'
```

Behind a gateway, the `antseed` commands elsewhere in this skill (rates, preflight, activity)
are optional: the request needs only the endpoint, your key and the pin. `GET
$ANTSEED_BASE_URL/models` lists what the gateway's buyer can reach, and `GET
$ANTSEED_BASE_URL/key` shows your own spend and limits.

From the OpenAI Python SDK that is `extra_body={"network": "base", "fields": [...]}` on
`chat.completions.create`. The SDK flattens `extra_body` into the body. If you write the JSON
yourself, put the arguments at the top level: a literal `"extra_body": {...}` key is refused
with a free 400 that says so.

**Do not post to `/v1/messages` or `/v1/responses` with arguments.** The buyer proxy translates
those shapes by rebuilding the body from a fixed key list, and your arguments are not on it.
They are dropped silently, you are served the default page, and you pay for it.

## 3. If your client translates, use a channel that survives

Two channels cross every translation the proxy performs, and every Sippar model reads both.
Under `metadata`, namespaced:

```json
"metadata": {"sippar": {"network": "base", "fields": ["blockNumber", "gasPrice"]}}
```

Or as headers, one per argument, `x-sippar-<argument>`:

```
x-sippar-network: base
x-sippar-fields: blockNumber,gasPrice
```

A header carries text, so a list is comma-separated there and an object (`rpc`) is its JSON as a
string. Under `metadata` a list may be a list. A top-level argument, when it reaches the seller,
wins over both. Every argument of every model rides these channels under its own name.

Neither channel is documented by the marketplace. Both are measured to survive, not promised
to; the check is free and offline (section 7).

## 4. Or fail closed, for free

```
x-antseed-required-parameters: network,fields
```

With this header the proxy refuses any call that would need a translation, before routing and
before payment, with `422 required_capability_unavailable`. A call that needs no translation is
unaffected. It buys you a refusal, not an answer, so prefer section 3.

Two rules. First, it checks what the seller announces, not what your body contains. A
misspelled name in the header (`netwrok`) is not announced, so the call is refused free with the
422. A misspelled key in the body, under a correct header, passes the check: the seller never
sees your `network`, serves the default page and bills it. The same goes for a name you require
but leave out of the body: requiring `fields` and sending none is served at full width and billed
in full; an outside buyer found this to be the one billing trap the header leaves.
The routing line (section 6) catches the wrong chain; only your own code catches a missing
`fields`. Second, require only what the model announces:
`quicknode-blockchain-data` announces `address, blocks, fields, network, rpc, tokens`;
`nansen-crypto-screener` announces `chains, rows, sort, symbols, timeframe, view`; `tavily-web-search`
announces `include_images, max_results`; `crypto-skills`, `sippar-skills`, `sippar-x-social`, `sippar-flight-search`, `sippar-linkedin-social`, `sippar-github`, `sippar-reddit-social`, `sippar-hotel-search`, `sippar-amazon`, `sippar-facebook-social`, `sippar-instagram-social`, `sippar-tiktok-social`, `sippar-news-search`, `sippar-job-search`, `sippar-video-search`, `sippar-web-search`, `3d-model-search` and `ui-animation-search` announce nothing, so requiring any name on them refuses every call. Read the current lists:

```bash
antseed network peer 706fca9c0d0684c30f86209aae0c3565ce1aa69f --json \
  | jq '.peer.providerServiceCapabilities.openai.services | map_values(.supportedParameters)'
```

## 5. At most 8 calls in flight

The seller serves at most 8 calls at once per buyer, across all of its models together. The
ninth is refused with HTTP 429; nothing is served and nothing is billed. The peer record's
`maxConcurrency` is the node's ceiling, not this number.

What reaches you is the buyer proxy's wrapper around our refusal, not the refusal itself. The
seller sends `buyer_concurrency_limit` with `retry-after: 1`. Through the buyer proxy it arrives as
`error.type` `rate_limit_error`, with our message in `error.peer_message` and no `retry-after`
header (measured by an outside buyer). So:

- Key on the 429 status, not on an error code.
- Wait about a second and retry the same pinned peer.
- Ignore the wrapper's advice to try another peer or use auto routing. It drops your pin and
  reaches a different seller.

A sweep over many chains runs in batches of 8 or fewer, with a retry on 429.

**A 429 with `code: "free_tier_exhausted"` is the free models' daily allowance.** The free models
(`3d-model-search`, `ui-animation-search` and the ten public-data models) share 50 calls per buyer
address and 150 per IP over a rolling 24 hours.
The answer carries `limitedBy` (`address` or `ip`) and a `Retry-After` header; wait that long.

**A 409 with `error.type` `payment_negotiation_failed` is your buyer's channel, not the seller.**
Its `peer_message` reads "An existing payment channel could not be recovered automatically. Close
or recover the channel and retry." Your own buyer raises it, in its payment code
(`buyer-payment-negotiator`), when the payment channel it holds with this seller cannot be
recovered, and it gives up before your request is sent. It can hit one buyer on every call while
another buyer's channel with the same seller keeps working. Retrying the pinned peer does not clear
it. Recover or
close that channel in your buyer (in the AntSeed app, or with `antseed buyer channels` if your
buyer runs from the CLI), then retry. As with the 429, ignore the wrapper's advice to try another
peer or auto routing: it reaches a different seller.

## 6. Read the routing line before you use the answer

Every `quicknode-blockchain-data` page carries a routing line, and the same facts under `routing` in
its JSON:

```
routing: mode=declared  network=base  confidence=n/a  source=network-field
```

`mode=declared` means your `network` arrived and selected the chain; `source` names the channel
(`network-field`, `network-meta`, `network-hdr`). `mode=default` means nothing arrived and you
are looking at Ethereum, billed in full. Check this in code before consuming the page. It is the
one signal that catches both a translated request and your own typo.

A refusal from the listing is an HTTP 400 whose message says what is accepted. On an open
channel it bills nothing: measured at zero on the ledger, against a response header that claimed
otherwise. Cost a call from your ledger (`antseed buyer activity`), never from
`x-antseed-estimated-cost-usd`.

Every model answers in one of three ways. Tell them apart in code by the HTTP status first, then
by the page's first line:

| What you get | What it means | Billed |
|---|---|---|
| an HTTP error (400, 422, 429) whose message says why | refused before anything was bought or served | nothing |
| a page whose first line starts `Not sent to <supplier>:` (or `Not sent`) | your request reached the model, which refused it before buying from the supplier, and says why | the page, by its width, like any page; it is short |
| a page whose first line says `<supplier> answered HTTP <code>` | the supplier was asked and returned an error; its response follows unchanged | the page, by its width |

Anything else is an answer. Each model's skill lists its own
first lines; the `sippar-github` skill has the fullest table.

## 7. Verify the shape rule yourself, free

```bash
node tools/check-argument-survival.mjs
```

Runs offline against the `@antseed/api-adapter` package your buyer already has, prints which
protocol pairs keep a top-level argument and which channels cross a translation, and exits
non-zero if the behaviour has moved.

## 8. Confirm the answer came from Sippar

The buyer proxy adds `x-antseed-*` headers to every answer. Two are worth reading in code:

- `x-antseed-peer-id` names the seller that answered. It must be
  `706fca9c0d0684c30f86209aae0c3565ce1aa69f`. This is how you know a call reached Sippar, pinned
  or not.
- `x-antseed-service` names the model that served it.

Reconcile money only against your ledger (`antseed buyer activity`), never against
`x-antseed-estimated-cost-usd`, which is an estimate and not what settled.

## AntSeed itself

This skill covers the Sippar layer. For the platform underneath:

| You need | AntSeed doc |
|---|---|
| install the CLI or desktop app | https://antseed.com/docs/install |
| configure the buyer (port, wallet, channels) | https://antseed.com/docs/config |
| how a buyer finds a seller | https://antseed.com/docs/discovery |
| payment channels and USDC settlement | https://antseed.com/docs/payments |
| how calls are metered | https://antseed.com/docs/metering |
| the CLI commands | https://antseed.com/docs/commands |
| the proxy from any OpenAI-compatible tool | https://antseed.com/docs/guides/using-the-api |

