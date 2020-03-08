
-- Module/class for the filterParticlesBlock

local config = require('scene.game-config').noDisplay.filter.group

-- Define module
local M = {}

function M.new( instance )

	function instance:makeBlock()
		config.x = instance.x
		config.y = instance.y
		config.halfWidth = instance.width / 2
        config.halfHeight = instance.height / 2

		instance.particleSystem:createGroup( config )
	end

	instance.isVisible = false

	-- Return instance
	instance.name = "filterParticlesBlock"
	instance.type = "filterParticlesBlock"
	return instance
end

return M
