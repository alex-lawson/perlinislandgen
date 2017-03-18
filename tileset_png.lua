TileSet = {}

function TileSet:new(config)
  local newTileSet = setmetatable(copy(config), {__index=TileSet})

  newTileSet.tileImage = love.graphics.newImage(newTileSet.sourceImage)
  local imgW, imgH = newTileSet.tileImage:getDimensions()

  newTileSet.tiles = {}
  for y = 0, imgH - newTileSet.tileSize, newTileSet.tileSize do
    for x = 0, imgW - newTileSet.tileSize, newTileSet.tileSize do
      table.insert(newTileSet.tiles, {quad = love.graphics.newQuad(x, y, newTileSet.tileSize, newTileSet.tileSize, imgW, imgH)})
    end
  end

  return newTileSet
end

function TileSet:render(map, toScreen, bounds)
  for y = bounds[4], bounds[2], -1 do
    for x = bounds[1], bounds[3] do
      self:renderTile(map:getTile(x, y), toScreen(x, y))
    end
  end
end

function TileSet:renderTile(id, screenX, screenY)
  local tile = self.tiles[id]
  love.graphics.draw(self.tileImage, tile.quad, screenX, screenY)
end
