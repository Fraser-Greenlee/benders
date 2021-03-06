
local config = require('scene.game-config').noDisplay.enemies.skullLanturn

-- Define module
local M = {}

function M.new( instance )

	-- Store map placement and hide placeholder
	instance.isVisible = false
    local parent = instance.parent
	local x, y = instance.x, instance.y

	-- Load spritesheet
	local sheet = graphics.newImageSheet( "scene/game/img/" .. config.sheetFileName, config.sheetData )
	instance = display.newSprite( parent, sheet, config.sequenceData )
	instance.x,instance.y = x, y
    instance:setSequence( "hover" )
    instance:play()

	-- Add physics
    physics.addBody( instance, "dynamic", config.physics )
    instance.gravityScale = config.gravityScale
	instance.isFixedRotation = true

    instance.isDead = false
    instance.health = config.maxParticleHitCount

    function instance:hurt()
        if instance.isDead then
            return nil
        end
        instance.health = instance.health - 1
        if instance.health < 1 then
            instance:die()
        end
    end

	function instance:die()
        -- swith to non-lanturn skull
        instance.isDead = true
        instance:removeEventListener( "collision" )
        Runtime:removeEventListener( "enterFrame", enterFrame )
        instance:setSequence( "dead" )
        instance.gravityScale = 1.0
        instance.water:destroyRadius( instance.x, instance.y, 160 )
    end

	function instance:collision( event )
		local phase = event.phase
		if phase == "began" then
			if event.other.type == "hero" then
                event.other:hurt()
			end
		end
    end

    instance.direction = 1
    instance.startedTurn = false

    function instance:turn()
        instance.startedTurn = true
        instance:setSequence( "turn" )
        instance:play()
        local swapDirection = function()
            if instance.isDead == false then
                instance.direction = instance.direction * -1
                instance.xScale = instance.direction
                instance:setSequence( "hover" )
                instance:play()
            end
            instance.startedTurn = false
        end
        instance.turnMethod = timer.performWithDelay(333, swapDirection, 1)
    end

    local function enterFrame()
        if instance.isDead then
            return nil
        end
        -- Do this every frame
        local xDist = instance.x - instance.hero.x
        local yDist = (instance.y - instance.hero.y) * 0.1
        local heroDistance = math.sqrt(xDist^2 + yDist^2)

        if instance.startedTurn == false then
            if xDist > 0 and instance.direction == 1 then
                instance:turn()
            elseif xDist < 0 and instance.direction == -1 then
                instance:turn()
            end
        end

        instance:applyLinearImpulse(
            (xDist/heroDistance) * -config.moveImpulse,
            (yDist/heroDistance) * -config.moveImpulse,
            instance.x,
            instance.y
        )

        if instance.health < config.maxParticleHitCount then
            instance.health = instance.health + 1
        end
	end

	function instance:finalize()
        -- On remove, cleanup instance, or call directly for non-visual
        timer.cancel(instance.turnMethod)
		instance:removeEventListener( "collision" )
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our collision listeners
	instance:addEventListener( "collision" )

	-- Return instance
	instance.name = "skullLanturn"
	instance.type = "skullLanturn"
	return instance
end

return M
