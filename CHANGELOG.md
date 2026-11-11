# Changes

The newest first. Each guide's current version is in its `metadata.version`.

## 2026-11-11

- `nansen-crypto-screener` guide 3.4.0: the options can also be typed as the whole message in JSON,
  such as `{"chains": ["base"], "sort": "volume", "rows": 5}`, with no `query`.
- `quicknode-blockchain-data` guide 3.7.1: from a chat box, the chain is the whole message (`base`);
  a short sentence naming a chain is refused free with the message to send instead.
- `sippar-tiktok-social`: its refusals no longer point at keyword search, which this model does not
  serve, and each one names a message that works.
- `sippar-facebook-social` 1.3.0, `sippar-x-social` 1.2.0 and `sippar-amazon` 1.2.0: a `limit`
  option in the JSON message serves only the first N rows (ads, posts, products), for a
  smaller answer that bills less at the same rate. Facebook takes 3 to 50; X and Amazon 1 to 50.
  Without `limit`, every answer is the same as before.

## 2026-11-08

- `sippar-skills` guide 1.2.0: one search across skills.sh, CryptoSkill and Sippar's own skills,
  best match first, from an index of every skill. A search can be a sentence describing the job.

## 2026-11-04

- Ten free public-data models, each with its guide, 1.0.0: `openalex-search`, `crossref-search`,
  `arxiv-search`, `sec-edgar-search`, `usgs-earthquakes`, `nasa-power-weather`, `country-indicators`
  (World Bank Open Data), `wikipedia-search`, `package-search-for-npm` and `open-library-search`.
  Each serves its provider's public data as the provider returns it, live for each request.
- README and buyer guide 3.3.0: the ten in the model tables, the free allowance shared by all free
  models.

## 2026-11-03

- `sippar-instagram-social` and `sippar-tiktok-social`: their guides, 1.0.0. One account's posts,
  reels or profile on Instagram; one creator's videos, or one video, on TikTok; from Social Fetch.
- `sippar-web-search`: its guide, 1.0.0. The first page of Google's results for a search, read live
  by an Apify Actor.
- Every guide in one shape: Try it, How to ask, Reading the answer, Limits and caveats, Cost.
  Descriptions say when to use the model; dated test notes are gone from the body; each guide's
  own change list moved here.
- Guides say where a short answer ends with the list of Sippar's other models, which comes after
  the JSON.
- The buyer guide opens with a free call, and covers the free models' 429 `free_tier_exhausted`.
- The adapter's capability map covers every model.

## 2026-11-02

- README rewritten: what AntSeed is in two sentences, try it in the AntSeed app first, one free
  call from code with a real answer, every model in one table (social and travel first), and what
  to do when something goes wrong.
- `ui-animation-search`: its guide, 0.1.0 (draft). The model is free on AntSeed.
- `3d-model-search` 1.1.1: free, under a daily allowance per buyer; the old rate removed.
- `sippar-x-social` 1.1.0: the guide in the new shape (try it, how to ask, reading the answer,
  limits and caveats, cost).

## 3d-model-search

- 1.2.0 (2026-11-03): the guide in the new shape.
- 1.1.1 (2026-11-02): the guide no longer prints the rate before the model went free.
- 1.1.0 (2026-10-28): the model is free, under a 50-a-day allowance per buyer address.
- 1.0.0 (2026-10-24): first publish.

## crypto-skills

- 2.2.2 (2026-11-03): the Instagram and TikTok models' skills open by exact name too.
- 2.2.1 (2026-11-03): `sippar-web-search`'s skill opens by exact name too.
- 2.2.0 (2026-11-03): the guide in the new shape.
- 2.1.2 (2026-11-02): the two free models' skills open by exact name too (3D models, UI animation).
- 2.1.1 (2026-10-13): the four newest models' skills open by exact name too (Facebook, news,
  jobs, video). A plainer warning to read a third-party skill before running it.
- 2.1.0 (2026-10-11): `sippar-skills` is its own model, the aggregator, not an earlier id of this
  one. The full list of Sippar's own skills this model serves.
- 2.0.0 (2026-10-08): the model is `crypto-skills`. A
  single word is a search; search pages by `{"query": ..., "page": ...}`; skill pages carry the
  quality score and the file list; files fetch by path.
- 1.0.0 (2026-10-08): first publish.

## nansen-crypto-screener

- 3.3.0 (2026-11-03): the guide in the new shape.
- 3.2.1 (2026-11-02): Sui named in the description; this entry for 3.2.0.
- 3.2.0 (2026-10-21): `sui` in `chains`.
- 3.1.0 (2026-10-10): added `symbols`, named tickers such as tokenized stocks, and the two
  keys it adds to the page.
- 3.0.0 (2026-10-08): the model is `nansen-crypto-screener` (the old id `onchain-token-rankings`
  still answers).
- 2.0.0 (2026-10-08): own skill. Added `view: perp-screener` and its page shape, and the
  page-count keys.

## quicknode-blockchain-data

- 3.7.0 (2026-11-03): the guide in the new shape.
- 3.6.3 (2026-11-02): no chain count in the text; a shorter description.
- 3.6.2 (2026-10-22): Sui commands answered from Sui GraphQL, since Sui's JSON-RPC is retired.
- 3.6.1 (2026-10-21): `rpc` without `network` runs on Ethereum, stated plainly.
- 3.6.0 (2026-10-21): Sui, with its own read-only commands.
- 3.5.1 (2026-10-09): `rpc` stated as the way in on all 46 chains; the summary page is an extra on
  the first 20.
- 3.5.0 (2026-10-09): `rpc` on 26 more chains with no page (`rpc`-only), from avalanche to zksync.
- 3.4.1 (2026-10-09): removed the price-feed example from `eth_call`.
- 3.4.0 (2026-10-09): `eth_call`, a contract's read-only answer at any block, with long results
  served in slices.
- 3.3.0 (2026-10-09): `trace_filter`, the calls and internal transfers that touched a wallet,
  with wide answers resumed by `after`.
- 3.2.0 (2026-10-08): `eth_getBalance`, an account's native balance at any block.
- 3.1.0 (2026-10-08): `eth_getTransactionByHash`, with long `input` served in slices; where to read
  the live command list.
- 3.0.0 (2026-10-08): the model is `quicknode-blockchain-data` (the old id `sippar-chain-state`
  still answers). `rpc` adds wallet-filtered `eth_getLogs`, `eth_getBlockByNumber` and
  `eth_getTransactionReceipt`.
- 2.0.0 (2026-10-08): own skill. Added `rpc` and its served-in-part page, `tokens`, the partial
  page rule, and the wei note.

## sippar-amazon

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.0 (2026-10-10): first publish.

## sippar-antseed-buyer

- 3.2.0 (2026-11-03): `sippar-instagram-social` and `sippar-tiktok-social`.
- 3.1.0 (2026-11-03): `sippar-web-search`.
- 3.0.0 (2026-11-03): the guide in the new shape.
- 2.19.0 (2026-11-02): `ui-animation-search`, and the two free models named as free; a shorter description.
- 2.18.0 (2026-10-24): the seventeenth model, `3d-model-search` (its id carries no sippar- prefix); a 409 `payment_negotiation_failed` is your buyer's channel with this seller, and what to do about it.
- 2.17.0 (2026-10-13): from an outside review of this repository.
  - The 429 as the buyer proxy delivers it: `rate_limit_error`, no `retry-after`; don't follow
    its "try another peer" advice.
  - A misspelled name in `x-antseed-required-parameters` is refused free. A misspelled or missing
    body key is served and billed.
  - Section 8: check `x-antseed-peer-id` to confirm the seller.
  - The three ways a model answers (HTTP error, `Not sent` page, supplier error page) and what
    each costs.
  - Paging per model.
  - The model table ordered by what people ask for.
  - The description no longer lists every model.
  - The AntSeed docs map.

- 2.16.0 (2026-10-12): the sixteenth model, `sippar-video-search`.
- 2.15.0 (2026-10-12): the fifteenth model, `sippar-job-search`.
- 2.14.0 (2026-10-12): the fourteenth model, `sippar-news-search`.
- 2.13.1 (2026-10-11): `sippar-facebook-social` also serves a public page's posts (`"by": "page"`).
- 2.13.0 (2026-10-11): the thirteenth model, `sippar-facebook-social`.
- 2.12.2 (2026-10-11): `tavily-web-search` buys from Tavily directly first, via gedx402 when Tavily refuses.
- 2.12.1 (2026-10-11): `tavily-web-search` announces `include_images, max_results`;
  `sippar-skills` announces nothing; 46 chains; the 8-in-flight limit spans all twelve models.
- 2.12.0 (2026-10-10): the twelfth model, `sippar-amazon`.
- 2.11.0 (2026-10-10): through an AntSeed API-key gateway. When `ANTSEED_BASE_URL` and
  `ANTSEED_API_KEY` are set, post there with the key: no local proxy and no `antseed` command
  are needed.
- 2.10.0 (2026-10-10): the eleventh model, `sippar-hotel-search`.
- 2.9.0 (2026-10-10): the tenth model, `sippar-reddit-social`.
- 2.8.1 (2026-10-10): `nansen-crypto-screener`'s announced list includes `symbols`.
- 2.8.0 (2026-10-10): `tavily-web-search` announces `include_images, include_raw_content, max_results`.
- 2.7.0 (2026-10-10): `sippar-skills` is the ninth model, the aggregator (skills.sh and CryptoSkill);
  `crypto-skills` stays CryptoSkill-only; the `sippar-skill-adapter` skill.
- 2.6.0 (2026-10-10): the eighth model, `sippar-github`.
- 2.5.0 (2026-10-09): the seventh model, `sippar-linkedin-social`.
- 2.4.0 (2026-10-09): the sixth model, `sippar-flight-search`.
- 2.3.0 (2026-10-09): the fifth model, `sippar-x-social`.
- 2.2.0 (2026-10-08): the models are named after their providers; the earlier ids still answer.
  Skills are referred to by name.
- 2.1.0 (2026-10-08): the fourth model, `sippar-skills` (now `crypto-skills`).
- 2.0.0 (2026-10-08): transport only; the per-model content moved to its own skills. Added the
  8-in-flight limit, the `extra_body` refusal, and the three announced parameter lists.
- 1.0.0 (2026-09-24): first publish, one skill for two models.

## sippar-facebook-social

- 1.2.0 (2026-11-03): the guide in the new shape.
- 1.1.0 (2026-10-11): a public page's recent posts, `"by": "page"` with its link.
- 1.0.0 (2026-10-11): first publish.

## sippar-flight-search

- 1.2.0 (2026-11-03): the guide in the new shape.
- 1.1.0 (2026-10-09): options (class, children, infants, lap, currency); filter stops, price and
  airline from the list; the Google Flights link for booking.
- 1.0.0 (2026-10-09): first publish.

## sippar-github

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.1 (2026-10-11): no printed rate; read it from the peer record.
- 1.0.0 (2026-10-10): first publish.

## sippar-hotel-search

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.0 (2026-10-10): first publish.

## sippar-instagram-social

- 1.0.0 (2026-11-03): first publish.

## sippar-job-search

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.0 (2026-10-12): first publish.

## sippar-linkedin-social

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.0 (2026-10-09): first publish.

## sippar-news-search

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.0 (2026-10-12): first publish.

## sippar-reddit-social

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.0 (2026-10-10): first publish.

## sippar-skill-adapter

- 1.1.2 (2026-11-03): Instagram and TikTok in the capability map.
- 1.1.1 (2026-11-03): `sippar-web-search` in the capability map.
- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.1 (2026-10-10): what the first real run taught the video lane: frame shape, the 409 retry, the two duration shapes.
- 1.0.0 (2026-10-10): first draft, from the video adapter experiments of 2026-10-09/10 (five
  AntSeed renders, one skills.sh skill adapted end to end) and real served pages of the skills
  model after skills.sh joined it. Generalised from a per-category adapter on Elad's call: one
  capability map, lanes beneath it.

## sippar-skills

- 1.1.2 (2026-11-03): the list includes the Instagram and TikTok models' skills.
- 1.1.1 (2026-11-03): the list includes `sippar-web-search`'s skill.
- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.3 (2026-11-02): the list includes the two free models' skills (3D models, UI animation).
- 1.0.2 (2026-10-13): the list now includes the four newest models' skills (Facebook, news,
  jobs, video). A plainer warning to read a third-party skill before running it.
- 1.0.1 (2026-10-11): the full list of Sippar's own skills this model serves.
- 1.0.0 (2026-10-10): the aggregator model: skills.sh and CryptoSkill together, `owner/repo/skill`
  ids, files by path, a search of both indexes paged together, the repository's license line and
  skills.sh's audit verdicts on every skills.sh page. `crypto-skills` keeps serving CryptoSkill and
  Sippar's own skills only. The `sippar-skill-adapter` skill.

## sippar-tiktok-social

- 1.0.0 (2026-11-03): first publish.

## sippar-video-search

- 1.1.0 (2026-11-03): the guide in the new shape.
- 1.0.1 (2026-10-12): `sort: date` is refused and points to `uploaded`.
- 1.0.0 (2026-10-12): first publish.

## sippar-web-search

- 1.0.0 (2026-11-03): first publish.

## sippar-x-social

- 1.1.1 (2026-11-03): where a short answer ends with the list of other models.
- 1.1.0 (2026-11-02): the guide in the new shape.
- 1.0.0 (2026-10-09): first publish.

## tavily-web-search

- 1.4.0 (2026-11-03): the guide in the new shape.
- 1.3.0 (2026-10-11): bought from Tavily directly first, through gedx402 when Tavily refuses;
  the source line names which.
- 1.2.0 (2026-10-11): bought through gedx402. Twenty results by default, `max_results` 20 to
  25; `include_raw_content` is not served.
- 1.1.0 (2026-10-10): `max_results`, `include_raw_content` and `include_images` (image links).
- 1.0.1 (2026-10-08): skills referred to by name.
- 1.0.0 (2026-10-08): first publish.

## ui-animation-search

- 0.1.0 (2026-11-02): first publish, a draft written from the code and a recorded measurement.
