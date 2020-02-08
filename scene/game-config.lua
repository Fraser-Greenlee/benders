local startConfig = {
    bending = {
        pixel = {
            start = {
                x = 20,
                y = -520
            },
            per = {
                row = 30
            }
        },
        radius = {
            px = 2.5
        },
        boxes = {},
        renderDelay = 1,
        staticDelay = 1,
        power = 200,
        maxAge = 1,
        playerVstatic = 0.2,
        playerVmultiplier = 0,

        debugLine = false,
        debugGrid = false,
        debugPrint = false
    },
    water = {
        radius = 18,
        imageRadius=20,
        density=2,
        gravityScale=1,
        pressureStrength=0.1
    },
    hero = {
        physics = {
            density = 1.5,
            bounce = 0,
            friction =  2.0,
            box = { halfWidth = 45, halfHeight = 60 }
        },
        jumpForce = -300
    },
    game = {
        debugPhysics = false
    }
}

return {
    new = function(display)
        startConfig.bending.pixel.size = math.floor(
            display.actualContentWidth / startConfig.bending.pixel.per.row
        )
        startConfig.bending.pixel.per.column = math.floor(
            display.actualContentHeight / startConfig.bending.pixel.size
        )
        startConfig.bending.radius.bendingPX = math.floor(
            startConfig.bending.radius.px / startConfig.bending.pixel.size
        )
        return startConfig
    end,
    noDisplay = startConfig
}
