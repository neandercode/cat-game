enemies = {}

function spawnEnemy(x, y)
    local enemy = world:newRectangleCollider(x, y, 75, 81, {collision_class = "Danger"})
    enemy.direction = 1
    enemy.speed = 200
    enemy.animation = animations.enemy
    table.insert(enemies, enemy)
end    

function updateEnemies(dt)
    for i,e in ipairs(enemies) do 
        e.animation:update(dt)
        local ex, ey = e:getPosition()

        local colliders = world:queryRectangleArea(ex + (75 * e.direction), ey + 40, 10, 10, {'Platform'})
        if #colliders == 0 then
            e.direction = e.direction * -1
        end

        e:setX(ex + e.speed * dt * e.direction)    
    end    
end   

function drawEnemies()
    for i,e in ipairs(enemies) do
        local ex, ey = e:getPosition()
        e.animation:draw(sprites.dogSprite, ex, ey, nil, e.direction, 1, 75, 100)
    end
end    