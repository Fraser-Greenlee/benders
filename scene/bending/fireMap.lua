
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
  
  local function updateFillColor(key)
    if self.config.debug then
      self.gridCells[key]:setFillColor( 0, 1, 0, 0.5 - 0.5*(self.grid[key]/10) )
    end
  end

  local function zeroGrid()    
    for y=0, self.config.pixelsPerCol do
      for x=0, self.config.pixelsPerRow do
        local key = tostring(x) .. tostring(y)
        if self.grid[key] ~= 10 then
          if self.grid[key] then
            self.grid[key] = self.grid[key] + 1
          else
            self.grid[key] = 10
          end
          updateFillColor(key)
        end
      end
    end
  end
  
  local function subtractCellVal(x, y, subVal)
    if x < 0 or x > self.config.pixelsPerRow or y < 0 or y > self.config.pixelsPerCol then
      return false
    end
    local key = tostring(x) .. tostring(y)
    self.grid[key] = math.max(self.grid[key] - subVal, 0)
    updateFillColor(key)
  end

  function self:timer(event)
    zeroGrid()
    local x, y;
    for y=0, self.config.pixelsPerCol do
      local actualY = y * self.config.pixelSize
      local hits = self.particleSystem:rayCast(0, actualY, display.actualContentWidth, actualY, "unsorted")

      if hits then

        for i,v in ipairs( hits ) do
          x = math.floor( (v.x / self.config.pixelSize) + 0.5 )
      
          local key = tostring(x) .. tostring(y)
          -- can only be zero if grid cell has already been ran this step
          if self.grid[key] ~= 0 then
            
            self.grid[key] = 0
            updateFillColor(key)
            
            local adjVal = 1.5

            subtractCellVal(x-1, y, adjVal)
            subtractCellVal(x-1, y-1, adjVal)
            subtractCellVal(x-1, y+1, adjVal)
            
            subtractCellVal(x+1, y, adjVal)
            subtractCellVal(x+1, y-1, adjVal)
            subtractCellVal(x+1, y+1, adjVal)
            
            subtractCellVal(x, y-1, adjVal)
            subtractCellVal(x, y+1, adjVal)
            
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
