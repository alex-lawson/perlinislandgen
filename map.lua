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
  newMap.tiles = {}
  return newMap
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

function Map:generate(heightSeed, rainSeed)
  self.heightSeed = heightSeed
  self.rainSeed = rainSeed

  self.files = {}

  local heightnoise = perlin.create(heightSeed, {
      freq = 0.02,
      octaves = 2,
      alpha = 4,
      beta = 2
    })

  local heightnoise2 = perlin.create(heightSeed + 1, {
      freq = 0.05,
      octaves = 2,
      alpha = 4,
      beta = 2
    })

  local rainnoise = perlin.create(rainSeed, {
      freq = 0.013
    })

  -- generate basic height and rainfall information
  local cx, cy = self.size[1] / 2, self.size[2] / 2
  local heightmap, rainmap = {}, {}
  for x = 1, self.size[1] do
    heightmap[x], rainmap[x] = {}, {}
    for y = 1, self.size[2] do
      local centerdist = math.sqrt(math.abs(x - cx) * math.abs(x - cx) + math.abs(y - cy) * math.abs(y - cy))
      local centerbias = math.cos(centerdist * 5 / self.size[1]) - 0.4

      heightmap[x][y] = heightnoise.get(x, y) + heightnoise2.get(x, y) * 0.4 + centerbias

      rainmap[x][y] = rainnoise.get(x, y)
    end
  end

  -- height based terrain
  for x = 1, self.size[1] do
    for y = 1, self.size[2] do
      local tileIndex = 1

      if heightmap[x][y] > 1.25 then
        tileIndex = 6 -- snow
      elseif heightmap[x][y] > 0.9 then
        tileIndex = 5 -- mountain
      elseif heightmap[x][y] > 0.03 then
        tileIndex = 3 -- grass
      elseif heightmap[x][y] > -0.1 then
        tileIndex = 2 -- sand
      else
        tileIndex = 1 -- water
      end

      self:setTile(x, y, tileIndex)
    end
  end

  -- convert grass to forests / deserts based on rainfall
  for x = 1, self.size[1] do
    for y = 1, self.size[2] do
      if self:getTile(x, y) == 3 then
        if rainmap[x][y] > 0.2 and heightmap[x][y] > 0.2 then
          self:setTile(x, y, 4) -- forest
        elseif rainmap[x][y] < -0.5 then
          self:setTile(x, y, 2) -- sand (desert)
        end
      end
    end
  end

  -- weird smoothing
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
