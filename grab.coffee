
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
  console.log "fetching single commit:", repo, hash

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
    console.log "contine since", response.headers.link, page

  # console.log list.data
  console.log "result from repo", list.length

  result = []
  counter = 0

  for c in list
    commit = await fetchSingleCommit(repo, c.sha)
    result.push
      sha: commit.sha
      commit: commit.commit
      stats: commit.stats
    counter += 1
    console.log "counting to", counter, "of total", list.length

  result

fetchAll = ->
  data = []

  for repo in configs.repos
    result = await fetchCommits repo
    data.push result

  # console.log JSON.stringify(data, null, 2)

  fs.writeFileSync "data/commits.json", JSON.stringify(data, null, 2)

console.log "\nMight take very long time to grab all data...\n"

fetchAll()
