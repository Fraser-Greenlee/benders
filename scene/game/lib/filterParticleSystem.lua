
-- Module/class for the filtering particle system.
-- Lets particles past but not solid objects.

local config = require('scene.game-config').noDisplay.filter.particleSystem

-- Define module
local M = {}

function M.new( physics )
    local self = {}

    self.particleSystem = physics.newParticleSystem( config )

	-- Return self
	self.name = "filterParticleSystem"
	self.type = "filterParticleSystem"
	return self
end

return M
