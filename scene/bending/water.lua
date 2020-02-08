
-- Module/class for water

-- Define module
local M = {}

function M.new( physics )
    local instance = {}

    instance.particleSystem = physics.newParticleSystem({
        filename = "scene/bending/img/rounded_square.png",
        radius=8,
        imageRadius=10,
        density=0.7,
        gravityScale=4,
        pressureStrength=0.1
    })

    function instance:makeParticle( x, y, velocityX, velocityY )
        print('makeParticle', x, y, velocityX, velocityY)
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
