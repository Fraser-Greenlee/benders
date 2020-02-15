
-- Module/class for platfomer hero

local config = require('scene.game-config').noDisplay.hero

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
	physics.addBody( instance, "dynamic", config.physics )
	instance.isFixedRotation = true
	instance.anchorY = config.anchorY
	instance.anchorX = config.anchorX
	instance.jumping = false

	-- Keyboard control
	local left, right, flip = 0, 0, 0
	local lastEvent = {}
	local function key( event )
		local phase = event.phase
		local name = event.keyName
		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
		if phase == "down" then
			if "left" == name or "a" == name then
				left = -config.walkAcceleration
				flip = -0.133
			end
			if "right" == name or "d" == name then
				right = config.walkAcceleration
				flip = 0.133
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
		end
		lastEvent = event
	end

	function instance:jump()
		if not self.jumping then
			self:applyLinearImpulse( 0, config.jumpForce )
			self:setSequence( "jump" )
			instance:play()
			self.jumping = true
		end
	end

	function instance:die()
		fx.fadeOut(
			function()
				composer.gotoScene( "scene.refresh", { params = { map = self.filename } } )
			end,
			5, 0
		)
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
			if not self.isDead and ( other.type == "blob" or other.type == "enemy" ) then
				if y1 < y2 then
					-- Hopped on top of an enemy
					other:die()
				elseif not other.isDead then
					-- They attacked us
					self:hurt()
				end
			elseif self.jumping and vy > 0 and not self.isDead then
				-- Landed after jumping
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
			--[[ 
				TODO use this to allow jumping through a one way platform
				if other.can_pass_thorugh then
					event.contact.isEnabled = false
				end
			]]
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
		instance.xScale = math.min( 1, math.max( instance.xScale + flip, -1 ) )
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