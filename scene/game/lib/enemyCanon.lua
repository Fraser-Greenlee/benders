
-- Module/class for platformer enemyCanon

local config = require('scene.game-config').noDisplay.enemyCanon

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )

	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	-- Store map placement and hide placeholder
	instance.isVisible = true
	local parent = instance.parent
    local x, y = instance.x, instance.y

    instance.baseX = x
    instance.baseY = y

    -- Add physics
    physics.addBody( instance, "static", { radius=70, density=1, bounce=0.1, friction=1.0 } )
    instance.gravityScale = 0.0
	instance.isFixedRotation = true
	instance.isDead = false

	function instance:die()
		audio.play( sounds.sword )
		self.isFixedRotation = false
		self.isSensor = true
		self.isDead = true
	end

	function instance:preCollision( event )
		-- print('collision')
	end

	local max, direction, flip, timeout = 250, 5000, 0.133, 0
	direction = direction * ( ( instance.xScale < 0 ) and 1 or -1 )
	flip = flip * ( ( instance.xScale < 0 ) and 1 or -1 )

    function instance:getHeroAngle()
        -- angle will be between -180 and 180 degrees
		return math.deg(math.atan2( instance.hero.y - instance.y , instance.hero.x - instance.x ))
    end

    function instance:fire()
        -- fire the canon
    end

    function instance:targetPlayer()
        if (instance.hero ~= nil) then
            local targetAngle = instance.getHeroAngle() - 90
            print(instance.rotation, targetAngle)
            if (instance.rotation + config.maxRotationStep < targetAngle) then
                instance:rotate(config.maxRotationStep)
            elseif (targetAngle < -180) and instance.rotation < targetAngle + 270 then
                instance:rotate(-config.maxRotationStep)
            elseif instance.rotation - config.maxRotationStep > targetAngle then
                instance:rotate(-config.maxRotationStep)
            end
        end
    end

	local function enterFrame()
        -- Do this every frame
        instance.targetPlayer()
	end

	function instance:finalize()
		-- On remove, cleanup instance, or call directly for non-visual
		Runtime:removeEventListener( "enterFrame", enterFrame )
		instance = nil
	end

    function instance:addHero(hero)
        instance.hero = hero
    end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our collision listener
	instance:addEventListener( "preCollision" )

	-- Return instance
	instance.name = "enemyCanon"
	instance.type = "enemyCanon"
	return instance
end

return M
