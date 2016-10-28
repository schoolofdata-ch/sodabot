# Description:
#   Experimental module for Happy Healthy Hackathons
#
# Dependencies:
#
# Commands:
#   hubot who are you - Some info on me and my makers
#   hubot welcome - Introduce the healthy hacker bot
#   hubot ready - Start receving hourly healthy habits
#   hubot quiet - Stop receiving hourly healthy habits

module.exports = (robot) ->

  robot.respond /(who|what) are you.*/i, (res) ->
    res.send "I am a SODA-001 series personal algoristant powered by a Hubot 2 engine - delighted to be with you today :)\nSend questions or suggestions or fork my code at https://github.com/sodacamp/sodabotnik/issues"

  robot.respond /(welcome|why are you here)/i, (res) ->
    res.send ":bell: After a while of working on something intently, human concentration usually takes a dive (we bots usually fare batter) - often for simple reasons like postures or hydration. I am here to help fix that. Tell me when you are READY, and I will send your team a healthy habit every hour - brought to you by Swiss startup http://mysyns.com/"

  remindIntervalId = null
  currentReminder = 0
  reminderTexts = [
    ':potable_water:  Now would be a great time to drink some tap water.',
    ':raising_hand: Did you have a strech within the last hour? Get up and do one now if not.',
    ':deciduous_tree: How about taking a break from the screen - go outside, get some fresh air!',
    ':squirrel: Oh boy, am I happy to see you still @here. Still having fun? Good! No? Watch and follow my lead: https://i.imgur.com/XBAdzwg.mp4',
    ':walking: A quick break from work helps you to *focus* better again. Why not take a quick walk now? You might get some new inspiration.',
    ':eyes: When using screens for a long time, it is healthy to regularly break out and look into the distance to avoid an eye strain. Try to first focus on something that is far away - then gaze in all directions without turning your head.',
    ':neckbeard: Remember to stretch your neck, many people have back and neck pain from holding the same position too long. Make sure you stretch your neck - look over your left then over your right shoulder. You can also use your arm to tilt your head like this: https://www.mskcc.org/sites/default/files/styles/medium/public/node/20311/images/neck-B.jpg',
    ':potable_water: Often humans do not drink enough and get dehydrated, which hinders performance and concentration.',
    ':tired_face: Can you still focus clearly? How many fingers am I holding up _(ツ)_/¯',
    ':man_in_business_suit_levitating: A stretch exercise that I recommend is to stand up straight, holding your arms up and trying to make yourself as tall as possible. Breathe deeply and slowly through your nose. Hold this position for 15-20 seconds.',
    ':back: If you have a stiff lower back you should do this exercise: put one foot on a chair holding your leg straight, then *slowly* lean forward until you feel a stretch old this position for 15-20 seconds, and repeat with the other leg, like this: http://shannonmiller.com/wp-content/uploads/2011/09/standing-hamstring-stretch.jpg',
    ':hurtrealbad: Make sure to sit up right with a straight back and your shoulders facing rather back and hold your chest out with pride. This will avoid a hunchback.',
    ':raised_hand_with_fingers_splayed: When you are typing, make sure that your are not leaning your weight on your wrist, there is a nerve gets pinched and your pinky finger can can start to feel numb. This condition is called Ulnar Tunnel Syndrome and can last a while once it surfaces. If you want to know more about the topic, see http://orthoinfo.aaos.org/topic.cfm?topic=a00025',
    ':footprints: Lets take care of you ankels. Stretch them out a bit, hold your toes up, and flex your ankle upwards. Next hold your tows down and flex into the other direction, repeat this 5-10 times, like this: http://www.posturite.co.uk/media//workstation-exercises/ankle-stretch.gif',
    ':face_with_rolling_eyes: Well, I am out of suggestions for now, but perhaps you have one for me? Write a note to my developers with your feedback by leaving a note in #support or https://github.com/sodacamp/sodabotnik/issues'
  ]

  robot.respond /.*(ready)[!]*/i, (res) ->
    if remindIntervalId
      res.send "I am already active, and you should get a message in the next hour. If you need help *now*, leave a note in #support"
      return
    res.send "OK! I will start checking in on you every once in a while. To shush me, just tell me to be QUIET. Happy hacking!"
    channelActive = true
    remindIntervalId = setInterval () ->
        res.send reminderTexts[currentReminder]
        if ++currentReminder == reminderTexts.length
          currentReminder = 0
          clearInterval(remindIntervalId)
          remindIntervalId = null
      , 1000 * 60 * 60 # TODO: set to every 60 minutes

  robot.respond /.*(quiet)[!]*/i, (res) ->
    if remindIntervalId
      clearInterval(remindIntervalId)
      remindIntervalId = null
      res.send "Fine, I will leave you in peace. Let me know when you are READY to rumble again!"
    else
      res.send "Did I say something? Did you say something?"
