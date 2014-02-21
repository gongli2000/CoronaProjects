module (...,package.seeall)

function new()
   local physics = require("physics")
   local localGroup = display.newGroup()
   physics.start() 
   physics.setScale( 60 )
   physics.setGravity( 0, 0 )

   local initialSpeed = 330
   local forceFactor = 10

   local b1 = display.newCircle( 75, 250, 25)
   b1:setFillColor(255, 0, 0); 
   physics.addBody( b1, { density=1, friction=0, bounce=.9, radius=25 } )
   b1:setLinearVelocity( 0, initialSpeed )

   local b2 = display.newCircle( 250, 250, 25)
   b2:setFillColor(0, 0, 255)
   physics.addBody( b2, { density=1, friction=0, bounce=.9, radius=25 } )
   b2:setLinearVelocity( 0, -initialSpeed )

   function ballForce(event) 
      vx = b2.x-b1.x; vy = b2.y-b1.y
      d12 = math.sqrt(vx^2 + vy^2)
      f1x = forceFactor*vx/d12; f1y = forceFactor*vy/d12
      b1:applyForce( f1x, f1y, b1.x, b1.y )
      b2:applyForce( -f1x, -f1y, b2.x, b2.y )
   end

   local oldx,oldy,cx,cy
   local line=nil 
   local function onTouch( event )
      local phase = event.phase
      if "began" == phase then

	 event.target.parent:insert(event.target)
	 display.getCurrentStage():setFocus(event.target)
	 event.target.isFocus=true
	 oldx ,oldy = event.x , event.y
      elseif event.target.isFocus then
	 if ("moved" == phase)  then

	    cx ,cy = event.x , event.y
	    if(line~=nil) then
	       line:removeSelf()
	    end

	    line = display.newLine(oldx,oldy,cx,cy)
	    line:setColor(255,255,255)
	 elseif "ended" == phase or "cancelled" == phase then
	    if(line~=nil) then
	       line:removeSelf()
	       line=nil
	    end
	    display.getCurrentStage():setFocus(nil)
	    event.target.isFocus=false
	    cx ,cy = event.x , event.y
	    transition.to( event.target, { time=550, alpha=1, x=cx, y=cy } )
 
	 end
      end
   end

   local x= display.newText("PLANET",100,100,nil,18)
   x:addEventListener ("touch",onTouch)

   return localGroup
end
