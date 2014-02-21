module(..., package.seeall)

local colorUtils = require("colors")

function new()
	local localGroup = display.newGroup()
	--> This is how we start every single file or "screen" in our folder, except for main.lua
	-- and director.lua
	--> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--set background
local background = display.newImage ("blackbackground.png")
localGroup:insert(background)


-- set button
local btnx =100
local btny = 40
local dy = 80
local fontsize = 36


local titleText = display.newText ("Cubic's Square",25,50,nil,40)
localGroup:insert(titleText)
local rectSize = 50
btny = btny+dy
local playBtn = display.newText ("Play",btnx,btny,nil,fontsize)
localGroup:insert(playBtn)

  -- rubicGreen = {21,119,40},
   --rubicRed = {204,0,0},
   --rubicBlue = {6,77,135},
   --rubicYellow = {242,242,37},
local playRect = display.newRect(btnx-rectSize-2,btny,rectSize,rectSize)
playRect:setFillColor(colorUtils.colorsRGB.RGB("rubicYellow"))
localGroup:insert(playRect)

btny = btny+dy
local settingsBtn = display.newText ("Levels",btnx,btny,nil,fontsize)
localGroup:insert(settingsBtn)

local settingsRect = display.newRect(btnx-rectSize-2,btny,rectSize,rectSize)
settingsRect:setFillColor(colorUtils.colorsRGB.RGB("rubicRed"))
localGroup:insert(settingsRect)

btny = btny+dy
local helpBtn = display.newText ("Help", btnx,btny,nil,fontsize)
localGroup:insert(helpBtn)

local helpRect = display.newRect(btnx-rectSize-2,btny,rectSize,rectSize)
helpRect:setFillColor(colorUtils.colorsRGB.RGB("rubicBlue"))
localGroup:insert(helpRect)

--> This adds the functions and listeners to each button
local function pressPlay (event)
	if event.phase == "ended" then
	  director:changeScene ("cubicsquare")
	end
	return true
end

playBtn:addEventListener ("touch", pressPlay)
playRect:addEventListener ("touch", pressPlay)

local function pressSettings (event)
   if event.phase == "ended" then
      director:changeScene ("levels")
   end
end

settingsBtn:addEventListener ("touch", pressSettings)
settingsRect:addEventListener ("touch", pressSettings)

local function pressHelp (event)
   if event.phase == "ended" then
      director:changeScene ("help")
   end
end

helpBtn:addEventListener ("touch", pressHelp)
helpRect:addEventListener ("touch", pressHelp)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
return localGroup
end
--> This is how we end every file except for director and main, as mentioned in my first comment
