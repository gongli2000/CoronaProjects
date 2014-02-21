module(..., package.seeall)


function new()
   local utils = require("utils")
   local makeuiButton = utils.makeuiButton
   local localGroup = display.newGroup()


   local background = display.newImageRect ("images/helpscreen.png",320,480)
   background.x = display.contentWidth/2
   background.y = display.contentHeight/2
   localGroup:insert(background)


   local function pressBack (event)
       utils.myChangeScene ("menu") --cubicsquare")
   end
   makeuiButton(localGroup,"images/myback_48.png",pressBack,"undo",(display.contentWidth-32)/2, display.contentHeight-30)

--   local ads = require "ads"
--   ads.hide()

   return localGroup
end
