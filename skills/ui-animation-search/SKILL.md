---
name: ui-animation-search
description: Use this when you need an animated React UI component (a text reveal, a marquee, a loader, an animated icon, a number that counts up) and want its full source to drop into a project. Sippar's free ui-animation-search model on AntSeed searches nine open-source shadcn registries and returns any component's source files, keyframes, install line and MIT notice.
metadata:
  version: "0.1.0"
  updated: "2026-11-02"
---

# ui-animation-search

Animated React components (Tailwind CSS and Motion) from nine open-source shadcn registries. Search
for a component, then ask for it by id to get its source. Free on AntSeed. How to reach the seller
is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "ui-animation-search", "messages": [{"role": "user", "content": "marquee"}]}
```

Then take an `id` from a row and send it on its own:

```json
{"model": "ui-animation-search", "messages": [{"role": "user", "content": "@magicui/marquee"}]}
```

## How to ask

The last user message is one of three things:

| Send | You get |
|---|---|
| a few words, such as `text reveal` or `loader` | up to 24 matching components from all nine registries |
| `@registry`, such as `@magicui` | that registry's components, 24 at a time |
| `@registry/item`, an id from a row | that component's source files, CSS variables and keyframes, dependencies, install line and MIT notice |

The registries: `@magicui`, `@motion-primitives`, `@kokonutui`, `@cult-ui`, `@eldoraui`,
`@smoothui`, `@ui-layouts`, `@lucide-animated` and `@heroicons-animated`.

To narrow a search or get the next page, send the message as JSON with `registry` or `cursor` (the
`next.cursor` of the previous answer):

```json
{"model": "ui-animation-search",
 "messages": [{"role": "user", "content": "{\"query\": \"text reveal\", \"registry\": \"@magicui\"}"}]}
```

Send the words a component's title would carry. The free search matches words: a row comes back
when every word you sent is in its id, title or description, and rows with the words in the id or
title come first. `number ticker` finds the number ticker; a sentence such as "a number that counts
up when it scrolls into view" finds little.

## Reading the answer

The first line names where the components were read from, when, and the request as parsed. Then
one line of JSON, then a closing line on how to ask, then the licence line.

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
```

A search: `{"query", "count", "total", "components": [...], "next": {"cursor"} | null}`. Each row
has `id` (send it back for the source), `registry`, `name`, `title`, `description`, `type`,
`dependencies`, `homepage`, `licence` and `install`, the shadcn command
(`npx shadcn@latest add @magicui/marquee`).

A component: `{"found": true, "component": {...}}` with its `files` (each file's path and source;
a file over 40,000 characters is cut and marked `truncated`), `cssVars`, `css`, `dependencies`,
`devDependencies`, `registryDependencies`, `install` and `licenceNotice`: the registry's copyright
line and the MIT text. An id the registry does not have comes back as `"found": false`.

## Limits and caveats

- Keep the `licenceNotice` with any copy of the code. It is the one condition of the MIT licence.
- A registry outside the nine is refused, and nothing is served.
- When a search finds fewer than five components, the answer ends with a list of Sippar's other
  models on AntSeed and a message to try with each.

## Cost

Free: 0 on the peer record. The free allowance is 50 requests per buyer address and 150 per IP
over a sliding 24 hours, shared with `3d-model-search`. Past it the seller answers HTTP 429 with
`code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a `Retry-After` header.
