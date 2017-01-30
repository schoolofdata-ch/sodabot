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
clients[0].requestType = 'GET'
clients.push new CKAN.Client "https://opendata.swiss/en"

DATA_REQUEST = "Use this link to make a request for data to be published:\n" +
	"https://www.stadt-zuerich.ch/portal/de/index/ogd/kontakt.html"

module.exports = (robot) ->

	robot.respond /(fresh )?(data)( on)?(.*)/i, (res) ->
		query = res.match[res.match.length-1].trim()

		if query is ""
			data = { sort: 'metadata_modified desc' }
			res.reply "Fetching fresh, open data..."
		else if query is "request"
			res.reply DATA_REQUEST
			return
		else
			data = { q: query }
			res.reply "Looking up open '#{query}' data..."

		getDsTitle = (title) ->
			title.en || title.de || title.fr || title

		shown = total = 0
		queryPortal = (client) ->
			logdev.info "#{client.endpoint}"
			portal = client.endpoint.split('//')[1]
			portalname = portal.split('/')[0]
			action = "package_search"
			client.action action, data, (err, json) ->
				shownhere = 0
				if err
					logdev.error "Service error"
					logdev.debug "#{err}"
				else if !json.success
					if json.error
						logdev.warn "#{json.error.message}"
					else
						logdev.error "#{json}"
				else
					if json.result.count > 0
						datasets = json.result.results
						total += json.result.count
						shownhere = Math.min(datasets.length, 3)
						shown += shownhere
						latest = (
							"> - [#{getDsTitle(ds.title)}](" +
							"https://" + portal + "/dataset/" +
							"#{ds.name})" for ds in datasets
							)
						latest = latest[0..2].join '\n'
						if shownhere
							res.send "*#{portalname}*\n#{latest}"
				if shownhere < 3
					if ++curClient < clients.length
						queryPortal clients[curClient]
					else if not shown
						res.send "Nothing found on that topic - say *data request* for help."
				else if shown < total
					res.send "(#{shown} shown from #{total})"

		curClient = 0
		queryPortal clients[0]
