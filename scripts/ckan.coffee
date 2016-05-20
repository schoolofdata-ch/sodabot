# Description:
#   Commands to query CKAN portals
#
# Dependencies:
#   "ckan.js"
#
# Commands:
#   hubot ckan:fresh <portal> - Get latest 5 datasets from a named portal (or blank for default)

CKAN = require 'ckan'
portal = "opendata.swiss"
client = new CKAN.Client "https://#{portal}"

module.exports = (robot) ->

	robot.respond /more (.*)/i, (res) ->
		query = res.match[1]
		if query is "data"
			data = { sort: 'metadata_modified desc' }
			res.send "Hold on, fetching fresh data from #{portal}..."
		else
			data = { q: query }
			res.send "Looking up top '#{query}' data in #{portal}..."
		action = "package_search"
		client.action action, data, (err, json) ->
			if !err
				if !json.success
					res.reply "#{json.error.message}"
				else
					datasets = json.result.results
					latest = ("#{ds.title.en}\n" +
						"https://opendata.swiss/en/dataset/" +
						"#{ds.name}" for ds in datasets)
					latest = latest[0..2].join '\n'
					res.reply "#{latest}"
			else
				res.reply "#{err}"
