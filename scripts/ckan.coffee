# Description:
#   Commands to query CKAN portals for open data
#
# Dependencies:
#   "ckan.js"
#
# Commands:
#   hubot fresh data - Get the latest open datasets
#   hubot data on <subject> - Query datasets for a subject

CKAN = require 'ckan'
portal = "opendata.swiss"
portal = "data.stadt-zurich.ch"
client = new CKAN.Client "https://#{portal}"

module.exports = (robot) ->

	robot.respond /(fresh )?(data)( on)?(.*)/i, (res) ->
		query = res.match[res.match.length-1].trim()
		if query is ""
			data = { sort: 'metadata_modified desc' }
			res.reply "Hold on, fetching fresh data from #{portal}..."
		else
			data = { q: query }
			res.reply "Looking up '#{query}' data in #{portal}..."
		action = "package_search"
		client.action action, data, (err, json) ->
			if !err
				if !json.success
					res.reply "#{json.error.message}"
				else
					datasets = json.result.results
					total = json.result.count
					if datasets.length > 0
						latest = ("#{ds.title.en}\n" +
							"https://" + portal + "/dataset/" +
							"#{ds.name}" for ds in datasets)
						latest = latest[0..2].join '\n'
						res.send "#{latest}"
						if datasets.length < total
							res.send "(from #{total} in total)"
					else
						res.send "Nothing like that published yet - why don't you request it?"
			else
				res.send "#{err}"
