display.setStatusBar (display.HiddenStatusBar)
--> Hides the status bar
local director = require ("director")
--> Imports director

local mainGroup = display.newGroup()
--> Creates a main group

local function onSystemEvent ( event )
   local quitOnDeviceOnly = true
   if quitOnDeviceOnly and system.getInfo("environment")=="device" then
      if( event.type == "applicationExit" ) then
      elseif ( event.type == "applicationSuspend") then
      elseif (event.type == "applicationStart") then
      end
   end
end

local function main()
   --> Adds main function
   
   Runtime:addEventListener( "system", onSystemEvent )
   mainGroup:insert(director.directorView)
   --> Adds the group from director
   
   director:changeScene("menu")
   --> Change the scene, no effects

   
   return true
end

main()
--> Starts our app
