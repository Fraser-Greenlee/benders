
-- Module/class for the waterBlock

local composer = require( "composer" )
local config = require('scene.game-config').noDisplay.water.createGroup

-- Define module
local M = {}

function M.new( instance )

    -- Hide placeholder
	instance.isVisible = false

    function instance:makeBlock()
		config.x = instance.x
		config.y = instance.y
		config.halfWidth = instance.width / 2
        config.halfHeight = instance.height / 2

		instance.particleSystem:createGroup( config )
	end

	-- Return instance
	instance.name = "waterBlock"
	instance.type = "waterBlock"
	return instance
end

return M
