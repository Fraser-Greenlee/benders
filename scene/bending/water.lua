
-- Module/class for water

local config = require('scene.game-config').noDisplay.water

-- Define module
local M = {}

function M.new( display, physics )
    local instance = {}

    instance.particleSystem = physics.newParticleSystem({
        filename = "scene/bending/img/rounded_square.png",
        radius=config.radius,
        imageRadius=config.imageRadius,
        density=config.density,
        gravityScale=config.gravityScale,
        pressureStrength=config.pressureStrength,
    })

    function instance:makeParticle( x, y, velocityX, velocityY )
        instance.particleSystem:createParticle({
            x = x,
            y = y,
            velocityX = velocityX,
            velocityY = velocityY,
            color = { 0.3, 0.4, 1, 1 },
            lifetime = 48,
            flags = { "water" }
        })
    end

    -- TODO finish proper water look!
    local screenWidth = display.actualContentWidth
    local screenHeight = display.actualContentHeight

    local worldGroup = display.newGroup()
    local letterboxWidth = (display.actualContentWidth-display.contentWidth)/2
    local letterboxHeight = (display.actualContentHeight-display.contentHeight)/2
    local midX = display.actualContentWidth/2
    local midY = letterboxHeight/2 + letterboxHeight/6
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
