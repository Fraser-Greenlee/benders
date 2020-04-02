
-- Module/class for fire

local config = require('scene.game-config').noDisplay.fire

-- Define module
local M = {}

function M.new( display, physics )
    local instance = {}

    instance.particleSystem = physics.newParticleSystem( config.particleSystem )

    local function particleSystemCollision( self, event )
        if ( event.phase == "began" and event.object.type ~= nil ) then
            if event.object.type == "enemyCanon" and event.r == 1 and event.g == 1 and event.b == 1 then
                event.object:dead()
            elseif event.object.type == "skullLanturn" and event.object.isDead == false then
                event.object:hurt()
            elseif event.object.type == "target" then
                event.object.fireHit()
            end
        end
    end

    instance.particleSystem.particleCollision = particleSystemCollision
    instance.particleSystem:addEventListener( "particleCollision" )

    function instance:fireColor( tempRatio )
        --[[
        # makes a color table relative to [0.0, 1.0] temperature ratio (1.0 is max)
        Range of values from max to min:
            { 254, 247, 93 }
            { 248, 205, 81 }
            { 229, 166, 56 }
            { 223, 104, 42 }
        ]]
        tempRatio = math.max(math.min(tempRatio + math.random(-5, 5)/10, 1), 0)
        return {
            (223 + (254 - 223) * tempRatio)/255,
            (104 + (247 - 104) * tempRatio)/255,
            (42 + (93 - 42) * tempRatio)/255,
            1
        }
    end

    function instance:makeParticle( x, y, velocityX, velocityY, tempRatio )
        config.fireBlock.createParticle.x = x + math.random(-50, 50)
        config.fireBlock.createParticle.y = y + math.random(-50, 50)
        config.fireBlock.createParticle.velocityX = velocityX
        config.fireBlock.createParticle.velocityY = velocityY
        config.fireBlock.createParticle.color = instance:fireColor( tempRatio )
        -- print(config.fireBlock.color[1], config.fireBlock.color[2], config.fireBlock.color[3], config.fireBlock.color[4])
        config.fireBlock.createParticle.lifetime = config.maxLifetime * tempRatio
        instance.particleSystem:createParticle( config.fireBlock.createParticle )
    end

    function instance:makeParticleGroup( x, y, velocityX, velocityY, tempRatio, maxRadius )
        config.fireBlock.createGroup.x = x
        config.fireBlock.createGroup.y = y
        config.fireBlock.createGroup.linearVelocityX = velocityX/2
        config.fireBlock.createGroup.linearVelocityY = velocityY/2
        config.fireBlock.createGroup.color = instance:fireColor( tempRatio )
        -- print(config.fireBlock.color[1], config.fireBlock.color[2], config.fireBlock.color[3], config.fireBlock.color[4])
        config.fireBlock.createGroup.lifetime = config.maxLifetime * tempRatio
        config.fireBlock.createGroup.radius = math.min(config.maxRadius * tempRatio, maxRadius)
        instance.particleSystem:createGroup( config.fireBlock.createGroup )
    end

    function instance:deleteParticles( startX, startY, endX, endY )
        local distX = endX - startX
        local distY = endY - startY
        local distance = math.sqrt(distX*distX + distY*distY)
        instance.particleSystem:destroyParticles({
            x = (startX + endX) / 2,
            y = (startY + endY) / 2,
            angle = math.atan2( distY, distX ),
            halfWidth = distance/2,
            halfHeight = 10
        })
    end

    function instance:destroyRadius(x, y, radius)
        local fullScreen = {
            x = -500,
            y = -200,
            halfWidth = display.actualContentWidth + 500,
            halfHeight = (display.actualContentHeight + 500)*2
        }
        print('destroyParticles')
        print( instance.particleSystem:destroyParticles( fullScreen ) )
        instance.particleSystem:destroyParticles({
            x = x,
            y = y,
            radius = radius
        })
    end

    local fullScreen = {
		x = -500,
		y = -200,
		halfWidth = display.actualContentWidth + 500,
		halfHeight = (display.actualContentHeight + 500)*2
    }

    function instance:destroy()
        timer.performWithDelay( 100, function()
            instance.particleSystem:destroyParticles( fullScreen )
        end, -1)
        instance.particleSystem:removeEventListener( "particleCollision" )
    end

    --[[
    local worldGroup = display.newGroup()
    -- Initialize snapshot for full screen
    local snapshot = display.newSnapshot( worldGroup, display.actualContentWidth*2, display.actualContentHeight*2 )
    local snapshotGroup = snapshot.group
    snapshot.x = 0
    snapshot.y = 0
    snapshot.canvasMode = "discard"
    snapshot.alpha = 0.8
    -- Insert the particle system into the snapshot
    snapshotGroup:insert( instance.particleSystem )
    -- Update (invalidate) the snapshot each frame
    local function onEnterFrame( event )
        snapshot:invalidate()
    end
    Runtime:addEventListener( "enterFrame", onEnterFrame )
    ]]

    return instance
end

return M
