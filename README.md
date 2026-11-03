# Sippar's models on AntSeed

Live data from X, Reddit, LinkedIn, YouTube, Google Flights, Amazon, job boards, news, GitHub and
web search, available as models on [AntSeed](https://antseed.com). Every answer names its source.
Two models are free: `3d-model-search` and `ui-animation-search`.

AntSeed is a peer-to-peer marketplace for AI models. You run its desktop app or command-line buyer
on your own machine; it finds a seller, sends your request and pays per answer from your AntSeed
balance. No account is needed. The free models work before you top up; for the others, top up
inside the app. To set it up, follow [AntSeed's install guide](https://antseed.com/docs/install).

This repository documents the models Sippar sells there, which together make up SeedStore: what
each one returns and how to call it.

## Try it in the app

The AntSeed desktop app has a chat. Pick any chat model there and ask:

> Use the flight model on AntSeed to find New York to London for two, 12 to 19 November 2026

The chat model calls Sippar's flight search and shows the fares for those dates. Ask for any model
in the table the same way:

> Use the X model on AntSeed to see what people are saying about Tesla this week
>
> Use the jobs model on AntSeed to find data engineer jobs in Austin
>
> Use the 3d-model-search model on AntSeed to find a printable cable clip

## Call it from code

1. Start the AntSeed buyer. Either open the desktop app, or install the command-line buyer with
   `npm i -g @antseed/cli` and run `antseed buyer start`.
2. The buyer listens on your machine at `127.0.0.1:8377` and speaks the OpenAI chat-completions
   format.
3. Send a call. The `x-antseed-pin-peer` header sends it to Sippar rather than another seller; use
   this exact value for every model here. This call is free:

```bash
curl http://127.0.0.1:8377/v1/chat/completions \
  -H 'content-type: application/json' \
  -H 'x-antseed-pin-peer: 706fca9c0d0684c30f86209aae0c3565ce1aa69f' \
  -d '{"model": "3d-model-search", "messages": [{"role": "user", "content": "cable clip"}]}'
```

The model id goes in `model` and your search in the `content` of the last user message. A paid
call looks the same, for example `"model": "sippar-news-search"` with `"content": "Federal Reserve
interest rates"`.

Options go inside that `content` too, written as a JSON string, because the message text reaches
the seller unchanged through every AntSeed client. This asks only for models
uploaded as STL files that you can download:

```bash
curl http://127.0.0.1:8377/v1/chat/completions \
  -H 'content-type: application/json' \
  -H 'x-antseed-pin-peer: 706fca9c0d0684c30f86209aae0c3565ce1aa69f' \
  -d '{"model": "3d-model-search", "messages": [{"role": "user",
       "content": "{\"query\": \"cable clip\", \"file_format\": \"stl\", \"downloadable\": \"true\"}"}]}'
```

The answer from `3d-model-search`, shortened to one of its eight results. A source line comes
first, then Sketchfab's JSON, then a note on how to ask again and a licence line. Each model's guide
shows its own answer and how to read it:

```
Source: Sketchfab (public 3D models), GET https://api.sketchfab.com/v3/search, retrieved
2026-11-02T19:30:12.127Z. Request sent: {"type":"models","q":"cable clip","count":"24",
"downloadable":"true","file_format":"stl"}. Below, for each model Sketchfab returned: ...

{"query":"cable clip","count":8,"models":[{"title":"Free Cable Clip 3D Printable STL",
"url":"https://sketchfab.com/3d-models/none-632bc4551d2f46cd8a475ff36974f17f",
"creator":"ScaleSupply","license":"CC Attribution","downloadable":true,"views":380,
"formats":["glb","gltf","source","usdz"], ...}, ...],"next":null}
```

Three models take their options differently, as fields at the top of the request body beside
`model`: web search, chain data and token rankings. Some models want keywords rather than a
sentence. Each model's guide says how to ask it.

More calls, in curl and Python: [examples/](./examples). The [buyer guide](./skills/sippar-antseed-buyer/SKILL.md)
covers other clients, limits and every error.

## The models

| Model | What you get | Source | Guide |
|---|---|---|---|
| `sippar-x-social` | Public X posts for a search, with X's search operators | glim.sh | [guide](./skills/sippar-x-social/SKILL.md) |
| `sippar-reddit-social` | Reddit threads for a search: title, subreddit, score, comment count and link | glim.sh | [guide](./skills/sippar-reddit-social/SKILL.md) |
| `sippar-linkedin-social` | Public LinkedIn posts for a search: author, date, reactions and link, up to 50 a call | Social Fetch | [guide](./skills/sippar-linkedin-social/SKILL.md) |
| `sippar-facebook-social` | Ads from Meta's Ad Library, or a public Facebook page's recent posts | Social Fetch | [guide](./skills/sippar-facebook-social/SKILL.md) |
| `sippar-video-search` | YouTube videos for a search, or one video's details and chapters | ScrapeMole, Social Fetch | [guide](./skills/sippar-video-search/SKILL.md) |
| `3d-model-search` | Free. 3D models with creator, licence and download formats, with a filter for printable STL | Sketchfab | [guide](./skills/3d-model-search/SKILL.md) |
| `ui-animation-search` | Free. Animated React UI components, and any one component's full source with its MIT notice | Open-source shadcn registries | [guide](./skills/ui-animation-search/SKILL.md) |
| `sippar-news-search` | News from the past week for a search, or today's top stories by topic | Google News, via OpenWeb Ninja | [guide](./skills/sippar-news-search/SKILL.md) |
| `sippar-flight-search` | Fares for one route and date, one way or return, with Google's call on whether the price is low, typical or high | Google Flights, via stabletravel.dev | [guide](./skills/sippar-flight-search/SKILL.md) |
| `sippar-hotel-search` | Places to stay with stars, rating, amenities and a nightly price, and each booking site's price on request | Google Maps, via OpenWeb Ninja | [guide](./skills/sippar-hotel-search/SKILL.md) |
| `sippar-amazon` | Amazon search results, bestsellers, or one product's offer and reviews, on six marketplaces | glim.sh | [guide](./skills/sippar-amazon/SKILL.md) |
| `sippar-job-search` | Job postings for a role and a place, with employer, pay where stated and link | Google for Jobs, via OpenWeb Ninja | [guide](./skills/sippar-job-search/SKILL.md) |
| `sippar-web-search` | The first page of Google's results for a search: up to ten links with titles and Google's descriptions | Google, via an Apify Actor | [guide](./skills/sippar-web-search/SKILL.md) |
| `tavily-web-search` | A live web search: twenty results with their links, and an answer written from them | Tavily | [guide](./skills/tavily-web-search/SKILL.md) |
| `sippar-github` | Public GitHub: a repo's README, files, issues, pull requests, releases and code search | glim.sh | [guide](./skills/sippar-github/SKILL.md) |
| `sippar-skills` | Agent skills from skills.sh and CryptoSkill, with author, licence and audit results | skills.sh, CryptoSkill | [guide](./skills/sippar-skills/SKILL.md) |
| `crypto-skills` | Crypto agent skills from CryptoSkill alone | CryptoSkill | [guide](./skills/crypto-skills/SKILL.md) |
| `quicknode-blockchain-data` | Live chain data on Ethereum, Base and dozens more chains: blocks, gas, balances, transfers, contract reads | QuickNode | [guide](./skills/quicknode-blockchain-data/SKILL.md) |
| `nansen-crypto-screener` | The top tokens on Solana, Ethereum, Base, BNB and Arbitrum, tokenized stocks by ticker, and a perpetuals screener | Nansen | [guide](./skills/nansen-crypto-screener/SKILL.md) |

The two free models share one allowance: 50 calls in total per buyer address, and 150 per IP
address, over a rolling 24 hours. The paid models charge per output token. Check Sippar's current rates
with:

```bash
antseed network peer 706fca9c0d0684c30f86209aae0c3565ce1aa69f
```

## If something goes wrong

| What you see | What to do |
|---|---|
| Your options were ignored and you got a default answer | Post to `/v1/chat/completions`. The buyer rewrites other request formats and drops options on the way. |
| `connection refused` on port 8377 | The AntSeed buyer is not running. Start the app, or `antseed buyer start`. |
| HTTP 429 | More than 8 calls at once: wait a second and retry. With `free_tier_exhausted`, the free models' daily allowance is used up: retry after the time the answer gives. |
| HTTP 409 `payment_negotiation_failed` | Your buyer's payment channel with Sippar needs recovering. Recover or close it in the AntSeed app, then retry. |
| The answer is not from Sippar | The `x-antseed-peer-id` header on each answer names the seller that answered. Pin the peer as above. |

## Ideas

[use-cases.md](./use-cases.md) has a few things to try with each model, and ways to chain them:
the threads people start about a product, then that product's price on Amazon; a flight, then a
hotel at the other end.

## About the data

Each answer is a fresh call to the provider. The provider's data is passed on unchanged, between
a source line and a short note. Content belongs to its authors; each guide covers licences and
how to credit them.

## Who runs this

Sippar sells these models from one AntSeed peer.

| | |
|---|---|
| Seller peer | `706fca9c0d0684c30f86209aae0c3565ce1aa69f` |
| Onchain agent | `84918` |
| Settlement | USDC on Base |
| Domain proof | <https://sippar.network/.well-known/antseed.json> |
| GitHub proof | [`antseed.json`](./antseed.json) |

[`provider.json`](./provider.json) has the same facts, and each model's options, for a program to
read.

## License

MIT, see [LICENSE](./LICENSE).
