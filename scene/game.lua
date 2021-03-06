
-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local physics = require( "physics" )
local json = require( "json" )
local scoring = require( "scene.game.lib.score" )
local heartBar = require( "scene.game.lib.heartBar" )
local Water = require( "scene.bending.water" )
local waterBend = require( "scene.bending.waterBend" )
local Fire = require( "scene.bending.fire" )
local FireBending = require( "scene.bending.fireBend" )
local FireMap = require( "scene.bending.fireMap" )
local FilterParticleSystem = require( "scene.game.lib.filterParticleSystem" )
local config = require('scene.game-config').noDisplay.game

-- Variables local to scene
local map, hero, shield, parallax, water, filterParticleSystem
local hasRan = false

-- Create a new Composer scene
local scene = composer.newScene()

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	-- Sounds
	local sndDir = "scene/game/sfx/"
	scene.sounds = {
		thud = audio.loadSound( sndDir .. "thud.mp3" ),
		sword = audio.loadSound( sndDir .. "sword.mp3" ),
		squish = audio.loadSound( sndDir .. "squish.mp3" ),
		slime = audio.loadSound( sndDir .. "slime.mp3" ),
		wind = audio.loadSound( sndDir .. "loops/spacewind.mp3" ),
		door = audio.loadSound( sndDir .. "door.mp3" ),
		hurt = {
			audio.loadSound( sndDir .. "hurt1.mp3" ),
			audio.loadSound( sndDir .. "hurt2.mp3" ),
		},
		hit = audio.loadSound( sndDir .. "hit.mp3" ),
		coin = audio.loadSound( sndDir .. "coin.mp3" ),
	}

	-- Start physics before loading map
	physics.start()
	if config.debugPhysics then
		physics.setDrawMode( "hybrid" )
	end
	physics.setGravity( 0, 32 )

	-- Load our map
	local filename = event.params.map or "scene/game/map/sandbox.json"
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "scene/game/map" )
	--map.xScale, map.yScale = 0.85, 0.85

	local background = display.newImage(sceneGroup, "inspiration/dark-towerfall-background.png")
	background:scale(3.15, 3.15)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- Find our hero!
	map.extensions = "scene.game.lib."
	map:extend( "hero" )
	hero = map:findObject( "hero" )
	hero.filename = filename

	-- Find our enemies and other items
	map:extend(
		"blob", "enemy", "exit", "coin", "spikes", "fountain", "target",
		"waterBlock", "iceBlock", "sandBlock", "mudBlock", "jellyBlock", "poisonBlock",
		"filterParticlesBlock", "filterPlayerBlock", "deathBlock", "killWaterBlock",
		"enemyCanon", "skullLanturn", "debugGridEnemy", "debugRaycastEnemy", "gunDrone"
	)

	-- Find the parallax layer
	parallax = map:findLayer( "parallax" )

	-- Add our scoring module
	local gem = display.newImageRect( sceneGroup, "scene/game/img/gem.png", 64, 64 )
	gem.x = display.contentWidth - gem.contentWidth / 2 - 24
	gem.y = display.screenOriginY + gem.contentHeight / 2 + 20

	scene.score = scoring.new( { score = event.params.score } )
	local score = scene.score
	score.x = display.contentWidth - score.contentWidth / 2 - 32 - gem.width
	score.y = display.screenOriginY + score.contentHeight / 2 + 16

	-- Add our hearts module
	shield = heartBar.new()
	shield.x = 48
	shield.y = display.screenOriginY + shield.contentHeight / 2 + 16
	hero.shield = shield

	-- Touch the sheilds to go back to the main...
	function shield:tap(event)
		fx.fadeOut( function()
				composer.gotoScene( "scene.menu")
			end )
	end
	shield:addEventListener("tap")

	-- Insert our game items in the correct back-to-front order
	sceneGroup:insert( map )
	sceneGroup:insert( score )
	sceneGroup:insert( gem )
	sceneGroup:insert( shield )

	-- Give fountains & waterBlocks water
	water = Water.new( display, physics )
	local allFountains = map:listTypes( "fountain" )
	for i, fountain in pairs(allFountains) do
		fountain.water = water
		fountain.addWater()
	end
	local allWaterBlocks = map:listTypes( "waterBlock" )
	for i, block in pairs(allWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.makeBlock()
	end
	local allWaterBlocks = map:listTypes( "iceBlock" )
	for i, block in pairs(allWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.makeBlock()
	end
	local allWaterBlocks = map:listTypes( "sandBlock" )
	for i, block in pairs(allWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.makeBlock()
	end
	local allWaterBlocks = map:listTypes( "mudBlock" )
	for i, block in pairs(allWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.makeBlock()
	end
	local allWaterBlocks = map:listTypes( "jellyBlock" )
	for i, block in pairs(allWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.makeBlock()
	end
	local allWaterBlocks = map:listTypes( "poisonBlock" )
	for i, block in pairs(allWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.makeBlock()
	end
	local allkillWaterBlocks = map:listTypes( "killWaterBlock" )
	for i, block in pairs(allkillWaterBlocks) do
		block.particleSystem = water.particleSystem
		block.start()
	end

	-- Give enamies reference to hero
	local allEnamies = map:listTypes( "enemyCanon", "skullLanturn" )
	for i, enemy in pairs(allEnamies) do
		enemy.hero = hero
		enemy.water = water
	end

	-- Use seperate particle system to filter water
	filterParticleSystem = FilterParticleSystem.new( physics )
	local filterBlocks = map:listTypes( "filterParticlesBlock" )
	for i, block in pairs(filterBlocks) do
		print("filterParticlesBlock")
		block.particleSystem = filterParticleSystem.particleSystem
		block.makeBlock()
	end

	if config.bendingMode == 'water' then
		-- Allow waterBend
		waterBend = waterBend.new( display, water, hero )
		waterBend.drawGrid(waterBend)
	elseif config.bendingMode == 'fire' then
		local fire = Fire.new( display, physics )
		-- Allow fireBending
		local fireBending = FireBending.new( display, fire, hero )
		fireBending.drawGrid(fireBending)
    -- Allow AI fireMap
    -- local fireMap = FireMap.new( display, fire )
    
    local allEnamies = map:listTypes( "debugGridEnemy" )
    for i, enemy in pairs(allEnamies) do
      enemy.hero = hero
      enemy.fire = fire
      enemy.fireMap = fireMap
      enemy:start()
      break
    end
    
    allEnamies = map:listTypes( "debugRaycastEnemy" )
    for i, enemy in pairs(allEnamies) do
      enemy.hero = hero
      enemy.particleSystem = fire.particleSystem
      enemy.allRaycastEnamies = allEnamies
    end
    for i, enemy in pairs(allEnamies) do
      enemy:start()
    end
    
    allEnamies = map:listTypes( "gunDrone" )
    for i, enemy in pairs(allEnamies) do
      enemy.hero = hero
      enemy.particleSystem = fire.particleSystem
      enemy.allRaycastEnamies = allEnamies
    end
    for i, enemy in pairs(allEnamies) do
      enemy:start()
    end
	else
		error("no valid bending mode")
	end
end

-- Function to scroll the map
local function enterFrame( event )
	-- Easy way to scroll a map based on a character
	if hero and hero.x and hero.y and not hero.isDead then
		local x, y = hero:localToContent( -400, -400 )
		x = display.contentCenterX - x
		y = display.contentCenterY - y
		map.x, map.y = map.x + x, map.y + y
		water.particleSystem.x, water.particleSystem.y = water.particleSystem.x + x, water.particleSystem.y + y
		waterBend.cameraOffset.x, waterBend.cameraOffset.y = waterBend.cameraOffset.x + x, waterBend.cameraOffset.y + y
	end
end

-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()	-- Fade up from black
		if config.cameraTracking then
			Runtime:addEventListener( "enterFrame", enterFrame )
		end
	elseif ( phase == "did" ) then
		-- Start playing wind sound
		-- For more details on options to play a pre-loaded sound, see the Audio Usage/Functions guide:
		-- https://docs.coronalabs.com/guide/media/audioSystem/index.html
		-- audio.play( self.sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
		audio.fadeOut( { time = 1000 } )
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )
	local fullScreen = {
		x = -500,
		y = -200,
		halfWidth = display.actualContentWidth + 500,
		halfHeight = (display.actualContentHeight + 500)*2
	}

	waterBend:destroy()
	water:destroy()
	filterParticleSystem.particleSystem:destroyParticles(fullScreen)

	audio.stop()  -- Stop all audio
	for s, v in pairs( self.sounds ) do  -- Release all audio handles
		audio.dispose( v )
		self.sounds[s] = nil
	end
end

scene:addEventListener( "create" )
scene:addEventListener( "show" )
scene:addEventListener( "hide" )
scene:addEventListener( "destroy" )

return scene
