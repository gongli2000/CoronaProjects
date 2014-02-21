local utils = require("utils")
local getAnchorPoint = utils.getAnchorPoint
local menuScreen = require("menu")
local colorUtils = require("colors")
local getRGB = colorUtils.colorsRGB.I
local getColorIndex  = colorUtils.getColorIndex
local boardDisplayGroup={}
local b = {}
local ind={}
local n =4
local dx= display.contentWidth/n
local xOffset =0 
local yOffset = (display.contentHeight - n*dx) /2
local curRow = -1
local curCol = -1
local rI = {-1,-1,-1, 0,0,0, 1 ,1,1}
local cI = {-1,0,1,-1,0,1,-1,0,1}
local dotap = true
local curRow =0
local curCol = 0

function changeGroup(obj,newGroup) 

   local x,y = obj:localToContent(0, 0) 
   obj.setReferencePoint = display.CenterReferencePoint 
   newGroup:insert(obj) 
   obj.x = x
   obj.y = y 
   obj.rotation = obj.parent.rotation
end 

local function endtap()
   dotap=true
end

local function getNeighbor(bb,row,col,k)
   local r = row+rI[k]
   local c = col+cI[k]
   return bb[r][c]
end

local function makegroup(row,col)
   local g = display.newGroup()        
   for k=1,9 do
      changeGroup(getNeighbor(b,row,col,k),g) --See function above, using insert        
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

local function moveCells(row,col,angle,oldgrp)
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


local function getcoords(x,y)
   local col = math.floor((x-xOffset)/dx)+1
   local row = math.floor((y-yOffset)/dx)+1
   return row,col
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
	 --board[row][col]:addEventListener("touch",handleStartTouch)
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



local function hideShowBoard(board)
   for row  = 1,n do
      for col =1,n do
	 board[row][col].isVisible= not board[row][col].isVisible
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
	      print(row,col,angle)
	      local grp = makegroup(row,col)
	      transition.to(grp,{time=305,rotation =angle,delta=true})
	      moveCells(row,col,angle,boardDisplayGroup)
	   end
	end
     end



Runtime:addEventListener("touch",handleStartTouch)


local bottom = 400
local button= display.newText( "reset" , 50,bottom ,nil,24)

function button:tap( event )
   deleteBoard(b)
   b=makeBoard(n,dx)
end

button:addEventListener( "tap", button )



local button2 = display.newText( "show/hide" , 150,bottom ,nil,24)

function button2:tap( event )
   hideShowBoard()
   Runtime:removeEventListener("touch",handleStartTouch)
   menuScreen.showHide()
end

button2:addEventListener( "tap", button2 )

b = makeBoard(n,dx)


