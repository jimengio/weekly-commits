
fs = require 'fs'
axios = require 'axios'
{DateTime} = require 'luxon'

configs = require '../data/configs'

headers =
  Authorization: "token #{configs.token}"

today = DateTime.local()

startTime = today.minus(week: 1).startOf('week')
endTime = today.minus(week: 1).endOf('week')

console.log "Grabbing data from", startTime.toFormat('yyyy-MM-dd'), endTime.toFormat('yyyy-MM-dd')

fetchSingleCommit = (repo, hash) ->
  result = await axios
    baseURL: 'https://api.github.com/'
    url: "/repos/#{repo}/commits/#{hash}"
    headers: headers

  return result.data

fetchCommits = (repo) ->
  console.log "start feching for repo", repo

  list = []
  page = 1

  while true
    response = await axios
      baseURL: 'https://api.github.com/'
      url: "/repos/#{repo}/commits"
      headers: headers
      params:
        since: startTime.toISO()
        until: endTime.toISO()
        per_page: 200
        page: page

    list = list.concat response.data
    if response.headers.link?
      if not (response.headers.link.includes 'rel="last"')
        break
    else
      break

    page = page + 1
    console.log "continue next page", page

  # console.log list.data
  console.log "result from repo", list.length

  result = []
  page = 0
  pageSize = 50
  remaining = list

  while remaining.length > 0
    try
      batchResult = await Promise.all remaining[...pageSize].map (c) ->
        commit = await fetchSingleCommit(repo, c.sha)
        return
          sha: commit.sha
          commit: commit.commit
          stats: commit.stats
      result = result.concat batchResult
    catch error
      console.error "Failed to fetch, would retry"
      if error.isAxiosError
        console.log error.code, error.config
      continue

    remaining = remaining[pageSize..]
    console.log "remaining:", remaining.length

  result

fetchAll = ->
  data = []

  for repo in configs.repos
    result = await fetchCommits repo
    data.push [repo, result]

  # console.log JSON.stringify(data, null, 2)

  fs.writeFileSync "../data/commits.json", JSON.stringify(data, null, 2)

console.log "\nMight take very long time to grab all data...\n"

fetchAll()
