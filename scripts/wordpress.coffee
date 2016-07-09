# Description:
#   Connect to a WP instance for crossposting
#
# Dependencies:
#   "wordpress-rest-api"
#
# Commands:
#

WP = require 'wordpress-rest-api'

wpConfigs = require '../presets/wp-setup.json'
wpApiJSON = require '../presets/wp-restapi.json'
wpConfigs.routes = wpApiJSON.routes
wp = new WP { endpoint: wpConfigs.endpoint, username: wpConfigs.username, password: wpConfigs.password, routes: wpApiJSON.routes }

wp.posts().then(data) ->
	console.log data

# module.exports = (robot) ->

	# robot.respond /^(https?:\/\/.*)/i, (res) ->
		# link = res.match[1]
		
