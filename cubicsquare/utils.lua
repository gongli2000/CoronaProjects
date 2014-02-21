module(..., package.seeall)

local ui = require("ui")
local colorUtils = require("colors")
local getRGB = colorUtils.colorsRGB.I
local getColorIndex = colorUtils.getColorIndex

local rI = { -1, -1, -1, 0, 0, 0, 1, 1, 1 }
local cI = { -1, 0, 1, -1, 0, 1, -1, 0, 1 }




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



local function getTrans(angle)
    -- 7->1, 4->2, 1->3,8->4,5->5,2->6,9->7,6->8,3->9
    -- 3 -> 1, 6 -> 2, 9 -> 3, 2 -> 4  , 5-> 5, 8->6, 1->7, 4-> 8, 7->9
    if (angle > 0) then
        return { 7, 4, 1, 8, 5, 2, 9, 6, 3 }
    else
        return { 3, 6, 9, 2, 5, 8, 1, 4, 7 }
    end
end

local function moveCells(b, ind, row, col, angle)
    local t = getTrans(angle)
    local x = {}
    local y = {}
    for k = 1, 9 do
        x[k] = getNeighbor(b, row, col, t[k])
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

local function addToDisplayGroup(n, board, group)
    if (group ~= nil) then
        for i = 1, n do
            for j = 1, n do
                changeGroup(board[i][j], group)
            end
        end
    end
end



function rotateGroupWithTrans2(b, row, col, angle, transtime)

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

function playBackMoves(b, ind, moves, angles)
    local delaytime = 0
    local dtime = 0
    local rottime = 0
    local rows = { 2, 2, 3, 3 }
    local cols = { 2, 3, 2, 3 }

    for i, v in ipairs(moves) do
        local angle, nrot;
        if (angles[i] < 0) then
            angle = -90
        else
            angle = 90
        end
        nrot = math.abs(angles[i])
        for j = 1, nrot do
            --rotateGroup(b, ind, rows[v], cols[v], angle)
            timer.performWithDelay(delaytime, function() rotateGroupWithTransx(b, rows[v], cols[v], nrot, rottime) end)
            delaytime = delaytime + rottime + dtime
        end
    end
end


function doboard(w, displaygroup, boardSize, x, y, moves, angles, eventhandler, id)
    local rows = { 2, 2, 3, 3 }
    local cols = { 2, 3, 2, 3 }
    b, ind = makeBoard(boardSize, w, x, y, eventhandler, id)

    --    if director.train then
    --        playBackMoves(b,ind,moves,angles)
    --    else
    for i, v in ipairs(moves) do
        local angle, nrot;
        if (angles[i] < 0) then
            angle = -90
        else
            angle = 90
        end
        nrot = math.abs(angles[i])
        for j = 1, nrot do
            rotateGroup(b, ind, rows[v], cols[v], angle)
        end
    end
    --    end


    addToDisplayGroup(boardSize, b, displaygroup)

    return b, ind
end


function myChangeScene(scene)
    director:changeScene(scene)
end


local function getletter(lastletter, ntimes)
    local x = math.random(8)

    if ((x + 4) % 8 == lastletter) then
        x = (x + 1) % 8
    end

    if (x == lastletter) then
        ntimes = ntimes + 1
    else
        ntimes = 1
    end

    if (ntimes == 3) then
        return getletter(lastletter, 2)
    else
        return x, ntimes
    end
end

function makePlaybackString(n)
    local lastletter, ntimes
    local str = ""
    lastletter = 0
    ntimes = 1

    for i = 1, n do
        lastletter, ntimes = getletter(lastletter, ntimes)
        str = str .. string.sub("abcdABCD", lastletter, lastletter)
    end
    return str
end



function haveSolution(n, indices)
    local ind = 1
    local havesolution = true
    for i = 1, n do
        if (havesolution == false) then
            break
        end

        for j = 1, n do

            if (indices[i][j] ~= ind) then
                havesolution = false
                break
            end
            ind = ind + 1
        end
    end
    return havesolution
end



function makegroup(bb, row, col)
    local g = display.newGroup()
    for k = 1, 9 do
        changeGroup(getNeighbor(bb, row, col, k), g) --See function above, using insert
    end
    g:setReferencePoint(display.CenterReferencePoint)
    g.rotation = 0
    return g
end


function rotateGroup(b, ind, row, col, angle)
    local g = makegroup(b, row, col)
    g.rotation = angle
    moveCells2(b, ind, row, col, angle)
end

function doMoves(nmoves, b, ind, boardsize)
    local xf, yf = nil, nil
    if (nmoves >= 1 and nmoves <= 4) then
        if (boardsize == 4) then
            xf = { 2, 3, 2, 3 }
            yf = { 2, 3, 3, 2 }
        end
        if (xf ~= nil) then
            for i = 1, nmoves do
                rotateGroup(b, ind, xf[i], yf[i], 90)
            end
        end
    end
end


function getnummoves(angles)
    local s = 0
    for i = 1, #angles do
        s = s + math.abs(angles[i])
    end
    return s
end


function getRowColIndex(n, k)
    -- row,col, k start from 1
    return 1 + math.floor((k - 1) / n), 1 + (k - 1) % n
end

function getrect(n, dx, xOffset, yOffset, row, col,strokewidth)

    local y0 = (row - 1) * dx + yOffset
    local x0 = (col - 1) * dx + xOffset

    local r = display.newRect(x0+2, y0+2, 3*dx+1, 3*dx+1)

    r:setFillColor(0,0,0,90)
    r:setStrokeColor(255,0,255)
    r.strokeWidth = 4
    r.isVisible = true

    local lx = x0  + 5 * dx /2
    local ly = y0   + 5 * dx/2
    local line= display.newLine(lx,ly, lx,ly-30)


    local rgb={255,255,255 }
    line:setColor(rgb[1],rgb[2],rgb[3])
    line.width = 4
    line.isVisible = true

    local line1= display.newLine(lx,ly-29, lx-10,ly-30+10)


    line1:setColor(rgb[1],rgb[2],rgb[3])
    line1.width = 4
    line1.isVisible = true

    local line2= display.newLine(lx,ly-29, lx+10,ly-30+10)


    line2:setColor(rgb[1],rgb[2],rgb[3])
    line2.width = 4
    line2.isVisible = true

    return  {r ,line,line1,line2 }
end

function makeBoard(n, dx, xOffset, yOffset, eventhandler, id)
    local board = {}
    local ind = {}
    local i = 1
    for row = 1, n do
        board[row] = {}
        ind[row] = {}
        y0 = (row - 1) * dx + yOffset
        for col = 1, n do
            x0 = (col - 1) * dx + xOffset

            board[row][col] = display.newRect(x0, y0, dx, dx)
            irow, icol = getRowColIndex(n, i)
            board[row][col]:setFillColor(getRGB(getColorIndex(irow, icol, n)))
            board[row][col]:setStrokeColor(0, 0, 0)
            board[row][col].strokeWidth = 2
            board[row][col].isVisible = true
            board[row][col].id = id

            if (eventhandler ~= nil) then
                board[row][col]:addEventListener("touch", eventhandler)
            end
            ind[row][col] = i
            i = i + 1
        end
    end
    return board, ind
end

function getAnchorPoint3(nmod, rowAnchors, colAnchors, row, col)
    return rowAnchors[1 + (row - 1) % nmod], colAnchors[1 + (col - 1) % nmod]
end

function getAnchorPoint(ncols, nrows, orow, ocol, newrow, newcol)
    local rotrow = 0
    local rotcol
    orow = orow - 1
    ocol = ocol - 1
    newrow = newrow - 1
    newcol = newcol - 1
    if (math.abs(newcol - ocol) > math.abs(newrow - orow)) then
        if (newcol > ocol) then -- swipe right
            if (ocol < (ncols - 1)) then
                rotrow = orow + 1
                rotcol = ocol + 1
                if (rotcol == (ncols - 1)) then
                    rotcol = ocol
                end
                if (rotrow >= (nrows - 1)) then
                    rotrow = -(orow - 1)
                end
            end
        else --swipe left
            if (ocol > 0) then
                rotrow = orow + 1
                rotcol = ocol - 1
                if (rotcol == 0) then
                    rotcol = ocol
                end
                if (rotrow >= (nrows - 1)) then
                    rotrow = orow - 1
                else
                    rotrow = -rotrow
                end
            end
        end
    else
        if (newrow > orow) then --swipe downn
            if (orow < (nrows - 1)) then
                rotrow = orow + 1
                rotcol = ocol + 1
                if (rotrow == (nrows - 1)) then
                    rotrow = orow
                end
                if (rotcol >= (ncols - 1)) then
                    rotcol = ocol - 1
                else
                    rotrow = -rotrow
                end
            end
        else --//swipe up
            if (orow > 0) then
                rotrow = orow - 1
                rotcol = ocol + 1
                if (rotrow == 0) then
                    rotrow = orow
                end
                if (rotcol >= (ncols - 1)) then
                    rotcol = ocol - 1
                    rotrow = -rotrow
                end
            end
        end
    end
    local angle = 1
    if (rotrow < 0) then
        angle = -1
        rotrow = rotrow * (-1)
    end
    if (rotrow == 0) then
        return -1, 0, 0
    else
        return (rotrow + 1), (rotcol + 1), angle
    end
end


function getAnchorPoint2(ncols, nrows, orow, ocol, dir)
    local newrow, newcol
    local rowanchors = { 1, 1 }
    local colnanchors = { 2, 2 }
    if (dir == "right") then
        return getAnchorPoint3(2, rowanchors, colanchors, orow, ocol)
    elseif (dir == "left") then
        return getAnchorPoint(ncols, nrows, orow, ocol, orow, ocol - 1)
    elseif (dir == "down") then
        return getAnchorPoint(ncols, nrows, orow, ocol, orow + 1, ocol)
    else
        return getAnchorPoint(ncols, nrows, orow, ocol, orow - 1, ocol)
    end
end

function split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then

            table.insert(Table, cap)
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end


function gap2MoveList(gapmoves)
    local function getcellnum(movestr)
        if (movestr == "a") then return 1
        elseif (movestr == "b") then return 2
        elseif (movestr == "c") then return 3
        else return 4
        end
    end

    local tokens = utils.split(gapmoves, "*")
    local movetable = {}
    local angletable = {}
    for i = 1, #tokens do
        local fields = utils.split(tokens[i], "^")
        table.insert(movetable, getcellnum(fields[1]))
        if (#fields == 1) then
            table.insert(angletable, 1)
        else
            table.insert(angletable, tonumber(fields[2]))
        end
    end
    return movetable, angletable
end

function getmoves(index)
    local moves, angles
    local gmoves = {
        "",

        "a", --1
        "a*d", --2
        "a*b*c", --3

        "a*d*a^-1*d^-1", --4
        "a*b^-1*a*c*b^-1", --5
        "a*b^-1*a*c*a^-1*b", --6

        "a*d*a^-1*d^-1*b^-1*c^-1*b*c", --7
        "a*b^-1*a*c*b^-1*c*d^-2", --8
        "a*d^-1*a*d^-1*a*d^-1*a*d^-1*a*d^-1*a*d^-1", --- 9

        "a*d*a^-1*d^-1*b^-1*c^-1*b*c*a*d*a^-1*d^-1", --10
        "a*d*a^-1*d^-1*b^-1*c^-1*b*c*a*d*a^-1*d^-1*d^-1*a^-1*d*a", --11
        "b*a*b*c*b^-1*c^-1*a*b^-2*a^-2*c*b^-1*c^-1*a*c*b*c^-1*a*b^-1*d^-1*a*d*a^-2*b*a^ -2*b^-2*d*a*d^-1*a", --12
    }
    moves, angles = utils.gap2MoveList(gmoves[index])
    return moves, angles
end

function displaynewText(textstr, x, y, fontsize, r, g, b)
    local font = "MarkerFelt-Thin"
    local tb = display.newText(textstr, x, y, font, fontsize)
    if (r == nil) then
        r, g, b = 0, 0, 0
    end
    tb:setTextColor(r, g, b)
    return tb
end


function makeuiTextButton(localGroup, title, eventHandler, id, x, y)
    local backgroundpng = "images/bluesquare.png"
    local bakcgroundOverpng = "images/bluesquare.png"
    local font = "MarkerFelt-Thin"
    local fontsize = 16
    local btn = ui.newButton{
        default = backgroundpng,
        over = backgroundOverpng,
        onEvent = eventHandler,
        id = title,
        text = title,
        font = font,
        size = fontsize,
        emboss = true
    }
    btn.x = x
    btn.y = y
    localGroup:insert(btn)
end

function makeuiButton(localGroup, iconfile, eventHandler, idstr, x, y)
    local btn = ui.newButton{
        default = iconfile,
        over = iconfile,
        onEvent = eventHandler,
        id = idstr
    }
    btn.x = x
    btn.y = y
    localGroup:insert(btn)
    return btn
end

function filereader()
    local path = system.pathForFile("data.txt", system.DocumentsDirectory)
    local fh, reason = io.open(path, "r")
    if fh then
        local contents = fh:read("*a")
        --print("Contents of " .. path .. "\n" .. contents)
    else
        --print("Reason open failed: " .. reason) -- display failure message in terminal
        fh = io.open(path, "w")
        if fh then
            --print("Created file")
        else
            --print("Create file failed!")
        end
        local numbers = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
        fh:write("Feed me data!\n", numbers[1], numbers[2], "\n")
        for _, v in ipairs(numbers) do
            fh:write(v, " ")
        end
        fh:write("\nNo more data\n")
    end
    io.close(fh)
end
