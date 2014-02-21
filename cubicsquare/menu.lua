module(..., package.seeall)



function new()
    local colorUtils = require("colors")
    local utils = require("utils")
    local makeBoard = utils.makeBoard
    local rotateGroup = utils.rotateGroup
    local changeGroup = utils.changeGroup
    local doboard = utils.doboard
    local localGroup = display.newGroup()
    local getmoves = utils.getmoves

    director.train=false

    --> This is how we start every single file or "screen" in our folder, except for main.lua
    -- and director.lua
    --> director.lua is NEVER modified, while only one line in main.lua changes, described in that file
    ------------------------------------------------------------------------------
    ------------------------------------------------------------------------------
    local function pressPlay(event)
        if event.phase == "ended" then
            director.board = nil
            director.moves, director.angles = getmoves(1)
            display.getCurrentStage():setFocus(nil)
            director.mode="play"

            utils.myChangeScene("cubicsquare")

        end
        return true
    end

    local function pressTrain(event)

        if event.phase == "ended" then
            director.board = nil
            director.train=true
            director.moves, director.angles = getmoves(1)
            director.mode="train"
            display.getCurrentStage():setFocus(nil)
            utils.myChangeScene("cubicsquare")

        end
        return true
    end

    local function pressSettings(event)
        if event.phase == "ended" then
            director.mode="levels"
            utils.myChangeScene("levels")

        end
    end

    local function pressHelp(event)
        if event.phase == "ended" then
            utils.myChangeScene("help2")
            director.mode="help"

        end
    end


    director.mode=""
    --set background
    local background = display.newImage("images/backgroundblue.png")
    localGroup:insert(background)


    -- set button
    local btnx = 100
    local btny = 20
    local dy = 90
    local fontsize = 32
    local boardSize = 4
    local displaynewText = utils.displaynewText

    local titleText = displaynewText("Larry's Square", 50, 20, 40)


    local rectX = 80
    local rectSize = 15
    local rightX = btnx - (boardSize * rectSize) - 2
    localGroup:insert(titleText)


    btny = btny + dy
    local helpBtn = displaynewText("Help Yourself", btnx + 10, btny, fontsize)
    helpBtn:addEventListener("touch", pressHelp)
    localGroup:insert(helpBtn)
    gmoves = "a*d^-1*a*d^-1*a*d^-1*a*d^-1*a*d^-1*a*d^-1"
    moves, angles = utils.gap2MoveList(gmoves)
    doboard(rectSize, localGroup, boardSize, rightX, btny, moves, angles, pressHelp, 4)

    btny = btny + dy
    local trainBtn = displaynewText("Train Brain", btnx + 10, btny, fontsize)
    localGroup:insert(trainBtn)
    trainBtn:addEventListener("touch", pressTrain)
    local gmoves = "a*d*a^-1*d^-1*b^-1*c^-1*b*c"
    local moves, angles = utils.gap2MoveList(gmoves)
    doboard(rectSize, localGroup, boardSize, rightX, btny, moves, angles, pressTrain)


    btny = btny + dy
    local settingsBtn = displaynewText("Challenge Mind", btnx + 10, btny, fontsize)
    localGroup:insert(settingsBtn)
    settingsBtn:addEventListener("touch", pressSettings)
    local gmoves = "a*d*a^-1*d^-1*b^-1*c^-1*b*c"
    local moves, angles = utils.gap2MoveList(gmoves)
    doboard(rectSize, localGroup, boardSize, rightX, btny, moves, angles, pressSettings)


    btny = btny + dy
    local playBtn = displaynewText("Explore Square", btnx + 10, btny, fontsize)
    playBtn:addEventListener("touch", pressPlay)
    localGroup:insert(playBtn)
    doboard(rectSize, localGroup, boardSize, rightX, btny, {}, {}, pressPlay)




--    local ads = require "ads"
--    --ads.show( "banner", { x=0, y=0, interval=60 } )
--    ads.hide()

    return localGroup
end

--> This is how we end every file except for director and main, as mentioned in my first comment
