
-- Module/class for platfomer hero

local config = require('scene.game-config').noDisplay.hero

local collisionFilters = require( "plugin.collisionFilters" )
collisionFilters.setupFilters( { nothing={ "player", "filterBlock" } } )
local playerFilter = collisionFilters.getFilter( "player" )

-- Use this as a template to build an in-game hero 
local fx = require( "com.ponywolf.ponyfx" )
local composer = require( "composer" )

-- Define module
local M = {}

function M.new( instance, options )
	-- Get the current scene
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	-- Default options for instance
	options = options or {}

	-- Store map placement and hide placeholder
	instance.isVisible = false
	local parent = instance.parent
	local x, y = instance.x, instance.y

	-- Load spritesheet
	local sheet = graphics.newImageSheet( "scene/game/img/" .. config.sheetFileName, config.sheetData )
	instance = display.newSprite( parent, sheet, config.sequenceData )
	instance.x,instance.y = x, y
	instance:setSequence( "idle" )

	-- Add physics
	if (config.body == 'hollow') then
		physics.addBody( instance, "dynamic",
			{
				density = 1.3,
				bounce = 0.0,
				friction = 0.2,
				filter = playerFilter,
				shape = { 
					0-90,0+10, 0-90,37+10, 38-90,62+10, 38-90,-10+10
				}
			},
			{
				density = 1.3,
				bounce = 0.0,
				friction = 0.2,
				filter = playerFilter,
				shape = { 
					160-90,62+10, 201-90,37+10, 201-90,1+10, 160-90,-10+10
				}
			},
			{
				density = 1.3,
				bounce = 0.0,
				friction = 0.2,
				filter = playerFilter,
				shape = { 
					38-90,10+10,  160-90,10+10, 160-90,-10+10, 38-90,-10+10
				}
			}
		)
	elseif (config.body == 'circle') then
		physics.addBody( instance, "dynamic",
			{
				density = 1.2,
				bounce = 0.0,
				friction = 0.2,
				filter = playerFilter,
				radius = 70
			}
		)
	end
	instance.isFixedRotation = true
	instance.anchorY = config.anchorY
	instance.anchorX = config.anchorX
	instance.jumping = false

	-- Keyboard control
	local left, right, flip = 0, 0, 1
	local lastEvent = {}
	local function key( event )
		local phase = event.phase
		local name = event.keyName
		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
		if phase == "down" then
			if "left" == name or "a" == name then
				left = -config.walkAcceleration
				flip = -1
			end
			if "right" == name or "d" == name then
				right = config.walkAcceleration
				flip = 1
			elseif "space" == name or "up" == name or "w" == name or "buttonA" == name or "button1" == name then
				instance:jump()
			end
			if not ( left == 0 and right == 0 ) and not instance.jumping then
				instance:setSequence( "walk" )
				instance:play()
			end
		elseif phase == "up" then
			if "left" == name or "a" == name then left = 0 end
			if "right" == name or "d" == name then right = 0 end
			if left == 0 and right == 0 and not instance.jumping then
				instance:setSequence("idle")
				instance:play()
			end
			if "space" == name or "up" == name or "w" == name or "buttonA" == name or "button1" == name then
				instance:jumpFloatEnd()
			end
		end
		lastEvent = event
	end

	function instance:jump()
		if not self.jumping then
			self.gravityScale = config.floatGravity
			self:applyLinearImpulse( 0, config.jumpForce )
			self:setSequence( "jump" )
			instance:play()
			self.jumping = true
		end
	end

	function instance:jumpFloatEnd()
		if self.jumping then
			self.gravityScale = 1
		end
	end

	function instance:die()
		composer.gotoScene( "scene.refresh", { params = { map = self.filename } } )
		instance.isDead = true
		instance.isSensor = true
		self:applyLinearImpulse( 0, -500 )
		-- Death animation
		instance:setSequence( "ouch" )
		self.xScale = 1
		transition.to( self, { xScale = -1, time = 750, transition = easing.continuousLoop, iterations = -1 } )
		-- Remove all listeners
		self:finalize()
	end

	function instance:hurt()
		fx.flash( self )
		audio.play( sounds.hurt[math.random(2)] )
		if self.shield:damage() <= 0 then
			instance:die()
		end
	end

	function instance:collision( event )
		local phase = event.phase
		local other = event.other
		local y1, y2 = self.y + 50, other.y - ( other.type == "enemy" and 25 or other.height/2 )
		local vx, vy = self:getLinearVelocity()
		if phase == "began" then
			if not self.isDead and ( other.type == "cannon-ball" ) then
				self:hurt()
			elseif self.jumping and vy > 0 and not self.isDead then
				-- Landed after jumping
				instance:jumpFloatEnd()
				self.jumping = false
				if not ( left == 0 and right == 0 ) and not instance.jumping then
					instance:setSequence( "walk" )
					instance:play()
				else
					self:setSequence( "idle" )
				end
			end
		end
	end

	function instance:preCollision( event )
		local other = event.other
		local y1, y2 = self.y + 50, other.y - other.height/2
		if event.contact and ( y1 > y2 ) then
			if other.floating then
				event.contact.friction = 0.0
			else
				event.contact.friction = 0.1
			end
		end
	end

	local function enterFrame()
		-- Do this every frame
	end

	function instance:finalize()
		-- On remove, cleanup instance, or call directly for non-visual
		instance:removeEventListener( "preCollision" )
		instance:removeEventListener( "collision" )
		Runtime:removeEventListener( "enterFrame", enterFrame )
		Runtime:removeEventListener( "key", key )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our key/joystick listeners
	Runtime:addEventListener( "key", key )

	-- Add our collision listeners
	instance:addEventListener( "preCollision" )
	instance:addEventListener( "collision" )

	-- Return instance
	instance.name = "hero"
	instance.type = "hero"
	return instance
end

return M
