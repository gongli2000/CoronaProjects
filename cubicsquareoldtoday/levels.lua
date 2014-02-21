module(..., package.seeall)
function new()

    local ui = require("ui")
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

   local function pressMenuBack (event)
      if(event.phase=="release") then
          utils.myChangeScene("cubicsquare")
	 display.getCurrentStage():setFocus(nil)
      end
      return true
   end

   local function makebtn(title ,x, y,dy,fontsize,eventtype,listenFunc,id)
      local btn = displaynewText (title,x,y,fontsize)
      btn.id= id
      if(listenFunc~=nil) then
         btn:addEventListener(eventtype,listenFunc)
      end
      localGroup:insert(btn)
      return y+dy
   end


   
   local boardWidth=15 
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
      doboard(boardWidth,localGroup,boardSize,x,y,moves,angles,eventhandler,id)
      makebtn("" ..  getnummoves(angles)  ,x+tdx,y+tdy,dy, fontsize,"touch" ,nil,id) 
      return  y+dy
   end

   local id=1
   local tdy =60
   local tdx = 20

   local background = display.newImage ("images/backgroundblue.png")
   localGroup:insert(background)
   
   local titlebtn = displaynewText ("Solve in the number of moves shown.",20,y-20,16)
   localGroup:insert(titlebtn)

   y =y+ 9
   id=1
   --makeicon(x1,y,dy,tdx,tdy,pressBack,id)
   makeicon(x1,y,dy,tdx,tdy,pressBack,2)
   makeicon(x2,y,dy,tdx,tdy,pressBack,3)
   y=makeicon(x3,y,dy,tdx,tdy,pressBack,4)



   makeicon(x1,y,dy,tdx,tdy,pressBack,5)
   makeicon(x2,y,dy,tdx,tdy,pressBack,6)
   y= makeicon(x3,y,dy,tdx,tdy,pressBack,7)



   makeicon(x1,y,dy,tdx,tdy,pressBack,8)
   makeicon(x2,y,dy,tdx,tdy,pressBack,9)
   y = makeicon(x3,y,dy,tdx,tdy,pressBack,10)


   makeicon(x1,y,dy,tdx,tdy,pressBack,11)
   makeicon(x2,y,dy,tdx,tdy,pressBack,12)
   y = makeicon(x3,y,dy,tdx,tdy,pressBack,13)
   

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
