---
name: sippar-github
description: Use this when you need to understand a library or codebase on GitHub, find where something is defined, read a project's docs or changelog, or check what an issue or pull request says. Sippar's sippar-github model on AntSeed returns public GitHub from glim.sh - a repository's README and metadata, a folder's files, one file, an issue, a pull request, a discussion, commits, releases, and code search with line numbers.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-github

Public GitHub, as glim.sh returns it. One message is one call. How to reach the seller is in the
`sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-github", "messages": [{"role": "user", "content": "x402-foundation/x402"}]}
```

## How to ask

The last user message is a GitHub ref, to fetch one thing, or a GitHub search, to find things. It is
matched literally; nothing reads it as a sentence.

| Send | You get |
|---|---|
| `owner/repo` (or its github.com URL) | metadata and the README |
| `owner/repo/tree/<branch>/<folder>` | the file list of that folder |
| `owner/repo/blob/<branch>/<path>` | one file, whole |
| `owner/repo/issues/N`, `/pull/N`, `/discussions/N` | the issue; the PR with comments and changed files; the discussion with replies |
| `owner/repo/commit/<sha>` | one commit with its diff |
| `owner/repo/commits/<branch>` or `/commits/<branch>/<path>` | history, of one file if a path is given |
| `owner/repo/releases`, `/releases/latest`, `/releases/tag/<tag>`, `/branches` | releases, the latest one, one tag, branches |
| `topics/<name>` | the top repositories with that topic |
| anything else | a GitHub search in GitHub's own syntax |

github.com URLs (including `/blame/` links), `raw.githubusercontent.com` URLs and
`git@github.com:owner/repo.git` addresses all work as refs, and branch names with a slash work.

Searching uses GitHub's syntax; a sentence finds nothing, because every word must match.

- Repositories: the name and qualifiers, such as `x402 language:typescript` or
  `created:>2026-09-01 sort:stars`.
- Code: one literal pattern (`useState(`), an `"exact string"`, a `/regex/`, or `symbol:name` for
  where a function or class is defined. Narrow with `language:`, `path:` and the repository.
  `symbol:` cannot be mixed with other words. Matching ignores case; for a case-sensitive match put
  `(?-i)` inside a `/regex/`. Only each repository's default branch is searched.
- Issues and PRs: keywords with `is:issue`, `is:pr`, `label:bug`, `is:open`; at most 5 AND/OR/NOT
  operators. An exact error message in quotes beats a paraphrase.
- Discussions are a separate index: `is:answered`, `category:Q&A`, with a repository.
- `sort:` replaces best-match ranking; leave it out for the best matches.

Four options go inside the message text, as JSON:

| Field | What it does |
|---|---|
| `repo` | `owner/name`: scope a search to one repository |
| `kind` | `repos`, `conversations` (issues and PRs), `discussions` or `code`; glim.sh infers it if left out |
| `per_page` | up to 30 search results (10 for discussions), or up to 100 commits, releases or branches; a smaller page bills less |
| `page` | the next page: up to 10 for a search, 100 for a list |

```json
{"model": "sippar-github",
 "messages": [{"role": "user", "content": "{\"query\": \"symbol:useRouter\", \"repo\": \"vercel/next.js\", \"kind\": \"code\", \"per_page\": 10}"}]}
```

`repo` or `kind` makes the line a search, whatever it looks like. `repo` and a `repo:` written in the
query must name the same repository.

A good order for a new repository: `owner/repo` first (its README and `default_branch`), then the
folder that matters, then `llms.txt` or the docs folder's files, then a code search scoped with
`repo`.

## Reading the answer

The answer is `choices[0].message.content`. Its first line decides how to read the rest:

| The first line | The page |
|---|---|
| `Source: glim.sh (GitHub), POST ...`, ending `The JSON below is glim.sh's response, unchanged.` | one JSON object follows, on one line |
| `... glim.sh answered HTTP 404; the JSON below is its response, unchanged.` | glim.sh's `error` and `detail` (a file or path that does not exist) |
| `... more than one page carries (96000 bytes), so it is not served.` | no JSON: the size, and the narrower request to send |
| `Not sent to glim.sh: ...` | no JSON: why the request was refused |

```python
import json
parts = page.split("\n\n")
data = json.loads(parts[1]) if parts[0].endswith("unchanged.") else None
```

- A ref: `kind` and `data`. A file is `data` as one string. A folder (`kind: tree`) is a list of
  entries (`path`, `type`, `sha`); `path_missing: true` means the folder is not there; `truncated:
  true` means glim.sh clipped the payload.
- A search: `kind`, `results`, `total_count`, `has_more`. Code results carry `repo`, `path`, `url`,
  `branch`, `license` and `snippets` (`line`, `text`). A `symbol:` hit's snippet is the definition
  line only; send the hit's `url` as the next message for the whole file.
- glim.sh's hints: `notice` (limited coverage, an empty result, how a ref was resolved). A ref they
  name is the next message to send. "Coverage was limited ... re-run" means the same request may
  return more, as a new call.

## Limits and caveats

- A folder's file list is recursive: on a large repository the root alone is far more than one page,
  and `per_page` does not shorten it. Learn the folder names from the README or a code search, then
  ask for the deepest folder you need.
- A repository that was renamed or moved finds nothing under its old name. Open `owner/repo` first;
  it shows the current `full_name`.
- A file over 96 KB is not served in part; the answer gives its github.com link instead.
- A bad value (an unknown `kind`, a malformed `repo`, `per_page` over 100) is refused with an error
  and bills nothing. A combination checked later (31 per page, page 11 of a search) comes back as a
  short `Not sent to glim.sh` page, which is billed.
- When a search finds fewer than five results, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each.
- Public repositories only. Content belongs to its authors under each repository's own licence.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. Every served page is billed by its width,
short ones included (a 404 reason about 450 tokens, an empty search about 385). Measured 2026-10-09:
a repo page 1,300 to 2,100 tokens, an issue about 850, a PR about 2,100, a folder list about 8,400, a
70 KB source file about 18,600, a code search 600 to 3,000. No page exceeds about 24,400 tokens; a
bigger answer is described instead.
