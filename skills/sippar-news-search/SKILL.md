---
name: sippar-news-search
description: Search the news of the past week, or get the day's top stories overall or for one topic, through Sippar's sippar-news-search model on AntSeed, with Google News data from OpenWeb Ninja. Use it when an agent on AntSeed needs current headlines with the publisher, the publication date, a link and a short snippet per article. It returns no article text. Triggers on - news search on AntSeed, latest news about X, today's headlines, top stories, business headlines, technology news, what happened this week, sippar-news-search.
metadata:
  version: "1.0.0"
  updated: "2026-10-12"
---

# sippar-news-search

News articles as Google News lists them, from OpenWeb Ninja's news APIs: a search of the past
week, the day's top stories, or the top stories of one topic. Each article comes with its headline,
publisher, date, link and a short snippet. There is no article text on any page. Transport (pin,
request shape, the 8-in-flight limit) is in the `sippar-antseed-buyer` skill; read it first. Model
string: `sippar-news-search`.

## How to ask

The last user message is one plain line. There are no arguments. Three kinds of line:

```json
{"model": "sippar-news-search",
 "messages": [{"role": "user", "content": "Federal Reserve interest rates"}]}
```

- **A search.** Any line that is not one of the two below is searched in Google News over the
  past week. You get up to 10 articles, in Google's order of relevance.
- **`headlines`.** The day's top stories: 10 stories, each with up to three related articles from
  other outlets.
- **`headlines` and a topic.** `headlines business`, or `business headlines`. The topics are
  `world`, `national`, `business`, `technology`, `entertainment`, `sports`, `science` and `health`.
  You get that topic's 10 top stories, each with up to three related articles. `headlines` followed by any
  other word is an ordinary search for those two words.
- **The edition is the US one, in English.** There is no country, language or date option, and a
  search always covers the past week.
- A line with fewer than three letters is refused for free. Up to 200 characters.

Do not send `x-antseed-required-parameters` on this model. It announces no parameters, so
requiring any name refuses every call.

## Reading the page

The page opens with one source line: `Source: Google News, via OpenWeb Ninja (…), retrieved
<time>. Request sent: {…}`. It ends with "values unchanged:" and the list of fields kept for each
article. Then comes the JSON, unfenced, then a closing line and a disclaimer. Text follows the
JSON, so parse the first JSON value after the marker:

```python
import json
# page = the answer text, e.g. response.choices[0].message.content
start = page.index("{", page.index("values unchanged:"))
data, _ = json.JSONDecoder().raw_decode(page, start)
```

A parser that grabs the first `{` on the page gets the request echo instead.

The JSON is OpenWeb Ninja's response: `status` (`"OK"`), `request_id` and `data`, and on a search
page `parameters`. Each article is cut to fields from the list on the source line, and no value
is changed. That list covers both kinds of page, so some of its names are absent on each:
`published_date` appears only on a search page, `authors` and `sub_articles` only on a headlines
page. The two kinds of page are shaped differently.

**A search page.** The articles are under `data.news`:

- `title`, `link` (the publisher's page), `source_name` and `source_url`.
- `snippet`: about 165 characters. It ends with Google's relative date ("… 3 days ago").
- `published_date`: Google's own relative text, such as `"3 days ago"` or `"5 hours ago"`. This is
  the real date information.
- `published_datetime_utc`: the retrieval time minus that interval. Its time of day is the
  retrieval clock's, not the article's, and its date can be a day off the real one (an article
  whose own link said 8 October came back as 9 October). Quote "about 3 days ago" or the day, never
  the time, and when the exact date matters read it from the article.
- The articles come in Google's order of relevance, and there is no sort option. To put the
  newest first, order by `published_date`; articles with the same text cannot be told apart.
- `data.top_stories` was an empty list on every page we bought.
- `parameters`, beside `data` at the top level, echoes what the search ran with, including
  `time_period` `last_week`, `sort_by` `relevance`, country `us` and language `en`.

**A headlines page.** The stories are the `data` list itself:

- `title`, `link`, `snippet`, `source_name` and `source_url`, as above. Now and then
  `source_name` is a site address, not a name.
- `published_datetime_utc`: the article's real publication time, so a headlines page can be sorted
  by it. There is no `published_date`.
- `authors`: a list of names, often one, sometimes empty.
- `sub_articles`: up to three articles on the same story from other outlets, each with `title`,
  `link`, `published_datetime_utc`, `authors`, `source_name` and `source_url`, and no snippet.
- A topic page is Google's own grouping. It can carry a story you would file elsewhere: a motor
  racing story sat on the technology page we bought.

A field an article does not have is absent, never filled in.

**An empty search exists, and it can be a miss.** A search that finds nothing returns
`"news": []` and is still billed, at the width of the short page. Once in our tests a real query
came back empty and the same line returned ten articles a few minutes later. If an everyday
subject returns nothing, send the line again before concluding there is no news.

**The articles belong to their publishers.** This page is a list of what was published and where.
Name the publisher and give the link when you use an item, and open the link for the article
itself. Not advice.

## Cost

Per output token at the rate on the peer record. Measured 2026-10-12 (the listing's own token
count): a search with ten articles 1,651 to 1,786 tokens; a headlines page 3,450 to 4,356,
because of the related articles; an empty search about 430. A refused line bills nothing.

## Changes

- 1.0.0 (2026-10-12): first publish.
