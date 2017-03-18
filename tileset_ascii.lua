require 'util'

TileSet = {}

function TileSet:new(config)
  local newTileSet = setmetatable(copy(config), {__index=TileSet})

  newTileSet.tiles = {
    {
      -- 1 water
      coloredtext = {{0, 0, 128}, "~"},
      x = 0,
      y = 0
    },
    {
      -- 2 sand
      coloredtext = {{140, 130, 50}, "s"},
      x = 0,
      y = 0
    },
    {
      -- 3 grass
      coloredtext = {{60, 220, 30}, "\""},
      x = -0.5,
      y = 2
    },
    {
      -- 4 forest
      coloredtext = {{0, 60, 0}, "w"},
      x = -0.5,
      y = -0.5
    },
    {
      -- 5 mountain
      coloredtext = {{140, 140, 100}, "^"},
      x = 0,
      y = 1
    },
    {
      -- 6 snow
      coloredtext = {{255, 255, 255}, "^"},
      x = 0,
      y = 0
    }
  }

  newTileSet.tileFont = love.graphics.newFont("cour.ttf", math.ceil(2 * newTileSet.tileSize))

  return newTileSet
end

function TileSet:render(map, toScreen, bounds)
  love.graphics.setFont(self.tileFont)

  for y = bounds[4], bounds[2], -1 do
    for x = bounds[1], bounds[3] do
      self:renderTile(toScreen(x, y), map:getTile(x, y))
    end
  end
end

function TileSet:renderTile(screenX, screenY, id)
  local tile = self.tiles[id]
  love.graphics.print(tile.coloredtext, screenX + tile.x, screenY + tile.y)
end
