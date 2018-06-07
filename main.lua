require "game"

WindowSize = {820, 835}
MapScreenPos = {10, 10}
MapSize = {100, 100}

function love.load()
  love.window.setMode(unpack(WindowSize))

  GuiFont = love.graphics.newFont("cour.ttf", 16)

  game = Game:new({
      mapSize = MapSize,
      ageRate = 0.05
    })

  game:generateMap(1)
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  game:renderMap(MapScreenPos)

  love.graphics.setFont(GuiFont)
  love.graphics.print(string.format("seed: %s     time: %.2f  (year %s)     rain: %.2f", game.map.seed, game.map.time, math.floor(game.map.time / game.map.yearLength), game.map.offsets.rain), 15, 813)
end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.keypressed(key)
  -- if key == "up" or key == "w" then
  --   game:movePlayer(0, 1)
  -- elseif key == "down" or key == "s" then
  --   game:movePlayer(0, -1)
  -- elseif key == "left" or key == "a" then
  --   game:movePlayer(-1, 0)
  -- elseif key == "right" or key == "d" then
  --   game:movePlayer(1, 0)
  -- end

  if key == "space" then
    game:setSeed(math.random())
    game:generateMap()
  end
end

function love.keyreleased(key)

end

function love.focus(f)

end

function love.quit()

end

