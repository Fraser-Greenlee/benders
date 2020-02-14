
-- Module/class for water fountain

local composer = require( "composer" )

-- Define module
local M = {}

function M.new( instance )
	-- Store map placement and hide placeholder
	local parent = instance.parent
	instance.i = 0

	function instance:addWater()

		local function enterFrame()
			instance.i = instance.i + 1
			if instance.i % 4 == 0 then
				instance.water.makeParticle( instance.water, instance.x, instance.y - 40, math.random(-3, 3), -1000 )
			end
		end

		local tm = timer.performWithDelay( 10, enterFrame, -1 )

		function instance:finalize()
			-- On remove, cleanup instance, or call directly for non-visual
			timer.cancel(tm)
		end
		
		-- Add a finalize listener (for display objects only, comment out for non-visual)
		instance:addEventListener( "finalize" )

	
		return instance
	end

	-- Return instance
	instance.name = "fountain"
	instance.type = "fountain"
	return instance
end

return M

