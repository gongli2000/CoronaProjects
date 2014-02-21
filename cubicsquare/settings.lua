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

local y = 100
local dy = 75
local btn4 = display.newText ("4 x 4",120,y,nil,fontsize)
localGroup:insert(btn4)
btn4.id=4

y = y+dy
local btn6 = display.newText ("6 x 6",120,y,nil,fontsize)
localGroup:insert(btn6)
btn6.id=6

y=y+dy
local btn8 = display.newText ("8 x 8",120,y,nil,fontsize)
localGroup:insert(btn8)
btn8.id=8

y=y+dy+dy
local backbutton = display.newText ("Back",120,y,nil,24)
localGroup:insert(backbutton)


local function pressBack (event)
   --if event.phase == "ended" then
      if(event.target) then
	 director.board = nil
         director.boardSize= event.target.id
      end
      director:changeScene ("cubicsquare")
      --end
      return true
end

local function pressMenuBack (event)
   --if event.phase == "ended" then
      director:changeScene ("menu")
      --end
      return true
end
backbutton:addEventListener ("touch", pressMenuBack)
btn4:addEventListener ("touch", pressBack)
btn6:addEventListener ("touch", pressBack)
btn8:addEventListener ("touch", pressBack)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
return localGroup
end
--> This is how we end every file except for director and main, as mentioned in my first comment
