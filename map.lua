local perlin = require 'perlin2'
local util = require 'util'

local surroundings = {
  {-1, 1},
  {0, 1},
  {1, 1},
  {1, 0},
  {1, -1},
  {0, -1},
  {-1, -1},
  {-1, 0}
}

Map = {}

function Map:new(config)
  local newMap = setmetatable(copy(config), {__index=Map})
  newMap:setSeed(0)
  newMap:setTime(0)
  newMap:clear()
  return newMap
end

function Map:setTime(time)
  self.time = time
  self:updateOffsets(time)
end

function Map:setSeed(seed)
  self.seed = seed
  self:createPerlins(seed, seed + 1, seed + 2)
end

function Map:setTile(x, y, value)
  self.tiles[(y - 1) * self.size[2] + x] = value
end

function Map:getTile(x, y)
  return self.tiles[(y - 1) * self.size[2] + x]
end

function Map:collides(x, y)
  if x < 1 or y < 1 or x > self.size[1] or x > self.size[2] then return false end

  local t = self:getTile(x, y)
  return not (t > 1 and t < 5)
end

function Map:generate(terrainType)
  self:clear()

  local heightMap, rainMap = self["generate_"..terrainType](self)

  self:buildTerrainFromHeight(heightMap)
  self:applyRainfall(rainMap, heightMap)

  self:smoothTiles()
end

function Map:generate_flat()
  local heightMap, rainMap = {}, {}
  for x = 1, self.size[1] do
    heightMap[x], rainMap[x] = {}, {}
    for y = 1, self.size[2] do
      heightMap[x][y] = self.heightnoise.get(x + self.offsets.heightnoise[1], y + self.offsets.heightnoise[2]) * 1.0 + self.heightnoise2.get(x + self.offsets.heightnoise2[1], y + self.offsets.heightnoise2[2]) * 0.3 + 0.5

      rainMap[x][y] = self.rainnoise.get(x + self.offsets.rainnoise[1], y + self.offsets.rainnoise[2]) + self.offsets.rain
    end
  end
  return heightMap, rainMap
end

function Map:generate_island()
  local cx, cy = self.size[1] / 2, self.size[2] / 2
  local heightMap, rainMap = {}, {}
  for x = 1, self.size[1] do
    heightMap[x], rainMap[x] = {}, {}
    for y = 1, self.size[2] do
      local centerdist = math.sqrt(math.abs(x - cx) * math.abs(x - cx) + math.abs(y - cy) * math.abs(y - cy))
      local centerbias = math.cos(centerdist * 5 / self.size[1]) - 0.4

      heightMap[x][y] = self.heightnoise.get(x + self.offsets.heightnoise[1], y + self.offsets.heightnoise[2]) + self.heightnoise2.get(x + self.offsets.heightnoise2[1], y + self.offsets.heightnoise2[2]) * 0.3 + centerbias

      rainMap[x][y] = self.rainnoise.get(x + self.offsets.rainnoise[1], y + self.offsets.rainnoise[2]) + self.offsets.rain
    end
  end
  return heightMap, rainMap
end

function Map:generate_valley()
  local cx, cy = self.size[1] / 2, self.size[2] / 2
  local heightMap, rainMap = {}, {}
  for x = 1, self.size[1] do
    heightMap[x], rainMap[x] = {}, {}
    for y = 1, self.size[2] do
      local centerdist = math.sqrt(math.abs(x - cx) * math.abs(x - cx) + math.abs(y - cy) * math.abs(y - cy))
      local centerbias = -math.cos(centerdist * 5 / self.size[1]) + 0.8

      heightMap[x][y] = self.heightnoise.get(x + self.offsets.heightnoise[1], y + self.offsets.heightnoise[2]) * 0.8 + self.heightnoise2.get(x + self.offsets.heightnoise2[1], y + self.offsets.heightnoise2[2]) * 0.3 + centerbias

      rainMap[x][y] = self.rainnoise.get(x + self.offsets.rainnoise[1], y + self.offsets.rainnoise[2]) + self.offsets.rain
    end
  end
  return heightMap, rainMap
end

function Map:createPerlins(heightSeed, height2Seed, rainSeed)
  self.heightSeed = heightSeed
  self.height2Seed = height2Seed
  self.rainSeed = rainSeed

  self.heightnoise = perlin.create(heightSeed, {
      freq = 0.02,
      octaves = 2,
      alpha = 4,
      beta = 2
    })

  self.heightnoise2 = perlin.create(height2Seed, {
      freq = 0.05,
      octaves = 2,
      alpha = 4,
      beta = 2
    })

  self.rainnoise = perlin.create(rainSeed, {
      freq = 0.013
    })
end

function Map:updateOffsets(time)
  self.offsets = self.offsets or {}
  self.offsets.heightnoise = {time * 0.5, 0}
  self.offsets.heightnoise2 = {0, time * 0.3}
  self.offsets.rainnoise = {time * 0.6, 0}
  self.offsets.rain = math.sin(time * math.pi * 2 / self.yearLength) * 0.2
end

-- height based terrain
function Map:buildTerrainFromHeight(heightMap)
  for x = 1, self.size[1] do
    for y = 1, self.size[2] do
      local tileIndex = 1

      if heightMap[x][y] > 1.25 then
        tileIndex = 6 -- snow
      elseif heightMap[x][y] > 0.9 then
        tileIndex = 5 -- mountain
      elseif heightMap[x][y] > 0.03 then
        tileIndex = 3 -- grass
      elseif heightMap[x][y] > -0.1 then
        tileIndex = 2 -- sand
      else
        tileIndex = 1 -- water
      end

      self:setTile(x, y, tileIndex)
    end
  end
end

-- convert grass to forests / deserts based on rainfall
function Map:applyRainfall(rainMap, heightMap)
  for x = 1, self.size[1] do
    for y = 1, self.size[2] do
      if self:getTile(x, y) == 3 then
        if rainMap[x][y] > 0.2 and heightMap[x][y] > 0.2 then
          self:setTile(x, y, 4) -- forest
        elseif rainMap[x][y] < -0.2 then
          self:setTile(x, y, 2) -- sand (desert)
        end
      end
    end
  end
end

-- weird smoothing
function Map:smoothTiles()
  for x = 2, self.size[1] - 1 do
    for y = 2, self.size[2] - 1 do
      if self:getTile(x, y) < 5 then
        local sum = 0
        for _, offset in pairs(surroundings) do
          sum = sum + self:getTile(x + offset[1], y + offset[2])
        end
        local average = sum / 8

        local diff = average - self:getTile(x, y)

        if diff < -0.5 then
          self:setTile(x, y, self:getTile(x, y) - 1)
        -- elseif diff > 0.5 then
        --   self:setTile(x, y, self:getTile(x, y) + 1)
        end
      end
    end
  end
end

function Map:clear(emptyTile)
  self.tiles = {}
  emptyTile = emptyTile or 1
  for x = 1, self.size[1] do
    for y = 1, self.size[2] do
      self:setTile(x, y, emptyTile)
    end
  end
end
