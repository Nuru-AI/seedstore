---
name: sippar-skills
description: Use this when you need an agent skill for a task (video, marketing, code, research, a crypto protocol) or Sippar's own skill for one of its models, without leaving AntSeed. Sippar's sippar-skills model on AntSeed serves skills from skills.sh and CryptoSkill's registry as their authors published them, by id, by one search across all of them and file by file, with the author, licence and audit or risk verdicts on every page.
metadata:
  version: "1.2.0"
  updated: "2026-11-08"
---

# sippar-skills

Agent skills, served as their authors published them, from three sources read fresh on every call.
Its sibling `crypto-skills` serves CryptoSkill and Sippar's own skills only; this model adds
skills.sh. How to reach the seller is in the `sippar-antseed-buyer` skill.

- **skills.sh** (Vercel's Agent Skills Directory): agent skills across every domain, each served
  from its author's GitHub repository with the repository's licence line and skills.sh's three audit
  verdicts (Gen Agent Trust Hub, Socket, Snyk).
- **CryptoSkill's registry** (cryptoskill.org): crypto skills across chains, DeFi, exchanges, wallets
  and trading, each with its `SOURCE.md`, quality score and risk flags.
- **Sippar's own skills**: `sippar-antseed-buyer`, `quicknode-blockchain-data`,
  `nansen-crypto-screener`, `tavily-web-search`, `crypto-skills`, `sippar-skills` and
  `sippar-skill-adapter`, and each other model's skill (`sippar-x-social`, `sippar-flight-search`,
  `sippar-linkedin-social`, `sippar-github`, `sippar-reddit-social`, `sippar-hotel-search`,
  `sippar-amazon`, `sippar-facebook-social`, `sippar-news-search`, `sippar-job-search`,
  `sippar-video-search`, `sippar-web-search`, `sippar-instagram-social`, `sippar-tiktok-social`,
  `3d-model-search`, `ui-animation-search`), found by a search or by exact
  name. The earlier names `sippar-chain-state` and `onchain-token-rankings` fetch the same files.

## Try it

```json
{"model": "sippar-skills", "messages": [{"role": "user", "content": "video generation"}]}
```

## How to ask

Send a skill name, an id or a file path to open it. Anything else is a search: describe the job in a
sentence, such as `make a product video from a few photos`, or send a few words.

| Send as the whole message | You get |
|---|---|
| one of our skill names, such as `sippar-skill-adapter` | that skill's `SKILL.md` |
| a skills.sh id, `owner/repo/skill`, such as `heygen-com/hyperframes/general-video` | its `SKILL.md`, the repository's licence line, skills.sh's audit verdicts, and how to fetch its other files |
| a file inside a skills.sh skill, `owner/repo/skill/<path>` | that one file |
| a CryptoSkill id, `category/name`, such as `chains/aave` | its `SKILL.md` and `SOURCE.md`, risk-index entry, quality score and the list of its other files |
| a file inside a CryptoSkill skill, `category/name/<path>` | that one file, with whether it matches CryptoSkill's recorded checksum |
| a sentence describing the job, or a few words such as `video generation` or `aave lending` | one list of 10 skills from skills.sh, CryptoSkill and Sippar's own, best match first |
| `{"query": "video generation", "page": "2"}` | the next 10 |

A single word is a search, even a skill's name: `aave` lists entries, `chains/aave` opens the skill.
Open a search result by the `id` it prints.

## Reading the answer

Every page opens with a source line (where the text came from, when, the request) and ends with a
line on what the model is for, how to ask, and on a third-party page a disclaimer.

- **One skills.sh skill:** the `SKILL.md` under a `----- path (url) -----` line, then
  `License: "<first line of the repository's licence file>"` or `License: NO LICENSE FILE FOUND`,
  then the audit verdicts as JSON (`ath`, `socket`, `snyk`, each with a risk and a date, or `null`),
  then how to fetch the rest.
- **One CryptoSkill skill:** each file under a `----- path (url) -----` line (`SKILL.md`, then
  `SOURCE.md` with the original author, source and licence), then the risk-index entry (flags such as
  `can_move_funds`, `requires_private_key`), the index entry with its `score`, and every recorded file
  with its SHA-256.
- **One file:** the file as published. A binary file, or one over 48 KB, is described with its link
  instead.
- **A search:** the source line, what the request was read as (an area such as `video` and a job
  such as `create`), how many skills were weighed, then the results as JSON, best match first: `n`,
  `id`, `source` (skills.sh, CryptoSkill or Sippar), `name`, the author's own `description` read
  fresh for this page, `installs` (skills.sh), `cryptoskillScore` (CryptoSkill's quality score) and
  `sameSkillInOtherRepos` (copies of the same skill under other owners). When there are more, the
  page says what to send next.
- **Your words:** a search's words are sent to an outside AI decision service, only to choose which
  skills it shows.

## Limits and caveats

- A skill is instructions your agent will follow, so read it before you run it. The third-party
  skills come from authors Sippar does not know and has not checked. Check the author, licence and
  verdicts, and never let an unread skill move money, use a key or change files.
- The verdicts are automated scans, not reviews; a "safe" beside a "critical" is what the tools
  returned. "NO LICENSE FILE FOUND" means the author's rights are reserved by default.
- Sippar does not write or review the third-party skills. The search chooses which to show; each
  file arrives as its author published it.
- Some skills are thin: a `SKILL.md` can be a header and a link, with the substance in other files.
  The same skill can appear under several owners on skills.sh; a search shows the most installed
  copy and lists the others.
- A skill carries no live data or model. To run one on AntSeed, keep its process and swap its tooling
  for Sippar's models and AntSeed's catalog, as the `sippar-skill-adapter` skill describes.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A page's width is the files its author wrote.
Measured 2026-10-10: our skills about 2,300 to 2,800 tokens; a skills.sh skill page 2,500 to 6,000; a
no-match page about 260; measured 2026-11-08, a 10-result search 1,400 to 2,000. Some skills are much wider
(one CryptoSkill page passed 17,000 tokens), and a search entry does not show a skill's size. Every
page is billed, a greeting and a no-match page included.
