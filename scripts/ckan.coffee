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
logdev = require('tracer').colorConsole()

clients = []
clients.push new CKAN.Client "https://data.stadt-zuerich.ch"
clients.push new CKAN.Client "https://opendata.swiss/en"

DATA_REQUEST = "Use this link to make a request for data to be published:\n" +
	"https://www.stadt-zuerich.ch/portal/de/index/ogd/kontakt.html"

module.exports = (robot) ->

	robot.respond /(fresh )?(data)( on)?(.*)/i, (res) ->
		query = res.match[res.match.length-1].trim()

		action = "package_search"
		if query is ""
			data = { sort: 'metadata_modified desc' }
			res.reply "Fetching fresh, open data..."
		else if query is "request"
			res.reply DATA_REQUEST
			return
		else
			data = { q: query }
			res.reply "Looking up open '#{query}' data..."

		queryPortal = (client) ->
			logdev.info "Querying #{client.endpoint}"
			portal = client.endpoint.split('//')[1]
			client.action action, data, (err, json) ->
				shown = total = 0
				if err
					logdev.warn "?? #{err}"
				else if !json.success
					logdev.warn "?! #{json.error.message}"
				else
					if json.result.count > 0
						datasets = json.result.results
						total = json.result.count
						shown = datasets.length
						latest = (
						  #"#{ds.title.en}\n" +
							"https://" + portal + "/dataset/" +
							"#{ds.name}" for ds in datasets
							)
						latest = latest[0..2].join '\n'
						res.send "#{latest}"
						if shown < total
							res.send "(#{shown} shown from #{total})"
				if shown < 3
					if ++curClient < clients.length
						queryPortal clients[curClient]
					else
						res.send "Nothing found on that topic - say *data request* for help."

		curClient = 0
		queryPortal clients[0]
