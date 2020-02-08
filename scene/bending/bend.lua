
-- Module/class for bending

local configMaker = require('scene.game-config').new

-- Define module
local M = {}

function M.new( display, particleSystem )
    local self = {}

    self.display = display
    -- Create display group to hold visuals
	self.displayGroup = display.newGroup()
    self.config = configMaker(self.display).bending
    self.particleSystem = particleSystem

    local function bendingPixelXY(x, y)
        x = x
        y = y - self.config.pixel.start.y + self.config.pixel.size/2
        local pixelX = math.round(x / self.config.pixel.size)
        local pixelY = math.round(y / self.config.pixel.size)
        return pixelX, pixelY
    end
    
    local function staticDeltaV(XorY)
        --[[
            TODO
            - gradually ramp up deltaV until at 80% bending radius
            - then gradually decrease till last 10% radius
            - put 0 force there
        ]]
        local bendingCoeff = ( (XorY / self.config.radius.px) - 0.1 )
        return - self.config.power * bendingCoeff
    end
    
    local function setDeltaV(XorY)
        return staticDeltaV(XorY) * (1 - self.config.playerVstatic)
    end
    
    local function showDebug(pixel)
        -- NOTE this will dramatically slow down the game
        if self.config.debugLine then
            local line = self.display.newLine(
                self.displayGroup,
                pixel.x, pixel.y, pixel.x + pixel.deltaVX/2, pixel.y + pixel.deltaVY/2
            )
            line:setStrokeColor( math.random(), math.random(), math.random(), 1 )
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
                    x*self.config.pixel.size + self.config.pixel.start.x,
                    y*self.config.pixel.size + self.config.pixel.start.y,
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

    function self:run(eventTime, globalX, globalY, playerVX, playerVY)
        centreX, centreY = bendingPixelXY(globalX, globalY)
        for y = centreY - self.config.radius.px, centreY + self.config.radius.px do
            for x = centreX - self.config.radius.px, centreX + self.config.radius.px do
    
                local relX = x - centreX
                local relY = y - centreY
                local distance = math.sqrt(relX*relX + relY*relY)
    
                if distance <= self.config.radius.px then
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

    function self:render()
        for coords, pixel in pairs(self.config.boxes) do
            if (pixel ~= nil) then
                local age = (system.getTimer() - pixel.madeAt) / 1000
                if (age >= self.config.maxAge) then
                    self.config.boxes[coords] = nil
                else
                    local ageRatio = 1 - (age / self.config.maxAge)

                    local region = self.particleSystem:queryRegion(
                        pixel.x - self.config.pixel.size/2,
                        pixel.y - self.config.pixel.size/2,
                        pixel.x + self.config.pixel.size/2,
                        pixel.y + self.config.pixel.size/2,
                        { deltaVelocityX=pixel.deltaVX * ageRatio, deltaVelocityY=pixel.deltaVY * ageRatio }
                    )
                end
            end
        end
    end

    -- attributes for tracking cursor movement
    self.previousTime = 0
    self.previousX = 0
    self.previousY = 0
    self.touchX = 0
    self.touchY = 0
    self.velocityX = 0
    self.velocityY = 0

    function self:staticBend()
        if ( self.previousTime + self.config.staticDelay < system.getTimer() ) then
            bend.run( self, system.getTimer(), touchX, touchY, velocityX, velocityY )
        end
    end
    local runstaticBend = function() return self.staticBend( self ) end

    local function onTouch(event)
        local timeDelta = ( event.time / 1000 ) - self.previousTime
        if timeDelta > 0 then
            self.touchX = event.x
            self.touchY = event.y
            self.previousTime = ( event.time / 1000 )
            local positionDeltaX = self.touchX - self.previousX
            local positionDeltaY = self.touchY - self.previousY
            self.previousX = self.touchX
            self.previousY = self.touchY
            self.velocityX = ( positionDeltaX / timeDelta )
            self.velocityY = ( positionDeltaY / timeDelta )
    
            self.run( self, event.time, self.touchX, self.touchY, self.velocityX, self.velocityY )
    
            if self.config.debugPrint then
                if ( "began" == event.phase ) then
                    print('began')
                    local staticTimer = timer.performWithDelay( 1, runstaticBend, -1 )
                elseif ( "moved" == event.phase ) then
                    print('moved')
                elseif ( "ended" == event.phase or "cancelled" == event.phase ) then
                    print('end')
                    timer.cancel( staticTimer )
                end
            end
        end
        return true
    end

    -- start run timers
    Runtime:addEventListener( "touch", onTouch )
    local runRender = function() return self.render( self ) end
    timer.performWithDelay(self.config.renderDelay, runRender, -1)

    return self
end

return M
