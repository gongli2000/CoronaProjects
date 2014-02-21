module(..., package.seeall)
function new()

    local ui = require("ui")
    local localGroup = display.newGroup()
    --> This is how we start every single file or "screen" in our folder, except for main.lua
    -- and director.lua
    --> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
    ------------------------------------------------------------------------------
    ------------------------------------------------------------------------------

    require("utils")
    local makeBoard = utils.makeBoard
    local makeuiTextButton = utils.makeuiTextButton
    local makeuiButton = utils.makeuiButton
    local rotateGroup = utils.rotateGroup
    local changeGroup = utils.changeGroup
    local doboard = utils.doboard
    local addToDisplayGroup = utils.addToDisplayGroup
    local displaynewText = utils.displaynewText
    local getmoves = utils.getmoves



    local function pressBack(event)
        if (event.phase == "ended") then
            if (event.target) then
                director.board = nil
                director.moves, director.angles = getmoves(event.target.id)
                display.getCurrentStage():setFocus(nil)
            end
            utils.myChangeScene("cubicsquare")
        end
        return true
    end



    local rI = { -1, -1, -1, 0, 0, 0, 1, 1, 1 }
    local cI = { -1, 0, 1, -1, 0, 1, -1, 0, 1 }


    local getnummoves = utils.getnummoves


    local delaytime = 0
    local function getTrans(angle)
        -- 7->1, 4->2, 1->3,8->4,5->5,2->6,9->7,6->8,3->9
        -- 3 -> 1, 6 -> 2, 9 -> 3, 2 -> 4  , 5-> 5, 8->6, 1->7, 4-> 8, 7->9
        if (angle > 0) then
            return { 7, 4, 1, 8, 5, 2, 9, 6, 3 }
        else
            return { 3, 6, 9, 2, 5, 8, 1, 4, 7 }
        end
    end
    local function getNeighbor(bb, row, col, k)
        local r = row + rI[k]
        local c = col + cI[k]
        return bb[r][c]
    end

    function changeGroup(obj, newGroup)
        local x, y = obj:localToContent(0, 0)
        obj.setReferencePoint = display.CenterReferencePoint
        newGroup:insert(obj)
        obj.x = x
        obj.y = y
        obj.rotation = obj.parent.rotation
    end

    local function makegroup(bb, row, col)
        local g = display.newGroup()
        for k = 1, 9 do
            changeGroup(getNeighbor(bb, row, col, k), g) --See function above, using insert
        end
        g:setReferencePoint(display.CenterReferencePoint)
        g.rotation = 0
        return g
    end

    local function moveCells(b, ind, row, col, angle)
        local t = getTrans(angle)
        local x = {}
        local y = {}
        for k = 1, 9 do
            x[k] = getNeighbor(b, row, col, t[k])
        end
        for k = 1, 9 do
            y[k] = getNeighbor(ind, row, col, t[k])
        end
        for k = 1, 9 do
            r = row + rI[k]
            c = col + cI[k]
            b[r][c] = x[k]
            ind[r][c] = y[k]
        end
    end

    local function moveCells2(b, ind, row, col, angle)
        local nrots = math.abs(angle) / 90
        local da
        if (angle < 0) then
            da = -90
        else
            da = 90
        end
        for i = 1, nrots do
            moveCells(b, ind, row, col, da)
        end
    end



    local function rotateGroupWithTrans(b, ind, row, col, angle, transtime)

        local g = makegroup(b, row, col)

        transition.to(g, { time = transtime, delay = 0, rotation = angle, delta = false,onComplete = nil})
        moveCells2(b, ind, row, col, angle)
    end

    local   function changeGroup(obj, newGroup)
        local x, y = obj:localToContent(0, 0)
        obj.setReferencePoint = display.CenterReferencePoint
        newGroup:insert(obj)
        obj.x = x
        obj.y = y
       -- obj.rotation = obj.parent.rotation
    end

    local function makeicon(x, y, dy, tdx, tdy,boardWidth,boardSize, eventhandler, id,angle,row,col,showsquare,rotatetime)

        local moves, angles = getmoves(id)
        local b, ind = doboard(boardWidth, localGroup, boardSize, x, y, moves, angles, eventhandler, id)

        if(showsquare)  then
            local x = utils.getrect( boardSize, boardWidth, x, y, 1,1,4)
            localGroup:insert(x[1])

            localGroup:insert(x[2])
           localGroup:insert(x[3])
            localGroup:insert(x[4])


        end
        if(not(angle==0)) then
            rotateGroupWithTrans(b, ind, row,col, angle, rotatetime)
        end
        return b,ind
    end


    local function writetext(x,y,fontsize,textx)
        local texty=y
        for i = 1, # textx do
            local btn = displaynewText(textx[i], x, texty, fontsize)
            localGroup:insert(btn)
            texty = texty+ fontsize
        end
        return texty
    end



    local id = 1
    local tdy = 60
    local tdx = 20
    local boardWidth = 20
    local boardSize = 4
    local fontsize = 18
    local x = 20
    local y = 60
    local dy = 60



    local background = display.newImage("images/backgroundblue.png")
    localGroup:insert(background)
    local cucurrentYry
    currentY=writetext(20,20,fontsize,
        {
            "Click on a corner square of a 3 x 3 block",
            "of squares. Then swipe or flick to rotate" ,
            "the block. "
        })
    local b1,ind1 =makeicon(display.contentWidth/2-boardWidth*3, currentY+10, dy, tdx, tdy,boardWidth,boardSize, nil, 2,0,2,2,true,0)
    --local b2,ind2 = makeicon(x+160, currentY+10, dy, tdx, tdy,boardWidth,boardSize, nil, 2,-90,2,2,false,2000)

    curentY =writetext(20,180,fontsize,{
        "Try to find a sequence of moves to get",
        "2x2 blocks of one color in the four",
        "corners of the square. Like this:"
    })
    local b3,ind3=makeicon(display.contentWidth/2-boardWidth*3, curentY+10, dy, tdx, tdy,boardWidth,boardSize, nil, 2,-90,2,2,false,5000)


    currentY=writetext(20,330,fontsize, {
        "It isn't necessary to position the " ,
        "3 x 3 block precisly. They will snap ",
        "to nearest location. It's easiest to just" ,
        "flick in the direction you want to rotate."
    })




    local function remove(board,n)
        for i=1,n do
            for j = 1,n do
                board[i][j]:removeSelf()
            end
        end
    end


    local function gomenu(event)
        remove(b1,boardSize)
        --remove(b2,boardSize)
        remove(b3,boardSize)
        utils.myChangeScene("menu")
    end


    makeuiButton(localGroup, "images/myback_48.png", gomenu, "undo", (display.contentWidth) / 2, display.contentHeight - 25)

    --    local ads = require "ads"
    --    ads.hide()

    return localGroup
end
