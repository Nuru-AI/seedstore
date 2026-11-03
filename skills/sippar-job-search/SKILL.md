---
name: sippar-job-search
description: Use this when you need open job postings for a role and a place, with the employer, the site that published each one, employment type, place, posted time, pay where the posting states it, benefits and the link. Sippar's sippar-job-search model on AntSeed returns Google for Jobs data from OpenWeb Ninja. It returns no description text.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-job-search

Job postings as Google for Jobs lists them, from OpenWeb Ninja: up to 10 a call. Each posting has
its title, employer, publishing site, employment type, place, posted time, pay where stated,
benefits and link. There is no description text; follow the link to read a posting. How to reach the
seller is in the `sippar-antseed-buyer` skill.

## Try it

```json
{"model": "sippar-job-search", "messages": [{"role": "user", "content": "data engineer jobs in Austin, TX"}]}
```

## How to ask

The last user message is one plain line naming the role and the place, sent to Google for Jobs as
written.

- A role and a place work best. A question works too (`Is Stripe hiring software engineers in San
  Francisco?`), and words such as `remote` or `part time` go in the line.
- **Outside the US, end the line with `country` and two letters**:
  `marketing manager jobs in Berlin country de`. The search runs in the US unless you say otherwise,
  and the country is never guessed from the place. `uk` and `gb` both mean the United Kingdom. The
  country can change the page's language.
- **The next page:** when a page has more, its JSON carries `data.cursor`. Send the same line again
  ending with `cursor` and that value: `data engineer jobs in Austin, TX cursor <value>`.
- A JSON message reads one key, `query`. Any other key is ignored, so put the country inside the line.
- There is no date, site or pay filter and no sort. A line ending in `on indeed` is refused, free;
  the ordinary search already includes Indeed postings.
- A line needs at least three letters, and up to 120 characters before the country and cursor.

## Reading the answer

The first line is `Source: Google for Jobs, via OpenWeb Ninja, retrieved <time>. Request sent:
{...}`, ending with "values unchanged:" and the fields kept for each posting. Then the JSON, a closing
line and a disclaimer.

```python
import json
start = page.index("{", page.index("values unchanged:"))
data, _ = json.JSONDecoder().raw_decode(page, start)
jobs = data["data"]["jobs"]
```

`parameters` echoes what the search ran with (query, country, language); check
`parameters.country` when a page looks wrong. Each posting in `data.jobs`:

- `job_title`, `employer_name`, `employer_website` (often `null`).
- `job_publisher` (LinkedIn, Indeed, ZipRecruiter, the employer's own site and others) and
  `job_apply_link`; `apply_options` lists `{publisher, apply_link, is_direct}`.
- `job_employment_type` as shown (`Full-time`, `Contractor`, `Vollzeit und Teilzeit`) and
  `job_employment_types` as codes.
- `job_is_remote`, `job_location` as Google shows it, and `job_city`, `job_state`, `job_country`
  (filled on most US postings).
- `job_posted_at`: Google's relative text in the page's language. `job_posted_at_datetime_utc` is
  worked out from it, so it is a day at midnight UTC; quote "about 3 days ago" or the day.
- Pay where stated: `job_salary_string`, `job_min_salary`, `job_max_salary`, `job_salary_period`
  (`YEAR` or `HOUR`).
- `job_benefits`: codes such as `health_insurance` or `paid_time_off`, or `null`.

A value the source does not have is `null`.

## Limits and caveats

- Relevance is loose: a search for data engineers can return a "Data Center Operations Engineer".
  Check each title before you use the row.
- Coverage is widest for the US and English postings. In another country a page can hold one site's
  postings only. On US pages, 0 to 9 postings in 10 stated pay; none of the 60 postings we read
  outside the US did.
- A search that finds nothing returns `"jobs": []`, and that short answer is billed. The usual cause
  is a place outside the US with no `country` on the line.
- A posting may have closed since it was listed. This is a list of public postings with links, not an
  offer of work or a recruiting service. Name the site and give the link when you use a posting.
- When a search finds fewer than five postings, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A page of ten postings is about 2,750 to
3,400 tokens (a second page is at the wide end because it repeats its cursor); an empty page about
470 (measured 2026-10-12). A refused line, or a search the supplier fails to answer, bills nothing.
