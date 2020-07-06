
local config = require('scene.game-config').noDisplay.enemies.debugRaycastEnemy

-- Define module
local M = {}

function M.new( instance )

  -- Store map placement and hide placeholder
  instance.isVisible = false
  local parent = instance.parent
  local x, y = instance.x, instance.y

  -- TODO work out display groups
  -- TODO debug the particle raycasts showing when lines are active using transparency
  instance.body = display.newCircle( parent, x, y, config.radius )
  -- TODO update N x/y to be in bodies position
  
  local function vectorLen(x, y)
    return math.sqrt(x^2 + y^2)
  end
  
  local diagonalUnitLen = math.sqrt(2) / 2
  
  local function newDebugLine(xLen, yLen)
    local line = display.newLine( parent, x, y, x + xLen * config.rayLength, y + yLen * config.rayLength )
    line.strokeWidth = 8
    return line
  end
  
  if config.debug then
    instance.N = newDebugLine( 0, -1)
    instance.W = newDebugLine(-1,  0)
    instance.E = newDebugLine( 1,  0)
    instance.S = newDebugLine( 0,  1)
    
    instance.NW = newDebugLine(-diagonalUnitLen, -diagonalUnitLen)
    instance.NE = newDebugLine( diagonalUnitLen, -diagonalUnitLen)
    instance.SW = newDebugLine(-diagonalUnitLen,  diagonalUnitLen)
    instance.SE = newDebugLine( diagonalUnitLen,  diagonalUnitLen)
  end

  -- Add physics
  physics.addBody( instance.body, "dynamic", config.physics )
  instance.body.gravityScale = 0.0
  instance.body.linearDamping = config.linearDamping

  instance.isDead = false
  instance.health = config.maxParticleHitCount

  function instance:hurt()
      if instance.isDead then
          return nil
      end
      instance.health = instance.health - 1
      if instance.health < 1 then
          instance:die()
      end
  end

  function instance:die()
    -- swith to non-lanturn skull
    instance.isDead = true
    instance:removeEventListener( "collision" )
    timer.cancel(instance.stepTimer)
  end

  function instance:collision( event )
    local phase = event.phase
    if phase == "began" and event.other.type == "hero" then
      event.other:hurt()
    end
  end

  local function cosTheta(x1, y1, x2, y2, len1, len2)
    return (x1 * x2 + y1 * y2) / (len1 * len2)
  end
  
  local function getHeroCoef(distance)
    return config.heroCoef
  end
  
  local function assignHeroProximityScores(directionScores)
    local heroDistX = instance.hero.x - instance.body.x
    local heroDistY = instance.hero.y - instance.body.y
    local heroDistance = math.sqrt(heroDistX^2 + heroDistY^2)
    local heroCoef = getHeroCoef(distance)
    
    -- use dot product for hero proximity, keep in -1,1 range
    directionScores.N  = directionScores.N  + heroCoef * cosTheta(heroDistX, heroDistY,  0,               -1,               heroDistance, 1)
    directionScores.W  = directionScores.W  + heroCoef * cosTheta(heroDistX, heroDistY, -1,                0,               heroDistance, 1)
    directionScores.E  = directionScores.E  + heroCoef * cosTheta(heroDistX, heroDistY,  1,                0,               heroDistance, 1)
    directionScores.S  = directionScores.S  + heroCoef * cosTheta(heroDistX, heroDistY,  0,                1,               heroDistance, 1)
    directionScores.NW = directionScores.NW + heroCoef * cosTheta(heroDistX, heroDistY, -diagonalUnitLen, -diagonalUnitLen, heroDistance, 1)
    directionScores.NE = directionScores.NE + heroCoef * cosTheta(heroDistX, heroDistY,  diagonalUnitLen, -diagonalUnitLen, heroDistance, 1)
    directionScores.SW = directionScores.SW + heroCoef * cosTheta(heroDistX, heroDistY, -diagonalUnitLen,  diagonalUnitLen, heroDistance, 1)
    directionScores.SE = directionScores.SE + heroCoef * cosTheta(heroDistX, heroDistY,  diagonalUnitLen,  diagonalUnitLen, heroDistance, 1)
    
    return directionScores
  end
  
  local function rayParticleLen(xLen, yLen)
    local closestTable = instance.particleSystem:rayCast( instance.body.x, instance.body.y, instance.body.x + xLen * config.rayLength, instance.body.y + yLen * config.rayLength, "closest" )
    if ( closestTable ) then
      return - ( 1 - closestTable[1].fraction ) * config.rayLength
    end
    return 0
  end
  
  local function assignParticleProximityScores(directionScores)
    -- TODO assign lower scores to adjacent rays that detected fire particles
    
    local directionMeasures = {
        N=rayParticleLen( 0, -1),
        W=rayParticleLen(-1,  0),
        E=rayParticleLen( 1,  0),
        S=rayParticleLen( 0,  1),
        NW=rayParticleLen( -diagonalUnitLen, -diagonalUnitLen ),
        NE=rayParticleLen(  diagonalUnitLen, -diagonalUnitLen ),
        SW=rayParticleLen( -diagonalUnitLen,  diagonalUnitLen ),
        SE=rayParticleLen(  diagonalUnitLen,  diagonalUnitLen )
      }
    
    directionScores.N  = directionScores.N  + config.fireCoef * (directionMeasures.N + 0.5 * directionMeasures.NW + 0.5 * directionMeasures.NE)
    directionScores.W  = directionScores.W  + config.fireCoef * (directionMeasures.W + 0.5 * directionMeasures.NW + 0.5 * directionMeasures.SW)
    directionScores.E  = directionScores.E  + config.fireCoef * (directionMeasures.E + 0.5 * directionMeasures.NE + 0.5 * directionMeasures.SE)
    directionScores.S  = directionScores.S  + config.fireCoef * (directionMeasures.S + 0.5 * directionMeasures.SW + 0.5 * directionMeasures.SE)

    directionScores.NW = directionScores.NW + config.fireCoef * (directionMeasures.NW + 0.5 * directionMeasures.N + 0.5 * directionMeasures.W)
    directionScores.NE = directionScores.NE + config.fireCoef * (directionMeasures.NE + 0.5 * directionMeasures.N + 0.5 * directionMeasures.E)
    directionScores.SW = directionScores.SW + config.fireCoef * (directionMeasures.SW + 0.5 * directionMeasures.S + 0.5 * directionMeasures.W)
    directionScores.SE = directionScores.SE + config.fireCoef * (directionMeasures.SE + 0.5 * directionMeasures.S + 0.5 * directionMeasures.E)

    -- improve the scores of directions pointing at right angles from fire
    directionScores.N  = directionScores.N - directionScores.S
    directionScores.W  = directionScores.W - directionScores.E
    directionScores.E  = directionScores.E - directionScores.W
    directionScores.S  = directionScores.S - directionScores.N

    directionScores.NW = directionScores.NW - directionScores.SE
    directionScores.NE = directionScores.NE - directionScores.SW
    directionScores.SW = directionScores.SW - directionScores.NE
    directionScores.SE = directionScores.SE - directionScores.NW

    return directionScores
  end
  
  local function avoidFellowEnemies(directionScores)
    -- find enemies within min rage
  end
  
  instance.currentDirection = {
    x=0,
    y=0
  }

  local function getBestDirectionForces(directionScores)
    -- find largest option
    local key, max = "N", directionScores.N
    for k, v in pairs(directionScores) do
      if config.debug then
        instance[k]:setStrokeColor( 1, 1, 1 )
      end
      if directionScores[k] > max then
        key, max = k, v
      end
    end
    
    max = config.stepForce

    if config.debug then
      instance[key]:setStrokeColor( 1, 0, 0 )
    end

    if key == "N" then
      return 0, -max
    elseif key == "NW" then
      return -max/2, -max/2
    elseif key == "NE" then
      return max/2, -max/2
    elseif key == "W" then
      return -max, 0
    elseif key == "E" then
      return max, 0
    elseif key == "S" then
      return 0, max
    elseif key == "SW" then
      return -max/2, max/2
    elseif key == "SE" then
      return max/2, max/2
    end
  end

  local function runStep()
    if instance.isDead then
      return nil
    end
    
    local directionScores = {
      N=0.0,
      NW=0.0,
      NE=0.0,
      W=0.0,
      E=0.0,
      S=0.0,
      SW=0.0,
      SE=0.0
    }
    
    directionScores = assignHeroProximityScores(directionScores)
    directionScores = assignParticleProximityScores(directionScores)
    -- directionScores = avoidFellowEnemies(directionScores)
    
    local xForce, yForce = getBestDirectionForces(directionScores)
    instance.currentDirection.x = ( xForce * 2 + instance.currentDirection.x ) / 3
    instance.currentDirection.y = ( yForce * 2 + instance.currentDirection.y ) / 3
  end
  
  local function matchBodyPos(obj)
    obj.x = instance.body.x
    obj.y = instance.body.y
  end
  
	local function enterFrame()
    -- TODO apply move forces here
    instance.body:applyLinearImpulse( instance.currentDirection.x, instance.currentDirection.y, 0, 0 )
    if config.debug then
      matchBodyPos(instance.N)
      matchBodyPos(instance.W)
      matchBodyPos(instance.E)
      matchBodyPos(instance.S)
      matchBodyPos(instance.NW)
      matchBodyPos(instance.NE)
      matchBodyPos(instance.SW)
      matchBodyPos(instance.SE)
    end
	end
  
  function instance:start()
    instance.stepTimer = timer.performWithDelay(config.stepDelay, runStep, -1)
    Runtime:addEventListener( "enterFrame", enterFrame )
  end

  function instance:finalize()
    -- On remove, cleanup instance, or call directly for non-visual
    timer.cancel(instance.stepTimer)
    instance:removeEventListener( "collision" )
    Runtime:addEventListener( "enterFrame" )
  end

  -- Add a finalize listener (for display objects only, comment out for non-visual)
  instance:addEventListener( "finalize" )

  -- Add our collision listeners
  instance:addEventListener( "collision" )

  -- Return instance
  instance.name = "debugRaycastEnemy"
  instance.type = "debugRaycastEnemy"
  return instance
end

return M
