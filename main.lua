function love.load()
  love.window.setMode(1000, 768)

  anim8 = require 'libraries/anim8-master/anim8'
  sti = require 'libraries/Simple-Tiled-Implementation-master/sti'
  cameraFile = require 'libraries/hump-master/camera'


  cam = cameraFile()

  sounds = {}
  sounds.jump = love.audio.newSource("audio/jump.wav", "static")
  sounds.music = love.audio.newSource("audio/Run-Amok.mp3", "stream")

  sounds.music:play()
  sounds.music:setLooping(true)
  sounds.music:setVolume(0.5)

  sprites = {}
  sprites.catSprite = love.graphics.newImage('sprites/cat/catSprite.png')
  sprites.dogSprite = love.graphics.newImage('sprites/dog/dogSprite.png')
  sprites.background = love.graphics.newImage('sprites/waterfall.png')

  local grid = anim8.newGrid(150, 163, sprites.catSprite:getWidth(), sprites.catSprite:getHeight())
  local enemyGrid = anim8.newGrid(150, 163, sprites.dogSprite:getWidth(), sprites.dogSprite:getHeight())

  animations = {}
  animations.idle = anim8.newAnimation(grid('1-10', 2), 0.09)
  animations.jump = anim8.newAnimation(grid('1-8', 3), 0.09)
  animations.walk = anim8.newAnimation(grid('1-10', 1), 0.09)
  animations.enemy = anim8.newAnimation(enemyGrid('1-2', 1), 0.09)

  wf = require 'libraries/windfield-master/windfield'
  world = wf.newWorld(0, 800, false)
  world:setQueryDebugDrawing(true)
  
    love.window.setMode(1000, 768)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')
    require('libraries/show')

    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    platforms = {}

    flagX = 0
    flagY = 0

    saveData = {}
    saveData.currentLevel = "catworld"

    if love.filesystem.getInfo("data.lua") then
      local data = love.filesystem.load("data.lua")
      data()
    end  

    loadMap(saveData.currentLevel)

    spawnEnemy(960, 256)
end 

function love.update(dt)
  world:update(dt)
  gameMap:update(dt)
  playerUpdate(dt)
  updateEnemies(dt)

  local px, py = player:getPosition()
  cam:lookAt(px, love.graphics.getHeight()/2)

  local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
  if #colliders > 0 then
    if saveData.currentLevel == "catworld" then
        loadMap("catworld2")
    elseif saveData.currentLevel == "catworld2" then    
      loadMap("catworld")
    end  
  end    
end 

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  cam:attach()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    drawPlayer()
    drawEnemies()
  cam:detach()  
end  

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then 
          player:applyLinearImpulse(0, -4000)
          sounds.jump:play()
        end  
    end   
end  

function love.mousepressed(x, y, button)
	if button == 1 then
		local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
    for i,c in ipairs(colliders) do
      c:destroy()
    end
	end
end

function spawnPlatform(x, y, width, height)
  if width > 0 and height > 0 then
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    table.insert(platforms, platform)
  end  
end 

function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end  
        table.remove(platforms, i)
        i = i -1   
    end  

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end  
        table.remove(enemies, i)
        i = i -1   
    end 
end  

function loadMap(mapName)
    saveData.currentLevel = mapName
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))
    destroyAll()
    player:setPosition(playerStartX, playerStartY)
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end  
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x 
        flagY = obj.y
    end
end  