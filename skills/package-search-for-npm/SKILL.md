---
name: package-search-for-npm
description: Use this when you need JavaScript or TypeScript packages for a task: name, latest version, description, licence, last publish date, weekly and monthly downloads, dependents and links. Sippar's free package-search-for-npm model on AntSeed searches the npm registry live for each request. Package metadata only, with no security or audit data.
metadata:
  version: "1.0.0"
  updated: "2026-11-04"
---

# package-search-for-npm

Packages on the [npm registry](https://www.npmjs.com), searched live for each request: up to 10 packages with their latest version, downloads and links. Free on AntSeed. How to reach the seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "package-search-for-npm", "messages": [{"role": "user", "content": "x402"}]}
```

```json
{"model": "package-search-for-npm", "messages": [{"role": "user", "content": "{\"query\": \"react animation\", \"limit\": 3}"}]}
```

## How to ask

The last user message is search words (up to 200 characters), as you would search on npmjs.com:
a package name, or words for what it does.

## Reading the answer

The first line is `Source: npm (JavaScript packages on the npm registry), GET <the URL we called>, retrieved <time>. Request
sent: {...}.` and it names the fields each row carries. Then a blank line, the JSON on one line, a
closing line on how to ask, and the credit line. The request echo also has braces, so parse from the
blank line:

```python
import json
data, _ = json.JSONDecoder().raw_decode(page, page.index("\n\n{") + 2)
rows = data["rows"]        # up to 10
total = data["total"]      # how many packages npm matched
```

`{"count", "total", "rows": [...]}`. Each row has `name`, `version` (latest), `description`, `keywords` (up to 10), `license`, `published` (last publish), `weeklyDownloads`, `monthlyDownloads`, `dependents`, `npmUrl`, `homepage` and `repository`.

Searching `x402` (2026-11-04) returned 10 packages, first `x402` 1.2.0 (Apache-2.0, about 671,000
weekly downloads, 132 dependents).

## Limits and caveats

- Package metadata only: no security or audit data and no maintainer or publisher details. Check a
  package's repository and advisories before you install it.
- Download counts are npm's own.
- Package metadata from the npm registry.
- `limit` (1 to 10) goes inside the message text as JSON beside `query`, e.g.
  `{"query": "react animation", "limit": 5}`. Leave out the `x-antseed-required-parameters`
  header: this model takes no options outside the message, so with that header every call is refused.
- A request in the wrong form is refused with HTTP 400 and a message naming the form it takes; nothing
  is sent to npm.
- When fewer than five rows come back, the answer ends with a list of Sippar's other models on AntSeed,
  each with its price and a message to try.
- Every call is a fresh, live request to npm. Nothing is cached or stored.

## Cost

Free: 0 input and 0 output on the peer record. The free allowance is 50 requests per buyer address and
150 per IP over a rolling 24 hours, shared with Sippar's other free models. Past it the seller answers
HTTP 429 with `code: "free_tier_exhausted"`, a `limitedBy` field (`address` or `ip`) and a
`Retry-After` header. A 10-package page is about 1,270 tokens; 3 packages with the free-model list about 1,500 (measured 2026-11-04).
