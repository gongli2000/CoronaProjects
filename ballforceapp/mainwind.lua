module (...,package.seeall)

function new()
   local editmode=false
   local physics = require("physics")
   local ui = require("ui")
   local localGroup = display.newGroup()
   physics.start() 
   physics.setScale(  54)
   physics.setGravity( 0,0 )

   local forceFactor = 55
   local centerx = display.contentWidth/2
   local centery = display.contentHeight/2
   local b1x , b1y =  centerx ,centery*2-100

   local balls= {}   
   local b1r,b2r,b3r = 15,5,5 
   local b1 = display.newCircle( b1x,b1y, b1r)
   b1:setFillColor(255, 0, 0); 
   local b2density = 100
   local cueBallDensity=99
   local oldx,oldy,cx,cy
   local line=nil 
   local vectorScale = 1.5
   local curBallHandler = {}
   local curRuntimeHandler ={}
   local function getforce(ball1,ball2)
      vx , vy = ball2.x-ball1.x ,  ball2.y-ball1.y
      d12 = math.sqrt(vx^2 + vy^2)
      f1x,f1y = forceFactor*vx/d12, forceFactor*vy/d12
      return f1x,f1y
   end
   
   local function addHandler(event)
      if(event.y < display.contentHeight-100) then
	 x = display.newCircle(event.x,event.y,b1r)
	 x:setFillColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
	 physics.addBody( x) --, { density=50, friction=0, bounce=0, radius=b1r } )
	 x.bodyType="kinematic"
	 table.insert(balls,x)
      end
   end
   
   curBallHandler.type="add"
   curBallHandler.handler = addHandler
   Runtime:addEventListener("tap",addHandler)

   local function setRuntimeHandler(curHandler,newHandler)
      if(curHandler.type ~= nil and curHandler.handler ~= nil) then
	 Runtime:removeEventListener(curHandler.type,curHandler.handler)
      end
      if(newHandler.type ~= nil and newHandler.handler ~= nil) then
	 Runtime:addEventListener(newHandler.type,newHandler.handler)
      end
   end 
   
   local function ballForce(event) 
      local fx,fy  = 0,0
      for i,ball1 in ipairs(balls)  do
	 f1x,f1y =  getforce(b1,ball1)
	 fx = fx + f1x
	 fy = fy + f1y
      end
      b1:applyForce( fx,fy, b1.x, b1.y )
   end

   local function makeuiTextButton (title,eventHandler,id,x,y)
      local backgroundpng  ="buttonBlueMini.png"
      local bakcgroundOverpng = "buttonBlueMiniOver.png"
      local font ="MarkerFelt-Thin"
      local fontsize = 16
      local btn = ui.newButton{
	 default = backgroundpng,
	 over = backgroundOverpng,
	 onEvent = eventHandler,
	 id = id,
	 text = title,
	 font = font,
	 size = fontsize,
	 emboss = true
      }
      btn.x=x
      btn.y=y
      localGroup:insert(btn)
   end
   
   
   local function onTouch( event )
      local phase = event.phase
      if "began" == phase then
	 print("ovedd")
	 event.target.parent:insert(event.target)
	 display.getCurrentStage():setFocus(event.target)
	 event.target.isFocus=true
	 oldx ,oldy = event.target.x , event.target.y
      elseif event.target.isFocus then
	 if ("moved" == phase)  then
	    print("moved")
	    cx ,cy = event.x , event.y
	    if(line~=nil) then
	       line:removeSelf()
	    end
	    print(oldx,oldy,cx,cy)
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
	    local fv = vectorScale
            b1:setLinearVelocity(fv*(cx-oldx) ,fv*(cy-oldy))
            Runtime:addEventListener( "enterFrame", ballForce )
	 end
      end
   end

   local function removeBalls(ballsList)
      for i,ball in pairs(ballsList) do
	 ball:removeSelf()
      end
   end

   local function btnHandler(event)
      if(event.id == "reset") then
	 removeBalls(balls)
	 Runtime:removeEventListener("enterFrame",ballForce)
	 b1:removeEventListener("touch",onTouch)
	 b1:removeSelf()
	 b1 = display.newCircle(b1x,b1y,b1r)
	 b1:addEventListener ("touch",onTouch)
	 b1:setFillColor(255, 0, 0); 
	 physics.addBody( b1, { density=cueBallDensity, friction=0, bounce=0, radius=25 } )
      elseif (event.id == "move") then
	 --curBallHandler.type = "touch"
	 --curBallHandler.handler = moveHandler
      elseif (event.id == "add" ) then
	 if(curBallHandler.type ~= nil and curBallHandler.handler~=nil) then
	    Runtime:removeEventListener(curBallHandler.type,curBallHandler.handler)
	 end
	 curBallHandler.type="tap"
         curBallHandler.handler=addHandler
         Runtime:addEventListener( "tap", addHandler )
      end
      return true
   end
   
   physics.addBody( b1, { density=cueBallDensity, friction=0, bounce=0, radius=b1r } )
   b1:addEventListener ("touch",onTouch)
   
   local dx = 50
   local btnx= 30
   makeuiTextButton("Add", btnHandler, "add", btnx, 2*centery-50)
   
   btnx = btnx+dx
   makeuiTextButton("Move", btnHandler, "move", btnx, 2*centery-50)
   
   btnx = btnx+dx
   makeuiTextButton("Vel", btnHandler, "vel", btnx, 2*centery-50)
   
   btnx = btnx+dx
   makeuiTextButton("Reset", btnHandler, "reset", btnx, 2*centery-50)
   
   return localGroup
end
