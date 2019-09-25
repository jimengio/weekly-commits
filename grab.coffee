
fs = require 'fs'
axios = require 'axios'
{DateTime} = require 'luxon'

configs = require './data/configs'

headers =
  Authorization: "token #{configs.token}"

today = DateTime.local()

startTime = today.minus(month: 1).startOf('month')
endTime = today.minus(month: 1).endOf('month')

console.log "Grabbing data from", startTime.toFormat('yyyy-MM-dd'), endTime.toFormat('yyyy-MM-dd')

fetchSingleCommit = (repo, hash) ->
  try
    result = await axios
      baseURL: 'https://api.github.com/'
      url: "/repos/#{repo}/commits/#{hash}"
      headers: headers
  catch error
    console.log "failed to get commit", repo, hash
    console.error error
    return null

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
    console.log "contine since", response.headers.link, page

  # console.log list.data
  console.log "result from repo", list.length

  result = []
  page = 0
  pageSize = 40
  remaining = list

  while remaining.length > 0
    batchResult = await Promise.all remaining[...pageSize].map (c) ->
      commit = await fetchSingleCommit(repo, c.sha)
      return
        sha: commit.sha
        commit: commit.commit
        stats: commit.stats
    result = result.concat batchResult

    remaining = remaining[pageSize..]
    console.log "remaining:", remaining.length

  result

fetchAll = ->
  data = []

  for repo in configs.repos
    result = await fetchCommits repo
    data.push [repo, result]

  # console.log JSON.stringify(data, null, 2)

  fs.writeFileSync "data/commits.json", JSON.stringify(data, null, 2)

console.log "\nMight take very long time to grab all data...\n"

fetchAll()
