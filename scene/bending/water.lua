
-- Module/class for water

local config = require('scene.game-config').noDisplay.water

-- Define module
local M = {}

function M.new( display, physics )
    local instance = {}

    instance.particleSystem = physics.newParticleSystem( config.particleSystem )

    function instance:makeParticle( x, y, velocityX, velocityY )
        config.createParticle.x = x
        config.createParticle.y = y
        config.createParticle.velocityX = velocityX
        config.createParticle.velocityY = velocityY
        instance.particleSystem:createParticle( config.createParticle )
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
