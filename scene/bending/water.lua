
-- Module/class for water

local config = require('scene.game-config').noDisplay.water

-- Define module
local M = {}

function M.new( display, physics )
    local instance = {}

    instance.particleSystem = physics.newParticleSystem( config.particleSystem )

    local function particleSystemCollision( self, event )
        if ( event.phase == "began" and event.object.type ~= nil ) then
            if event.object.type == "target" then
                event.object.waterHit()
            end
        end
    end

    instance.particleSystem.particleCollision = particleSystemCollision
    instance.particleSystem:addEventListener( "particleCollision" )

    function instance:makeParticle( x, y, velocityX, velocityY )
        config.createParticle.x = x
        config.createParticle.y = y
        config.createParticle.velocityX = velocityX
        config.createParticle.velocityY = velocityY
        instance.particleSystem:createParticle( config.createParticle )
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

    local worldGroup = display.newGroup()
    -- Initialize snapshot for full screen
    local snapshot = display.newSnapshot( worldGroup, display.actualContentWidth*2, display.actualContentHeight*2 )
    local snapshotGroup = snapshot.group
    snapshot.x = 0
    snapshot.y = 0
    snapshot.canvasMode = "discard"
    snapshot.alpha = 0.6
    -- Insert the particle system into the snapshot
    snapshotGroup:insert( instance.particleSystem )
    -- Update (invalidate) the snapshot each frame
    local function onEnterFrame( event )
        snapshot:invalidate()
    end
    Runtime:addEventListener( "enterFrame", onEnterFrame )

    return instance
end

return M
