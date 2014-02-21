-- SUN 7:30 uncomment delete board in reset function
-- 9:08     make rotation work righ
module(..., package.seeall)



function new()

    local widget = require "widget"
    local trans = require "transformutils"

    local slider
    local ui = require("ui")
    local starttime
    local titleBtn = nil
    local direction, oldx, oldy
    local finishedTransit = true
    local rowAnchor, colAnchor, angleAnchor, startAngle
    local localGroup = display.newGroup()
    local utils = require("utils")
    local getAnchorPoint3 = utils.getAnchorPoint3
    local makeuiTextButton = utils.makeuiTextButton
    local makeuiButton = utils.makeuiButton
    local displaynewText = utils.displaynewText
    local haveSolution = utils.haveSolution
    local makePlaybackString = utils.makePlaybackString
    local getnummoves = utils.getnummoves
    local colorUtils = require("colors")
    local getRGB = colorUtils.colorsRGB.I
    local getColorIndex = colorUtils.getColorIndex
    local curNeighborGroup
    local b = nil
    local ind = {}
    local n
    local nummoves = 0
    local onCompleteSoln
    local numleft = director.trainlevel
    local backbtn, undobtn, timers


    if (director.boardSize) then
        n = director.boardSize
    else
        n = 4
    end
    local dx = 0.9 * display.contentWidth / n
    local xOffset = (display.contentWidth - n * dx) / 2
    local yOffset = (display.contentHeight - n * dx) / 5 + 20
    local rI = { -1, -1, -1, 0, 0, 0, 1, 1, 1 }
    local cI = { -1, 0, 1, -1, 0, 1, -1, 0, 1 }
    local dotap = true
    local dotouch = true
    local curRow = 0
    local curCol = 0
    local endRow, endCol
    local nummovesBtn = displaynewText("", 50, display.contentHeight - 100, 18)
    local gTransTime = 2000



    local function movedDelta(x0, y0, x1, y1, delta)
        return math.abs(x0 - x1) > delta or math.abs(y0 - y1) > delta
    end






    local function endtouch()
    end

    local function endtap()
        dotap = true
    end




    local function hideShowBoard(board, visible)
        nummovesBtn.isVisible = visible
        for row = 1, n do
            for col = 1, n do
                board[row][col].isVisible = visible
            end
        end
    end





    local function handleTap(event)
        if (dotap) then
            dotap = false
            row, col = trans.getcoords(event.x, event.y,xOffset,yOffset,dx,dy)
            local grp = trans.makegroup(b, row, col)
            transition.to(grp, { time = 5, rotation = 90, delta = true, onComplete = endtap })
            trans.moveCells(b,row, col)
        end
    end

    local function displaySolveIn(nmoves)
        local movestr = "move"
        if (director.train) then

            if (director.trainlevel == 1) then
                movestr = " move"
            else
                movestr = " moves"
            end
            titleBtn.text = "Unscramble in " .. director.trainlevel .. movestr

        elseif (director.mode == "play") then
            titleBtn.text = "Make interesting patterns."
        else
            if (nmoves > 1) then
                movestr = " moves"
            end
            titleBtn.text = "Solve in " .. nmoves .. movestr
        end
    end


    local function endTouch()
        finishedTransit = true
        numleft = numleft - 1

        if (numleft == 0) then
            timers = {}
            displaySolveIn(director.trainlevel)
        end

    end



    local delaytime = 0


    local function getmovestr(rowanchor, colanchor, angle)
        local angleval
        if (angle == 270) then
            angle = -90
        elseif (angel == 360) then
            angel = 0
        end

        if (angle > 0) then
            angleval = 1
        else
            angleval = 2
        end
        local n = math.abs(angle) / 90

        local movestr = { { { "a", "b" }, { "c", "d" } }, { { "A", "B" }, { "C", "D" } } }
        local str = ""
        if (n == 0) then
            return ""
        else
            local i
            for i = 1, n do
                str = str .. movestr[angleval][rowanchor - 1][colanchor - 1]
            end
        end
        return str
    end

    local function deleteBoard(board)
        for row = 1, n do
            for col = 1, n do
                if (board[row][col] ~= nil) then
                    board[row][col]:removeSelf()
                end
            end
        end
    end


    local rotSpeed = 1.0

    local function showSolved()
        if (director.train) then
            titleBtn.text = ""
            local x = native.showAlert("You've done it!",
                "Do you want to stay at this level or go to the next  level?",
                { "Next Level", "Stay On Level" }, onCompleteSol)
        else
            local x = native.showAlert("You've done it!",
                "Do you want to stay at this level or choose another level?",
                { "Another Level", "Stay On Level" }, onCompleteSol)
        end
    end


    local function showNotSolved()
        titleBtn.text = ""
        if (nummoves > 1) then
            local nlevel = director.trainlevel - 1
            if (nlevel < 1) then
                nlevel = 1
            end
            local x = native.showAlert("Oops, you've used up allotted moves.",
                "Do you want try again or go back to level " .. nlevel .. " ?",
                { "Go back", "Try again" }, onCompleteNotSol)
        else
            local y = native.showAlert("Oops, that's not right.",
                "Try again.", { "Okay" }, onCompleteNotSol)
        end
    end
    local function endRotate()
        finishedTransit = true
        numleft = numleft - 1

        if (numleft == 0) then
            timers = {}
            displaySolveIn(director.trainlevel)
        end

    end
    local function onTouch(event)
        local endRow, endCol
        local t = event.target
        local phase = event.phase
        if (finishedTransit == false or (director.train and numleft > 0)) then
            return true
        end
        if "began" == phase then
            starttime = event.time
            curRow, curCol = trans.getcoords(event.x, event.y,xOffset,yOffset,dx,dy)
            startRow, startCol = curRow, curCol
            cx, cy = event.x, event.y
            local parent = t.parent
            parent:insert(t)
            display.getCurrentStage():setFocus(t)

            t.isFocus = true

            oldx, oldy = event.x, event.y
            curNeighborGroup = nil
            rowAnchor, colAnchor = getAnchorPoint3(2, { 2, 3 }, { 2, 3 }, startRow, startCol)
            curNeighborGroup = trans.makegroup(b, rowAnchor, colAnchor)
            startAngle = trans.getAngle(event, curNeighborGroup)
        elseif t.isFocus then
            if ("moved" == phase) then
                cx, cy = trans.center(curNeighborGroup)
                local deltaAngle = trans.getAngle(event, curNeighborGroup) - startAngle
                curNeighborGroup.rotation = rotSpeed * deltaAngle
            elseif "ended" == phase or "cancelled" == phase then
                if (curNeighborGroup ~= nil) then
                    --audio.play(director.sound)
                    nummoves = nummoves + 1
                    local deltatime = event.time - starttime
                    local newAngle = trans.getAngle(event, curNeighborGroup)
                    local finalAngle = trans.getNearestAngle(curNeighborGroup.rotation, deltatime)


                    transition.to(curNeighborGroup, { time = 100, rotation = finalAngle, delta = false, onComplete = endTouch })
                    trans.moveCells2(rowAnchor, colAnchor, finalAngle)
                    --nummovesBtn.text = tonumber( nummovesBtn.text) + 1

                    if (math.abs(finalAngle) > 0) then
                        local havesol = false
                        titleBtn.text = "Move " .. nummoves .. " out of " .. director.trainlevel
                        -- if (director.angles ~= nil and getnummoves(director.angles) > 0) then
                        havesol = haveSolution(n, ind)
                        --end
                        if (havesol and not (director.mode == "play")) then
                            timer.performWithDelay(500, function() showSolved() end)
                        elseif (director.train and nummoves == director.trainlevel) then
                            timer.performWithDelay(500, function() showNotSolved() end)
                        end
                    end
                end
                finishedTransit = true
                display.getCurrentStage():setFocus(nil)
                t.isFocus = false
            end
        end

        -- Important to return true. This tells the system that the event
        -- should not be propagated to listeners of any objects underneath.
        return true
    end



    local function reset2()
        finishedTransit = true
        nummoves = 0
        numleft = director.trainlevel
        deleteBoard(b)


        director.board = nil

        if (director.ind) then
            ind = director.ind
        else
            ind = {}
        end
        if (director.boardSize) then
            n = director.boardSize
        else
            n = 4
        end

        if director.train then
            director.moves = nil
            director.angles = nil
            director.ind = nil
        end

        if (director.moves ~= nil) then
            local nmoves = getnummoves(director.angles)
            displaySolveIn(nmoves)
            b, ind = utils.doboard(dx, nil, n, xOffset, yOffset, director.moves, director.angles, onTouch)
        else

            b, ind = utils.doboard(dx, nil, n, xOffset, yOffset, {}, {}, onTouch)
        end

        if director.train then
            titleBtn.text = "Try to get back to this pattern "
            finishedTransit=false
            timer.performWithDelay(1500, function() trans.playBackString2(b,director.playbackstring,director.trainlevel,titleBtn) end)
        end
    end


    function onCompleteNotSol(event)

        if (nummoves == 1) then
            reset2()
        elseif "clicked" == event.action then
            local i = event.index
            if 2 == i then
                nummovesBtn.text = ""
                reset2()

            elseif 1 == i then

                director.trainlevel = director.trainlevel - 1
                director.playbackstring = makePlaybackString(director.trainlevel)
                reset2()
            end
        end
    end

    function onCompleteSol(event)

        if "clicked" == event.action then
            local i = event.index
            if 2 == i then
                nummovesBtn.text = ""
                director.playbackstring = makePlaybackString(director.trainlevel)
                reset2()

            elseif 1 == i then
                if (director.train) then
                    director.trainlevel = director.trainlevel + 1
                    director.playbackstring = makePlaybackString(director.trainlevel)
                    reset2()
                else
                    hideShowBoard(b, false)
                    utils.myChangeScene("levels")
                end
            end
        end
    end


    local function makeBoard(n, dx)
        local board = {}
        ind = {}
        local i = 1
        for row = 1, n do
            board[row] = {}
            ind[row] = {}
            y0 = (row - 1) * dx + yOffset
            for col = 1, n do
                x0 = (col - 1) * dx + xOffset
                board[row][col] = display.newRect(x0, y0, dx, dx)

                board[row][col]:setFillColor(getRGB(getColorIndex(row, col, n)))
                board[row][col]:setStrokeColor(0, 0, 0)
                board[row][col].strokeWidth = 2

                board[row][col].isVisible = true
                board[row][col]:addEventListener("touch", onTouch)
                ind[row][col] = i
                i = i + 1
            end
        end
        return board
    end







    local function doUndoOneMove(event)
        if event.phase == "ended" then
            reset2()
        end
        return true
    end




    local function getnummovesStr(angles)
        local nmoves = getnummoves(director.angles)
        local movestr = "moves"
        if (nmoves == 1) then
            movestr = "move"
        end
        return movestr
    end



    local function reset()
        finishedTransit = true
        if (director.ind) then
            ind = director.ind
        else
            ind = {}
        end
        if (director.board) then
            b = director.board
            hideShowBoard(b, true)
        else

            if (director.boardSize) then
                n = director.boardSize
            else
                n = 4
            end
            if (director.moves ~= nil) then
                local nmoves = getnummoves(director.angles)
                displaySolveIn(nmoves)
                b, ind = utils.doboard(dx, nil, n, xOffset, yOffset, director.moves, director.angles, onTouch)
            else

                b, ind = utils.doboard(dx, nil, n, xOffset, yOffset, {}, {}, onTouch)
            end
        end
    end

    local function pressBack(event)
        if event.phase == "ended" then
            --deleteBoard(b)
            director.board = b
            director.ind = ind
            hideShowBoard(b, false)
            -- Runtime:removeEventListener("touch",handleStartTouch)
            utils.myChangeScene("menu")
        end
        return true
    end

    local function pressLevels(event)
        if event.phase == "ended" then
            hideShowBoard(b, false)
            utils.myChangeScene("levels")
        end
        return true
    end


    local background = display.newImage("images/backgroundblue.png")
    localGroup:insert(background)

    --Runtime:addEventListener("touch",handleStartTouch)

    local fontsize = 36

    local iconx = -60
    local dicony = 40
    local diconx = 80


    local movesstr
    local function fieldHandler()

        return function(event)

            if ("began" == event.phase) then
                -- This is the "keyboard has appeared" event

            elseif ("ended" == event.phase) then
                -- This event is called when the user stops editing a field:
                -- for example, when they touch a different field or keyboard focus goes away



            elseif ("submitted" == event.phase) then
                -- This event occurs when the user presses the "return" key
                -- (if available) on the onscreen keyboard

                -- Hide keyboard
                native.setKeyboardFocus(nil)
            end
        end -- "return function()"
    end



    local function buttonHandler(event)
        if (event.phase == "release") then

            if (director.train) then
                --                print("timers  " .. table.getn(timers))
                --                if not (timers == nil) and table.getn(timers) > 0 then
                --                    for i = 1, table.getn(timers) do
                --                        timer.cancel(timers[i])
                --                    end
                --                    timers = {}
                --                end
                if (not finishedTransit) then
                    return true
                end
            end


            if (event.id == "help") then
                trans.playBackString(director.playbackstring)
                --                hideShowBoard(b, false)
                --                director:changeScene("help")
            elseif (event.id == "undo") then
                nummovesBtn.text = ""
                reset2()
            elseif (event.id == "puzzle") then
                nummovesBtn.text = ""
                hideShowBoard(b, false)
                utils.myChangeScene("levels")
            elseif (event.id == "info") then
                hideShowBoard(b, false)
                if(director.train) then
                    display.remove(slider)
                    slider=nil
                end
                utils.myChangeScene("menu")
            elseif (event.id == "prev") then
                director.trainlevel = director.trainlevel - 1
                if (director.trainlevel < 1) then
                    director.trainlevel = 1
                end
                director.playbackstring = utils.makePlaybackString(director.trainlevel)
                reset2()
            elseif (event.id == "next") then
                director.trainlevel = director.trainlevel + 1
                director.playbackstring = utils.makePlaybackString(director.trainlevel)
                reset2()
            end
        end
        return true
    end

    local function startOverHandler(event)
        nummovesBtn.text = ""
        reset2()
    end

    if (director.train) then
        iconx = -diconx + 40
    else
        iconx = -diconx + 100
    end

    iconx = iconx + diconx
    backbtn = makeuiButton(localGroup, "images/myback_48.png", buttonHandler, "info", iconx, display.contentHeight - dicony)

    iconx = iconx + diconx
    undobtn = makeuiButton(localGroup, "images/undo_32.png", buttonHandler, "undo", iconx, display.contentHeight - dicony)

    if (director.train) then
        iconx = iconx + diconx
        prevbtn = makeuiButton(localGroup, "images/prevLevel_48.png", buttonHandler, "prev", iconx, display.contentHeight - dicony)

        iconx = iconx + diconx
        nextbtn = makeuiButton(localGroup, "images/nextLevel_48.png", buttonHandler, "next", iconx, display.contentHeight - dicony)
    end

    titleBtn = displaynewText("", 165, 25, 24)
    localGroup:insert(titleBtn)

    reset()





    if director.train then


        local slidervalue2time = function(slidervalue,minTimeSecs,maxTimeSecs)
            return  (minTimeSecs + (slidervalue/100) * maxTimeSecs ) * 1000
        end

        local time2slidervalue = function(t,minTimeSecs,maxTimeSecs)

            return ((t/1000) - minTimeSecs)*100 /maxTimeSecs

        end
        -- slider listener function
        local function sliderListener( event )
            director.rottime = slidervalue2time(event.value, .5 ,3 )
            timebtn.text= string.format("Rotation time: %.1f seconds",director.rottime/1000)
        end


        slider = widget.newSlider{
            top = display.contentHeight - display.contentHeight/6,
            left = 20,
            width = display.contentWidth-display.contentWidth/9,
            value =    time2slidervalue(director.rottime,.5,3),
            cornerRadius=0,
            listener = sliderListener
        }




        print(slider.value)
        slider.value=100
        titleBtn.text = "Try to get back to this pattern "
        finishedTransit=false


        timebtn = displaynewText(string.format("Rotation time: %.1f seconds",director.rottime/1000), 20,370,18)
        localGroup:insert(timebtn)

        timer.performWithDelay(1500, function() trans.playBackString2(b,director.playbackstring,director.trainlevel,titleBtn) end)

    end


    if director.mode == "play" then
        titleBtn.text = "Make interesting patterns"
    end

--    local ads = require"ads"
--    ads.show("banner", { x = 0, y = 0, interval = 60 })


    localGroup.clean = cleanUp
    return localGroup
end
