require "game"

WindowSize = {980, 990}
MapScreenPos = {10, 10}
MapSize = {120, 120}

function love.load()
  love.window.setMode(unpack(WindowSize))

  GuiFont = love.graphics.newFont("cour.ttf", 16)

  game = Game:new({
      mapSize = MapSize
    })

  game:generateMap()
end

function love.update(dt)

end

function love.draw()
  game:renderMap(MapScreenPos)

  love.graphics.setFont(GuiFont)
  love.graphics.print(string.format("heightSeed: %s   rainSeed: %s", game.map.heightSeed, game.map.rainSeed), 25, 972)
end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.keypressed(key)
  if key == "up" or key == "w" then
    game:movePlayer(0, 1)
  elseif key == "down" or key == "s" then
    game:movePlayer(0, -1)
  elseif key == "left" or key == "a" then
    game:movePlayer(-1, 0)
  elseif key == "right" or key == "d" then
    game:movePlayer(1, 0)
  end

  if key == "space" then
    game:generateMap()
  end
end

function love.keyreleased(key)

end

function love.focus(f)

end

function love.quit()

end

