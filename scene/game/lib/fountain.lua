
-- Module/class for water fountain

-- Use this as a template to build an in-game hero 
local composer = require( "composer" )

-- Define module
local M = {}

function M.new( instance )
	-- Get the current scene
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	-- Store map placement and hide placeholder
	local parent = instance.parent
    local x, y = instance.x, instance.y
    
    --[[

    -- define particle system
    local 

	local function enterFrame()
		-- Do this every frame
        -- add water particle from fountain
	end

    ]]
end

return M

