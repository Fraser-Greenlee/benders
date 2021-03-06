
-- Module/class for the killWaterBlock

local config = require('scene.game-config').noDisplay.filter.group

-- Define module
local M = {}

function M.new( instance )

	function instance:start()

		local function enterFrame()
			instance.particleSystem:destroyParticles(
                {
                    x = instance.x,
                    y = instance.y,
                    halfWidth = instance.width/2,
                    halfHeight = instance.height/2
                }
            )
		end

		local tm = timer.performWithDelay( 10000, enterFrame, -1 )

		function instance:finalize()
			-- On remove, cleanup instance, or call directly for non-visual
			timer.cancel(tm)
		end

		-- Add a finalize listener (for display objects only, comment out for non-visual)
		instance:addEventListener( "finalize" )
	
		return instance
	end

	-- Return instance
	instance.name = "killWaterBlock"
	instance.type = "killWaterBlock"
	return instance
end

return M
