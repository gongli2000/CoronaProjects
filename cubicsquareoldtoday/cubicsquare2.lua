-- SUN 7:30 uncomment delete board in reset function
-- 9:08     make rotation work righ
module(..., package.seeall)

function new()
   local starttime
   local titleBtn = nil
   local direction,oldx,oldy
   local finishedTransit = true
   local rowAnchor,colAnchor,angleAnchor,startAngle
   local localGroup = display.newGroup()
   local utils = require("utils")
   local getAnchorPoint3 = utils.getAnchorPoint3
   local displaynewText = utils.displaynewText
   local haveSolution = utils.haveSolution
   local getnummoves = utils.getnummoves
   local colorUtils = require("colors")
   local getRGB = colorUtils.colorsRGB.I
   local getColorIndex  = colorUtils.getColorIndex
   local curNeighborGroup
   local b = nil
   local ind={}
   local n 
   local nummoves=0

  local moveBtn = displaynewText ("",50,display.contentHeight -121,18)
  local nummovesBtn = displaynewText ("Num Moves: 0",50,display.contentHeight -100,18)
  --localGroup:insert(moveBtn)
   if(director.boardSize) then
      n = director.boardSize
   else
      n =4
   end
   local dx=  0.9 * display.contentWidth/n
   local xOffset = (display.contentWidth - n*dx)/2 
   local yOffset = (display.contentHeight - n*dx) /5
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
	 return angle
      else 
	 return -angle
      end
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
	 transition.to(grp,{time=5,rotation =90,delta=true,onComplete=endtap})
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
      local a = acos(dx,dy)
      return  acos(dx,dy)
   end

   local function getNearestAngle(angle,deltatime)
      local argmin
      local thetathreshold=300
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
	 local aa 
	 if deltatime < thetathreshold then
	    aa= {90,90,180,270}
	 else 
	    aa = {0,90,180,270}
	 end
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
	 local aa 
	 if deltatime < thetathreshold then
	    aa = {-90,-90,-180,-270}
	 else
	    aa= {0,-90,-180,-270}
	 end
	 return aa[argmin]
      end
   end

   local function endTouch()
      finishedTransit=true
   end

   local delaytime = 0
   function rotateGroupWithTrans (b,row,col,angle,transtime)
      print(finishedTransit)
      if(finishedTransit) then
	 if(transtime == nil) then
	    transtime=100
	 end
        finishedTransit=false
        local g = makegroup(b,row,col)
	print(row,col,angle,transtime)
        transition.to(g,{time=transtime,delay=0,rotation =angle,delta=false,onComplete=endTouch})
        moveCells2(row,col,angle)
      end
   end 
   
   function rotateGroup (b,row,col,angle)
      local g = makegroup(b,row,col)
      g.rotation = angle
      moveCells2(row,col,angle)
   end 
   
   function doMoves(nmoves,b,boardsize)
      local xf,yf = nil,nil
      if(nmoves >=1 and nmoves <= 4) then
	 if(boardsize==4) then
	    xf = {2,3,2,3}
	    yf = {2,3,3,2}
	 end
	 if(xf ~= nil) then
	    for i =1 , nmoves do
	       rotateGroup(b,xf[i],yf[i],90)
	    end
	 end
      end
   end

   local function getmovestr(rowanchor,colanchor,angle)
      local angleval 
      if(angle == 270) then
	 angle = -90
      elseif (angel==360) then
	 angel=0
      end
      
      if (angle > 0 ) then
	 angleval=1
      else 
	 angleval= 2
      end
      local n = math.abs(angle)/90
      print(n,angle)
      print("faddfsfasdfdsfasdfsdafds:")
      local movestr = {  {{"a","b"},{"c","d"}}, {{"A","B"} , {"C","D"}}  }
      local str =""
      if( n==0) then
	 return ""
      else
	 local i
	 for i =1,n do
	    str = str .. movestr[angleval][rowanchor-1][colanchor-1]
	 end
      end
      return str
   end

   local rotSpeed = 1.0
   local function onTouch( event )
      local endRow,endCol
      local t = event.target
      local phase = event.phase
      if (finishedTransit == false) then
	 return true
      end
      if "began" == phase then
	 starttime = event.time
	 curRow ,curCol = getcoords(event.x,event.y) 
	 startRow,startCol=curRow,curCol
	 cx,cy = event.x , event.y
	 local parent = t.parent
	 parent:insert( t )
	 display.getCurrentStage():setFocus( t )
	 
	 t.isFocus = true
	 
	 oldx ,oldy = event.x , event.y
	 curNeighborGroup = nil
	 rowAnchor,colAnchor= getAnchorPoint3(2, {2,3},{2,3},startRow,startCol) 
	 curNeighborGroup = makegroup(b,rowAnchor,colAnchor)
	 startAngle = getAngle(event,curNeighborGroup)
      elseif t.isFocus then
	 if ("moved" == phase)  then
	    cx,cy = center(curNeighborGroup)
	    local deltaAngle  =   getAngle(event,curNeighborGroup) - startAngle
	    curNeighborGroup.rotation = rotSpeed* deltaAngle
	 elseif "ended" == phase or "cancelled" == phase then
	    if(curNeighborGroup ~= nil) then
	       local deltatime = event.time - starttime
	       local newAngle = getAngle(event,curNeighborGroup)
	       local finalAngle = getNearestAngle(curNeighborGroup.rotation,deltatime)
	       finishedTransit=false
	       transition.to(curNeighborGroup,{time=100,rotation =finalAngle,delta=false,onComplete=endTouch})
               moveCells2(rowAnchor,colAnchor,finalAngle)
	       print(startAngle,newAngle,newAngle-startAngle)
	       moveBtn.text = moveBtn.text .. getmovestr(rowAnchor,colAnchor,finalAngle)
	       local havesol=false
	       if(director.angles ~= nil and getnummoves(director.angles) > 0) then
		  havesol=haveSolution(n,ind)
	       end
	       if(havesol) then
		  local x= native.showAlert( "You've done it!","Do you want to stay at this level or move to next level?", { "Next Level", "Stay On Level" }, nil )
	       end
	       
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
	 y0 = (row-1)* dx  + yOffset
	 for col =1,n do
	    x0 = (col-1)*dx +xOffset
	    board[row][col] =display.newRect(x0,y0,dx,dx)
	    board[row][col]:setFillColor(getRGB(getColorIndex(row,col,n)))
	    board[row][col]:setStrokeColor(0,0,0)
	    board[row][col].strokeWidth=2
	    
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
	    if(board[row][col]~=nil) then
	       board[row][col]:removeSelf()
	    end
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


   local function reset2()
      finishedTransit=true
      deleteBoard(b)
      if(titleBtn~=nil) then
	 titleBtn:removeSelf()
      end
      
      director.board=nil
      if(director.ind) then
	 ind = director.ind
      else
	 ind={}
      end
      if(director.boardSize) then
	 n = director.boardSize
      else
	 n=4
      end
      if(director.moves ~= nil) then
	 local nmoves = getnummoves(director.angles)
	 displaySolveIn(nmoves)
	 b,ind =utils.doboard(dx,nil,n,xOffset,yOffset,director.moves,director.angles,onTouch)
      else    
         titleBtn = displaynewText ("",50,1,18)
	 b,ind =utils.doboard(dx,nil,n,xOffset,yOffset,{},{},onTouch)
      end
      localGroup:insert(titleBtn)
   end
   
   local function doUndoOneMove(event)
      if event.phase == "ended" then
	 reset2()
      end
      return true
   end

   local function playBackString(moveStr) 
      local delaytime=0
      local rottime=100
      for c in string.gmatch(moveStr,".") do
	 if(c=='a') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,2,2,90,rottime) end)
	 elseif(c=='A') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,2,2,-90,rottime) end)
	 elseif(c=='b') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,2,3,90,rottime) end)
	 elseif(c=='B') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,2,3,-90,rottime) end)
	 elseif(c=='c') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,3,2,90,rottime) end)
	 elseif(c=='C') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,3,2,-90,rottime) end)
	 elseif(c=='d') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,3,3,90,rottime) end)
	 elseif(c=='D') then
	    timer.performWithDelay(delaytime, function() rotateGroupWithTrans (b,3,3,-90,rottime) end)
	 end
	 delaytime =  delaytime + rottime+100

      end
   end
  

   local function doReset(event)
      if event.phase == "ended" then
	 --reset2()
	 nummoves=nummoves+1 
	 nummovesBtn.text = "Num moves: " .. nummoves
	 playBackString(moveBtn.text)
      end
      return true
   end


  
  local function doA(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "a"
         rotateGroupWithTrans (b,2,2,90)
      end
    return true
   end
   
  local function doAInv(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "A"
         rotateGroupWithTrans (b,2,2,-90)
      end
    return true
   end
   
  local function doB(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "b"
         rotateGroupWithTrans (b,2,3,90)
      end
    return true
   end
   
  local function doBInv(event)
     if(event.phase == "ended") then
	 moveBtn.text = moveBtn.text .. "B"
         rotateGroupWithTrans (b,2,3,-90)
      end
    return true
   end
   
  local function doC(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "c"
         rotateGroupWithTrans (b,3,2,90)
      end
    return true
   end
   
  local function doCInv(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "C"
         rotateGroupWithTrans (b,3,2,-90)
      end
    return true
   end
   
  local function doD(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "d"
         rotateGroupWithTrans (b,3,3,90)
      end
    return true
   end
   
  local function doDInv(event)
     if(event.phase == "ended") then
	  moveBtn.text = moveBtn.text .. "D"
         rotateGroupWithTrans (b,3,3,-90)
      end
    return true
   end
   

   local function pressResetMoves (event)
      if event.phase == "ended" then
	moveBtn.text=""
      end
      return true
   end
   
   local function pressHelp (event)
      if event.phase == "ended" then
	 reset2()
        -- hideShowBoard(b,false)
	--- director:changeScene ("help")
      end
      return true
   end
   
   local function getnummovesStr(angles)
      local nmoves = getnummoves(director.angles)
      local movestr ="moves"
      if(nmoves == 1) then
	 movestr = "move"
      end
      return movestr
   end
   
   local function displaySolveIn(nmoves)
      if(nmoves > 0) then
	 titleBtn = displaynewText ("Solve in " .. nmoves .. " moves" ,18,display.contentHeight - 120,18)
      else
	 titleBtn = displaynewText ("" ,28,10,18)
      end 
   end
   
   local function reset()
      finishedTransit=true
      if(director.ind) then
	 ind = director.ind
      else
	 ind={}
      end
      if(director.board) then
	 b = director.board
	 hideShowBoard(b,true)
      else
         if(titleBtn ~=nil) then
	    titleBtn:removeSelf()
	 end
	 if(director.boardSize) then
	    n = director.boardSize
	 else
	    n=4
	 end
	 if(director.moves ~= nil) then
	    local nmoves = getnummoves(director.angles)
	    displaySolveIn(nmoves)
	    b,ind =utils.doboard(dx,nil,n,xOffset,yOffset,director.moves,director.angles,onTouch)
	 else
            titleBtn = displaynewText ("",40,1,36)
	    b,ind =utils.doboard(dx,nil,n,xOffset,yOffset,{},{},onTouch)
	 end
         localGroup:insert(titleBtn)
      end
   end
   
   local function pressBack (event)
      if event.phase == "ended" then
	 --deleteBoard(b)
	 director.board = b
	 director.ind = ind
	 hideShowBoard(b,false)
	 -- Runtime:removeEventListener("touch",handleStartTouch)
	 director:changeScene ("menu")
      end
      return true
   end

   local function pressLevels (event)
      if event.phase == "ended" then
         hideShowBoard(b,false)
	 director:changeScene ("levels")
      end
      return true
   end


   local background = display.newImage ("images/backgroundblue.png")
   localGroup:insert(background)

   --Runtime:addEventListener("touch",handleStartTouch)

   local fontsize = 36

   local iconx = -60
   local dicony = 40
   local diconx = 80

   iconx=iconx+diconx
   local helpBtn = display.newImage("images/helpicon.png",system.ResourceDirectory ,iconx, display.contentHeight-dicony)
   helpBtn:addEventListener ("touch", pressHelp)
   localGroup:insert(helpBtn)

   iconx=iconx+diconx
   local infoBtn = display.newImage("images/info.png",system.ResourceDirectory ,iconx, display.contentHeight-dicony)
   infoBtn:addEventListener ("touch", pressResetMoves)
   localGroup:insert(infoBtn)
   
   
   iconx=iconx+diconx
   local aboutBtn = display.newImage("images/puzzleicon.png",system.ResourceDirectory ,iconx, display.contentHeight-dicony)
   aboutBtn:addEventListener ("touch", pressLevels)
   localGroup:insert(aboutBtn)
   
   iconx=iconx+diconx
   local resetBtn = display.newImage("images/undo_32.png",system.ResourceDirectory ,iconx, display.contentHeight-dicony)
   resetBtn:addEventListener ("touch", doReset)
   localGroup:insert(resetBtn)
   
   local function addRotButton(imagefile,x,y,handler)
     local aBtn = display.newImage(imagefile,system.ResourceDirectory ,x,y)
     aBtn:addEventListener ("touch", handler)
     localGroup:insert(aBtn)
   end
   
   reset()

   return localGroup
end
