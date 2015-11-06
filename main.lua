function love.load()
  grid = {}
  grid.cols = 16 * 8
  grid.rows = 10 * 8
  grid.size = 8
  grid.gutter = 2

  color = {}
  color.alive = {150, 150, 200}
  color.dead = {50, 50, 50}

  display = {}
  display.x = grid.cols * grid.size
  display.y = grid.rows * grid.size
  display.mode = love.window.setMode(display.x, display.y)

  organisms = {}
  for i = 0, grid.rows - 1 do
    local row = i
    local y = i * grid.size

    for i = 0 ,grid.cols - 1 do
      local col = i
      local x = i * grid.size

      organism = {}
      organism.col = col
      organism.row = row
      organism.x = x
      organism.y = y
      organism.isAlive = false
      organism.aliveNeighbors = 0
      table.insert(organisms, organism)
    end
  end

  function randomiseBoard()
    for i, v in ipairs(organisms) do
      if love.math.random() > 0.5 then
        v.isAlive = true
      end
    end
  end

  randomiseBoard()

  function countNeighbors()
    for i,v in ipairs(organisms) do
      v.aliveNeighbors = 0

      if v.row > 0 and organisms[i - grid.cols].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- north
      if v.row > 0 and v.col < grid.cols - 1 and organisms[i - grid.cols + 1].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- north east
      if v.col < grid.cols - 1 and organisms[i + 1].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- east
      if v.row < grid.rows - 1 and v.col < grid.cols - 1 and organisms[i + grid.cols].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- south east
      if v.row < grid.rows - 1 and organisms[i + grid.cols].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- south
      if v.row < grid.rows - 1 and v.col > 0 and organisms[i + grid.cols - 1].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- south west
      if v.col > 0 and organisms[i - 1].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- west
      if v.row > 0 and v.col > 0 and organisms[i - grid.cols - 1].isAlive then v.aliveNeighbors = v.aliveNeighbors + 1 end -- north west
    end
  end

  function switchState()
    for i, v in ipairs(organisms) do
      if v.isAlive == false and v.aliveNeighbors == 3 then
        v.isAlive = true
      elseif v.isAlive == true and v.aliveNeighbors < 2 then
        v.isAlive = false
      elseif v.isAlive == true and v.aliveNeighbors > 3 then
        v.isAlive = false
      end
    end
  end

  timer = 0
end

function love.update(dt)
  timer = timer + dt

  if timer >= 0.001 then
    countNeighbors()
    switchState()
    timer = 0
  end

  if love.keyboard.isDown("r") then
    randomiseBoard()
  end
end

function love.draw()
  for i, v in ipairs(organisms) do
    if v.isAlive == true then love.graphics.setColor(color.alive) else love.graphics.setColor(color.dead) end
    love.graphics.rectangle("fill", v.x, v.y, grid.size, grid.size)

    love.graphics.setLineWidth(grid.gutter)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", v.x, v.y, grid.size, grid.size)
  end
end