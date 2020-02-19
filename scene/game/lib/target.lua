
-- Module/class for the target

local config = require('scene.game-config').noDisplay.filter.group

-- Define module
local M = {}

function M.new( instance )

    if not instance.bodyType then
		physics.addBody( instance, "static" )
    end

	function instance:collision( event )
		print( "collision" )
	end

	instance:addEventListener( "collision" )

	-- Return instance
	instance.name = "target"
	instance.type = "target"
	return instance
end

return M
