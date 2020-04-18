
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

  self.gridPositions = {}
  self.gridPositionsPredictions = {}

  local function drawQueryLines()
    for y=0, self.config.pixelsPerCol do
      local line = self.display.newLine(self.displayGroup, 0, y * self.config.pixelSize, display.actualContentWidth, y * self.config.pixelSize)
      line:setStrokeColor( 1, 1, 0, 1 )
      line.strokeWidth = 5
    end
  end

  local function drawGrid()
    -- graw grid of squares to represent dict grid
    self.gridPositionsCells = {}
    local cell
  
    for y=0, self.config.pixelsPerCol do
      for x=0, self.config.pixelsPerRow do
        cell = self.display.newRect(self.displayGroup, x * self.config.pixelSize, y * self.config.pixelSize, self.config.pixelSize, self.config.pixelSize)
        cell:setFillColor( 0, 0, 0, 0 )
        self.gridPositionsCells[tostring(x) .. tostring(y)] = cell
      end
    end
  end
  
  local function updateFillColor(key)
    if self.config.debug then
      self.gridPositionsCells[key]:setFillColor( 1, 0, 0, 0.5 - 0.5 * (self.gridPositionsPredictions[key]/3)  )
    end
  end

  local function zeroGrid()
    for y=0, self.config.pixelsPerCol do
      for x=0, self.config.pixelsPerRow do
        local key = tostring(x) .. tostring(y)
        if self.gridPositions[key] ~= 10 then
          if self.gridPositions[key] then
            self.gridPositions[key] = self.gridPositions[key] + 1
          else
            self.gridPositions[key] = 10
          end
        end
        if self.gridPositionsPredictions[key] then
          updateFillColor(key)
          self.gridPositionsPredictions[key] = math.min(3, 1 + self.gridPositionsPredictions[key])
        else
          self.gridPositionsPredictions[key] = 3
        end
      end
    end
  end
  
  local function isActiveCell(x, y)
    if x < 0 or x > self.config.pixelsPerRow or y < 0 or y > self.config.pixelsPerCol then
      return false
    end
    return self.gridPositions[tostring(x) .. tostring(y)] < 10
  end
  
  local function subtractCellVal(x, y, subVal)
    if x < 0 or x > self.config.pixelsPerRow or y < 0 or y > self.config.pixelsPerCol then
      return false
    end
    local key = tostring(x) .. tostring(y)
    self.gridPositions[key] = math.max(self.gridPositions[key] - subVal, 1)
    updateFillColor(key)
  end

  local function predictedCellVal(x, y)
    if x < 0 or x > self.config.pixelsPerRow or y < 0 or y > self.config.pixelsPerCol then
      return false
    end
    local key = tostring(x) .. tostring(y)
    self.gridPositionsPredictions[key] = 0
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
          if self.gridPositions[key] ~= 0 then
            
            self.gridPositions[key] = 0
            -- self.gridPositionsPredictions[key] = 0
            updateFillColor(key)
            
            -- TODO run adjacency values next frame?

            if isActiveCell(x-1, y) then
              predictedCellVal(x+1, y)
            end
            if isActiveCell(x-1, y-1) then
              predictedCellVal(x+1, y+1)
            end
            if isActiveCell(x-1, y+1) then
              predictedCellVal(x+1, y-1)
            end

            if isActiveCell(x+1, y) then
              predictedCellVal(x-1, y)
            end
            if isActiveCell(x+1, y-1) then
              predictedCellVal(x-1, y+1)
            end
            if isActiveCell(x+1, y+1) then
              predictedCellVal(x-1, y-1)
            end
            
            if isActiveCell(x, y+1) then
              predictedCellVal(x, y-1)
            end
            if isActiveCell(x, y-1) then
              predictedCellVal(x, y+1)
            end

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
