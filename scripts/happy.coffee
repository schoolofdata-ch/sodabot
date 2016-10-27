# Description:
#   Experimental module for Happy Healthy Hackathons
#
# Dependencies:
#
# Commands:
#   hubot who are you - Some info on me and my makers
#   hubot welcome - Get started with the healthy hacker bot

module.exports = (robot) ->

  robot.respond /(who|what) are you.*/i, (res) ->
    res.send "I am a SODA-001 series personal algoristant powered by a Hubot 2 engine - delighted to be with you today :)\nSend questions or suggestions or fork my code at https://github.com/sodacamp/sodabotnik/issues"

  robot.respond /(welcome|why are you here)/i, (res) ->
    res.send "Hi! I am here to make sure that you take good care of yourself during this hackathon.\nAfter a while of working on something intently, human concentration usually takes a dive (we bots usually fare batter) - and at some point you even experience pain from staying in the same position too long. Often humans do not drink enough and get dehydrated, which hinders performance and concentration.\nI am here to help fix that. Tell me when you are READY!"

  remindIntervalId = null
  currentReminder = 0
  reminderTexts = [
    ':potable_water:  Now would be a great time to drink some tap water.',
    ':raising_hand: Did you have a strech within the last hour? Get up and do one now if not.',
    ':deciduous_tree: How about taking a break from the screen - go outside, get some fresh air!',
    ':tired_face: Can you still focus clearly? How many fingers am I holding up _(ツ)_/¯',
    'Boy, am I happy to see you still with me. That is all for now.',
  ]

  robot.respond /.*(ready)[!]*/i, (res) ->
    if remindIntervalId
      res.send "I am already active. Everybody chill."
      return
    res.send "OK! I will start checking in on you every once in a while. To shush me, just tell me to be QUIET. Happy hacking!"
    channelActive = true
    currentReminder = 0
    remindIntervalId = setInterval () ->
        res.send reminderTexts[currentReminder]
        if ++currentReminder == reminderTexts.length
          currentReminder = 0
          clearInterval(remindIntervalId)
          remindIntervalId = null
      , 1000 * 60 * 0.1 # TODO: set to every 25 or 55 minutes

  robot.respond /.*(quiet)[!]*/i, (res) ->
    if remindIntervalId
      clearInterval(remindIntervalId)
      remindIntervalId = null
      res.send "Fine, I will leave you in peace. Let me know when you are READY to rumble again!"
    else
      res.send "Did I say something? Did you say something?"
