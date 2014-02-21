module(...,package.seeall)



function getAnchorPoint(ncols,nrows,orow,ocol,newrow,newcol)
   local rotrow,rotcol
   orow=orow-1
   ocol=ocol-1
   newrow=newrow-1 
   newcol=newcol- 1
   if(math.abs(newcol - ocol) > math.abs(newrow - orow))then
      print("horizontal swipe")
      if(newcol > ocol) then  -- swipe right
	 print("right")
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
	 print("left")
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
      print ("vertical swipe")
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
   local angle=90
   if(rotrow < 0) then
      angle = -90
      rotrow = rotrow*(-1)
   end
   return (rotrow+1),(rotcol+1),angle
end


 
 
