-- Sun 7:30 uncomment delete board in reset function
-- 9:08     make rotation work righ
module(..., package.seeall)

function new()
   local direction
   local curAngle,rowAnchor,colAnchor,angleAnchor,startAngle
   local localGroup = display.newGroup()
   local utils = require("utils")
   local getAnchorPoint = utils.getAnchorPoint
   local getAnchorPoint2 = utils.getAnchorPoint2

   local colorUtils = require("colors")
   local getRGB = colorUtils.colorsRGB.I
   local getColorIndex  = colorUtils.getColorIndex
   local curNeighborGroup
   local b = nil
   local ind={}
   local n 

   if(director.boardSize) then
      n = director.boardSize
   else
      n =4
   end
   
   local dx= display.contentWidth/n
   local xOffset =0 
   local yOffset = (display.contentHeight - n*dx) /2
   local rI = {-1,-1,-1, 0,0,0, 1 ,1,1}
   local cI = {-1,0,1,-1,0,1,-1,0,1}
   local dotap = true
   local dotouch =true
   local curRow =0
   local curCol = 0
   local endRow,endCol

   local function movedDelta(x0,y0,x1,y1,delta)
      return math.abs(x0-x1) > delta or math.abs(y0-y1) > delta
   end
   local function acos(x,y)
      local angle =  math.acos(x/math.sqrt(x*x+y*y))*180/math.pi
      if( y < 0) then
	 angle=360-angle
      end
      if(angle > 180) then
	 angle = angle-360
      end
      return angle
   end

   local function center(obj)
      return obj.x ,obj.y
   end

   function changeGroup(obj,newGroup) 
      local x,y = obj:localToContent(0, 0) 
      obj.setReferencePoint = display.CenterReferencePoint 
      newGroup:insert(obj) 
      obj.x = x
      obj.y = y 
      obj.rotation = obj.parent.rotation
   end 

   local function endtouch()
   end
   
   local function endtap()
      dotap=true
   end

   local function getNeighbor(bb,row,col,k)
      local r = row+rI[k]
      local c = col+cI[k]
      return bb[r][c]
   end

   local function makegroup(bb,row,col)
      local g = display.newGroup()        
      for k=1,9 do
	 changeGroup(getNeighbor(bb,row,col,k),g) --See function above, using insert        
      end
      g:setReferencePoint(display.CenterReferencePoint)  
      g.rotation=0  
      return g
   end 



   local function getTrans (angle)
      -- 7->1, 4->2, 1->3,8->4,5->5,2->6,9->7,6->8,3->9
      -- 3 -> 1, 6 -> 2, 9 -> 3, 2 -> 4  , 5-> 5, 8->6, 1->7, 4-> 8, 7->9
      if(angle > 0) then
	 return {7,4,1,8,5,2,9,6,3}
      else
	 return {3,6,9,2,5,8,1,4,7}
      end
   end

   -- 1 2 3
   -- 4 5 6
   -- 7 8 9

   -- 7 4 1

   local function moveCells(row,col,angle)
      local t = getTrans(angle)
      local x = {}
      local y = {}
      for k =1,9 do
	 x[k] = getNeighbor(b,row,col,t[k]) 
      end
      for k =1,9 do
	 y[k] = getNeighbor(ind,row,col,t[k])
      end
      for k=1,9 do
	 r = row+rI[k]
	 c = col+cI[k]
	 b[r][c]= x[k]
	 ind[r][c]= y[k]
      end
   end

   local function moveCells2(row,col,angle)
      local nrots = math.abs(angle)/90
      local da
      if (angle < 0 ) then 
	 da =-90
      else
	 da=90
      end
      for i =1,nrots do
	 moveCells(row,col,da)
      end

   end

   
   local function getcoords(x,y)
      local col = math.floor((x-xOffset)/dx)+1
      local row = math.floor((y-yOffset)/dx)+1
      return row,col
   end



   local function handleTap(event)
      if(dotap) then
	 dotap=false
	 row,col= getcoords(event.x,event.y)
	 local grp = makegroup(b,row,col)
	 transition.to(grp,{time=305,rotation =90,delta=true,onComplete=endtap})
	 moveCells(row,col)
	 
      end
   end

   local function getDir(x0,y0,x1,y1)
      local dx = x1-x0
      local dy = y1 -y0
      if(movedDelta(x0,y0,x1,y1,5)) then
	 if (math.abs(dx) > math.abs(dy)) then
	    if(dx > 0 ) then
	       return "right"
	    else
	       return "left"
	    end
	 else
	    if(dy < 0 ) then
	       return "up"
	    else
	       return "down"
	    end
	 end
      else
	 return ""
      end
      
   end
   
   local function getAngle(event, t)
      cx,cy = center(t)
      local dx = event.x -cx 
      local dy = cy - event.y 
      return  acos(dx,dy)
   end

   local function getNearestAngle(angle)
      print(angle)
      local argmin
      local abs=  math.abs 
      if ( angle > 0 ) then
	 local minangle = math.min(abs(angle),abs(90-angle),
				   abs(180-angle), abs(270-angle))
	 local angles = {abs(angle),abs(90-angle),abs(180-angle),abs(270-angle)}
         for i =1,4 do
	    if minangle == angles[i] then
	       argmin = i
	       break
	    end
	 end
	 local aa = {90,90,180,270}
	 return aa[argmin]
      else
	 local minangle = math.min(abs(angle),abs(-90-angle),
				   abs(-180-angle), abs(-270-angle))
	 local angles = {abs(angle),abs(-90-angle),abs(-180-angle),abs(-270-angle)}
         for i =1,4 do
	    if minangle == angles[i] then
	       argmin = i
	       break
	    end
	 end
	 local aa = {-90,-90,-180,-270}
	 return aa[argmin]
      end
   end


   local function onTouch( event )

      local endRow,endCol

      local t = event.target
      
      -- Print info about the event. For actual production code, you should
      -- not call this function because it wastes CPU resources.
      
      local phase = event.phase
      if "began" == phase then

	 curRow ,curCol = getcoords(event.x,event.y) 
	 startRow,startCol=curRow,curCol
	 cx = event.x
	 cy = event.y
	 -- Make target the top-most object
	 local parent = t.parent
	 parent:insert( t )
	 display.getCurrentStage():setFocus( t )
	 
	 t.isFocus = true
	 
	 -- Store initial position
	 t.x0 = event.x - t.x
	 t.y0 = event.y - t.y
	 oldx = event.x
	 oldy = event.y
	 curNeighborGroup = nil
	 rowAnchor=-1
	 startAngle=0
	 direction =""
      elseif t.isFocus then
	 if "moved" == phase then
	    if(rowAnchor == -1) then 
	       direction = getDir(oldx,oldy,event.x,event.y)
	       if(direction ~= "") then
		  rowAnchor,colAnchor,angleAnchor= getAnchorPoint2(n,n,startRow,startCol,direction)
		  if(rowAnchor ~= -1) then
		     curNeighborGroup = makegroup(b,rowAnchor,colAnchor)
		     startAngle = getAngle(event,t)
		     curAngle = startAngle
		  end
	       end
	    else
	       local deltaAngle
	       if(direction == "left" or direction =="up") then
		  deltaAngle  = getAngle(event,t) - curAngle
	       else
		  deltaAngle = curAngle-getAngle(event,t)
	       end
	       curNeighborGroup.rotation = -deltaAngle
	       -- curAngle=newAngle
	    end

	 elseif "ended" == phase or "cancelled" == phase then
	    if(curNeighborGroup) then
	       local newAngle = getAngle(event,t)
	       local finalAngle = getNearestAngle(curNeighborGroup.rotation)
	       print (finalAngle)
	       transition.to(curNeighborGroup,{time=105,rotation =finalAngle,delta=false})
	       moveCells2(rowAnchor,colAnchor,finalAngle)
	    end
	    display.getCurrentStage():setFocus( nil )
	    t.isFocus = false
	 end
      end
      
      -- Important to return true. This tells the system that the event
      -- should not be propagated to listeners of any objects underneath.
      return true
   end

   local function makeBoard(n,dx)
      local board ={}
      ind={}
      local i=1
      for row  = 1,n do
	 board[row] = {}
	 ind[row]={}
	 local r =100*( math.floor((row-1)/2) + 1)
	 y0 = (row-1)* dx  + yOffset
	 for col =1,n do
	    local g = 100*(math.floor((col-1)/2)+1)
	    x0 = (col-1)*dx +xOffset
	    board[row][col] =display.newRect(x0,y0,dx-2,dx-2)
	    board[row][col]:setFillColor(getRGB(getColorIndex(row,col,n)))
	    board[row][col].isVisible=true
	    board[row][col]:addEventListener("touch",onTouch)
	    ind[row][col]=i
	    i=i+1
	 end
      end
      return board
   end

   local function deleteBoard(board)
      for row  = 1,n do
	 for col =1,n do
	    board[row][col]:removeSelf()
	 end
      end
   end

   local function hideShowBoard(board,visible)
      for row  = 1,n do
	 for col =1,n do
	    board[row][col].isVisible = visible
	 end
      end
   end

   local function handleStartTouch  ( event )
      local endRow,endCol
      if(event.phase =="began" )then
	 curRow ,curCol = getcoords(event.x,event.y) 
      elseif (event.phase == "ended") then
	 endRow,endCol = getcoords(event.x,event.y) 
	 if((endRow > 0 ) and (endRow <=n) and (endCol > 0) and (endCol <=n)) then
	    local row,col,angle = getAnchorPoint(n,n,curRow,curCol,endRow,endCol)
	    local grp = makegroup(b,row,col)
	    transition.to(grp,{time=305,rotation =angle,delta=true})
	    moveCells(row,col,angle)
	 end
      end
      return true
   end

   local function reset()
      if(b) then 
	 deleteBoard(b)
      end
      if(director.ind) then
	 ind = director.ind
      else
	 ind={}
      end
      
      if(director.board) then
	 b = director.board
	 hideShowBoard(b,true)
      else
	 if(director.boardSize) then
	    n = director.boardSize
	 else
	    n=4
	 end
	 b = makeBoard(n,dx)
      end
   end


   local function doReset(event)
      reset()
   end

   local function pressBack (event)
      --if event.phase == "ended" then
      --deleteBoard(b)
      director.board = b
      director.ind = ind
      hideShowBoard(b,false)
      -- Runtime:removeEventListener("touch",handleStartTouch)
      director:changeScene ("menu")
      --end
      return true
   end



   --Runtime:addEventListener("touch",handleStartTouch)

   local fontsize = 36

   local backbutton = display.newText ("Menu" , 
				       10,
				       display.contentHeight - 50, nil, fontsize)

   backbutton:addEventListener ("tap", pressBack)
   localGroup:insert(backbutton)


   local resetBtn = display.newText ("Reset" , 
				     160,
				     display.contentHeight - 50, nil, fontsize)

   resetBtn:addEventListener ("tap", doReset)
   localGroup:insert(resetBtn)


   reset()

   return localGroup
end
