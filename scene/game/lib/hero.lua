
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

	physics.addBody( instance, "dynamic",
		{
			density = 1.2,
			bounce = 0.0,
			friction = 0.2,
			filter = playerFilter,
			shape={ 0,-150, 120,-100, 80,130, -80,130, -120,-100 }
		}
	)
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
		if phase == "began" then
			if not self.isDead and ( event.other.type == "cannon-ball" ) then
				local heroVx, heroVy = self:getLinearVelocity()
				local otherVx, otherVy = event.other:getLinearVelocity()
				local collisionSpeed = math.sqrt(heroVx*heroVy + otherVx*otherVy)
				-- cannon ball kills player on first hit
				if collisionSpeed > 100 then
					instance:die()
				end
			end
			self.jumping = false
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
		local vx, vy = instance:getLinearVelocity()
		local dx = left + right
		-- if instance.jumping then dx = dx / 2 end
		local dy = 0
		-- if instance.jumping then dy = -5 end
		if (dx == 0 and instance.jumping) then
			instance:applyForce( -3*vx, dy, instance.x, instance.y )
		elseif ( dx < 0 and vx > -config.maxWalkSpeed ) or ( dx > 0 and vx < config.maxWalkSpeed ) then
			instance:applyForce( dx or 0, dy, instance.x, instance.y )
		end
		-- Turn around
		instance.xScale = math.min( 1, flip )
	end

	function instance:finalize()
		-- On remove, cleanup instance, or call directly for non-visual
		instance:removeEventListener( "preCollision" )
		instance:removeEventListener( "collision" )
		Runtime:removeEventListener( "key", key )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )

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
