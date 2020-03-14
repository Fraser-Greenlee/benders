
-- Module/class for the mudBlock

local composer = require( "composer" )
local config = require('scene.game-config').noDisplay.water.mudBlock.createGroup

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
	instance.name = "mudBlock"
	instance.type = "mudBlock"
	return instance
end

return M
