module(..., package.seeall)



function new()
   local localGroup = display.newGroup()
   --> This is how we start every single file or "screen" in our folder, except for main.lua
   -- and director.lua
   --> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
   ------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   local boardSize=4
   local fontsize = 36

   local x = 50
   local y = 100
   local dy = 75

   local function pressBack (event)
      if event.phase == "ended" then
	 if(event.target) then
	    director.board = nil
	    director.solveNMoves = event.target.id
	 end
	 director:changeScene ("cubicsquare")
      end
      return true
   end

   local function pressMenuBack (event)
      if event.phase == "ended" then
	 director:changeScene ("menu")
      end
      return true
   end

   local function makebtn(title ,x, y,dy,fontsize,id,eventtype,listenFunc,solveNMoves)
      local btn = display.newText (title,x,y,nil,fontsize)
      btn.id= solveNMoves
      btn:addEventListener(eventtype,listenFunc)
      localGroup:insert(btn)
      return y+dy
   end

   local temp = display.newText("Levels", 10,10,nil,40)
   localGroup:insert(temp)
   y = makebtn("Just Play",x,y,dy, 24,1,"touch" ,pressBack,0) 

   y= makebtn("Solve in 1 Move",x,y,dy, 24,1,"touch" ,pressBack,1) 

   y = makebtn("Solve in 2 Moves",x,y,dy, 24,2,"touch" ,pressBack,2) 
   
   y = makebtn("Solve in 3 Moves",x,y,dy, 24,3,"touch" ,pressBack,3) 
   
   y = makebtn("Solve in 4 Moves",x,y,dy, 24,4,"touch" ,pressBack,4 ) 

   y = makebtn("Back",x,y+dy,dy, 24,0,"touch" ,pressMenuBack) 


   return localGroup
end
