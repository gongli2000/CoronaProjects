

local square = display.newRect( 0, 0, 100, 100 )
square.isVisible=false square:setFillColor( 0,255,255 )
 
local w,h = display.contentWidth, display.contentHeight
 
local square = display.newRect( 0, 0, 100, 100 )
square:setFillColor( 0,255,255 )
 
local w,h = display.contentWidth, display.contentHeight
 
-- (1) move square to bottom right corner; subtract half side-length
--     b/c the local origin is at the square's center; fade out square
--transition.to( square, { time=1500, alpha=0, x=(w-50), y=(h-50) } )
 
-- (2) fade square back in after 2.5 seconds
--transition.to( square, { time=500, delay=2500, alpha=1.0 } )

local function animate(event)
  square.rotation = square.rotation+3
  square.x = square.x+1
  square.y = square.y + 1
end


Runtime:addEventListener("enterFrame", animate)
main()
