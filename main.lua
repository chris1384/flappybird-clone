--[[ by cristivalentin1384@gmail.com ]]

local screenW, screenH, deviceW, deviceH, centerW, centerH = display.contentWidth, display.contentHeight, display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY

math.randomseed(os.time())
local logoImage = "assets/1384_games.png"
if math.random(1, 6) == 3 then
	logoImage = "assets/peasant_games.png"
end
local blackbg = display.newRect(centerW, centerH, deviceW, deviceH)
blackbg:setFillColor(0,0,0)
blackbg:toFront()
local logo = display.newImageRect(logoImage, screenW/1.4, screenW/1.4)
logo.x, logo.y = centerW, centerH
logo.alpha = 0
logo:toFront()
transition.to(logo, {time = 2000, alpha = 1, height = screenW/1.2, width = screenW/1.2, transition  = easing.outQuad })

timer.performWithDelay(2000, function()
	local game = require("game")
	game()
	blackbg:toFront()
	logo:toFront()
	transition.to(blackbg, {time = 400, alpha = 0})
	transition.to(logo, {time = 400, alpha = 0, height = screenW/1.6, width = screenW/1.6})
	timer.performWithDelay(400, function()
		blackbg:removeSelf()
		blackbg = nil
		logo:removeSelf()
		logo = nil
	end)
end, 1)