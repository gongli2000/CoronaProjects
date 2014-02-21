--
-- Created by IntelliJ IDEA.
-- User: macbookpro
-- Date: 10/16/12
-- Time: 10:04 AM
-- To change this template use File | Settings | File Templates.
--

module(..., package.seeall)

local utils = require("utils")
function acos(x, y)
    local angle = math.acos(x / math.sqrt(x * x + y * y)) * 180 / math.pi
    if (y < 0) then
        return angle
    else
        return -angle
    end
end

function center(obj)
    return obj.x, obj.y
end

function getAngle(event, t)
    cx, cy = center(t)
    local dx = event.x - cx
    local dy = cy - event.y
    local a = acos(dx, dy)
    return acos(dx, dy)
end


function getTrans(angle)
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

function moveCells(b,row, col, angle)
    local t = getTrans(angle)
    local x = {}
    local y = {}
    for k = 1, 9 do
        x[k] = utils.getNeighbor(b, row, col, t[k])
    end
    for k = 1, 9 do
        y[k] = utils.getNeighbor(b,ind, row, col, t[k])
    end
    for k = 1, 9 do
        r = row + rI[k]
        c = col + cI[k]
        b[r][c] = x[k]
        ind[r][c] = y[k]
    end
end

function moveCells2(b,row, col, angle)
    local nrots = math.abs(angle) / 90
    local da
    if (angle < 0) then
        da = -90
    else
        da = 90
    end
    for i = 1, nrots do
        moveCells(b,row, col, da)
    end
end


function getcoords(x, y,xOffset,yOffset,dx,dy)
    local col = math.floor((x - xOffset) / dx) + 1
    local row = math.floor((y - yOffset) / dx) + 1
    return row, col
end



function getDir(x0, y0, x1, y1)
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



function getNearestAngle(angle, deltatime)
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

function rotateGroupWithTrans(b, row, col, angle, transtime)

    if (finishedTransit) then
        if (transtime == nil) then
            transtime = gTransTime
        end
        finishedTransit = false
        local g = makegroup(b, row, col)

        transition.to(g, { time = transtime, delay = 0, rotation = angle, delta = false, onComplete = endTouch })
        moveCells2(b,row, col, angle)
    end
end

function changeGroup(obj, newGroup)
    local x, y = obj:localToContent(0, 0)
    obj.setReferencePoint = display.CenterReferencePoint
    newGroup:insert(obj)
    obj.x = x
    obj.y = y
    obj.rotation = obj.parent.rotation
end

function makegroup(bb, row, col)
    local g = display.newGroup()
    for k = 1, 9 do
        changeGroup(utils.getNeighbor(bb, row, col, k), g) --See function above, using insert
    end
    g:setReferencePoint(display.CenterReferencePoint)
    g.rotation = 0
    return g
end

function rotateGroupWithTrans2(b, row, col, angle, transtime, onEnd)


    if (transtime == nil) then
        transtime = gTransTime
    end

    local g = makegroup(b, row, col)

    transtime = director.rottime
    transition.to(g, { time = transtime, delay = 0, rotation = angle, delta = false, onComplete = onEnd })
    moveCells2(b,row, col, angle)
end


function rotateGroup(b, row, col, angle)
    local g = makegroup(b, row, col)
    g.rotation = angle
    moveCells2(b,row, col, angle)
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


function playBackString2(b,movestr,count,titleBtn)

    finishedTransit = false
    numleft = 0
    --displaySolveIn(director.trainlevel)
    local rottime = director.rottime
    if (string.len(movestr) > 0) then
        count = count - 1
        local restmoves = string.sub(movestr, 2)
        local c = string.char(string.byte(movestr, 1))
        if(not (titleBtn == nil))then
            titleBtn.text = count +1
        end

        if (c == 'a') then
            rotateGroupWithTrans2(b, 2, 2, 90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'A') then
            rotateGroupWithTrans2(b, 2, 2, -90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'b') then
            rotateGroupWithTrans2(b, 2, 3, 90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'B') then
            rotateGroupWithTrans2(b, 2, 3, -90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'c') then
            rotateGroupWithTrans2(b, 3, 2, 90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'C') then
            rotateGroupWithTrans2(b, 3, 2, -90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'd') then
            rotateGroupWithTrans2(b, 3, 3, 90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        elseif (c == 'D') then
            rotateGroupWithTrans2(b, 3, 3, -90, rottime, function() playBackString2(b,restmoves,count,titleBtn) end)
        end
    else
        finishedTransit=true
    end
end

function playBackString(moveStr)
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
