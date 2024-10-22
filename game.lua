--[[ by cristivalentin1384@gmail.com ]]

function startFlappyBird()

local screenW, screenH, deviceW, deviceH, centerW, centerH = display.contentWidth, display.contentHeight, display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY

local physics = require("physics")
physics.start()
--physics.setDrawMode( "hybrid" )
local game = {state = "ready", dieCooldown = false, score = 0, best = 0}

local filePath = system.pathForFile("userconfig", system.CachesDirectory)
local loadFile = io.open(filePath, "r")
if loadFile then
	local best = loadFile:read("*all")
	best = tonumber(best)
	if best then
		game.best = best
	end
	io.close(saveFile)
	best = nil
	loadFile = nil
	filePath = nil
end

local systemColor, backgroundImage = {94/255,227/255,112/255}, "assets/background-day.png"
local hour = os.date("*t")["hour"]
if hour <= 6 or hour >= 20 then
	systemColor = {1/255, 163/255, 0}
	backgroundImage = "assets/background-night.png"
end

local systemBackground = display.newRect(centerW, centerH, deviceW, deviceH)
systemBackground:setFillColor(unpack(systemColor))

local background = display.newImageRect(backgroundImage, screenW, screenH)
background.x, background.y = centerW-screenW/2, centerH-deviceH/2+screenH/2

local background2 = display.newImageRect(backgroundImage, screenW, screenH)
background2.x, background2.y = centerW+screenW/2, centerH-deviceH/2+screenH/2

local groundbottom = display.newImageRect("assets/base.png", deviceW, screenW*112/336)
groundbottom.x, groundbottom.y = centerW, centerH+deviceH/2
groundbottom.rotation = 180

local ground = display.newImageRect("assets/base.png", screenW, screenW*112/336)
ground.x, ground.y = centerW-180, centerH+deviceH/2-(screenW*112/336)/2 - 100

local ground2 = display.newImageRect("assets/base.png", screenW, screenW*112/336)
ground2.x, ground2.y = centerW+screenW-180, centerH+deviceH/2-(screenW*112/336)/2 - 100

local ground3 = display.newImageRect("assets/base.png", screenW, screenW*112/336)
ground3.x, ground3.y = centerW+screenW*2-180, centerH+deviceH/2-(screenW*112/336)/2 - 100

local groundCollider = display.newRect(centerW, centerH+deviceH/2-(screenW*112/336)/2 - 100, screenW*3, screenW*112/336)
groundCollider.alpha = 0
physics.addBody(groundCollider, "static")

local groundCollider = display.newRect(centerW, centerH-deviceH/2-50, 2000, 100)

local yellowBirdSprite = graphics.newImageSheet("assets/yellow.png", {width = 34, height = 24, numFrames = 3})
local player = display.newSprite(yellowBirdSprite, {{name = "flap", start = 1, count = 3, time = 300, loopCount = 0}, {name = "idle", start = 3, count = 1, time = 1000}, {name = "died", start = 1, count = 1, time = 1000}})
player.startX = centerW
player.startY = centerH
player.velY = 0
player.x, player.y = centerW, centerH
player:setSequence("flap")
player:play()

physics.addBody(player, "dynamic", {friction = 1, shape = {-46, -46, 46, -46, 46, 46, -46, 46} })
player.gravityScale = 0

local beginGame = display.newImageRect("assets/message.png", 184*3.4, 267*3.4)
beginGame.x, beginGame.y = centerW, player.startY-154
beginGame.startX, beginGame.startY = beginGame.x, beginGame.y

local gameOver = display.newImageRect("assets/gameover.png", 192*4, 42*4)
gameOver.x, gameOver.y = centerW, centerH - 400
gameOver.alpha = 0

local gameOverTextShadow = display.newText({text = "Press anywhere to continue", x = centerW+4, y = gameOver.y + gameOver.height+4, fontSize = 50})
gameOverTextShadow:setFillColor(0, 0, 0, 0.5)
gameOverTextShadow.alpha = 0

local gameOverText = display.newText({text = "Press anywhere to continue", x = centerW, y = gameOver.y + gameOver.height, fontSize = 50})
gameOverText.alpha = 0

local gameOverFlash = display.newRect(centerW, centerH, deviceW, deviceH)
gameOverFlash.alpha = 0

local scoreTextFinalShadow = display.newText({text = "Final Score: 0", x = centerW+4, y = gameOverText.y + 66+4, fontSize = 50})
scoreTextFinalShadow:setFillColor(0, 0, 0, 0.5)
scoreTextFinalShadow.alpha = 0
local scoreTextFinal = display.newText({text = "Final Score: 0", x = centerW, y = gameOverText.y + 66, fontSize = 50})
scoreTextFinal.alpha = 0

local scoreTextShadow = display.newText({text = "Score: 0", x = centerW+4, y = centerH-deviceH/2+200+4, fontSize = 60})
scoreTextShadow:setFillColor(0, 0, 0, 0.5)
scoreTextShadow.alpha = 0
local scoreText = display.newText({text = "Score: 0", x = centerW, y = centerH-deviceH/2+200, fontSize = 60})
scoreText.alpha = 0

local scoreTextBestShadow = display.newText({text = "Best Score: "..tostring(game.best), x = centerW+4, y = beginGame.y + beginGame.height/2 + 104, fontSize = 50})
scoreTextBestShadow:setFillColor(0, 0, 0, 0.5)
scoreTextBestShadow.startY = scoreTextBestShadow.y
local scoreTextBest = display.newText({text = "Best Score: "..tostring(game.best), x = centerW, y = beginGame.y + beginGame.height/2+100, fontSize = 50})
scoreTextBest.startX, scoreTextBest.startY = scoreTextBest.x, scoreTextBest.y

local pipes = {}

function addPipes()
	local randomY = math.random(-500, 250)
	local pipeDown = display.newImageRect("assets/pipe-green.png", 52*4, 320*4)
	physics.addBody(pipeDown, "static")
	pipeDown.x, pipeDown.y = centerW+deviceW/2+400, centerH+(320*4)/2+180+randomY
	pipeDown.timer = timer.performWithDelay(10000, function() pipeDown:removeSelf() pipes[pipeDown] = nil pipeDown = nil end, 1)
	
	local pipeUp = display.newImageRect("assets/pipe-green.png", 52*4, 320*4)
	physics.addBody(pipeUp, "static")
	pipeUp.x, pipeUp.y = pipeDown.x, pipeDown.y - 320*5.2
	pipeUp.rotation = 180
	pipeUp.timer = timer.performWithDelay(10000, function() pipeUp:removeSelf() pipes[pipeUp] = nil pipeUp = nil end, 1)
	
	local pipeUpExtra = display.newImageRect("assets/pipe-green.png", -52*4, 320*4)
	physics.addBody(pipeUpExtra, "static")
	pipeUpExtra.x, pipeUpExtra.y = pipeUp.x, pipeUp.y - 320*4
	pipeUpExtra.timer = timer.performWithDelay(10000, function() pipeUpExtra:removeSelf() pipes[pipeUpExtra] = nil pipeUpExtra = nil end, 1)
	
	local pipeScore = display.newRect(pipeDown.x + pipeDown.width/1.2, centerH, 100, deviceH*2)
	pipeScore.alpha = 0
	physics.addBody(pipeScore, "static")
	pipeScore.isSensor = true
	
	pipes[pipeDown] = {timer = pipeDown.timer}
	pipes[pipeUp] = {timer = pipeUp.timer}
	pipes[pipeUpExtra] = {timer = pipeUpExtra.timer}
	pipes[pipeScore] = {isSensor = true}
	
	groundbottom:toFront()
	ground:toFront()
	ground2:toFront()
	ground3:toFront()
	scoreTextShadow:toFront()
	scoreText:toFront()
end

local flapSound = audio.loadSound("assets/wing.ogg")
local hitSound = audio.loadSound("assets/hit.ogg")
local deathSound = audio.loadSound("assets/die.ogg")
local scoreSound = audio.loadSound("assets/point.ogg")
local restartSound = audio.loadSound("assets/swoosh.ogg")
audio.play(restartSound)

function render(event)

	player.width, player.height = 96*34/24, 96
	
	if game.state == "ready" then
		player.y = player.startY + math.cos(event.frame/15)*30
		beginGame.y = beginGame.startY - math.cos(event.frame/40)*15
		scoreTextBestShadow.y = scoreTextBestShadow.startY - math.cos(event.frame/40)*15
		scoreTextBest.y = scoreTextBest.startY - math.cos(event.frame/40)*15
		
	elseif game.state == "playing" then
	
		player.velY = math.min(30, player.velY + 0.9)
		player.y = math.max(centerH-deviceH/2, player.y + player.velY)
		
		if player.velY > 15 then
			player.rotation = math.min(player.rotation + 2, 30)
			player:setSequence("idle")
			player.width, player.height = 96*34/24, 96
		else
			player.rotation = -20
		end
		
	end
	
	if game.state ~= "died" then
		ground.x = ground.x - 6
		if ground.x + screenW <= 0 then
			ground.x = screenW + screenW
		end
		
		ground2.x = ground2.x - 6
		if ground2.x + screenW <= 0 then
			ground2.x = screenW + screenW
		end
		
		ground3.x = ground3.x - 6
		if ground3.x + screenW <= 0 then
			ground3.x = screenW + screenW
		end
		
		for pipe,_ in pairs(pipes) do
			pipe.x = pipe.x - 6
		end
	end
	
end
Runtime:addEventListener("enterFrame", render)

function tapControl(event)

	if game.state == "ready" then
		game.state = "playing"
		player.velY = -20
		audio.play(flapSound)
		pipesTimer = timer.performWithDelay(1800, addPipes, 0)
		transition.to(beginGame, {time = 500, y = beginGame.startY - 100, alpha = 0})
		transition.to(scoreTextBestShadow, {time = 500, y = scoreTextBest.startY - 100, alpha = 0})
		transition.to(scoreTextBest, {time = 500, y = scoreTextBest.startY - 100, alpha = 0})
		scoreTextShadow.alpha = 1
		scoreText.alpha = 1
		audio.play(restartSound)
		
	elseif game.state == "playing" then
		player.velY = -20
		audio.play(flapSound)
		player:setSequence("flap")
		player:play()
		
	elseif game.state == "died" then
		if game.dieCooldown then return end
		game.state = "ready"
		for pipe,data in pairs(pipes) do
			pipe:removeSelf()
			pipes = {}
		end
		player.rotation = 0
		player.angularVelocity = 0
		player:setLinearVelocity(0, 0)
		player.gravityScale = 0
		player.x, player.y = player.startX, player.startY
		player:setSequence("flap")
		player:play()
		
		gameOver.alpha = 0
		gameOverTextShadow.alpha = 0
		gameOverText.alpha = 0
		scoreTextFinalShadow.alpha = 0
		scoreTextFinal.alpha = 0
		game.score = 0
		scoreText.text = "Score: 0"
		scoreTextShadow.text = scoreText.text
		transition.to(beginGame, {time = 300, alpha = 1})
		beginGame.y = beginGame.startY
		
		scoreTextBestShadow.y = scoreTextBest.startY+4
		scoreTextBest.y = scoreTextBest.startY
		transition.to(scoreTextBestShadow, {time = 300, alpha = 1})
		transition.to(scoreTextBest, {time = 300, alpha = 1})
	end
	
end
Runtime:addEventListener("tap", tapControl)

function playerCollisions(event)
	if event.phase == "began" then
	
		if game.state == "playing" then
			
			if pipes[event.other] then
				if pipes[event.other].isSensor then
					audio.play(scoreSound, {volume = 0.7})
					game.score = game.score + 1
					scoreText.text = "Score: "..tostring(game.score)
					scoreTextShadow.text = scoreText.text
					return
				end
			end
			
			game.state = "died"
			game.dieCooldown = true

			timer.performWithDelay(800, function() 
				game.dieCooldown = false 
			end, 1)
			
			if game.score > game.best then
				game.best = game.score
				scoreTextBestShadow.text = "Best Score: "..tostring(game.score)
				scoreTextBest.text = "Best Score: "..tostring(game.score)
				local savePath = system.pathForFile("userconfig", system.CachesDirectory)
				local saveFile = io.open(savePath, "r")
				if saveFile then
					file:write(tostring(game.best))
					io.close(saveFile)
					savePath = nil
					saveFile = nil
				end
			end
			
			gameOverFlash.alpha = 0.7
			gameOverFlash:toFront()
			transition.to(gameOverFlash, {time = 300, alpha = 0})
			
			scoreTextShadow.alpha = 0
			scoreText.alpha = 0
			
			
			scoreTextFinal.text = "Final Score: "..tostring(game.score)
			scoreTextFinalShadow.text = scoreTextFinal.text
			
			timer.performWithDelay(500, function() 
				transition.to(gameOver, {time = 200, alpha = 1})
				transition.to(gameOverTextShadow, {time = 200, alpha = 1})
				transition.to(gameOverText, {time = 200, alpha = 1})
				transition.to(scoreTextFinalShadow, {time = 200, alpha = 1})
				transition.to(scoreTextFinal, {time = 200, alpha = 1})
			end, 1)
			
			
			player:setSequence("idle")
			
			audio.play(hitSound)
			audio.play(deathSound)
			
			player.gravityScale = 5
			player:setLinearVelocity(math.random(-1300,1300), math.random(500,2020))
			player:applyTorque(math.random(-400,400))
			
			timer.cancel(pipesTimer)
			
			pipesTimer = nil
			for pipe,data in pairs(pipes) do
				if data.timer then
					timer.cancel(data.timer)
				end
			end
			
			gameOver:toFront()
			gameOverTextShadow:toFront()
			gameOverText:toFront()
			scoreTextFinalShadow:toFront()
			scoreTextFinal:toFront()
			scoreTextShadow:toFront()
			scoreText:toFront()
			
		end
		
	end
end
player:addEventListener("collision", playerCollisions)

end

return startFlappyBird