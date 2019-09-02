
fs = require 'fs'
axios = require 'axios'
{DateTime} = require 'luxon'

configs = require './data/configs'

headers =
  Authorization: "token #{configs.token}"

today = DateTime.local()

startTime = today.minus(weeks: 1).startOf('day')

fetchSingleCommit = (repo, hash) ->
  result = await axios
    baseURL: 'https://api.github.com/'
    url: "/repos/#{repo}/commits/#{hash}"
    headers: headers

  return result.data

fetchCommits = (repo) ->
  list = await axios
    baseURL: 'https://api.github.com/'
    url: "/repos/#{repo}/commits"
    headers: headers
    params:
      since: startTime.toISO()

  result = await Promise.all list.data.map (c) ->
    commit = await fetchSingleCommit(repo, c.sha)

    return
      sha: commit.sha
      commit: commit.commit
      stats: commit.stats

  result


fetchAll = ->

  data = await Promise.all configs.repos.map (repo) ->
    result = await fetchCommits repo

    [repo, result]

  # console.log JSON.stringify(data, null, 2)

  fs.writeFileSync "data/commits.json", JSON.stringify(data, null, 2)

fetchAll()
