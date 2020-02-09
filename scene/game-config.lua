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
    
        charge = {
            max = 100,
            lossPerParticle = 0.02
        },

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
            density = 1.2,
            bounce = 0,
            friction =  2.0,
            box = { halfWidth = 42, halfHeight = 75 }
        },
        anchorY = 0.56,
        anchorX = 0.45,
        jumpForce = -500,
        walkAcceleration = 1000,
        maxWalkSpeed = 375,
        sheetFileName = "katara.png",
        sheetData = {
            width = 150,
            height = 170,
            numFrames = 25,
            sheetContentWidth = 3750,
            sheetContentHeight = 170
        },
        sequenceData = {
            { name = "idle", frames = { 1, 2, 3, 4, 5, 6 } },
            { name = "walk", frames = { 15, 16, 17, 18, 19, 20 }, time = 333, loopCount = 0 },
            { name = "jump", frames = { 21, 22, 23, 24, 25 } },
            { name = "ouch", frames = { 7, 8, 9, 10, 11, 12, 13, 14 } },
        },
        oldSprite = {
            sheetFileName = "sprites.png",
            sheetData = {
                width = 192,
                height = 256,
                numFrames = 79,
                sheetContentWidth = 1920,
                sheetContentHeight = 2048
            }
        }
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
