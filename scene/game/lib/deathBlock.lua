
-- Module/class for the deathBlock

local config = require('scene.game-config').noDisplay.filter.group

-- Define module
local M = {}

function M.new( instance )

    instance.isVisible = false
    if not instance.bodyType then
		physics.addBody( instance, "static", { isSensor = true } )
    end

	function instance:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then
			other:die()
		end
	end

	instance:addEventListener( "collision" )

	-- Return instance
	instance.name = "deathBlock"
	instance.type = "deathBlock"
	return instance
end

return M
