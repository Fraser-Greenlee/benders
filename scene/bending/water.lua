
-- Module/class for water

local config = require('scene.game-config').noDisplay.water

-- Define module
local M = {}

function M.new( physics )
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
            color = { 0.3, 0.4, 1, 0.8 },
            lifetime = 48,
            flags = { "water" }
        })
    end

    return instance
end

return M
