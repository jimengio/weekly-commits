
fs = require 'fs'
axios = require 'axios'
{DateTime} = require 'luxon'

configs = require '../data/configs'

headers =
  Authorization: "token #{configs.token}"

today = DateTime.local()

startTime = today.minus(month: 3).startOf('month')
endTime = today.endOf('month')

console.log "Grabbing data from", startTime.toFormat('yyyy-MM-dd'), endTime.toFormat('yyyy-MM-dd')

timeout = (x) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, x

checkRateLimit = () ->
  try
    result = await axios
      baseURL: 'https://api.github.com/'
      url: "/users/octocat"
      headers: headers
    console.log result.headers
  catch error
    # 5k per hour limit
    console.log "Failed to check", error?.response?.headers
    throw error

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
    console.log "Fetching commits for", repo
    try
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
    catch error
      console.error "Failed to load commits of", repo
      console.error error

    page = page + 1
    console.log "continue next page", page

  # console.log list.data
  console.log "result from repo", list.length

  result = []
  page = 0
  pageSize = 50
  remaining = list

  while remaining.length > 0
    chunk = remaining[...pageSize]
    remaining = remaining[pageSize..]

    console.log "Trying with chunk", chunk.length

    await Promise.all chunk.map (c) ->
      try
        commit = await fetchSingleCommit(repo, c.sha)
        data =
          sha: commit.sha
          commit: commit.commit
          stats: commit.stats
        result.push data

      catch error
        if error.isAxiosError
          console.log error.code, error.config

        remaining.push c
        # await timeout(1000)
        console.log "Failed to fetch, adding to remaining(#{remaining.length})", c

    console.error "Retry from remaining", remaining.length

  result

fetchAll = ->
  data = []

  await checkRateLimit()

  for repo in configs.repos
    result = await fetchCommits repo
    data.push [repo, result]

  # console.log JSON.stringify(data, null, 2)

  fs.writeFileSync "../data/commits.json", JSON.stringify(data, null, 2)

console.log "\nMight take very long time to grab all data...\n"

fetchAll()
