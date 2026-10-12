---
name: sippar-job-search
description: Search current job postings through Sippar's sippar-job-search model on AntSeed, with Google for Jobs data from OpenWeb Ninja. Use it when an agent on AntSeed needs open postings for a role and a place, with the employer, the site that published each posting, employment type, place, posted time, pay where the posting states it, benefits and the link to the posting. It returns no description text. Triggers on - job search on AntSeed, job postings for X in Y, who is hiring, open roles at a company, remote jobs, jobs outside the US, pay ranges on postings, sippar-job-search.
metadata:
  version: "1.0.0"
  updated: "2026-10-12"
---

# sippar-job-search

Job postings as Google for Jobs lists them, from OpenWeb Ninja's job search: up to 10 postings a
call for one search. Each posting comes with its title, employer, the site that published it,
employment type, place, posted time, pay where the posting states it, benefits and the link to
the posting. There is no description text on any page: follow a posting's link to read it.
Transport (pin, request shape, the 8-in-flight limit) is in the `sippar-antseed-buyer` skill;
read it first. Model string: `sippar-job-search`.

## How to ask

The last user message is one plain line naming the role and the place. There are no arguments.

```json
{"model": "sippar-job-search",
 "messages": [{"role": "user", "content": "data engineer jobs in Austin, TX"}]}
```

- **The line is sent to Google for Jobs as written.** A role and a place work best. A question
  works too: `Is Stripe hiring software engineers in San Francisco?` returned ten Stripe postings.
  Words such as `remote` or `part time` go in the line: `remote customer support jobs` returned
  ten remote postings.
- **Outside the US, end the line with `country` and two letters**:
  `marketing manager jobs in Berlin country de`. The search runs in the US unless you say
  otherwise, and the country is never guessed from the place. The same Berlin line without
  `country de` returned no postings and was still billed. `uk` and `gb` both mean the United
  Kingdom. The country can change the page's language: the `de` page came back in German.
- **A JSON message reads one key, `query`.** `{"query": "data engineer jobs in Austin, TX"}` is
  the same as the plain line. Any other key is ignored: a message with a separate `"country"`
  key was searched in the US, returned nothing and was billed. Put the country inside the line.
- **The next page.** When a page has more behind it, its JSON carries `data.cursor`. Send the
  same line again ending with `cursor` and that value:
  `data engineer jobs in Austin, TX cursor <value>`. You get the next 10 postings; ours shared
  none with the first page. A cursor is 10 to about 1,000 characters.
- There is no date, site or pay filter, and no sort option. A line ending in `on indeed` is
  refused for free; the ordinary search already carries Indeed postings among the other sites.
- A line with fewer than three letters is refused for free. Up to 120 characters, not counting
  the country and the cursor.

Do not send `x-antseed-required-parameters` on this model. It announces no parameters, so
requiring any name refuses every call.

## Reading the page

The page opens with one source line: `Source: Google for Jobs, via OpenWeb Ninja, retrieved
<time>. Request sent: {…}`. It ends with "values unchanged:" and the list of fields kept for each
posting. Then comes the JSON, unfenced, then a closing line and a disclaimer. Text follows the
JSON, so parse the first JSON value after the marker:

```python
import json
# page = the answer text, e.g. response.choices[0].message.content
start = page.index("{", page.index("values unchanged:"))
data, _ = json.JSONDecoder().raw_decode(page, start)
jobs = data["data"]["jobs"]
```

A parser that grabs the first `{` on the page gets the request echo instead.

The JSON is OpenWeb Ninja's response: `status` (`"OK"`), `request_id`, `parameters` and `data`.
`parameters` echoes what the search ran with: the query, the country and the language. Check
`parameters.country` when a page looks wrong. The postings are the list `data.jobs`, each cut to
the fields named on the source line, and no value is changed. A value the source does not have
is `null`.

- `job_title` and `employer_name`. `employer_website` is often `null`, more often outside the US.
- `job_publisher`: the site that published the posting, such as LinkedIn, Indeed, ZipRecruiter,
  Monster, or the employer's own careers site. One search returns postings from several sites.
- `job_apply_link`: the posting's page on that site. `apply_options` is a list of
  `{publisher, apply_link, is_direct}`; on every posting we read it held one entry with the same
  link, and `job_apply_is_direct` was `false`.
- `job_employment_type` is the text as shown (`Full-time`, `Contractor`, `Vollzeit und Teilzeit`).
  `job_employment_types` is a list of codes; we saw `FULLTIME`, `PARTTIME` and `CONTRACTOR`.
- `job_is_remote`, and `job_location`, the place as Google shows it: `Austin, TX`, `Anywhere`,
  `Austin, TX   (+3 others)`. Outside the US it can carry the site as well
  (`Berlin     •  über Stepstone`). `job_city`, `job_state` and `job_country` are filled on most
  US postings and `null` on most others.
- `job_posted_at`: Google's relative text, in the page's language (`3 days ago`,
  `vor 11 Tagen`). It is `null` on some postings: one of ten on a US page, five of ten on a
  German one. `job_posted_at_datetime_utc` is worked out from that text, so it is the day at
  midnight UTC, not a real time of day. Quote "about 3 days ago" or the day.
- Pay, where the posting states it: `job_salary_string` (`145K–170K a year`, `70–95 an hour`),
  `job_min_salary` and `job_max_salary` as numbers, and `job_salary_period` (`YEAR` or `HOUR`).
  `job_salary` is usually `null`; a few postings carry one figure there. On US pages 0 to 9
  postings of 10 stated pay. None of the 60 postings we read outside the US did (Germany, the
  United Kingdom, Israel, Canada, France).
- `job_benefits`: a list of codes such as `health_insurance`, `dental_coverage` and
  `paid_time_off`, or `null`.
- `employer_reviews` was `null` on every posting we read.

**The order is Google's relevance, and it is loose.** A search for data engineers also returned
a "Data Center Operations Engineer". Check each title against what you asked for before you use
the row.

**Coverage is widest for the US and for postings in English.** In another country a page can
hold one site's postings only: an Israel search returned ten, all published on LinkedIn.

**An empty page is billed.** A search that finds nothing returns `"jobs": []` with no cursor, at
the width of the short page. The usual cause is a place outside the US with no `country` on the
line, so read `parameters.country` before concluding there are no postings. A refused line, or a
search the supplier fails to answer, returns an error and bills nothing.

**A posting may have closed.** The page is what the source listed at the retrieval time. It is a
list of public postings with links: not an offer of work, and not a recruiting or placement
service. Name the site and give the link when you use a posting. Not advice.

## Cost

Per output token at the rate on the peer record. Measured 2026-10-12 (the listing's own token
count): a page with ten postings 2,752 to 3,387 tokens; a second page is at the wide end because
it repeats its cursor; an empty page about 470. A refused line bills nothing.

## Changes

- 1.0.0 (2026-10-12): first publish.
