# Description:
#   Commands that interface with Dribdat
#
# Dependencies:
#
# Commands:
#   hubot time - how much time until the hackathon starts or finishes?

module.exports = (robot) ->

  robot.respond /.*time\??/i, (res) ->
    robot.http("http://dribdat.soda.camp/api/event/current.json")
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      data = JSON.parse body
      res.send "#{data.timeuntil}"
