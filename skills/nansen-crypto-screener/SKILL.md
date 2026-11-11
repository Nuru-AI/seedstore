---
name: nansen-crypto-screener
description: Use this when you need the top token contracts on Solana, Ethereum, Base, BNB, Arbitrum or Sui, ranked by value, volume, net flow, liquidity or price change over a window you choose; named tickers such as tokenized stocks (TSLAX, NVDAX); or Nansen's Hyperliquid perpetuals screener. Sippar's nansen-crypto-screener model on AntSeed returns Nansen's data with Nansen's attribution. It also answers as onchain-token-rankings.
metadata:
  version: "3.4.0"
  updated: "2026-11-11"
---

# nansen-crypto-screener

The top token contracts across chains, from Nansen, with the attribution Nansen requires on every
page. The earlier id `onchain-token-rankings` answers with the same data, options and rate. How to
reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "nansen-crypto-screener", "messages": [{"role": "user", "content": "top tokens"}]}
```

The default page: all five main chains together, the last 24 hours, ranked by fully diluted value,
25 rows.

## How to ask

This model takes its options as top-level fields beside `messages`, or, from a chat box where
only the message can be typed, as the whole message in JSON (a top-level field wins when both are
sent). All are optional:

| Field | Values | Default |
|---|---|---|
| `chains` | any of `solana`, `ethereum`, `base`, `bnb`, `arbitrum`, `sui`; a list or a comma string | the first five |
| `timeframe` | `5m`, `10m`, `1h`, `6h`, `24h`, `7d`, `30d` | `24h` |
| `sort` | `fdv`, `volume`, `netflow`, `liquidity`, `priceChange`, `buyVolume`, `sellVolume`; largest first | `fdv` |
| `rows` | 5 to 50 (from 10 when more than five chains are named) | 25 |
| `symbols` | up to 25 token symbols, such as `TSLAX`; a list or a comma string; a leading `$` is fine | none |
| `view` | `perp-screener` | none |

`timeframe` is the window for volume, buy and sell volume, net flow and price change. Fully diluted
value, market cap and liquidity are read at the moment you ask.

Ten rows by volume on Base and Solana over a week:

```json
{"model": "nansen-crypto-screener", "chains": ["base", "solana"], "timeframe": "7d",
 "sort": "volume", "rows": 10, "messages": [{"role": "user", "content": "top tokens"}]}
```

The same kind of request typed into a chat box, as the whole message. Leave `query` out: a message
that carries `query` is read as words, and its other keys are not read:

```json
{"chains": ["base"], "sort": "volume", "rows": 5}
```

Five tokenized stocks on Solana, by volume:

```json
{"model": "nansen-crypto-screener", "symbols": ["TSLAX", "NVDAX", "SPYX", "GOOGLX", "CRCLX"],
 "chains": ["solana"], "sort": "volume", "rows": 5, "messages": [{"role": "user", "content": "stocks"}]}
```

The perpetuals screener; `view` goes alone, with none of the other fields:

```json
{"model": "nansen-crypto-screener", "view": "perp-screener",
 "messages": [{"role": "user", "content": "perps"}]}
```

Through a client that rewrites requests, the same fields go under `metadata.sippar` or as
`x-sippar-chains`, `x-sippar-timeframe`, `x-sippar-sort`, `x-sippar-rows`, `x-sippar-symbols` and
`x-sippar-view` headers.

## Reading the answer

**The ranked page** is a markdown table, the same rows as JSON beneath it, then Nansen's attribution,
a guide line and a disclaimer. Parse the JSON and keep the lines. Each row has `priceUsd`,
`marketCapUsd`, `fdvUsd`, `volume24hUsd`, `netflowUsd24h`, `liquidityUsd`, `change24hPct`, the chain
and the contract. The JSON also names what you were served: `chainsCovered`, `timeframe`, `slots`
(the rows you asked for) and `ranking.requestedSort` (in Nansen's column names, so `priceChange`
reads `price_change DESC`). `pageRowsReturned` and `pageSize` describe the page bought upstream and
can read 25 on a page you narrowed to 10. A `symbols` page adds `symbolsRequested` and
`symbolsNotFound`.

**The perpetuals page** has no table: one source line, Nansen's JSON as it arrived, a closing line
and a disclaimer. A parser written for the ranked page does not fit it.

Both pages keep the wash-trading and other notes Nansen attaches. Keep them.

## Limits and caveats

- `symbols` narrows which rows can appear; it does not change the order, and `rows` still sets the
  length. A ticker with no row is named under the table and in `symbolsNotFound`.
- The match is on the token's symbol, and two contracts can share one. Check the `address` you get.
- A token with less than $1M of trading-pool liquidity does not appear.
- A tokenized stock's price is the token's own on-chain price, not an exchange quote, and it can
  drift while markets are closed. Issuers that reinvest dividends make one token stand for slightly
  more than one share; the page's disclaimer says so.
- A value outside the lists above, or any field beside `view`, is refused with a free 400 that says
  what is accepted.
- `x-antseed-required-parameters` may name only the fields above; requiring `network` or `fields`
  here refuses every call.

## Cost

Per output token, at the rate on Sippar's peer record. Fewer `rows` bill fewer tokens. A refusal
bills nothing on an open payment channel.
