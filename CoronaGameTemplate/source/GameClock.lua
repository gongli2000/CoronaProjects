--[[
###############################################################################
##	Mike Ziray
##	LTZLLC.com
##	LTZ, LLC
##
###############################################################################
]]--

module(..., package.seeall)


local gameTimer



--=====================================================================================--
--== BEGIN GAME CLOCK =================================================================--
--=====================================================================================--
function GameClock:beginGameClock()
	 gameTimer = system.getTimer()
end


--=====================================================================================--
--== STOP GAME CLOCK ==================================================================--
--=====================================================================================--
function GameClock:stopGameClock()
	-- TODO
end


--=====================================================================================--
--== GET GAME TIME ====================================================================--
--=====================================================================================--
function GameClock:getGameTime()
	return gameTimer
end


--=====================================================================================--
--== GET CURRENT TIME =================================================================--
--=====================================================================================--
function GameClock:getCurrentTime()
	-- The reason we abstract this and not call it directly is, if we ever want to
	--  change the behavior of the clock, or execute some code before we return the
	--  timer, we can do so here, and not everywhere else we called the functino below
	return system.getTimer()
end