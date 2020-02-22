
-- Module/class for the filterPlayerBlock

-- local config = require('scene.game-config').noDisplay.filter.group
local collisionFilters = require( "plugin.collisionFilters" )
collisionFilters.setupFilters( { nothing={ "player", "filterBlock" } } )
local blockFilter = collisionFilters.getFilter( "filterBlock" )

-- Define module
local M = {}

function M.new( instance )

	physics.addBody( instance, "static", { filter=blockFilter } )

	-- Return instance
	instance.name = "filterPlayerBlock"
	instance.type = "filterPlayerBlock"
	return instance
end

return M
