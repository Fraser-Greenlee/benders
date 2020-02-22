
-- Module/class for the target

local config = require('scene.game-config').noDisplay.target

-- Define module
local M = {}

function M.new( instance )

    if not instance.bodyType then
		physics.addBody( instance, "static" )
	end

	instance.HP = config.startHealth
	instance.fill.effect = "filter.brightness"
	instance.killed = false

	function instance:kill()
		if instance.killed == false then
			instance.killed = true
			local moveAway = function() instance.x = -200 end
    		local renderTimer = timer.performWithDelay(100, moveAway, 1)
		end
	end

	function instance:damage( amount )
		instance.HP = instance.HP - amount
		if instance.HP <= 0 then
			instance.kill()
		else
			instance.fill.effect.intensity = -(1 - (instance.HP / config.startHealth))
		end
	end

	function instance:waterHit()
		instance.damage(instance, config.waterHitDamage)
	end

	function instance:collision( event )
		if event.other.type == "hero" then
			instance.kill()
		end
	end

	instance:addEventListener( "collision" )

	-- Return instance
	instance.name = "target"
	instance.type = "target"
	return instance
end

return M
