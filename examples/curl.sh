#!/usr/bin/env bash
# Working calls to Sippar's models on AntSeed, through YOUR AntSeed buyer proxy (default
# 127.0.0.1:8377). `3d` and `ui` are free within a daily allowance; every other case is a paid
# call, billed per output token at the rate on the peer record. Run one at a time.
# Usage: ./curl.sh <case> ['your words'], e.g. ./curl.sh reddit 'home espresso machine'.
# Transport rules: the sippar-antseed-buyer skill.
set -euo pipefail
PROXY="${SIPPAR_ANTSEED_PROXY:-http://127.0.0.1:8377}"
PEER='706fca9c0d0684c30f86209aae0c3565ce1aa69f'

call() {
  curl -s "$PROXY/v1/chat/completions" \
    -H 'content-type: application/json' \
    -H "x-antseed-pin-peer: $PEER" \
    -d "$1"
}

case "${1:-}" in
  x)       # X posts: keywords, names or X operators (from:, lang:, since:, "phrase"); any subject; pass the search as $2
    call "$(jq -cn --arg c "$2" '{model:"sippar-x-social",messages:[{role:"user",content:$c}]}')" ;;
  reddit) # Reddit posts: keywords; pass the search as $2. Past week: content '{"query":"…","time":"week"}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-reddit-social",messages:[{role:"user",content:$c}]}')" ;;
  linkedin) # LinkedIn posts: keywords; pass the search as $2. More posts: content '{"query":"…","posts":30}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-linkedin-social",messages:[{role:"user",content:$c}]}')" ;;
  facebook) # Facebook/Instagram ads (Meta Ad Library): keywords, or one company's ads as JSON, e.g. '{"query":"Stripe","by":"company","country":"US"}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-facebook-social",messages:[{role:"user",content:$c}]}')" ;;
  instagram) # One Instagram account's recent posts: its @name or profile link; reels or profile as JSON, e.g. '{"query":"@natgeo","by":"reels"}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-instagram-social",messages:[{role:"user",content:$c}]}')" ;;
  tiktok) # One TikTok creator's latest videos: @handle or profile link; one video as JSON, e.g. '{"query":"<video link>","by":"video"}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-tiktok-social",messages:[{role:"user",content:$c}]}')" ;;
  video) # Videos: search words, or one video's link for its details; filters as JSON, e.g. '{"query":"home espresso machine review","uploaded":"year"}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-video-search",messages:[{role:"user",content:$c}]}')" ;;
  3d) # 3D models on Sketchfab: search words, or one model's link for its details; filters as JSON, e.g. '{"query":"phone stand","file_format":"stl","downloadable":"true"}'
    call "$(jq -cn --arg c "$2" '{model:"3d-model-search",messages:[{role:"user",content:$c}]}')" ;;
  ui) # Animated React components (free): search words, or a component id from a row, e.g. '@magicui/marquee' for its source
    call "$(jq -cn --arg c "$2" '{model:"ui-animation-search",messages:[{role:"user",content:$c}]}')" ;;
  news) # News: a search of the past week, or 'headlines', or 'headlines business' (eight topics)
    call "$(jq -cn --arg c "$2" '{model:"sippar-news-search",messages:[{role:"user",content:$c}]}')" ;;
  flights) # one line: FROM TO DATE [RETURN-DATE] [ADULTS], airport codes; pass it as $2
    call "$(jq -cn --arg c "$2" '{model:"sippar-flight-search",messages:[{role:"user",content:$c}]}')" ;;
  hotels) # Places to stay: one line, e.g. 'hostels in Lisbon, Portugal'; end it with "offers" for booking-site prices
    call "$(jq -cn --arg c "$2" '{model:"sippar-hotel-search",messages:[{role:"user",content:$c}]}')" ;;
  amazon) # Amazon: a search, bestsellers:<category>, an ASIN or a product URL; options as JSON, e.g. '{"query":"electric kettle","tld":"co.uk"}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-amazon",messages:[{role:"user",content:$c}]}')" ;;
  jobs) # Job postings: one line, a role and a place; outside the US end it with the country, e.g. 'marketing manager jobs in Berlin country de'
    call "$(jq -cn --arg c "$2" '{model:"sippar-job-search",messages:[{role:"user",content:$c}]}')" ;;
  web) # The first page of Google's results: the search as you would type it into Google; pass it as $2
    call "$(jq -cn --arg c "$2" '{model:"sippar-web-search",messages:[{role:"user",content:$c}]}')" ;;
  search)  # the last user message is the query; pass it as $2
    call "$(jq -cn --arg c "$2" '{model:"tavily-web-search",messages:[{role:"user",content:$c}]}')" ;;
  github) # GitHub: a ref (owner/repo, a github.com URL) or a GitHub search; pass it as $2.
    # Options: content '{"query":"symbol:useRouter","repo":"vercel/next.js","kind":"code","per_page":10}'
    call "$(jq -cn --arg c "$2" '{model:"sippar-github",messages:[{role:"user",content:$c}]}')" ;;
  skills) # Agent skills from skills.sh and CryptoSkill: a skill id ('owner/repo/skill') or two or three keywords
    call "$(jq -cn --arg c "$2" '{model:"sippar-skills",messages:[{role:"user",content:$c}]}')" ;;
  skill)   # a CryptoSkill id (e.g. chains/aave), one of Sippar's skill names, or two or three keywords to search; pass it as $2
    call "$(jq -cn --arg c "$2" '{model:"crypto-skills",messages:[{role:"user",content:$c}]}')" ;;
  chain)   # two fields on Base
    call '{"model":"quicknode-blockchain-data","network":"base","fields":["blockNumber","gasPrice"],
           "messages":[{"role":"user","content":"chain state"}]}' ;;
  account) # one account on Arbitrum, only its own rows; pass the address as $2
    call "$(jq -cn --arg a "${2:?usage: $0 account 0x<40 hex>}" '{model:"quicknode-blockchain-data",network:"arbitrum",address:$a,
           fields:["addressNativeBalance","addressErc20Balance","addressTransactionCount"],
           messages:[{role:"user",content:"chain state"}]}')" ;;
  logs)    # USDC transfers on Ethereum over a 16-block range; narrow ranges keep the page small
    call '{"model":"quicknode-blockchain-data","network":"ethereum",
           "rpc":{"method":"eth_getLogs","params":[{"address":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
             "topics":["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"],
             "fromBlock":"0x15f9000","toBlock":"0x15f9010"}]},
           "messages":[{"role":"user","content":"chain state"}]}' ;;
  wallet)  # every ERC-20 transfer a wallet received in a 16-block range; pass the 0x address as $2
    w=$(echo "${2:?usage: $0 wallet 0x<40 hex>}" | sed 's/^0x//' | tr 'A-F' 'a-f')
    [[ "$w" =~ ^[0-9a-f]{40}$ ]] || { echo "wallet: expected 0x and 40 hex characters" >&2; exit 2; }
    call "{\"model\":\"quicknode-blockchain-data\",\"network\":\"ethereum\",
           \"rpc\":{\"method\":\"eth_getLogs\",\"params\":[{\"topics\":[\"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef\",null,\"0x000000000000000000000000$w\"],
             \"fromBlock\":\"0x15f9000\",\"toBlock\":\"0x15f9010\"}]},
           \"messages\":[{\"role\":\"user\",\"content\":\"chain state\"}]}" ;;
  block)   # the latest Base block: header and transaction hashes
    call '{"model":"quicknode-blockchain-data","network":"base","rpc":{"method":"eth_getBlockByNumber","params":["latest",false]},
           "messages":[{"role":"user","content":"chain state"}]}' ;;
  tokens)  # ten rows by volume on Base and Solana over a week
    call '{"model":"nansen-crypto-screener","chains":["base","solana"],"timeframe":"7d","sort":"volume","rows":10,
           "messages":[{"role":"user","content":"top tokens"}]}' ;;
  stocks)  # five tokenized stocks on Solana by volume; a ticker with no row is named on the page
    call '{"model":"nansen-crypto-screener","symbols":["TSLAX","NVDAX","SPYX","GOOGLX","CRCLX"],"chains":["solana"],"sort":"volume","rows":5,
           "messages":[{"role":"user","content":"stocks"}]}' ;;
  perps)   # Nansen's perpetuals screener; "view" goes alone
    call '{"model":"nansen-crypto-screener","view":"perp-screener",
           "messages":[{"role":"user","content":"perps"}]}' ;;
  translated) # a client that must post the Anthropic shape: arguments ride metadata.sippar and survive
    curl -s "$PROXY/v1/messages" -H 'content-type: application/json' -H "x-antseed-pin-peer: $PEER" \
      -d '{"model":"quicknode-blockchain-data","max_tokens":1024,
           "metadata":{"sippar":{"network":"base","fields":["blockNumber","gasPrice"]}},
           "messages":[{"role":"user","content":"chain state"}]}' ;;
  *) echo "usage: $0 <case> ['your words']" >&2
     echo "cases: x reddit linkedin facebook video 3d ui news flights hotels amazon jobs search github skills skill chain account logs wallet block tokens stocks perps translated" >&2
     echo "e.g.:  $0 flights 'JFK LHR 2026-11-12 2026-11-19 2'   $0 3d 'phone stand'   $0 x 'Formula 1 since:2026-10-01'" >&2
     exit 2 ;;
esac
