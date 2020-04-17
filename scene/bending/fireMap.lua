
-- Module/class for the fireMap
-- Gives a grid of the current particle positions.

local composer = require( "composer" )
local configMaker = require('scene.game-config').new

-- Define module
local M = {}

function M.new( display, fire )
  local self = {}
  
  self.display = display
  self.displayGroup = display.newGroup()
  self.config = configMaker(self.display).fireMap
  self.particleSystem = fire.particleSystem

  self.grid = {}

  local function drawQueryLines()
    for y=0, self.config.pixelsPerCol do
      local line = self.display.newLine(self.displayGroup, 0, y * self.config.pixelSize, display.actualContentWidth, y * self.config.pixelSize)
      line:setStrokeColor( 1, 1, 0, 1 )
      line.strokeWidth = 5
      print(y)
    end
  end

  local function drawGrid()
    -- graw grid of squares to represent dict grid
    self.gridCells = {}
    local cell
  
    for y=0, self.config.pixelsPerCol do
      for x=0, self.config.pixelsPerRow do
        cell = self.display.newRect(self.displayGroup, x * self.config.pixelSize, y * self.config.pixelSize, self.config.pixelSize, self.config.pixelSize)
        cell:setFillColor( 0, 1, 0, 0 )
        self.gridCells[tostring(x) .. tostring(y)] = cell
      end
    end
  end

  local function zeroGrid()    
    for y=0, self.config.pixelsPerCol do
      for x=0, self.config.pixelsPerRow do
        self.grid[tostring(x) .. tostring(y)] = 10
        self.gridCells[tostring(x) .. tostring(y)]:setFillColor( 0, 1, 0, 0 )
      end
    end
  end

  function self:timer(event)
    zeroGrid()
    local x, y;
    for y=0, self.config.pixelsPerCol do
      local hits = self.particleSystem:rayCast(0, y * self.config.pixelSize, display.actualContentWidth, y * self.config.pixelSize, "unsorted")
      if hits then

        for i,v in ipairs( hits ) do
          x = math.floor( (v.x / self.config.pixelSize) + 0.5 )
      
          self.grid[tostring(x) .. tostring(y)] = 0
          if self.config.debug then
            print( "Hit: ", i, " Position: ", x, y)
            self.gridCells[tostring(x) .. tostring(y)]:setFillColor( 0, 1, 0, 0.5 )
          end
        end
      end
    end
  end

  if self.config.debug then
    drawQueryLines()
    drawGrid()
  end

  self.bendTimer = timer.performWithDelay( self.config.refreshRate, self, -1 )

	-- Return instance
	self.name = "fireMap"
	self.type = "fireMap"
	return self
end

return M
