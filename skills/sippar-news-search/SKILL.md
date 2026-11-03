---
name: sippar-news-search
description: Use this when you need current news on a subject from the past week, or today's top stories overall or for one topic, with the publisher, date, link and a short snippet per article. Sippar's sippar-news-search model on AntSeed returns Google News data from OpenWeb Ninja. It returns no article text.
metadata:
  version: "1.1.0"
  updated: "2026-11-03"
---

# sippar-news-search

News articles as Google News lists them, from OpenWeb Ninja: a search of the past week, the day's
top stories, or one topic's top stories. Each article has its headline, publisher, date, link and a
short snippet; there is no article text. How to reach the seller is in the `sippar-antseed-buyer`
skill.

## Try it

```json
{"model": "sippar-news-search", "messages": [{"role": "user", "content": "Federal Reserve interest rates"}]}
```

## How to ask

The last user message is one plain line, one of three kinds:

- **A search.** Any line that is not one of the two below is searched in Google News over the past
  week: up to 10 articles, in Google's order of relevance.
- **`headlines`.** The day's top stories: 10 stories, each with up to three related articles from
  other outlets.
- **`headlines` and a topic**, such as `headlines business` or `business headlines`. The topics are
  `world`, `national`, `business`, `technology`, `entertainment`, `sports`, `science` and `health`.
  `headlines` followed by any other word is an ordinary search for those two words.

The edition is the US one, in English. There is no country, language or date option. A line needs
at least three letters, and up to 200 characters.

## Reading the answer

The first line is `Source: Google News, via OpenWeb Ninja (...), retrieved <time>. Request sent:
{...}`, ending with "values unchanged:" and the fields kept for each article. Then the JSON, a
closing line and a disclaimer.

```python
import json
start = page.index("{", page.index("values unchanged:"))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

The two kinds of page are shaped differently.

A search page, articles under `data.news`:

- `title`, `link` (the publisher's page), `source_name`, `source_url`, and `snippet` (about 165
  characters, ending with Google's relative date).
- `published_date`: Google's relative text, such as `"3 days ago"`. This is the real date
  information.
- `published_datetime_utc`: the retrieval time minus that interval. Its time of day is the retrieval
  clock's, and its date can be a day off. Quote "about 3 days ago" or the day, never the time.
- `parameters` echoes the search: `last_week`, `relevance`, country `us`, language `en`.

A headlines page, stories as the `data` list itself:

- `title`, `link`, `snippet`, `source_name`, `source_url`, and `published_datetime_utc` (the real
  publication time, so this page can be sorted by it).
- `authors`: a list of names, often one.
- `sub_articles`: up to three articles on the same story from other outlets, without snippets.

## Limits and caveats

- There is no sort option. To put the newest first on a search page, order by `published_date`.
- A topic page is Google's own grouping and can hold a story you would file elsewhere.
- Now and then `source_name` is a site address, not a name. A field an article does not have is
  absent, never filled in.
- A search that finds nothing returns `"news": []`, and that short answer is billed. An everyday
  subject coming back empty can be a miss: send the line again before concluding there is no news.
- The articles belong to their publishers. Name the publisher, give the link, and open it for the
  article itself.
- When a search finds fewer than five articles, the answer ends with a list of Sippar's other models
  on AntSeed and a message to try with each; it comes after the JSON, so the parser above is not
  affected.
- Leave out the `x-antseed-required-parameters` header: this model takes no options outside the
  message, so with that header every call is refused.

## Cost

Per output token, at the rate on Sippar's peer record. A ten-article search is about 1,650 to 1,800
tokens; a headlines page 3,450 to 4,350, because of the related articles; an empty search about 430
(measured 2026-10-12). A refused line bills nothing.
