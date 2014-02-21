local physics = require("physics")
physics.start()
physics.setScale( 60 )
 
display.setStatusBar( display.HiddenStatusBar )
 
local bkg = display.newImage( "clouds.png" )
 
borderCollisionFilter = { categoryBits = 1, maskBits = 6 } -- collides with (4 & 2) only
borderBodyElement = { friction=0, bounce=.5, filter=borderCollisionFilter }
 
local borderTop = display.newRect( 0, 0, 320, 1 )
borderTop:setFillColor( 0, 0, 0, 0)             -- make invisible
physics.addBody( borderTop, "static", borderBodyElement )
 
local borderBottom = display.newRect( 0, 479, 320, 1 )
borderBottom:setFillColor( 0, 0, 0, 0)          -- make invisible
physics.addBody( borderBottom, "static", borderBodyElement )
 
local borderLeft = display.newRect( 0, 1, 1, 480 )
borderLeft:setFillColor( 0, 0, 0, 0)            -- make invisible
physics.addBody( borderLeft, "static", borderBodyElement )
 
local borderRight = display.newRect( 319, 1, 1, 480 )
borderRight:setFillColor( 0, 0, 0, 0)           -- make invisible
physics.addBody( borderRight, "static", borderBodyElement )
 
 
local red = {}
 
 
local redCollisionFilter = { categoryBits = 2, maskBits = 3 } -- collides with (2 & 1) only
 
 
local redBody = { density=0.4, friction=0, bounce=0.8, radius=43.0, filter=redCollisionFilter }
 
 
 
for i = 1,4 do
        red[i] = display.newImage( "red.png", (80*i)-60, 50 + math.random(20) )
        physics.addBody( red[i], redBody )
        red[i].isFixedRotation = true
        
 
end