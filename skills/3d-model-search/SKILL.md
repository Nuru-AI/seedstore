---
name: 3d-model-search
description: Search public 3D models on Sketchfab, or read one model's details, through Sippar's 3d-model-search model on AntSeed. Use it when an agent on AntSeed needs 3D models that match a search (title, link, creator, licence, thumbnail, downloadable or not, face and vertex counts, views, likes, file formats offered) or one model's licence terms, downloads, materials and textures. Filters narrow a search to a licence, to downloadable models, to models uploaded as STL or another file type, or to one category. It returns no files and no descriptions. Triggers on - 3D model search on AntSeed, find a 3D model of X, printable STL of X, CC0 3D models, CC-BY models I can use commercially, Sketchfab models, a model's licence, 3d-model-search.
metadata:
  version: "1.1.1"
  updated: "2026-10-28"
---

# 3d-model-search

Public 3D models on Sketchfab, two ways. Send search words and you get up to 24 matching models,
each with its title, link, creator, licence, a thumbnail, whether Sketchfab lets account holders
download it, face and vertex counts, animations, views, likes, publish date, categories, tags and
the file formats Sketchfab offers. Send one model's link and you get that model's details: the
licence and its terms, downloads, comment count, materials, textures and dates. No file and no
description is on any page: open the link to see the model, and download it on Sketchfab with a
Sketchfab account. Transport (pin, request shape, the 8-in-flight limit) is in the
`sippar-antseed-buyer` skill; read it first. Model string: `3d-model-search`.

## How to ask

The last user message is one plain line: search words, or one model's link.

```json
{"model": "3d-model-search",
 "messages": [{"role": "user", "content": "cable clip"}]}
```

```json
{"model": "3d-model-search",
 "messages": [{"role": "user", "content": "https://sketchfab.com/3d-models/cable-clip-6200ffa5fd6b446fb9611a6552c84a43"}]}
```

- **A model link asks for that model's details.** `sketchfab.com/3d-models/<name>-<id>`,
  `sketchfab.com/models/<id>` and `/models/<id>/embed` are accepted. Any other Sketchfab link (a
  user, a collection) is refused with an error and bills nothing. Anything else is a search, up to
  200 characters.
- **Filters go inside the message text, as JSON.** `query` carries the search words, beside any of
  these, each one of Sketchfab's own search parameters:
  - `downloadable`: `true` for models Sketchfab lets account holders download.
  - `file_format`: the file type the creator uploaded, such as `stl`, `obj` or `fbx`.
  - `license`: `cc0`, `by`, `by-sa`, `by-nd`, `by-nc`, `by-nc-sa`, `by-nc-nd`, `ed` (editorial) or
    `st` (standard).
  - `sort_by`: `likeCount`, `viewCount`, `publishedAt` or `processedAt`, with a leading `-` for
    descending (`-likeCount`). Omit it for relevance.
  - `categories`: one Sketchfab category, such as `electronics-gadgets`, `furniture-home` or
    `cars-vehicles`.
  - `cursor`: the `next.cursor` value from the previous page, for the next 24.

  `{"query": "cable clip", "file_format": "stl", "downloadable": "true"}`. Do not put filters at
  the top level of the request body: this model announces no parameters.
- **For something to 3D-print, ask for STL uploads that can be downloaded.** A plain search for
  `cable clip` returned 24 models, 9 of them downloadable, several of them render assets rather
  than printable parts. The same words with `file_format: stl` and `downloadable: true` returned 8,
  every one a downloadable CC Attribution model, titles such as `Free Cable Clip 3D Printable STL`.
  A test agent asked for `phone stand` the same way and got a full 24, every one downloadable: 20
  `CC Attribution`, 3 `Free Standard`, 1 `CC Attribution-NonCommercial`. You get the file on the
  model's Sketchfab page, with a Sketchfab account.
- **A filter that is not one of the values above is refused** with an error naming the allowed
  values, and nothing is billed. So is a filter sent with a model link.

Do not send `x-antseed-required-parameters` on this model. It announces no parameters, so
requiring any name refuses every call.

## Reading the page

The page opens with one source line: `Source: Sketchfab (public 3D models), GET <endpoint>,
retrieved <time>. Request sent: {…}.` Then a blank line, the JSON on one line, a closing line on
how to ask, and a line saying the models are provided by Sketchfab. The first `{` on the page is
the request echo, so parse the first JSON value after the blank line:

```python
import json
# page = the answer text, e.g. response.choices[0].message.content
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
if "models" in data:                       # a search
    models = data["models"]
    next_cursor = (data["next"] or {}).get("cursor")
else:                                      # a model's details
    model = data["model"]                  # None when data["found"] is false
```

### A search

`{"query": …, "count": …, "models": [...], "next": {"cursor": "24"} | null}`. `count` is how many
models came back, up to 24. `next` is null on the last page. A search that finds nothing comes back
as a short page with `"models": []`. Each model:

- `title`, `url` (Sketchfab's own link; `…/3d-models/none-<id>` redirects to the model page),
  `creator`, `creatorUsername` and `creatorUrl`.
- `license`: the licence label, such as `CC Attribution`, `CC0 Public Domain` or `Standard`.
  **It is `null` on a model Sketchfab does not offer for download**: on the first `cable clip`
  page, 13 of 24 rows had no licence, and none of the 13 was downloadable. Do not read a null as
  "free to use".
- `thumbnail`: one Sketchfab image of the model, about 640 pixels wide. Null on an age-restricted
  model.
- `downloadable`, `faces`, `vertices`, `animations`, `views`, `likes`, `publishedAt`.
- `categories` and `tags`: as the creator set them; often empty (9 of 24 rows had no tags).
- `formats`: the download packages Sketchfab holds for the model, usually `glb`, `gltf`, `source`
  and `usdz` (`extra` on some). **`stl` never appears here, even on a search filtered with
  `file_format: stl`**: the filter matches the file type the creator uploaded, and this list names
  Sketchfab's packages, not that type. Sketchfab's API documentation does not say what `source`
  holds. Every downloadable model we read listed packages, but so did five that were not
  downloadable, so check `downloadable`, not this list.
- `ageRestricted`.

**What each licence allows, in Sketchfab's words** (`GET /v3/licenses`, read 2026-10-24). A model's
details page carries its own line as `licenseRequirements`; read that before you use a model.

| `license` | Sketchfab's terms |
|---|---|
| `CC Attribution` | Author must be credited. Commercial use is allowed. |
| `CC Attribution-ShareAlike` | Author must be credited. Modified versions must have the same license. Commercial use is allowed. |
| `CC Attribution-NoDerivs` | Author must be credited. Modified versions can not be distributed. Commercial use is allowed. |
| `CC Attribution-NonCommercial` (and its `-ShareAlike`, `-NoDerivs` forms) | Author must be credited. No commercial use. |
| `CC0 Public Domain` | Credit is not mandatory. Commercial use is allowed. |
| `Standard`, `Free Standard` | Under basic restrictions, use worldwide, on all types of media, commercially or not, and in all types of derivative works |
| `Editorial` | Use only in connection with events that are newsworthy or of public interest |

The `license` filter takes the short codes listed under How to ask; Sketchfab's search does not
list one for `Free Standard`.

**The order is Sketchfab's, and relevance is loose.** The `cable clip` search held a coffee-can
amplifier and, on page 2, a neon typography set. Titles come in other languages too (`Clip para
cables`, `Clips de câble`). Check each title against your words before you use a row.

### A model's details

`{"found": …, "model": {...}}`. `found` is false, and `model` null, when Sketchfab has no public
model at that link. On `found`, the row fields above, plus:

- `licenseRequirements`: the licence's terms in Sketchfab's words (`Author must be credited.
  Commercial use is allowed.`), and `licenseUrl` when Sketchfab gives one (null on the CC
  Attribution model we read).
- `downloads`, `comments` (a count), `materials`, `textures`, `updatedAt`.
- `formats` is null: Sketchfab's details call does not list file formats. Take them from the
  model's search row.

Models are provided by Sketchfab, and each belongs to its creator under the licence shown with it.
Credit the creator and give the link when you use a model. Not affiliated with Sketchfab. Not
advice.

## Cost

Free: 0 input and 0 output on the peer record since 2026-10-28. The free allowance is 50 requests per buyer address and 150 per IP over a sliding
24 hours, shared with Sippar's other free model, ui-animation-search. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. Page sizes, measured
2026-10-24 through the network (the token counts add up to the buyer's own ledger, $0.132252 for
the four): a plain 24-model search 4,368 tokens; page 2 4,257; the STL filter search with 8
models 1,808; a model's details 588. Through the seller's own shim the same day: full searches
4,099 to 5,241, an empty search 329, a link with no model 314. From a second buyer on the network the same day: a 24-model STL search 4,519 tokens, two
models' details 631 and 657. A refused line bills nothing.

## Changes

- 1.1.1 (2026-11-02): the guide no longer prints the rate before the model went free.
- 1.1.0 (2026-10-28): the model is free, under a 50-a-day allowance per buyer address.
- 1.0.0 (2026-10-24): first publish.
