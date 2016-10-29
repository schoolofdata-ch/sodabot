# Description:
#   A module for Happy Healthy Hackathons
#
# Dependencies:
#   "lodash.js"
#   "moment.js"
#
# Commands:
#   hubot time left - How much time until the hackathon starts or finishes?
#   hubot all projects - List all documented projects at the current hackathon.
#   hubot find <query> - Search among all hackathon projects.
#   hubot start project - Get help starting a project
#   hubot update project - Publish project documentation
#   hubot who are you - Some info on me and my makers
#   hubot welcome - Introduce the healthy hacker bot
#   hubot ready - Start receving hourly healthy habits
#   hubot quiet - Stop receiving hourly healthy habits
#   hubot fix <something> - Notify the developers of a problem

moment = require 'moment'
_ = require 'lodash'
fs = require 'fs'

logdev = require('tracer').colorConsole()
logger = require('tracer').dailyfile(
  root: '.'
  maxLogFiles: 5)

DRIBDAT_URL = "http://" + (process.env.DRIBDAT_HOST or "127.0.0.1:5000")
SODABOT_KEY = process.env.SODABOT_KEY or ''

scrunchName = (nm) ->
  return nm.toLowerCase().replace(/[^A-z0-9]/g, "-")

timeUntil = (event) ->
  fmt = "ddd, D MMM YYYY hh:mm:ss"
  sta_at = moment(event.starts_at, fmt)
  end_at = moment(event.ends_at, fmt)
  has_started = sta_at < moment()
  if moment() > end_at then return false
  dt = if has_started then end_at else sta_at
  cc = if has_started then 'will finish' else 'will start'
  suffix = ''
  if has_started and moment(end_at - moment()).hours() in [1, 2]
    suffix = ' - time to get your presentation together!'
  return cc + ' ' + moment(dt, fmt).fromNow() + suffix

module.exports = (robot) ->

  # Load the quote file
  hackyQuotes = require process.cwd() + '/hacky-quotes.json'
  hackyQuotes = _.shuffle hackyQuotes.all

  # Get and cache current event data
  eventInfo = null
  robot.http(DRIBDAT_URL + "/api/event/current/info.json")
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      jsondata = JSON.parse body
      eventInfo = if jsondata then jsondata.event else robot.brain.get('eventInfo')
      if _.isEmpty(eventInfo)
        return logdev.warn "Could not connect to server #{DRIBDAT_URL}"
      timeuntil = timeUntil eventInfo
      robot.brain.set 'eventInfo', eventInfo
      logdev.info "#{eventInfo.name} #{timeuntil}"

  # Log all interactions
  hasIntroduced = false
  robot.hear /(.*)/, (res) ->
    query = res.match[0]
    logger.trace "#{query} [##{res.message.room}]"
    if not remindIntervalId and not hasIntroduced
      setTimeout () ->
        return if hasIntroduced or remindIntervalId
        hasIntroduced = true
        res.send "Hi there! I would love to help you with your project. Say `@sodabot ready` to get general advice, `@sodabot update` to get your documentation set up, or `@sodabot help` for other options."
      , 1000 * 60 * 5

  # Notify the developer of something
  robot.respond /fix (.*)/, (res) ->
    query = res.match[0]
    logdev.warn query + ' #' + res.message.room
    res.send "Thanks for letting us know. If you do not get a response from us soon, post to the wall of shame at https://github.com/sodacamp/sodabotnik/issues"

  robot.respond /(issue|bug|problem|who are you|what are you).*/i, (res) ->
    res.send "I am an alpha personal algoristant powered by a Hubot 2 engine - delighted to be with you today :simple_smile:\nDid you find a bug or have an improvement to suggest? Write a note to my developers by telling me to FIX something, or look for *sodabot* on GitHub and blame her instead!"

  robot.respond /.*(stupid|idiot|blöd).*/i, (res) ->
    res.send "I heard that! :slightly_frowning_face:"

  # List all projects in Dribdat by activity order
  robot.respond /all( projects)?/i, (res) ->
    hasIntroduced = true
    robot.http(DRIBDAT_URL + "/api/event/current/projects.json")
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      data = JSON.parse body
      if data.projects.length == 0
        res.send "No projects to speak of. Have we even started yet? :stuck_out_tongue_closed_eyes:"
      else
        pcount = data.projects.length + 1
        prlist = ""
        for project, ix in data.projects
          roomname = scrunchName project.name
          prlist += ":star: ##{roomname} "
        res.send "#{prlist}:star:\nTo see all #{pcount} projects, visit #{DRIBDAT_URL}"

  # Search for projects in Dribdat
  robot.respond /find( a)?( project)?(.*)/i, (res) ->
    hasIntroduced = true
    query = res.match[res.match.length-1].trim()
    if query is ""
      res.send "Looking for something to work on..? :stuck_out_tongue_closed_eyes:"
      return
    robot.http(DRIBDAT_URL + "/api/project/search.json?q=" + query)
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      data = JSON.parse body
      if data.projects.length == 0
        res.send ":wind_blowing_face: Nothing found. Why not make your own #{query}?"
      else
        res.send "First #{data.projects.length} matches:"
        for project in data.projects
          res.send "*#{project.name}*: #{project.summary} #{DRIBDAT_URL}/project/#{project.id}"

  # Help with picking a name for the project
  hasPicked = false
  robot.respond /start( project)?(.*)/i, (res) ->
    hasIntroduced = true
    query = res.match[res.match.length-1].trim()
    if _.isEmpty(query)
      res.send "You need to specify a name for your team. Say START again followed by a name, like this: `start #{res.message.room}`"
      setTimeout () ->
          return if hasPicked
          res.send "Having trouble finding a name? Try http://www.ykombinator.com/"
          setTimeout () ->
              return if hasPicked
              res.send "Maybe that was not so helpful :laughing: Try this instead: http://www.namemesh.com/company-name-generator/"
            , 1000 * 30
        , 1000 * 5
      return
    hasPicked = true
    teamname = scrunchName query
    roomname = scrunchName res.message.room
    if teamname != roomname
      res.send "Great! You should now start a channel called ##{teamname} ...then invite your team members to it, and then repeat what you just told me from there."
    else
      res.send "Looks like your project has been set up. Say UP when you are ready to update."

  roomtopic = null
  robot.topic (res) ->
    roomtopic = res.message.text
    logdev.debug "Topic changed to #{roomtopic}"

  robot.respond /the topic/i, (res) ->
    res.send roomtopic

  hasExplained = false
  robot.respond /(level up|level down|up)(date )?(project)?(.*)/i, (res) ->
    hasIntroduced = true
    query = res.match[res.match.length-1].trim()
    levelup = 0
    if res.match[0] == 'status'
      return res.send "Change your project status by sending me `level up` or `level down` commands"
    if res.match[0] == 'level up' then levelup = 1
    if res.match[0] == 'level down' then levelup = -1
    if !_.startsWith(query, 'http') then query = ''
    postdata = JSON.stringify({
      'autotext_url': query,
      'levelup': levelup,
      'summary': if roomtopic? then roomtopic else '',
      'hashtag': scrunchName(res.message.room),
      'key': SODABOT_KEY,
    })
    robot.http(DRIBDAT_URL + "/api/project/push.json")
    .header('Content-Type', 'application/json')
    .post(postdata) (err, response, body) ->
      # logdev.debug body
      # error checking code here
      data = JSON.parse body
      if data.error?
        res.send "Sorry, something went wrong. Please check with #support"
        logdev.warn data.error
      else
        project = data.project
        if _.isEmpty(query) and levelup == 0 and project.summary == ''
          res.send "The *topic* of your channel can be used to set the project summary. Append the link to the site where you have hosted the project for a full *description*, e.g. `sodabot up http:/github.com/my/project`\n"
        if !project.id?
          res.send "Sorry, your project could not be synced. Please check with #support"
          logdev.warn project
        else
          res.send "Your project is now *#{project.phase}* at #{DRIBDAT_URL}/project/#{project.id} - set your *status* with `level up` or `level down`."
        if project.score > 30 and not hasExplained
          hasExplained = true
          res.send "Your project is coming together! Now we need you to fill in the blanks. On the README or wiki page which you have linked to this project, please answer the following questions:\n\n- What challenge(s) apply to your project?\n- Describe the problem and why we should care in 3-5 sentences.\n- Describe your solution in 3-5 sentences.\n- Add any screenshots / demo links / photos of the results we should look at.\n- Enter any links or datasets that were key to your progress.\n- Where did this project stand prior to the Climathon?\n- Why do you think your project is relevant for the City of Zurich?\n- Any other comments about your experience."

  # Just say hello
  robot.respond /(hello|hey|gruezi|grüzi|welcome|why are you here)/i, (res) ->
    hasIntroduced = true
    res.send "Hi there! So awesome to be here at this hackathon. After a while of working on something intently human [not bot, mind you :robot_face:] concentration usually takes a dive, often for simple reasons like postures or hydration. I am here to help fix that. If you are READY, I will send your team a healthy habit every half hour - brought to you by @max of #mySYNS\n\nReady?"

  # How much time
  timeAndQuote = (res) ->
    eventInfo = robot.brain.get('eventInfo')
    timeuntil = timeUntil eventInfo
    if timeuntil
      quote = res.random hackyQuotes
      res.send "> #{quote}\n\n#{eventInfo.name} #{timeuntil}"
    else
      res.send "#{eventInfo.name} is over. Hack again soon!"

  # Answer if asked
  robot.respond /time( left)?\??/i, timeAndQuote

  remindAt = 0
  remindIntervalId = null
  robot.respond /.*(yes|ready|s go)[!]*/i, (res) ->
    hasIntroduced = true
    if remindIntervalId
      res.send "All set! You should get messages every next hour. If you need one *now*, leave a note in #support or say TIME."
      return
    res.send "Okay, I will check in on you from time to time. To shush me, just tell me to be QUIET. Happy hacking!"
    remindIntervalId = setInterval () ->
        remindAt = 0 if ++remindAt == hackyQuotes.length
        timeAndQuote res
      , 1000 * 60 * 30

  robot.respond /.*(quiet)[!]*/i, (res) ->
    if remindIntervalId
      clearInterval(remindIntervalId)
      remindIntervalId = null
      res.send "Fine, I will leave you in peace. Let me know when you are READY to rumble again!"
    else
      res.send "Did I say something? Did you say something?"
