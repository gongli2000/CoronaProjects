display.setStatusBar (display.HiddenStatusBar)
--> Hides the status bar
local utils = require("utils")
local director = require ("director")
require("refPointConversions") 
--> Imports director

local mainGroup = display.newGroup()
--> Creates a main group

--local function onSystemEvent ( event )
--    local quitOnDeviceOnly = true
--    if quitOnDeviceOnly and system.getInfo("environment")=="device" then
--        if( event.type == "applicationExit" ) then
--        elseif ( event.type == "applicationSuspend") then
--        elseif (event.type == "applicationStart") then
--        end
--    end
--end

local function main()
   --> Adds main function
   
--   Runtime:addEventListener( "system", onSystemEvent )
   mainGroup:insert(director.directorView)
   --> Adds the group from director
   
   director:changeScene("menu") --"cubicsquare")
   --> Change the scene, no effects

   director.undoIcon="images/reset_48.png"
   director.backIcon = "images/undo_48.png"
   director.train=false
   director.trainlevel=1
   director.rottime=800
   director.playbackstring=utils.makePlaybackString(director.trainlevel)
   utils.filereader()
   --director.sound  = audio.loadSound("sounds/crick.wav")

   local ads = require "ads"
   --ads.init( "inmobi", "4028cbff3a1c0028013a3be914910262" )
   ads.init( "inmobi", "4028cba631d63df10131e1d4650600cd" )            --test

   return true
end

main()
--> Starts our app
