
module(...,package.seeall)

local backbtn = display.newText("fdfds",100,100,nil,24)
backbtn.isVisible=false

function showHide()
   backbtn.isVisible = not backbtn.isVisible
   
end


function backbtn:tap(event)
   hideShowBoard()
   Runtime:addEventListener("touch",handleStartTouch)
   print("back")
end

backbtn:addEventListener("tap",backbtn)
