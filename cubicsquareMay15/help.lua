module(..., package.seeall)

function new()
	local localGroup = display.newGroup()
	--> This is how we start every single file or "screen" in our folder, except for main.lua
	-- and director.lua
	--> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
------------------------------------------------------------------------------
------------------------------------------------------------------------------
local background = display.newImage ("helpscreen.png")
localGroup:insert(background)
--> This sets the background

local backbutton = display.newText ("Menu",42,420,nil,36)
localGroup:insert(backbutton)
--> This places our "back" button

local function pressBack (event)
if event.phase == "ended" then
director:changeScene ("menu")
end
end

backbutton:addEventListener ("touch", pressBack)
--> This adds the function and listener to the "back" button

------------------------------------------------------------------------------
------------------------------------------------------------------------------
	return localGroup
end
--> This is how we end every file except for director and main, as mentioned in my first comment
