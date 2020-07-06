
local config = require('scene.game-config').noDisplay.enemies.debugGridEnemy

-- Define module
local M = {}

function M.new( instance )

  -- Store map placement and hide placeholder
  instance.isVisible = false
  local parent = instance.parent
  local x, y = instance.x, instance.y

  instance = display.newCircle( parent, x, y, config.radius )

  -- Add physics
  physics.addBody( instance, "static", config.physics )

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

  local function targetPlayer(moveOptions)
    
    local xDist = instance.hero.x - instance.x
    local yDist = (instance.hero.y - instance.y)
    local heroDistance = math.sqrt(xDist^2 + yDist^2)
    
    if heroDistance < instance.fireMap.config.pixelSize then
      moveOptions.middle = 1
      return moveOptions
    end
    
    if math.abs(xDist) > math.abs(yDist) then
      if xDist > 0 then
        moveOptions.right = 1
        moveOptions.left = -1
      else
        moveOptions.left = 1
        moveOptions.right = -1
      end
    else
      if yDist > 0 then
        moveOptions.down = 1
        moveOptions.up = -1
      else
        moveOptions.up = 1
        moveOptions.down = -1
      end
    end
    
    return moveOptions
  end

  local function fireGridValue(x, y)
    local key = tostring(x) .. "," .. tostring(y)
    if x >= 0 and x <= instance.fireMap.config.pixelsPerRow and y >= 0 and y <= instance.fireMap.config.pixelsPerCol then
      if instance.fireMap.gridPositions[key] and instance.fireMap.gridPositions[key] < 10 then
        return -2
      end
      if instance.fireMap.gridPositionsPredictions[key] and instance.fireMap.gridPositionsPredictions[key] ~= 3 then
        return -2
      end
      return 0
    end
    return -100
  end

  local function avoidFire(moveOptions)
    local gridX = math.floor( (instance.x / instance.fireMap.config.pixelSize) + 0.5 )
    local gridY = math.floor( (instance.y / instance.fireMap.config.pixelSize) + 0.5 )

    moveOptions.up =      moveOptions.up     + fireGridValue(gridX,   gridY-1 ) + fireGridValue(gridX,   gridY-2 )
    moveOptions.middle =  moveOptions.middle + fireGridValue(gridX,   gridY   )
    moveOptions.down =    moveOptions.down +   fireGridValue(gridX,   gridY+1 ) + fireGridValue(gridX,   gridY+2 )
    moveOptions.left =    moveOptions.left   + fireGridValue(gridX-1, gridY   ) + fireGridValue(gridX-2,   gridY )
    moveOptions.right =   moveOptions.right +  fireGridValue(gridX+1, gridY   ) + fireGridValue(gridX+2,   gridY )

    return moveOptions
  end

  local function runStep()
    if instance.isDead then
      return nil
    end
    
    local moveOptions = {
      up = 0,
      down = 0,
      middle = 0,
      left = 0,
      right = 0
    }
    
    moveOptions = targetPlayer(moveOptions)
    moveOptions = avoidFire(moveOptions)
    
    -- find largest option
    local key, max = "middle", moveOptions.middle
    for k, v in pairs(moveOptions) do
      if moveOptions[k] > max then
        key, max = k, v
      end
    end
    
    if key == "up" then
      instance.y = instance.y - instance.fireMap.config.pixelSize
    elseif key == "down" then
      instance.y = instance.y + instance.fireMap.config.pixelSize
    elseif key == "left" then
      instance.x = instance.x - instance.fireMap.config.pixelSize
    elseif key == "right" then
      instance.x = instance.x + instance.fireMap.config.pixelSize
    end
  end
  
  function instance:start()
    instance.stepTimer = timer.performWithDelay(config.stepDelay, runStep, -1)
  end

  function instance:finalize()
    -- On remove, cleanup instance, or call directly for non-visual
    timer.cancel(instance.stepTimer)
    instance:removeEventListener( "collision" )
  end

  -- Add a finalize listener (for display objects only, comment out for non-visual)
  instance:addEventListener( "finalize" )

  -- Add our collision listeners
  instance:addEventListener( "collision" )

  -- Return instance
  instance.name = "debugGridEnemy"
  instance.type = "debugGridEnemy"
  return instance
end

return M
