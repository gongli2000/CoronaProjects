module(..., package.seeall)

function new()
	local localGroup = display.newGroup()
	--> This is how we start every single file or "screen" in our folder, except for main.lua
	-- and director.lua
	--> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
------------------------------------------------------------------------------
------------------------------------------------------------------------------
local background = display.newImage ("blackbackground.png")
localGroup:insert(background)
--> This sets the background

local redbutton = display.newImage ("redbutton.png")
redbutton.x = 160
redbutton.y = 100
localGroup:insert(redbutton)

local bluebutton = display.newImage ("bluebutton.png")
bluebutton.x = 160
bluebutton.y = 225
localGroup:insert(bluebutton)

local yellowbutton = display.newImage ("yellowbutton.png")
yellowbutton.x = 160
yellowbutton.y = 350
localGroup:insert(yellowbutton)
--> This places our three buttons

local function pressRed (event)
if event.phase == "ended" then
director:changeScene ("red")
end
end

redbutton:addEventListener ("touch", pressRed)

local function pressBlue (event)
if event.phase == "ended" then
director:changeScene ("blue")
end
end

bluebutton:addEventListener ("touch", pressBlue)

local function pressYellow (event)
if event.phase == "ended" then
director:changeScene ("yellow")
end
end

yellowbutton:addEventListener ("touch", pressYellow)
--> This adds the functions and listeners to each button

------------------------------------------------------------------------------
------------------------------------------------------------------------------
	return localGroup
end
--> This is how we end every file except for director and main, as mentioned in my first comment