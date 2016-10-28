# Description:
#   Experimental module for Happy Healthy Hackathons
#
# Dependencies:
#   "lodash.js"
#
# Commands:
#   hubot who are you - Some info on me and my makers
#   hubot welcome - Introduce the healthy hacker bot
#   hubot ready - Start receving hourly healthy habits
#   hubot quiet - Stop receiving hourly healthy habits

_ = require 'lodash'

module.exports = (robot) ->

  remindIntervalId = null
  reminderTexts = _.shuffle [
    ':deciduous_tree: A quick break from work helps you to *focus* better again. Why not take a quick walk now? You might get some new inspiration.',
    ':deciduous_tree: How about taking a break from the screen - go outside, get some fresh air!',
    ':eight_spoked_asterisk: Release early, release often. Commit yourself and your team now to going the distance and delivering the ideas you set out with, make something you will be proud of, and make an impact!',
    ':eight_spoked_asterisk: Some things are free. Some things you pay for. Some things are priceless. Your project will have some of each - and in the things-to-pay for category, improvements to software and data and defining work that could be outsourced are good things to consider. Do not limit your options',
    ':eight_spoked_asterisk: Take the task at hand as seriously as you would your regular work. The more you put into a hackathon, the more you get out. But at the same time, use the opportunity to stretch your boundaries and try something new!',
    ':eight_spoked_asterisk: Volunteer events like this hackathon bring people together and raise energy levels, but they are but a small part of a much larger plan and movement. Take a moment to learn more about the organization(s) that have brought us together today.',
    ':face_with_rolling_eyes: Do you have ideas on feature improvements? Feel free to write a note to my developers in the #support channel, or say ISSUE. And hey, I am just a baby bot, so go gentle, okay?'
    ':footprints: A stretch exercise that I recommend is to stand up straight, holding your arms up and trying to make yourself as tall as possible. Breathe deeply and slowly through your nose. Hold this position for 15-20 seconds.',
    ':footprints: Can you still focus clearly? How many fingers am I holding up _(ツ)_/¯ A nap or even 15 min shuteye on the couch would help.',
    ':footprints: Did you have a stretch within the last hour? Get up and do one now if not.',
    ':footprints: If you have a stiff lower back you should do this exercise: put one foot on a chair holding your leg straight, then *slowly* lean forward until you feel a stretch old this position for 15-20 seconds, and repeat with the other leg, like this: http://shannonmiller.com/wp-content/uploads/2011/09/standing-hamstring-stretch.jpg',
    ':footprints: Lets take care of you ankels. Stretch them out a bit, hold your toes up, and flex your ankle upwards. Next hold your tows down and flex into the other direction, repeat this 5-10 times, like this: http://www.posturite.co.uk/media//workstation-exercises/ankle-stretch.gif',
    ':footprints: Make sure to sit up right with a straight back and your shoulders facing rather back and hold your chest out with pride. This will avoid a hunchback.',
    ':footprints: Remember to stretch your neck, many people have back and neck pain from holding the same position too long. Make sure you stretch your neck - look over your left then over your right shoulder. You can also use your arm to tilt your head like this: https://www.mskcc.org/sites/default/files/styles/medium/public/node/20311/images/neck-B.jpg',
    ':footprints: When using screens for a long time, it is healthy to regularly break out and look into the distance to avoid an eye strain. Try to first focus on something that is far away - then gaze in all directions without turning your head.',
    ':footprints: When you are typing, make sure that your are not leaning your weight on your wrist, there is a nerve gets pinched and your pinky finger can can start to feel numb. This condition is called Ulnar Tunnel Syndrome and can last a while once it surfaces. If you want to know more about the topic, see http://orthoinfo.aaos.org/topic.cfm?topic=a00025',
    ':potable_water:  Now would be a great time to drink some tap water. Go. I will still be here when you return.',
    ':potable_water: Often humans do not drink enough and get dehydrated, which hinders performance and concentration. Take 5 and down some tap.',
    ':spock-hand: “Live long, and prosper.” –Spock',
    ':squirrel: Oh boy, am I happy to see you still @here. Still having fun? Good! No? Watch and follow my lead: https://i.imgur.com/XBAdzwg.mp4',
    ':stars: “Do. Or do not. There is no try.” –Yoda',
    ':stars: “I find your lack of faith disturbing.” – Darth Vader',
    ':stars: “It’s not my fault.” – Han Solo',
    ':stars: “Mind tricks don’t work on me.” – Watto',
    ':stars: “Never tell me the odds.” – Han Solo',
    ':stars: “Somebody has to save our skins.” – Leia Organa',
    ':stars: “Stay on target.” – Gold Five',
  ]

  robot.respond /(issue|bug|problem|who are you|what are you).*/i, (res) ->
    res.send "I am a SODA-001 series personal algoristant powered by a Hubot 2 engine - delighted to be with you today :simple_smile:\nDid you find a bug or have an improvement to suggest? Write a note to my developers in the #support channel, or look for *sodabotnik* on GitHub and blame him instead!"

  robot.respond /(hello|hey|gruezi|grüzi|welcome|why are you here)/i, (res) ->
    res.send "Hi there! So awesome to be here at this hackathon. After a while of working on something intently human [not bot, mind you :robot_face:] concentration usually takes a dive, often for simple reasons like postures or hydration. I am here to help fix that. If you are READY, I will send your team a healthy habit every half hour - brought to you by @max of #mySYNS\n\nReady?"

  remindAt = 0
  robot.respond /.*(yes|ready|s go)[!]*/i, (res) ->
    if remindIntervalId
      res.send "All set! You should get a message in the next hour. If you need help *now*, leave a note in #support"
      return
    res.send "Okay, I will check in on you regularly. To shush me, just tell me to be QUIET. Happy hacking!"
    channelActive = true
    remindIntervalId = setInterval () ->
        remindAt = 0 if ++remindAt == reminderTexts.length
        res.send reminderTexts[remindAt]
      , 1000 * 60 * 30

  robot.respond /.*(quiet)[!]*/i, (res) ->
    if remindIntervalId
      clearInterval(remindIntervalId)
      remindIntervalId = null
      res.send "Fine, I will leave you in peace. Let me know when you are READY to rumble again!"
    else
      res.send "Did I say something? Did you say something?"
