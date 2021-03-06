module(..., package.seeall)

function new()
   local localGroup= display.newGroup()
   local ui = require("ui")

   local function handler(event)
	 director.id=event.target.id
	 director:changeScene("puzzle1")
   end
      
      local function makeMenuItem(text,x,y,menuhandler)
	 local item = display.newText(text,x,y,nil,20)
	 item:addEventListener("tap",handler)
	 item.id =text
	 localGroup:insert(item)
      end

      local items = {"rotar3cups","rotarMovingCup","rotarWall","puzzle2","puzzle3"}
      for i  = 1 , #items do
	 makeMenuItem(items[i],90, 10 + i*60,handler)
      end
      return localGroup
   end
