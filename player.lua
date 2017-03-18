require 'util'

Player = {}

function Player:new(config)
  local newPlayer = setmetatable(copy(config), {__index=Player})

  newPlayer.playerImage = love.graphics.newImage(newPlayer.sourceImage)

  return newPlayer
end

function Player:render(toScreen)
  love.graphics.draw(self.playerImage, toScreen(self.x, self.y))
end
