module(...,package.seeall)


   
function getAnchorPoint(ncols,nrows,orow,ocol,newrow,newcol)
   local rotrow=0
   local rotcol
   orow=orow-1
   ocol=ocol-1
   newrow=newrow-1 
   newcol=newcol- 1
   if(math.abs(newcol - ocol) > math.abs(newrow - orow))then
      if(newcol > ocol) then  -- swipe right
	 if(ocol < (ncols-1)) then
	    rotrow = orow+1
	    rotcol = ocol+1
	    if(rotcol ==  (ncols-1)) then
	       rotcol = ocol
	    end
	    if(rotrow >=(nrows -1)) then
	       rotrow=-(orow-1)
	    end
	 end
      else --swipe left
	 if(ocol > 0) then
	    rotrow = orow+1
	    rotcol = ocol-1
	    if(rotcol ==  0) then 
	       rotcol = ocol
	    end
	    if(rotrow >=(nrows -1)) then
	       rotrow=orow-1
	    else
	       rotrow=-rotrow
	    end
	 end
      end
   else
      if(newrow > orow) then  --swipe downn
	 if(orow < (nrows-1)) then
	    rotrow = orow+1
	    rotcol = ocol+1
	    if(rotrow ==  (nrows-1)) then 
	       rotrow = orow
	    end
	    if(rotcol >=(ncols -1)) then
	       rotcol=ocol-1
	    else
	       rotrow=-rotrow
	    end
	 end
      else --//swipe up
	 if(orow > 0) then 
	    rotrow = orow-1
	    rotcol = ocol+1
	    if(rotrow ==  0) then 
	       rotrow =orow
	    end
	    if(rotcol >=(ncols -1)) then
	       rotcol=ocol-1
	       rotrow=-rotrow
	    end
	 end
      end
   end
   local angle=1
   if(rotrow < 0) then
      angle = -1
      rotrow = rotrow*(-1)
   end
   if(rotrow==0) then
      return -1,0,0
   else
      return (rotrow+1),(rotcol+1),angle
   end
end


function getAnchorPoint2(ncols,nrows,orow,ocol,dir)
   local newrow,newcol
   if(dir == "right") then
      return getAnchorPoint(ncols,nrows,orow,ocol,orow, ocol+1)
   elseif (dir == "left") then
      return getAnchorPoint(ncols,nrows,orow,ocol,orow, ocol-1)
      elseif(dir == "down") then
      return getAnchorPoint(ncols,nrows,orow,ocol,orow+1, ocol)
   else 
      return getAnchorPoint(ncols,nrows,orow,ocol,orow-1, ocol)
   end
end





