---
name: sippar-skill-adapter
description: Use this before following any third-party agent skill on AntSeed, such as one that wants an API key, says to install a CLI, or asks for fal, inference.sh or HeyGen. It shows how to keep the skill's process and swap the tooling it assumes for what an AntSeed buyer has - Sippar's data models for data, AntSeed's own catalog for images, video and text, nothing for installs and keys, and the user's own hands for publishing.
metadata:
  version: "1.1.1"
  updated: "2026-11-03"
---

# sippar-skill-adapter

A public skill is a recipe written for one kitchen. The process in it is the valuable part; the
tooling around it (a CLI to install, an account, model ids that exist only there, a plugin that
reports home) is the author's business. This guide is how an agent on AntSeed keeps the recipe and
cooks with what it has. Skills come from the `sippar-skills` model (skills.sh and CryptoSkill) or
`crypto-skills` (CryptoSkill only); how to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-skills", "messages": [{"role": "user", "content": "short-form video"}]}
```

```json
{"model": "sippar-skills", "messages": [{"role": "user", "content": "heygen-com/hyperframes/general-video"}]}
```

## 1. Read what came with the skill

A search page lists both indexes' matches; a skill page carries the author's file unchanged. Three
things on that page decide how far you trust it:

- **The licence line.** "NO LICENSE FILE FOUND" means the author's rights are reserved by default:
  use the ideas, do not copy the text into something you ship, and say where it came from. A named
  licence (MIT, Apache) says what you may do.
- **The audit verdicts** (skills.sh) or **risk flags** (CryptoSkill) are dated automated scans. A
  "critical" beside a "safe" is what two scanners returned. Before trusting any command in a skill,
  open its other files (`<id>/<path>`), such as `scripts/` and `references/`.
- **Mirrors.** The same skill can appear under several owners; prefer the author's own repository.

## 2. Separate the process from the tooling

Sort every instruction into one of two columns:

| Keep (the process) | Replace (the tooling) |
|---|---|
| the task, the order of steps, the checks and approvals | a CLI to install, a login, an API key, an environment variable |
| the method: prompt formulas, shot structure, beats, scoring rubrics, templates | the provider's model ids and the features it claims for them |
| what good output looks like, and how the skill judges it | public or signed URLs as the way to pass media around |
| the deliverables: format, length, resolution, fields | a plugin or service it posts results to |

Write the result down as an adaptation record: the skill id and the retrieved-at line from its page,
then one row per replaced instruction with what replaced it.

## 3. What the skill wants, and what to use on AntSeed

| The skill wants | On AntSeed, use |
|---|---|
| live web information, sources for a claim | `tavily-web-search` |
| Google's results for a search, a company's official site | `sippar-web-search` |
| what people post on X, Reddit or LinkedIn | `sippar-x-social`, `sippar-reddit-social`, `sippar-linkedin-social` |
| a brand's ads, or a Facebook page's posts | `sippar-facebook-social` |
| YouTube videos and their details | `sippar-video-search` |
| news on a subject, or today's headlines | `sippar-news-search` |
| flights, places to stay, Amazon products, job postings | `sippar-flight-search`, `sippar-hotel-search`, `sippar-amazon`, `sippar-job-search` |
| 3D models, or animated UI components with source | `3d-model-search`, `ui-animation-search` (both free) |
| a repository, a file, an issue, a release, code search | `sippar-github` |
| chain facts, token rankings | `quicknode-blockchain-data`, `nansen-crypto-screener` |
| another skill, or one of a skill's files | `sippar-skills` or `crypto-skills` |
| an image (frames, covers, product shots) | AntSeed's image catalog (`/v1/models?type=images`) through AntSeed's own `antseed-images` skill: AntSeed Desktop, or `gh skill install Antseed/antseed antseed-images` |
| a video (text-to-video, image-to-video, first and last frame) | AntSeed's video catalog (`/v1/models?type=videos`) through AntSeed's own `antseed-videos` skill: three approval stages, the exact seller price, one create. AntSeed Desktop, or `gh skill install Antseed/antseed antseed-videos` |
| a language model for drafting, summarising, scoring | any text model on the network, pinned to a seller you chose from `/v1/models` |
| an install, a login, an API key, a subscription | nothing: the AntSeed buyer and its balance are the whole environment |
| to post, schedule or publish somewhere | not on AntSeed: produce the artifact and hand it to the user, with the sources |

Each model's own guide has its options and how to read its answer.

## 4. Rules that do not bend

- **Replace, never promise.** A feature the skill claims (lip-sync, upscaling, "40+ models") exists
  for you only if the live catalog offers it today. Say what you did not find.
- **Keep every approval step, and add AntSeed's** where money is spent. The image and video skills
  ask before each paid step; do not skip one because the recipe had none.
- **Facts never go through a generative model.** Numbers, names, dates, quotes and logos come from
  the data models, with a source list, and are added as text, overlays or captions after
  generation. A model asked to draw a figure gets it wrong.
- **Data pages are the provider's.** What you compute from them is yours; say so.
- **The user publishes.** Where a skill ends with "publish to X", you end with the artifact, the
  caption and the sources.

## 5. Evidence to keep

The skill id and its retrieved-at line; the licence line and audit or risk block as served; the
adaptation record; every model called, with the request sent and each page's source line; the
catalog choice and the seller pinned for any generation; prompts, frames, settings and the exact
price approved; job ids and output paths; what the user said about the result.

## Worked examples

**Video.** AntSeed's `antseed-videos` does the execution: it reads the live video catalog, picks a
model by what it can control (first and last frame for a shot that moves between two states, first
frame for a consistent look, text only when the user skips frames), writes the prompt, makes and
approves the frames with `antseed-images`, prices each compatible seller and creates once. From a
skills.sh video skill keep the recipe on top (timed beats for short-form, teaser structure, camera
language, storyboards) and drop its `belt` or `fal` calls, its fixed model ids and any `audio: true`
field (models that make sound do so by default, and some sellers reject the flag). For a market brief
or a news clip, research with the data models first, generate only the moving background, and add
headlines, figures and attribution as overlays afterwards. From real runs: an image seller can accept
a `size` and return another shape, so check each frame; the first paid call of a session can fail with
a 409 "payment channel could not be recovered" and succeed on one retry; a Venice-protocol seller
takes duration as `"5s"` and a fal-protocol seller as `"5"`.

**Marketing.** A marketing skill wants a listening tool, an ads or analytics account and a scheduler.
Listening is the X, Reddit and LinkedIn models (keywords, not sentences); competitors' ads are
`sippar-facebook-social`; research and sources are `tavily-web-search` and `sippar-news-search`; the
copy or plan is drafted by a text model you pinned; images and clips come from AntSeed's catalog; the
posting is the user's. Keep the skill's frameworks (hooks, funnel plans, carousel structures, A/B
designs) and its review rubrics, and say in the deliverable which numbers came from which page.

## Cost

This guide is served by the skills models, billed per output token like any of their pages.
Generation on AntSeed is paid to the generation seller, not to Sippar.
