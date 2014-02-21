r = display.newRect(100,100,20,20)
r:setFillColor(255,0,0)

g = display.newRect(180,100,20,20)
g:setFillColor(0,255,0)

b = display.newRect(100,200,20,20)
b:setFillColor(0,255,255)

local function center(obj)
   return obj.x,obj.y
end


local function acos(x,y)
   local angle =  math.acos(x/math.sqrt(x*x+y*y))*180/math.pi
   if( y < 0) then
      angle=360-angle
   end
   
   print(x,y,angle)
   return angle
end
local function onTouch( event )
        local t = event.target
 
        -- Print info about the event. For actual production code, you should
        -- not call this function because it wastes CPU resources.
 
        local phase = event.phase
        if "began" == phase then
	        cx = event.x
	        cy = event.y
                -- Make target the top-most object
                local parent = t.parent
                parent:insert( t )
                display.getCurrentStage():setFocus( t )
 
                -- Spurious events can be sent to the target, e.g. the user presses 
                -- elsewhere on the screen and then moves the finger over the target.
                -- To prevent this, we add this flag. Only when it's true will "move"
                -- events be sent to the target.
                t.isFocus = true
 
                -- Store initial position
                t.x0 = event.x - t.x
                t.y0 = event.y - t.y
		curAngle= acos(event.x-100, event.y - 100 )
		print ("fdff")
		oldx = event.x
		oldy = event.y
        elseif t.isFocus then
                if "moved" == phase then
                        -- Make object move (we subtract t.x0,t.y0 so that moves are
                        -- relative to initial grab point, rather than object "snapping").
                   --t.x = event.x - t.x0
                  -- t.y = event.y - t.y0
		   cx,cy = center(t)
		   local line = display.newLine(cx,cy,event.x,event.y)
		   local dx = event.x -cx 
		   local dy = cy - event.y 
		   local newAngle = acos(dx,dy)
		   print(newAngle)
		   t.rotation = newAngle
                elseif "ended" == phase or "cancelled" == phase then
                        display.getCurrentStage():setFocus( nil )
                        t.isFocus = false
                end
        end
 
        -- Important to return true. This tells the system that the event
        -- should not be propagated to listeners of any objects underneath.
        return true
end
 
local function makegroup(a,b)
	local x = display.newGroup()
	x:insert(a)
	x:insert(b)
	x:setReferencePoint(display.CenterReferencePoint)
        a:addEventListener( "touch", onTouch )
        b:addEventListener( "touch", onTouch )
	return x
end

local function doGroupRot(obj1,obj2, time,delay,angle)
  local grp= makegroup(obj1,obj2)
  transition.to(grp,{ time=time,delay =delay,rotation=angle,delta = true})
end

--doGroupRot(r,g,1000,500,45)
doGroupRot(b,g,1000,1500,45)



