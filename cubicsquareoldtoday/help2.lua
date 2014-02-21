module(..., package.seeall)
function new()

   local ui = require("ui")
   local trans = require("transformutils")
   local localGroup = display.newGroup()
   --> This is how we start every single file or "screen" in our folder, except for main.lua
   -- and director.lua
   --> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
   ------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   
   require("utils")
   local makeBoard = utils.makeBoard
   local makeuiTextButton = utils.makeuiTextButton
   local makeuiButton = utils.makeuiButton
   local rotateGroup = utils.rotateGroup
   local changeGroup = utils.changeGroup
   local doboard = utils.doboard
   local addToDisplayGroup = utils.addToDisplayGroup
   local displaynewText = utils.displaynewText
   local getmoves = utils.getmoves



   local function pressBack (event)
      if(event.phase=="ended") then
	 if(event.target) then
	    director.board = nil
	    director.moves,director.angles = getmoves(event.target.id)
        display.getCurrentStage():setFocus(nil)
	 end
     utils.myChangeScene ("cubicsquare")
      end
      return true
   end




   
   local boardWidth=30
   local boardSize=4
   local fontsize = 16
   local x = 20
   local y = 30
   local dy = 102

   x = x+90 
   x1 = x-60
   x2 = x1+90
   x3 = x2+90
   local b,ind
   local moves,angles 

   local getnummoves = utils.getnummoves

   local function makeicon(x,y,dy,tdx,tdy, eventhandler,id)

      local moves,angles = getmoves(id)
      local b,ind= doboard(boardWidth,localGroup,boardSize,x,y,moves,angles,eventhandler,id)

      return b, y+dy
   end

   local id=1
   local tdy =60
   local tdx = 20

   local background = display.newImage ("images/backgroundblue.png")
   localGroup:insert(background)


   local titlebtn = displaynewText ("Swipe or flick the corner of 3x3 blocks" ,20,y-20,  18 )
   localGroup:insert(titlebtn)

   y =y+ 9
   id=1
   local b,y = makeicon(x1,y,dy,tdx,tdy,nil,2)

   trans.rotateGroupWithTrans(b, 2, 2, 45, 1000)

   local function gomenu(event)
       utils.myChangeScene("menu")
   end

   local function pressBack (event)
       utils.myChangeScene ("cubicsquare")
   end
   
   makeuiButton(localGroup,"images/myback_48.png",gomenu,"undo",(display.contentWidth)/2, display.contentHeight-25)

--    local ads = require "ads"
--    ads.hide()

    return localGroup
end
