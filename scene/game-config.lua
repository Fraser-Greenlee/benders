local startConfig = {
    bending = {
        pixel = {
            start = {
                x = 20,
                y = -520
            },
            per = {
                row = 50
            }
        },
        radius = {
            px = 2.5
        },
        farRadius = 2,
        boxes = {},
        renderDelay = 1,
        staticDelay = 1,
        power = 140,
        maxAge = 1,
        playerVstatic = 0.2,
        playerVmultiplier = 0,
    
        charge = {
            max = 300,
            min = 100,
            lossPerParticle = 0.02,
            rechargePerRender = 3,
            indicator = {
                width = 200,
                height = 50
            }
        },
        distancePower = {
            max = 850,
        },
        heroPull = 5,
        heroPullDist = 300,

        debugLine = false,
        debugGrid = false,
        debugPrint = false
    },
    water = {
        particleSystem = {
            filename = "scene/bending/img/water_droplet.png",
            radius = 18,
            imageRadius=23,
            density=2,
            gravityScale=1,
            pressureStrength=0.1
        },
        waterBlock = {
            createParticle = {
                color = { 0.3, 0.43, 1, 1 },
                lifetime = 200,
                flags = { "water", "colorMixing", "fixtureContactListener" }
            },
            createGroup = {
                color = { 0.3, 0.43, 1, 1 },
                lifetime = 200,
                flags = { "water", "colorMixing", "fixtureContactListener" }
            }
        },
        iceBlock = {
            createParticle = {
                color = { 1, 1, 1, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "fixtureContactListener" },
                groupFlags = { "solid", "rigid", "barrier" }
            },
            createGroup = {
                color = { 1, 1, 1, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "fixtureContactListener" },
                groupFlags = { "solid", "rigid", "barrier" }
            }
        },
        sandBlock = {
            createParticle = {
                color = { 210/255, 180/255, 150/255, 1 },
                lifetime = 200,
                strength = 0.0,
                flags = { "powder", "repulsive", "staticPressure", "reactive", "fixtureContactListener" },
            },
            createGroup = {
                color = { 210/255, 180/255, 150/255, 1 },
                lifetime = 200,
                strength = 0.0,
                flags = { "powder", "repulsive", "staticPressure", "reactive", "fixtureContactListener" },
            }
        },
        mudBlock = {
            createParticle = {
                color = { 86/255, 48/255, 51/255, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "viscous", "tensile", "fixtureContactListener" }
            },
            createGroup = {
                color = { 86/255, 48/255, 51/255, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "viscous", "tensile", "fixtureContactListener" }
            }
        },
        jellyBlock = {
            createParticle = {
                color = { 200/255, 255/255, 76/255, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "spring", "elastic", "fixtureContactListener" }
            },
            createGroup = {
                color = { 200/255, 255/255, 76/255, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "spring", "elastic", "fixtureContactListener" }
            }
        },
        poisonBlock = {
            createParticle = {
                color = { 70/255, 231/255, 40/255, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "water", "colorMixing", "fixtureContactListener" }
            },
            createGroup = {
                color = { 30/255, 210/255, 40/255, 1 },
                lifetime = 200,
                strength = 1.0,
                flags = { "water", "colorMixing", "fixtureContactListener" }
            }
        },
    },
    hero = {
        body = 'hollow',
        floatGravity = 0.5,
        jumpForce = -480,
        anchorY = 0.56,
        anchorX = 0.45,
        walkAcceleration = 1000,
        maxWalkSpeed = 375,
        sheetFileName = "katara-boat-export.png",
        sheetData = {
            width = 230,
            height = 180,
            numFrames = 25,
            sheetContentWidth = 5750,
            sheetContentHeight = 180
        },
        sequenceData = {
            { name = "idle", frames = { 1, 2, 3, 4, 5, 6 }, time = 333 },
            { name = "walk", frames = { 15, 16, 17, 18, 19, 20 }, time = 333, loopCount = 0 },
            { name = "jump", frames = { 21, 22, 23, 24, 25 }, time = 333 },
            { name = "ouch", frames = { 7, 8, 9, 10, 11, 12, 13, 14 } }
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
    filter = {
        particleSystem = {
            filename = "scene/bending/img/invisible.png",
            radius = 30,
            gravityScale = 0.0
        },
        group = {
            flags = {"wall"},
            groupFlags = "rigid",
            strength = 0.0
        }
    },
    target = {
        startHealth = 100,
        waterHitDamage = 1
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
