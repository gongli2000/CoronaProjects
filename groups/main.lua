

local r = display.newRect(100,100,20,20) 
r:setFillColor(255,0,0)

local g = display.newRect(180,100,20,20)
g:setFillColor(0,255,0)

local b = display.newRect(100,200,20,20)
b:setFillColor(0,255,255)  

local boxes= {r,g,b}
   
function changeGroup(obj,newGroup) 
	--using group:remove() deletes 
	-- the object. We want to keep the object, so we need to be a 
	-- bit more creative.           
	--Set transform params we want to preserve         
	--local oldGroup = obj.parent
	local x,y = obj:localToContent(0, 0) 
	obj.setReferencePoint = display.CenterReferencePoint 
	--if you are using non-center reference points, remember to reset 
	--them after using this function!          
	newGroup:insert(obj) 
	--Object needs to inherit oldGroup's transform, replace 
	--with saved ones!
	obj.x = x
	obj.y = y 
	--obj.rotation = oldGroup.rotation 
end 



local function makegroup(a,b)
	local x = display.newGroup()        
	changeGroup(a,x) --See function above, using insert        
	changeGroup(b,x) --doesn't preserve transformations!        
	x:setReferencePoint(display.CenterReferencePoint)  
	x.rotation=0  
	return x
end  


local function doGroupRot(obj1,obj2, time,angle)  
	local grp= makegroup(obj1,obj2)
	transition.to(grp,{ time=time,rotation=angle,delta = true})   
end 

local function addPoints  (event )
   local i 
   if( event.y < 200 ) then
      i = 1
   else 
      i=2
   end
   local j = (i+1) % 3 + 1
   doGroupRot(boxes[i],boxes[j],1000,90)
end 


Runtime:addEventListener("tap",addPoints)
