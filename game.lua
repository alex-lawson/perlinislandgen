require 'util'
require 'map'
require 'player'
-- require 'tileset_ascii'
require 'tileset_png'

Game = {}

function Game:new(config)
  local newGame = setmetatable(copy(config), {__index=Game})

  newGame.map = Map:new({
      size = newGame.mapSize,
      yearLength = 20
    })

  -- newGame.tileSet = TileSet:new({tileSize=4})

  newGame.tileSet = TileSet:new({
      tileSize = 8,
      sourceImage = "tiles8.png"
    })

  -- newGame.player = Player:new({
  --     x = 40,
  --     y = 40,
  --     sourceImage = "player8.png"
  --   })

  newGame.runTime = 0
  newGame.ageTimer = newGame.ageRate

  return newGame
end

function Game:update(dt)
  self.runTime = self.runTime + dt
  self.ageTimer = self.ageTimer - dt
  while self.ageTimer <= 0 do
    self.ageTimer = self.ageTimer + self.ageRate
    self.map:setTime(self.runTime)
    self:generateMap()
  end
end

function Game:setSeed(seed)
  self.map:setSeed(seed)
end

function Game:generateMap()
  self.map:generate("island")
  -- self:movePlayerTo(self:findPlayerStart())
end

function Game:renderMap(screenPosition)
  local bounds = {1, 1, self.map.size[1], self.map.size[2]}

  local mapToScreen = function(x, y)
    local screenX = screenPosition[1] + (x - 1) * self.tileSet.tileSize
    local screenY = screenPosition[2] + (bounds[4] - y) * self.tileSet.tileSize
    return screenX, screenY
  end

  self.tileSet:render(self.map, mapToScreen, bounds)
  -- self.player:render(mapToScreen)
end

-- function Game:findPlayerStart()
--   local cx, cy = math.floor(self.map.size[1] / 2), math.floor(self.map.size[2] / 2)

--   for i = 1, 100 do
--     local tx = math.floor(nrandf(self.map.size[1] / 4, cx))
--     local ty = math.floor(nrandf(self.map.size[2] / 4, cy))
--     if not self.map:collides(tx, ty) then
--       return tx, ty
--     end
--   end

--   return cx, cy
-- end

-- function Game:movePlayer(dX, dY)
--   return self:movePlayerTo(self.player.x + dX, self.player.y + dY)
-- end

-- function Game:movePlayerTo(x, y)
--   if not self.map:collides(x, y) then
--     self.player.x = x
--     self.player.y = y
--     return true
--   end
--   return false
-- end
