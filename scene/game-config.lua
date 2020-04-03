local startConfig = {
    waterBending = {
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
        farRadius = 1,
        boxes = {},
        renderDelay = 1,
        staticDelay = 1,
        power = 140,
        maxAge = 1,
        playerVstatic = 0.2,
        playerVmultiplier = 0,
        charge = {
            max = 1000,
            min = 100,
            lossPerParticle = 0.015,
            rechargePerRender = 6,
            indicator = {
                width = 200,
                height = 50
            }
        },
        distancePower = {
            max = 1250,
        },
        heroPull = 5,
        heroPullDist = 300,

        debugLine = false,
        debugGrid = false,
        debugPrint = false
    },
    fireBend = {
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
            px = 6
        },
        farRadius = 1,
        boxes = {},
        renderDelay = 1,
        staticDelay = 1,
        power = 240,
        maxAge = 1,
        playerVstatic = 0.2,
        playerVmultiplier = 0,
        charge = {
            max = 100,
            min = 0,
            lossPerParticle = 0.015,
            rechargePerRender = 1,
            indicator = {
                width = 200,
                height = 50
            }
        },
        distancePower = {
            max = 1250,
        },
        makeParticleMaxDistance = 600,
        heroPull = 5,
        heroPullDist = 300,

        maxPlayerVelocity = 1000,
        minStepsPerParticleMax = 10,

        debugLine = false,
        debugGrid = false,
        debugPrint = false
    },
    fire = {
        maxLifetime = 20,
        maxRadius = 100,
        particleSystem = {
            filename = "scene/bending/img/water_droplet.png",
            radius = 23,
            imageRadius=25,
            density=1,
            gravityScale=0.0,
            pressureStrength=0.1,
            surfaceTensionPressureStrength=0.2,
            surfaceTensionNormalStrength=0.2,
            maxCount=2000
        },
        fireBlock = {
            createParticle = {
                flags = { "water", "colorMixing", "fixtureContactListener" }
            },
            createGroup = {
                flags = { "water", "colorMixing", "fixtureContactListener" }
            }
        },
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
                flags = { "water", "colorMixing", "fixtureContactListener" }
            },
            createGroup = {
                color = { 0.3, 0.43, 1, 1 },
                flags = { "water", "colorMixing", "fixtureContactListener" }
            }
        },
        iceBlock = {
            createParticle = {
                color = { 1, 1, 1, 1 },
                strength = 1.0,
                flags = { "fixtureContactListener" },
                groupFlags = { "solid", "rigid", "barrier" }
            },
            createGroup = {
                color = { 1, 1, 1, 1 },
                strength = 1.0,
                flags = { "fixtureContactListener" },
                groupFlags = { "solid", "rigid", "barrier" }
            }
        },
        sandBlock = {
            createParticle = {
                color = { 210/255, 180/255, 150/255, 1 },
                strength = 0.0,
                flags = { "powder", "repulsive", "staticPressure", "reactive", "fixtureContactListener" },
            },
            createGroup = {
                color = { 210/255, 180/255, 150/255, 1 },
                strength = 0.0,
                flags = { "powder", "repulsive", "staticPressure", "reactive", "fixtureContactListener" },
            }
        },
        mudBlock = {
            createParticle = {
                color = { 86/255, 48/255, 51/255, 1 },
                strength = 1.0,
                flags = { "viscous", "tensile", "fixtureContactListener" }
            },
            createGroup = {
                color = { 86/255, 48/255, 51/255, 1 },
                strength = 1.0,
                flags = { "viscous", "tensile", "fixtureContactListener" }
            }
        },
        jellyBlock = {
            createParticle = {
                color = { 200/255, 255/255, 76/255, 1 },
                strength = 1.0,
                flags = { "spring", "elastic", "fixtureContactListener" }
            },
            createGroup = {
                color = { 200/255, 255/255, 76/255, 1 },
                strength = 1.0,
                flags = { "spring", "elastic", "fixtureContactListener" }
            }
        },
        poisonBlock = {
            createParticle = {
                color = { 70/255, 231/255, 40/255, 1 },
                strength = 1.0,
                flags = { "water", "colorMixing", "fixtureContactListener" }
            },
            createGroup = {
                color = { 30/255, 210/255, 40/255, 1 },
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
    enemies = {
        enemyCanon = {
            maxPositionOffset = 100,
            maxRotationStep = 2,
            fireCooldown = 10,
            fireDelay = 1000 * 5,
            canonCount = 3,
            canonForce = 1000,
            canonBallPhysics = { density=10.0, friction=0.2, bounce=0.0, radius=85 }
        },
        skullLanturn = {
            physics = { density=2.0, friction=0.5, bounce=0.0, radius=60 },
            gravityScale = -0.1,
            maxParticleHitCount = 60,
            sheetFileName = "skull-lanturn-Sheet.png",
            moveImpulse = 10,
            sheetData = {
                width = 150,
                height = 140,
                numFrames = 8,
                sheetContentWidth = 1200,
                sheetContentHeight = 140
            },
            sequenceData = {
                { name = "hover", frames = { 1, 2, 3, 4 }, time = 1200 },
                { name = "turn", frames = { 5, 6, 7 }, time = 333, loopCount = 0 },
                { name = "dead", frames = { 8 }, time = 333, loopCount = 0 },
            }
        }
    },
    game = {
        debugPhysics = false,
        bendingMode = 'fire'
    }
}

return {
    new = function(display)

        startConfig.waterBending.pixel.size = math.floor(
            display.actualContentWidth / startConfig.waterBending.pixel.per.row
        )
        startConfig.waterBending.pixel.per.column = math.floor(
            display.actualContentHeight / startConfig.waterBending.pixel.size
        )
        startConfig.waterBending.radius.bendingPX = math.floor(
            startConfig.waterBending.radius.px / startConfig.waterBending.pixel.size
        )

        startConfig.fireBend.pixel.size = math.floor(
            display.actualContentWidth / startConfig.fireBend.pixel.per.row
        )
        startConfig.fireBend.pixel.per.column = math.floor(
            display.actualContentHeight / startConfig.fireBend.pixel.size
        )
        startConfig.fireBend.radius.bendingPX = math.floor(
            startConfig.fireBend.radius.px / startConfig.fireBend.pixel.size
        )

        return startConfig
    end,
    noDisplay = startConfig
}
