function love.load()
    --seed for math.random
    math.randomseed(os.time())
    --add new font
    scoreFont = love.graphics.newFont("fonts/Minecraft.ttf", 30)
    --importing sprites
    sprites = {}
    sprites.ship_full = love.graphics.newImage("sprites/MainShip/MainShip_FullHealth.png")
    sprites.ship_slight = love.graphics.newImage("sprites/MainShip/MainShip_SlightDmg.png")
    sprites.ship_dmged = love.graphics.newImage("sprites/MainShip/MainShip_Dmg.png")
    sprites.ship_Very = love.graphics.newImage("sprites/MainShip/MainShip_VeryDmg.png")
    sprites.rocket = love.graphics.newImage("sprites/rocket/rocket_2.png")
    sprites.base = love.graphics.newImage("sprites/enemys/base.png")
    sprites.heart = love.graphics.newImage("sprites/hearts/heart.png")
    sprites.heart_empty = love.graphics.newImage("sprites/hearts/heart_empty.png")
    --table for the player controlled ship
    ship = {}
    ship.x = love.graphics.getWidth()/2
    ship.y = love.graphics.getHeight()/2 + 100
    ship.speed = 350
    --table for all the rockets
    rockets = {}
    --table for all the enemys
    enemys = {}
    --table for enemy rockets
    enemyRockets = {}
    --makes enemys shoot rockets at random times
    enemyRocketsTime = math.random(1, 2.5)
    --sets the starting sate for the game
    gameState = 2
    --time till enemys spawn
    timer = 2.5
    --how much health the player has left
    dmg = 3
    -- the time that timer resest to 
    maxTime = 2.5
    --sets the starting score
    score = 0
end

function love.update(dt)
    --moves player to right if d key is pressed down
    if love.keyboard.isDown("d") then
        ship.x = ship.x + ship.speed * dt
    end
    --moves player left if a key is pressed down
    if love.keyboard.isDown("a") then
        ship.x = ship.x - ship.speed * dt
    end
    --moves player up/forwards if w key is pressed down
    if love.keyboard.isDown("w") then
        ship.y = ship.y - ship.speed * dt
    end
    --moves player down/back if s key is pressed down
    if love.keyboard.isDown("s") then
        ship.y = ship.y + ship.speed * dt
    end
    --stops player flying off the left side of the screen
    if ship.x < 16 then
        ship.x = 16
    end
    --stops player flying off the right side of the screen
    if ship.x > love.graphics.getWidth() - 16 then
        ship.x = love.graphics.getWidth() - 16
    end
    --stops player from flying off the top of the screen
    if ship.y < 16 then
        ship.y = 16
    end
    --stops player flying off the bottom on the screen
    if ship.y > love.graphics.getHeight() - 16 then
        ship.y = love.graphics.getHeight() - 16
    end
    --makes every rocket spawned move up the screen every frame
    for i,r in ipairs(rockets) do
        r.y = r.y - r.speed * dt
    end
    --moves every enemy down the screen every frame
    for i,e in ipairs(enemys) do
        e.y = e.y + e.speed * dt
    end

    for i,eR in ipairs(enemyRockets) do
		eR.x = eR.x + (math.cos(eR.direction) * eR.speed * dt)
		eR.y = eR.y + (math.sin(eR.direction) * eR.speed * dt)
	end
    --if dmg = 0 / player died locks player to middle of the screen
    --and sets game state to 1
    if dmg == 0 then
        ship.x = love.graphics.getWidth()/2
        ship.y = love.graphics.getHeight()/2
        gameState = 0
    end
    --checks if enemy is dead and removes enemy
    --checks if enemy has left the screen and removes and removes 100 from the score
    for i=#enemys, 1, -1 do
        local e = enemys[i]
        if e.dead == true then
            table.remove(enemys, i)
        end
        if e.y > love.graphics.getHeight() then
            table.remove(enemys, i)
            score = score - 100
        end
    end
    -- checks if any enemys and rockets have collied and if yes marks both as dead and adds 100 to score
    for i,e in ipairs(enemys) do
		for j,r in ipairs(rockets) do
			if distanceBetween(e.x, e.y, r.x, r.y) < 20 then
				e.dead = true
				r.dead = true
				score = score + 100
			end
		end
	end
    --checks if enemy and player have collied
    for i,e in ipairs(enemys) do
		if distanceBetween(e.x, e.y, ship.x, ship.y) < 20 then
			dmg = dmg - 1
			table.remove(enemys, i)
		end
	end

    --checks all rockets to see if there marked dead or have left the screen and if yes removes them
    for i=#rockets, 1, -1 do
        local r = rockets[i]
        if r.y < 0 or r.dead == true then
            table.remove(rockets, i)
        end
    end
    --checks if game is in play state and starts the timer and starts spawning enemys
    if gameState < 1 then
        timer =  timer - dt
        enemyRocketsTime = enemyRocketsTime - dt
        if timer <= 0 then
            spawnEnemy()
            timer = maxTime
        end
    end
end

function love.draw()
    --draws the player ship
    if dmg == 3 then
        love.graphics.draw(sprites.ship_full, ship.x, ship.y, nil, 1.5, nil, sprites.ship_full:getWidth()/2, sprites.ship_full:getHeight()/2)
    elseif dmg == 2 then
        love.graphics.draw(sprites.ship_slight, ship.x, ship.y, nil, 1.5, nil, sprites.ship_slight:getWidth()/2, sprites.ship_slight:getHeight()/2)
    elseif dmg == 1 then
        love.graphics.draw(sprites.ship_dmged, ship.x, ship.y, nil, 1.5, nil, sprites.ship_dmged:getWidth()/2, sprites.ship_dmged:getHeight()/2)
    elseif dmg == 0 then
        love.graphics.draw(sprites.ship_Very, ship.x, ship.y, nil, 1.5, nil, sprites.ship_Very:getWidth()/2, sprites.ship_Very:getHeight()/2)
    end
    --draws all enemys
    for i,e in ipairs(enemys) do
        love.graphics.draw(sprites.base, e.x, e.y, enemyPlayerAngle(e), nil, nil, sprites.base:getWidth()/2, sprites.base:getHeight()/2)
    end
    --draws all rockets
    for i,r in ipairs(rockets) do
        love.graphics.draw(sprites.rocket, r.x, r.y, nil, 1.5, nil, sprites.rocket:getWidth()/2, sprites.rocket:getHeight()/2)
    end
    --once player dies it clears the screen
    if dmg == 0 then
        love.graphics.clear()
    end
    --prints the score
    love.graphics.printf("score: " .. score, scoreFont, 10, 45, 115, "left")
    --checks  health and draws the amount of hearts
    if dmg == 3 then
        love.graphics.draw(sprites.heart, 10, 10, nil)
        love.graphics.draw(sprites.heart, 42, 10, nil)
        love.graphics.draw(sprites.heart, 74, 10, nil)
    elseif dmg == 2 then
        love.graphics.draw(sprites.heart, 10, 10, nil)
        love.graphics.draw(sprites.heart, 42, 10, nil)
        love.graphics.draw(sprites.heart_empty, 74, 10, nil) 
    elseif dmg == 1 then
        love.graphics.draw(sprites.heart, 10, 10, nil)
        love.graphics.draw(sprites.heart_empty, 42, 10, nil)
        love.graphics.draw(sprites.heart_empty, 74, 10, nil)
    elseif dmg == 0 then
        love.graphics.draw(sprites.heart_empty, 10, 10, nil)
        love.graphics.draw(sprites.heart_empty, 42, 10, nil)
        love.graphics.draw(sprites.heart_empty, 74, 10, nil)
    end
end
--if space key has been pressed spawns rocket
function love.keypressed(key)
    if key == "space" and gameState > 1 then
        spawnEnemy()
    end
end
--table for all the enemy rockets being made inside the enemy rockets table
function spawnEnemyRocket()
    local enemyRocket = {}
    enemyRocket.x = enemys.x
    enemyRocket.y = enemys.y
    enemyRocket.speed = 500
    enemyRocket.dead = false

    table.insert(enemyRockets, enemyRocket)
end
--the table for all the rockets being made inside the rockets table
function spawnRocket()
    local rocket = {}
    rocket.x = ship.x
    rocket.y = ship.y
    rocket.speed = 500
    rocket.dead = false

    table.insert(rockets, rocket)
end
--the table for all the enemys being made inside the enemys table
function spawnEnemy()
    local enemy = {}
    enemy.x = math.random(16, love.graphics.getWidth() - 16)
    enemy.y =  -5
    enemy.speed = math.random(30, 100)
    enemy.dead = false
    table.insert(enemys,enemy)
end
--calculates the angle of the player and enemy
function enemyPlayerAngle(e)
	return math.atan2(ship.y - e.y, ship.x - e.x) + math.pi / 2
end
--calculates the distanceBetween 2 objects
function distanceBetween(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end