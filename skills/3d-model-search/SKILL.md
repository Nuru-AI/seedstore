---
name: 3d-model-search
description: Use this when you need 3D models that match a search, such as something to 3D-print, a CC0 or commercial-use model, or a model in one category, or one model's licence terms, downloads, materials and textures. Sippar's free 3d-model-search model on AntSeed searches Sketchfab, with filters for licence, downloadable models, uploaded file type (such as STL) and category. It returns no files and no descriptions.
metadata:
  version: "1.2.0"
  updated: "2026-11-03"
---

# 3d-model-search

Public 3D models on Sketchfab, two ways: search words return up to 24 matching models, and one
model's link returns its details. No file and no description is served; open the link to see a model,
and download it on Sketchfab with a Sketchfab account. Free on AntSeed. How to reach the seller is in
the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "3d-model-search", "messages": [{"role": "user", "content": "cable clip"}]}
```

```json
{"model": "3d-model-search", "messages": [{"role": "user", "content": "https://sketchfab.com/3d-models/cable-clip-6200ffa5fd6b446fb9611a6552c84a43"}]}
```

## How to ask

The last user message is search words (up to 200 characters), or one model's link
(`sketchfab.com/3d-models/<name>-<id>`, `sketchfab.com/models/<id>` or `/models/<id>/embed`).

Search filters go inside the message text, as JSON, beside `query`. Each is one of Sketchfab's own
search parameters:

| Field | Values |
|---|---|
| `downloadable` | `true` for models Sketchfab lets account holders download |
| `file_format` | the file type the creator uploaded, such as `stl`, `obj` or `fbx` |
| `license` | `cc0`, `by`, `by-sa`, `by-nd`, `by-nc`, `by-nc-sa`, `by-nc-nd`, `ed` (editorial) or `st` (standard) |
| `sort_by` | `likeCount`, `viewCount`, `publishedAt` or `processedAt`, with a leading `-` for descending; leave it out for relevance |
| `categories` | one Sketchfab category, such as `electronics-gadgets` or `furniture-home` |
| `cursor` | the next 24: the `next.cursor` value from the previous answer |

For something to 3D-print, ask for STL uploads that can be downloaded:

```json
{"model": "3d-model-search",
 "messages": [{"role": "user", "content": "{\"query\": \"cable clip\", \"file_format\": \"stl\", \"downloadable\": \"true\"}"}]}
```

A plain `cable clip` search returned 24 models, 9 of them downloadable and several of them render
assets rather than printable parts. The same words with these two filters returned 8, every one a
downloadable CC Attribution model with titles such as `Free Cable Clip 3D Printable STL`.

## Reading the answer

The first line is `Source: Sketchfab (public 3D models), GET <endpoint>, retrieved <time>. Request
sent: {...}.` Then a blank line, the JSON on one line, a closing line on how to ask, and a line saying
the models are provided by Sketchfab. The request echo also has braces, so parse from the blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
if "models" in data:                       # a search
    models = data["models"]
    next_cursor = (data["next"] or {}).get("cursor")
else:                                      # a model's details
    model = data["model"]                  # None when data["found"] is false
```

A search, `{"query", "count", "models": [...], "next": {"cursor"} | null}`. Each model has `title`,
`url`, `creator`, `creatorUsername`, `creatorUrl`, `license`, `thumbnail` (about 640 pixels wide),
`downloadable`, `faces`, `vertices`, `animations`, `views`, `likes`, `publishedAt`, `categories`,
`tags`, `formats` (Sketchfab's download packages, usually `glb`, `gltf`, `source`, `usdz`) and
`ageRestricted`.

A model's details, `{"found", "model": {...}}`: the row fields above, plus `licenseRequirements` (the
licence's terms in Sketchfab's words), `licenseUrl` when Sketchfab gives one, `downloads`, `comments`
(a count), `materials`, `textures` and `updatedAt`. `formats` is `null` here; take it from the search
row.

What each licence allows, in Sketchfab's words (`GET /v3/licenses`, read 2026-10-24):

| `license` | Sketchfab's terms |
|---|---|
| `CC Attribution` | Author must be credited. Commercial use is allowed. |
| `CC Attribution-ShareAlike` | Author must be credited. Modified versions must have the same license. Commercial use is allowed. |
| `CC Attribution-NoDerivs` | Author must be credited. Modified versions can not be distributed. Commercial use is allowed. |
| `CC Attribution-NonCommercial` (and its `-ShareAlike`, `-NoDerivs` forms) | Author must be credited. No commercial use. |
| `CC0 Public Domain` | Credit is not mandatory. Commercial use is allowed. |
| `Standard`, `Free Standard` | Under basic restrictions, use worldwide, on all types of media, commercially or not, and in all types of derivative works |
| `Editorial` | Use only in connection with events that are newsworthy or of public interest |

Read a model's own `licenseRequirements` before you use it.

## Limits and caveats

- `license` is `null` on a model Sketchfab does not offer for download. Do not read a null as "free
  to use".
- `stl` never appears in `formats`, even on a search filtered with `file_format: stl`: the filter
  matches the type the creator uploaded, and `formats` names Sketchfab's own packages. Check
  `downloadable`, not `formats`, to know whether you can download.
- The order is Sketchfab's and relevance is loose; titles come in other languages too. Check each
  title before you use a row.
- A filter outside the values above, or a filter sent with a model link, is refused with an error
  that names the allowed values, and nothing is billed. Any other Sketchfab link (a user, a
  collection) is refused the same way.
- When a search finds fewer than five models, the answer ends with a list of Sippar's other models on
  AntSeed and a message to try with each.
- Each model belongs to its creator under the licence shown with it. Credit the creator and give the
  link when you use a model. Not affiliated with Sketchfab.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Free: 0 on the peer record. The free allowance is 50 requests per buyer address and 150 per IP over a
rolling 24 hours, shared with `ui-animation-search`. Past it the seller answers HTTP 429 with
`code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a `Retry-After` header.
A full 24-model search is about 4,100 to 5,250 tokens, the STL-filtered search above about 1,800, a
model's details about 600 (measured 2026-10-24).
