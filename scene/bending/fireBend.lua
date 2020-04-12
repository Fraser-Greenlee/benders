
-- Module/class for bending

local configMaker = require('scene.game-config').new

-- Define module
local M = {}

function M.new( display, fire, hero )
    local self = {}

    self.display = display
    -- Create display group to hold visuals
	self.displayGroup = display.newGroup()
    self.config = configMaker(self.display).fireBend
    self.fire = fire
    self.particleSystem = fire.particleSystem
    self.hero = hero

    local function bendingPixelXY(x, y)
        local x = x
        local y = y - self.config.pixel.start.y
        local pixelX = math.round(x / self.config.pixel.size)
        local pixelY = math.round(y / self.config.pixel.size)

        self.pixelOffsetX = -(x % self.config.pixel.size)
        self.pixelOffsetY = -(y % self.config.pixel.size)

        return pixelX, pixelY
    end

    local function staticDeltaV(XorY)
        --[[
            TODO
            - gradually ramp up deltaV until at 80% bending radius
            - then gradually decrease till last 10% radius
            - put 0 force there
        ]]
        local bendingCoeff = ( (XorY / self.bendingRadius) )
        return - self.config.power * bendingCoeff
    end
    
    local function setDeltaV(XorY, playerXorY)
        -- print(XorY, playerXorY)
        --if ((XorY > 0 and playerXorY < 0) or (XorY < 0 and playerXorY > 0)) then
        --    return 0
        --end
        return staticDeltaV(XorY) * (1 - self.config.playerVstatic)
    end
    
    local function showDebug(pixel)
        -- NOTE this will dramatically slow down the game
        if self.config.debugLine then
            local line = self.display.newLine(
                self.displayGroup,
                pixel.x + self.pixelOffsetX, pixel.y + self.pixelOffsetY, pixel.x + self.pixelOffsetX + pixel.deltaVX/2, pixel.y + self.pixelOffsetY + pixel.deltaVY/2
            )
            -- line:setStrokeColor( math.random(), math.random(), math.random(), 1 )
            line.strokeWidth = 1
        end
    end

    function self:drawGrid()
        if self.config.debugGrid == false then
            return false
        end
        for y=0, self.config.pixel.per.column do
            for x=0, self.config.pixel.per.row do
                local bendingPixel = self.display.newRect(
                    self.displayGroup,
                    x * self.config.pixel.size + self.config.pixel.start.x,
                    y * self.config.pixel.size + self.config.pixel.start.y,
                    self.config.pixel.size,
                    self.config.pixel.size
                )
                bendingPixel.strokeWidth = 1
                bendingPixel:setStrokeColor( 1, 0.4, 0.25 )
                bendingPixel:setFillColor( 1, 0.4, 0.25, 0.2 )
                self.config.boxes[tostring(x) .. tostring(y)] = bendingPixel
            end
        end
    end

    function self:run(eventTime, globalX, globalY, playerVX, playerVY, isThrow)
        local centreX, centreY = bendingPixelXY(globalX, globalY)
        for y = centreY - self.bendingRadius, centreY + self.bendingRadius do
            for x = centreX - self.bendingRadius, centreX + self.bendingRadius do
    
                local relX = x - centreX
                local relY = y - centreY
                local distance = math.sqrt(relX*relX + relY*relY)
    
                if distance <= self.bendingRadius then
                    local skip = false
                    if isThrow then
                        local dotProduct = relX*playerVX + relY*playerVY
                        if dotProduct > 0 then
                            skip = true
                        end
                    end

                    if skip == false then
                        local pixel = self.config.boxes[tostring(x) .. ',' .. tostring(y)]
                        if pixel == nil then
                            pixel = {}
                        end
                        pixel.deltaVX = setDeltaV(relX, playerVX)
                        pixel.deltaVY = setDeltaV(relY, playerVY)

                        pixel.x = x * self.config.pixel.size
                        pixel.y = y * self.config.pixel.size + self.config.pixel.start.y
                        pixel.madeAt = eventTime
                        self.config.boxes[tostring(x) .. ',' .. tostring(y)] = pixel

                        showDebug(pixel)
                    end
                end
            end
        end
    end

    self.hasCharge = 1

    function self:render()
        local particlesTouched = 0
        if self.bendingCharge <= 0 then
            self.hasCharge = 0
        elseif self.hasCharge == 0 and self.bendingCharge >= self.config.charge.min then
            self.hasCharge = 1
        end
        for coords, pixel in pairs(self.config.boxes) do
            if (pixel ~= nil) then
                local age = (system.getTimer() - pixel.madeAt) / 1000
                if (age >= self.config.maxAge) then
                    self.config.boxes[coords] = nil
                else
                    local ageRatio = 1 - (age / self.config.maxAge)

                    local hits = self.particleSystem:queryRegion(
                        pixel.x - self.config.pixel.size/2 + self.pixelOffsetX,
                        pixel.y - self.config.pixel.size/2 + self.pixelOffsetY,
                        pixel.x + self.config.pixel.size/2 + self.pixelOffsetX,
                        pixel.y + self.config.pixel.size/2 + self.pixelOffsetY,
                        { deltaVelocityX=pixel.deltaVX * ageRatio * self.hasCharge, deltaVelocityY=pixel.deltaVY * ageRatio * self.hasCharge }
                    )

                    if hits ~= nil and self.hasCharge == 1 then
                        particlesTouched = particlesTouched + #hits
                    end
                end
            end
        end
        self.bendingCharge = self.bendingCharge - particlesTouched * self.config.charge.lossPerParticle
        if particlesTouched == 0 and self.bendingCharge < self.config.charge.max and self.hero.jumping == false then
            self.bendingCharge = self.bendingCharge + self.config.charge.rechargePerRender
        end
        if self.bendingCharge < 0 then
            self.bendingCharge = 0
        end
        self.bendingChargeIndicator.path.width = self.config.charge.indicator.width * self.bendingCharge/self.config.charge.max
    end

    -- attributes for tracking cursor movement
    self.previousTime = 0
    self.previousX = 0
    self.previousY = 0
    self.makeParticlePreviousX = 0
    self.makeParticlePreviousY = 0
    self.makeParticlePreviousTime = 0
    self.touchX = 0
    self.touchY = 0
    self.velocityX = 0
    self.velocityY = 0
    self.pixelOffsetX = 0
    self.pixelOffsetY = 0
    self.bendingCharge = self.config.charge.max
    self.bendingChargeIndicatorFull = display.newRect(
        self.displayGroup, 400, -250, self.config.charge.indicator.width, self.config.charge.indicator.height
    )
    self.bendingChargeIndicator = display.newRect(
        self.displayGroup, 400, -250, self.config.charge.indicator.width, self.config.charge.indicator.height
    )
    self.bendingChargeIndicator:setFillColor( 0.2, 0.7, 0.1 )
    self.bendingRadius = self.config.radius.px
    self.bendingCircle = display.newCircle( self.displayGroup, 300, 300, self.config.pixel.size * self.bendingRadius )
    self.bendingCircle.strokeWidth = 30
    self.bendingCircle:setStrokeColor( 0.2, 0.7, 0.1 )
    self.bendingCircle:setFillColor( 1, 1, 1, 0.0 )
    self.bendingCircle.alpha = 0.0
    self.lastTouchEvent = 0
    self.bendTimer = 0
    self.ranRestart = false -- if player holds touch while level is restarted the event times will be off, use this to reset it
    self.stepsSinceLastParticleMade = 0

    function self:timer(event)
        self.touchX = self.lastTouchEvent.x
        self.touchY = self.lastTouchEvent.y
        local positionDeltaX = self.touchX - self.previousX
        local positionDeltaY = self.touchY - self.previousY
        self.previousX = self.touchX
        self.previousY = self.touchY
        self.velocityX = ( positionDeltaX / self.timeDelta )
        self.velocityY = ( positionDeltaY / self.timeDelta )

        self.bendingCircle.x = self.touchX
        self.bendingCircle.y = self.touchY

        self.bendingCircle.path.radius = self.bendingRadius * self.config.pixel.size

        if self.bendingCharge <= 0 or self.hasCharge == 0 then
            self.bendingCircle.alpha = 0.0
        else
            self.bendingCircle.alpha = 0.05 + 0.3 * self.bendingCharge/self.config.charge.max
        end

        local touchVelocity = math.sqrt((self.velocityX * self.velocityX) + (self.velocityY * self.velocityY))
        self.run( self, event.time, self.touchX, self.touchY, self.velocityX, self.velocityY, touchVelocity > 4 )
    end

    function self:makeParticle(event)
        if self.bendingCharge < 10 then
            return nil
        end
        local touchX = event.x
        local touchY = event.y

        local heroDistX = touchX - self.hero.x
        local heroDistY = touchY - self.hero.y
        local heroDistance = math.sqrt(heroDistX^2 + heroDistY^2)

        if  heroDistance >= self.config.makeParticleMaxDistance or heroDistance <= self.config.makeParticleMinDistance then
            -- print('too far from player')
            return nil
        end

        local positionDeltaX = touchX - self.makeParticlePreviousX
        local positionDeltaY = touchY - self.makeParticlePreviousY
        local positionDistance = math.sqrt(positionDeltaX^2 + positionDeltaY^2)
        if positionDistance < 90 then
            -- print('too close')
            return nil
        end
        local timeDelta = ( event.time / 1000 ) - self.makeParticlePreviousTime
        local velocityX = ( positionDeltaX / timeDelta )
        local velocityY = ( positionDeltaY / timeDelta )

        local touchVelocity = math.sqrt((velocityX * velocityX) + (velocityY * velocityY))
        if touchVelocity < self.config.minPlayerVelocity then
            -- print('too slow', touchVelocity, timeDelta)
            return nil
        end

        local touchVelocityRatio = math.min(touchVelocity, self.config.maxPlayerVelocity) / self.config.maxPlayerVelocity
        local maxPlayerRadius = 150
        local invHeroDist = 1 - ( (heroDistance - maxPlayerRadius) / (self.config.distancePower.max - maxPlayerRadius) )
        local tempRatio = 0.2 * invHeroDist + 0.8 * touchVelocityRatio

        self.fire:makeParticleGroup( touchX, touchY, velocityX, velocityY, tempRatio, positionDistance )
        self.bendingCharge = self.bendingCharge - 15 * tempRatio
        self.stepsSinceLastParticleMade = 0

        self.makeParticlePreviousX = touchX
        self.makeParticlePreviousY = touchY
        self.makeParticlePreviousTime = event.time / 1000
    end

    function self:touch(event)
        self.timeDelta = ( event.time / 1000 ) - self.previousTime
        if self.timeDelta > 0 then
            self.lastTouchEvent = event
            if ( "began" == event.phase ) then
                self.bendTimer = timer.performWithDelay( 1, self, -1 )
                self.ranRestart = false

                self.makeParticlePreviousX = event.x
                self.makeParticlePreviousY = event.y
                self.makeParticlePreviousTime = event.time / 1000
            else
                self:makeParticle(event)
            end
            if self.ranRestart == true then
                self.previousTime = event.time
                self.makeParticlePreviousX = event.x
                self.makeParticlePreviousY = event.y
                self.makeParticlePreviousTime = event.time / 1000
            end
        end
        if ( "ended" == event.phase or "cancelled" == event.phase ) and type(self.bendTimer) ~= 'number' then
            timer.cancel(self.bendTimer)
            self.bendingCircle.alpha = 0.0
            self.previousTime = 0
            self.pixelOffsetX, self.pixelOffsetY = 0, 0
        end
        return true
    end

    -- start run timers
    Runtime:addEventListener( "touch", self )
    local runRender = function() return self.render( self ) end
    local renderTimer = timer.performWithDelay(self.config.renderDelay, runRender, -1)

    function self:destroy()
        if type(self.bendTimer) ~= 'number' then
            timer.cancel(self.bendTimer)
            self.bendingCircle.alpha = 0.0
            self.previousTime = 0
            self.ranRestart = true
        end
        self.displayGroup:removeSelf()
        timer.cancel( renderTimer )
        Runtime:removeEventListener( "touch", self )
    end

    return self
end

return M
