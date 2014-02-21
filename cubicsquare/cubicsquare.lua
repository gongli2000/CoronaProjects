-- SUN 7:30 uncomment delete board in reset function
-- 9:08     make rotation work righ
module(..., package.seeall)




function new()

    local widget = require"widget"


    local slider, playstring
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
    local backbtn, undobtn, timers, finalAngle


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

    local function acos(x, y)
        local angle = math.acos(x / math.sqrt(x * x + y * y)) * 180 / math.pi
        if (y < 0) then
            return angle
        else
            return -angle
        end
    end

    local function center(obj)
        return obj.x, obj.y
    end

    function changeGroup(obj, newGroup)
        local x, y = obj:localToContent(0, 0)
        obj.setReferencePoint = display.CenterReferencePoint
        newGroup:insert(obj)
        obj.x = x
        obj.y = y
        obj.rotation = obj.parent.rotation
    end


    local function endtap()
        dotap = true
    end

    local function getNeighbor(bb, row, col, k)
        local r = row + rI[k]
        local c = col + cI[k]
        return bb[r][c]
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

    local function hideShowBoard(board, visible)
        nummovesBtn.isVisible = visible
        for row = 1, n do
            for col = 1, n do
                board[row][col].isVisible = visible
            end
        end
    end


    local function getTrans(angle)
        -- 7->1, 4->2, 1->3,8->4,5->5,2->6,9->7,6->8,3->9
        -- 3 -> 1, 6 -> 2, 9 -> 3, 2 -> 4  , 5-> 5, 8->6, 1->7, 4-> 8, 7->9
        if (angle > 0) then
            return { 7, 4, 1, 8, 5, 2, 9, 6, 3 }
        else
            return { 3, 6, 9, 2, 5, 8, 1, 4, 7 }
        end
    end

    -- 1 2 3
    -- 4 5 6
    -- 7 8 9

    -- 7 4 1

    local function moveCells(row, col, angle)
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

    local function moveCells2(row, col, angle)
        local nrots = math.abs(angle) / 90
        local da
        if (angle < 0) then
            da = -90
        else
            da = 90
        end
        for i = 1, nrots do
            moveCells(row, col, da)
        end
    end


    local function getcoords(x, y)
        local col = math.floor((x - xOffset) / dx) + 1
        local row = math.floor((y - yOffset) / dx) + 1
        return row, col
    end



    local function handleTap(event)
        if (dotap) then
            dotap = false
            row, col = getcoords(event.x, event.y)
            local grp = makegroup(b, row, col)
            transition.to(grp, { time = 5, rotation = 90, delta = true, onComplete = endtap })
            moveCells(row, col)
        end
    end

    local function getDir(x0, y0, x1, y1)
        local dx = x1 - x0
        local dy = y1 - y0
        if (movedDelta(x0, y0, x1, y1, 5)) then
            if (math.abs(dx) > math.abs(dy)) then
                if (dx > 0) then
                    return "right"
                else
                    return "left"
                end
            else
                if (dy < 0) then
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
        cx, cy = center(t)
        local dx = event.x - cx
        local dy = cy - event.y
        local a = acos(dx, dy)
        return acos(dx, dy)
    end

    local function getNearestAngle(angle, deltatime)
        local argmin
        local thetathreshold = 300
        local abs = math.abs
        if (angle == 0) then
            return 0
        end

        if (angle > 0) then
            local minangle = math.min(abs(angle), abs(90 - angle),
                abs(180 - angle), abs(270 - angle))


            local angles = { abs(angle), abs(90 - angle), abs(180 - angle), abs(270 - angle) }
            for i = 1, 4 do
                if minangle == angles[i] then
                    argmin = i
                    break
                end
            end
            local aa
            if deltatime < thetathreshold then
                aa = { 90, 90, 180, 270 }
            else
                aa = { 0, 90, 180, 270 }
            end
            return aa[argmin]
        else
            local minangle = math.min(abs(angle), abs(-90 - angle),
                abs(-180 - angle), abs(-270 - angle))
            local angles = { abs(angle), abs(-90 - angle), abs(-180 - angle), abs(-270 - angle) }
            for i = 1, 4 do
                if minangle == angles[i] then
                    argmin = i
                    break
                end
            end
            local aa
            if deltatime < thetathreshold then
                aa = { -90, -90, -180, -270 }
            else
                aa = { 0, -90, -180, -270 }
            end
            return aa[argmin]
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

    local function getmovestr(angle, row, col)
        local x = { "a", "b", "c", "d" }
        local caps = { "A", "B", "C", "D" }
        local k = (row - 2) * 2 + (col - 2) + 1
        local move
        if (angle < 0) then
            move = caps[k]
        else
            move = x[k]
        end
        local n = math.abs(angle) / 90
        local retstr = ""
        for i = 1, n do
            retstr = retstr .. move
        end
        return retstr
    end

    local function endTouch()
        finishedTransit = true
        numleft = numleft - 1

        if (numleft == 0) then
            timers = {}
            displaySolveIn(director.trainlevel)
        end
        if (math.abs(finalAngle) > 0) then
            if (director.mode == "play") then
                local x = getmovestr(finalAngle, rowAnchor, colAnchor)
                playstring.text = playstring.text .. x
            else

                local havesol = false
                titleBtn.text = "Move " .. nummoves
                if (director.train) then
                    titleBtn.text = titleBtn.text .. " out of " .. director.trainlevel
                end
                -- if (director.angles ~= nil and getnummoves(director.angles) > 0) then
                havesol = haveSolution(n, ind)
                --end
                if (havesol and not (director.mode == "play")) then
                    timer.performWithDelay(100, function() showSolved() end)
                elseif (director.train and nummoves == director.trainlevel) then
                    timer.performWithDelay(100, function() showNotSolved() end)
                end
            end
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
    local delaytime = 0
    function rotateGroupWithTrans(b, row, col, angle, transtime)

        if (finishedTransit) then
            if (transtime == nil) then
                transtime = gTransTime
            end
            finishedTransit = false
            local g = makegroup(b, row, col)

            transition.to(g, { time = transtime, delay = 0, rotation = angle, delta = false, onComplete = endRotate })
            moveCells2(row, col, angle)
        end
    end



    function rotateGroupWithTrans2(b, row, col, angle, transtime, onEnd)


        if (transtime == nil) then
            transtime = gTransTime
        end

        local g = makegroup(b, row, col)

        transtime = director.rottime
        transition.to(g, { time = transtime, delay = 0, rotation = angle, delta = false, onComplete = onEnd })
        moveCells2(row, col, angle)
    end


    function rotateGroup(b, row, col, angle)
        local g = makegroup(b, row, col)
        g.rotation = angle
        moveCells2(row, col, angle)
    end

    function doMoves(nmoves, b, boardsize)
        local xf, yf = nil, nil
        if (nmoves >= 1 and nmoves <= 4) then
            if (boardsize == 4) then
                xf = { 2, 3, 2, 3 }
                yf = { 2, 3, 3, 2 }
            end
            if (xf ~= nil) then
                for i = 1, nmoves do
                    rotateGroup(b, xf[i], yf[i], 90)
                end
            end
        end
    end

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



    local function onTouch(event)
        local endRow, endCol
        local t = event.target
        local phase = event.phase
        if (finishedTransit == false or (director.train and numleft > 0)) then
            return true
        end
        if "began" == phase then
            starttime = event.time
            curRow, curCol = getcoords(event.x, event.y)
            startRow, startCol = curRow, curCol
            cx, cy = event.x, event.y
            local parent = t.parent
            parent:insert(t)
            display.getCurrentStage():setFocus(t)

            t.isFocus = true

            oldx, oldy = event.x, event.y
            curNeighborGroup = nil
            rowAnchor, colAnchor = getAnchorPoint3(2, { 2, 3 }, { 2, 3 }, startRow, startCol)
            curNeighborGroup = makegroup(b, rowAnchor, colAnchor)
            startAngle = getAngle(event, curNeighborGroup)
        elseif t.isFocus then
            if ("moved" == phase) then
                cx, cy = center(curNeighborGroup)
                local deltaAngle = getAngle(event, curNeighborGroup) - startAngle
                curNeighborGroup.rotation = rotSpeed * deltaAngle
            elseif "ended" == phase or "cancelled" == phase then
                if (curNeighborGroup ~= nil) then
                    --audio.play(director.sound)
                    nummoves = nummoves + 1
                    local deltatime = event.time - starttime
                    local newAngle = getAngle(event, curNeighborGroup)
                    finalAngle = getNearestAngle(curNeighborGroup.rotation, deltatime)

                    finishedTransit = false
                    transition.to(curNeighborGroup, { time = 100, rotation = finalAngle, delta = false, onComplete = endTouch })
                    moveCells2(rowAnchor, colAnchor, finalAngle)
                    --nummovesBtn.text = tonumber( nummovesBtn.text) + 1
                end

                display.getCurrentStage():setFocus(nil)
                t.isFocus = false
            end
        end

        -- Important to return true. This tells the system that the event
        -- should not be propagated to listeners of any objects underneath.
        return true
    end

    local function playBackString2(movestr, count)

        finishedTransit = false
        numleft = 0
        displaySolveIn(director.trainlevel)
        local rottime = director.rottime
        if (string.len(movestr) > 0) then

            local restmoves = string.sub(movestr, 2)
            local c = string.char(string.byte(movestr, 1))
            if(count > 0) then
                count = count - 1
                titleBtn.text = "Just a sec. Scrambling... " .. count + 1
            end

            if (c == 'a') then
                rotateGroupWithTrans2(b, 2, 2, 90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'A') then
                rotateGroupWithTrans2(b, 2, 2, -90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'b') then
                rotateGroupWithTrans2(b, 2, 3, 90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'B') then
                rotateGroupWithTrans2(b, 2, 3, -90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'c') then
                rotateGroupWithTrans2(b, 3, 2, 90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'C') then
                rotateGroupWithTrans2(b, 3, 2, -90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'd') then
                rotateGroupWithTrans2(b, 3, 3, 90, rottime, function() playBackString2(restmoves, count) end)
            elseif (c == 'D') then
                rotateGroupWithTrans2(b, 3, 3, -90, rottime, function() playBackString2(restmoves, count) end)
            end
        else
            finishedTransit = true
        end
    end

    local function playBackString(moveStr)
        local delaytime = 300
        local dtime = 200
        local rottime = 500
        timers = {}

        for i = 1, string.len(moveStr) do
            local c = string.char(string.byte(moveStr, i))


            if (c == 'a') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 2, 2, 90, rottime) end)
            elseif (c == 'A') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 2, 2, -90, rottime) end)
            elseif (c == 'b') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 2, 3, 90, rottime) end)
            elseif (c == 'B') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 2, 3, -90, rottime) end)
            elseif (c == 'c') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 3, 2, 90, rottime) end)
            elseif (c == 'C') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 3, 2, -90, rottime) end)
            elseif (c == 'd') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 3, 3, 90, rottime) end)
            elseif (c == 'D') then
                timers[i] = timer.performWithDelay(delaytime, function() rotateGroupWithTrans(b, 3, 3, -90, rottime) end)
            end
            i = i + 1
            delaytime = delaytime + rottime + dtime
        end
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
            finishedTransit = false
            timer.performWithDelay(1500, function() playBackString2(director.playbackstring, director.trainlevel) end)
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

            if (event.id == "help") then
                playBackString(director.playbackstring)
                --                hideShowBoard(b, false)
                --                director:changeScene("help")
            elseif (event.id == "undo" and finishedTransit) then
                nummovesBtn.text = ""
                playstring.text=""
                print("undo")
                reset2()


            elseif (event.id == "info" and finishedTransit) then
                hideShowBoard(b, false)

                if (director.train) then
                    display.remove(slider)
                    slider = nil
                end
                utils.myChangeScene("menu")
            elseif (event.id == "prev" and finishedTransit) then
                if (director.mode == "play") then
                    if (string.len(playstring.text) > 0) then
                        playstring.text = string.sub(playstring.text, 1, string.len(playstring.text) - 1)
                    end
                else
                    director.trainlevel = director.trainlevel - 1
                    if (director.trainlevel < 1) then
                        director.trainlevel = 1
                    end
                    director.playbackstring = utils.makePlaybackString(director.trainlevel)

                    reset2()
                end
            elseif (event.id == "next" and finishedTransit) then
                if (director.mode == "play") then

                    director.rottime = 300
                     playBackString2(playstring.text,0)

                else
                    director.trainlevel = director.trainlevel + 1
                    director.playbackstring = utils.makePlaybackString(director.trainlevel)
                    reset2()
                end
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
        iconx = -diconx + 40
    end

    iconx = iconx + diconx
    backbtn = makeuiButton(localGroup, "images/myback_48.png", buttonHandler, "info", iconx, display.contentHeight - dicony)

    iconx = iconx + diconx
    undobtn = makeuiButton(localGroup, "images/undo_32.png", buttonHandler, "undo", iconx, display.contentHeight - dicony)

    titleBtn = displaynewText("", 165, 25, 24)
    localGroup:insert(titleBtn)

    reset()


    if director.train then

        iconx = iconx + diconx
        prevbtn = makeuiButton(localGroup, "images/prevLevel_48.png", buttonHandler, "prev", iconx, display.contentHeight - dicony)

        iconx = iconx + diconx
        nextbtn = makeuiButton(localGroup, "images/nextLevel_48.png", buttonHandler, "next", iconx, display.contentHeight - dicony)

        local slidervalue2time = function(slidervalue, minTimeSecs, maxTimeSecs)
            return (minTimeSecs + (slidervalue / 100) * maxTimeSecs) * 1000
        end

        local time2slidervalue = function(t, minTimeSecs, maxTimeSecs)

            return ((t / 1000) - minTimeSecs) * 100 / maxTimeSecs
        end
        -- slider listener function
        local function sliderListener(event)
            director.rottime = slidervalue2time(event.value, .5, 3)
            timebtn.text = string.format("Rotation time: %.1f seconds", director.rottime / 1000)
        end


        slider = widget.newSlider{
            top = display.contentHeight - display.contentHeight / 6,
            left = 20,
            width = display.contentWidth - display.contentWidth / 9,
            value = time2slidervalue(director.rottime, .5, 3),
            cornerRadius = 0,
            listener = sliderListener
        }

        slider.value = 100
        titleBtn.text = "Try to get back to this pattern "
        finishedTransit = false


        timebtn = displaynewText(string.format("Rotation time: %.1f seconds", director.rottime / 1000), 20, 370, 18)
        localGroup:insert(timebtn)

        timer.performWithDelay(1500, function() playBackString2(director.playbackstring, director.trainlevel) end)
    end

    playstring = displaynewText("", display.contentWidth / 2, 360, 18)
    localGroup:insert(playstring)

    if director.mode == "play" then
        titleBtn.text = "Make interesting patterns"

        local function movehandler(event)
            if (event.phase == "release" and finishedTransit) then
                if (string.len(playstring.text) < 25) then
                    director.rottime =300
                    playBackString2(event.id,0)
                    playstring.text = playstring.text .. event.id
                else
                    native.showAlert("You can only record up to 25 moves",
                        "",
                        { "Okay" }, nil)
                end
            end
        end

        iconx = iconx + diconx
        prevbtn = makeuiButton(localGroup, "images/prevLevel_48.png", buttonHandler, "prev", iconx, display.contentHeight - dicony)


        iconx = iconx + diconx
        nextbtn = makeuiButton(localGroup, "images/nextLevel_48.png", buttonHandler, "next", iconx, display.contentHeight - dicony)

        local btnx = 40
        local btny = 400
        local dy = 35
        utils.makeuiTextButton(localGroup, "a", movehandler, 1, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "A", movehandler, 2, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "b", movehandler, 3, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "B", movehandler, 4, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "c", movehandler, 5, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "C", movehandler, 6, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "d", movehandler, 7, btnx, btny); btnx = btnx + dy
        utils.makeuiTextButton(localGroup, "D", movehandler, 8, btnx, btny); btnx = btnx + dy
    end

    --    local ads = require"ads"
    --    ads.show("banner", { x = 0, y = 0, interval = 60 })


    localGroup.clean = cleanUp
    return localGroup
end
