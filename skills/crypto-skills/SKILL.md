---
name: crypto-skills
description: Use this when you need instructions for a crypto protocol or task (a skill such as chains/aave or a uniswap swap), or Sippar's own skill for one of its models, without leaving AntSeed. Sippar's crypto-skills model on AntSeed serves CryptoSkill's registry of crypto agent skills by id, by search and file by file, each as its author published it, with the author, licence and CryptoSkill's risk flags.
metadata:
  version: "2.2.1"
  updated: "2026-11-03"
---

# crypto-skills

Agent skills, served as their authors published them, from two sources read fresh on every call.
`sippar-skills` is a separate model, the aggregator that adds skills.sh; this one serves CryptoSkill
and Sippar's own skills only. How to reach the seller is in the `sippar-antseed-buyer` skill.

- **CryptoSkill's registry** (cryptoskill.org): crypto agent skills across chains, DeFi, exchanges,
  wallets, trading and more.
- **Sippar's own skills**: listed and searched are `sippar-antseed-buyer`,
  `quicknode-blockchain-data`, `nansen-crypto-screener`, `tavily-web-search`, `crypto-skills`,
  `sippar-skills` and `sippar-skill-adapter`. The other models' skills (`sippar-x-social`,
  `sippar-flight-search`, `sippar-linkedin-social`, `sippar-github`, `sippar-reddit-social`,
  `sippar-hotel-search`, `sippar-amazon`, `sippar-facebook-social`, `sippar-news-search`,
  `sippar-job-search`, `sippar-video-search`, `sippar-web-search`, `3d-model-search`,
  `ui-animation-search`) open when you
  send the exact name. The earlier names `sippar-chain-state` and `onchain-token-rankings` fetch the
  same files.

## Try it

```json
{"model": "crypto-skills", "messages": [{"role": "user", "content": "uniswap swap"}]}
```

## How to ask

The last user message is matched literally. Send a skill name, an id, a file path, or two or three
keywords, never a sentence: a search needs every word to appear in an entry, so a sentence matches
nothing and is still billed.

| Send as the whole message | You get |
|---|---|
| one of our skill names, such as `quicknode-blockchain-data` | that skill's `SKILL.md` |
| a CryptoSkill id, `category/name`, such as `chains/aave` | its `SKILL.md` and `SOURCE.md`, risk-index entry, quality score and the list of its other files |
| a file inside a skill, `category/name/<path>`, such as `analytics/fomo-research/references/api.md` | that one file, with whether it matches CryptoSkill's recorded checksum |
| two or three keywords, such as `uniswap swap` or `aave` | a search, 10 entries a page (each word matched at the start of a word), and on page 1 any of Sippar's own skills that match |
| `{"query": "uniswap swap", "page": "2"}` | the next 10 entries |

A single word is a search, even a skill's name: `aave` lists entries, `chains/aave` opens the skill.
To open an entry from a search, build its id from the entry's own `category` and `name`.

## Reading the answer

Every page opens with a source line (where the text came from, when, the request) and ends with a
line on what the model is for, how to ask, and on a third-party page a disclaimer.

- **One skill:** each file under a `----- path (url) -----` line, `SKILL.md` then `SOURCE.md` (the
  original author, the source and the licence); then CryptoSkill's risk-index entry (flags such as
  `can_move_funds`, `requires_private_key`), its index entry with the quality `score`, and every
  recorded file with its SHA-256. A file the registry does not have is named on a "Not found" line.
- **One file:** the file as published, with whether its SHA-256 matches. A binary file, or one over
  48 KB, is described with its link instead.
- **A search:** how many entries matched and which are shown, then the entries as JSON, then what to
  send for the next page, and on page 1 Sippar's matching skills.
- **No match:** a short page saying so; try fewer or different words.

## Limits and caveats

- A skill is instructions your agent will follow, so read it before you run it. The third-party
  skills come from authors Sippar does not know and has not checked; read the risk flags first, and
  never let an unread skill move money, use a key or change files.
- The score and risk flags are CryptoSkill's automated heuristics, not audits. A capability shown as
  false is weak evidence, not proof.
- Sippar does not write, review, rank or filter the third-party skills.
- Some skills are thin: a `SKILL.md` can be a header and a link, with the substance in other files.
- A skill carries no live data. For the numbers it names, call the data model: chain facts from
  `quicknode-blockchain-data`, token rankings from `nansen-crypto-screener`, current web information
  from `tavily-web-search`. For example, the `chains/base` skill names gas prices and block numbers;
  `quicknode-blockchain-data` with `"network": "base"` and
  `"fields": ["gasPrice", "baseFeePerGas", "blockNumber"]` returns them.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A page's width is the files its author wrote.
Measured 2026-10-08: our skills about 1,800 to 2,300 tokens; `chains/aave` about 2,200; a 10-entry
search about 3,700; a no-match page about 200. One CryptoSkill page passed 17,000 tokens, and a
search entry does not show a skill's size. Every page is billed, a greeting and a no-match page
included.
