function love.load()
  -- grid dimensions
  -- ===============
  grid = {}
  grid.cols = 5
  grid.rows = 5
  grid.size = 80 -- width & height of grid cells in pixels
  grid.gutter = 10 -- size of gap between grid cells in pixels

  -- color definitions
  -- ==================
  color = {}
  color.background = {0, 0, 0}
  color.alive = {150, 150, 255}
  color.dead = {30, 30, 50}

  -- display setup
  -- =============
  love.window.setMode(grid.cols * grid.size + grid.gutter, grid.rows * grid.size + grid.gutter)

  -- organisms setup
  -- ===============
  organismsGroup = {}

  function randomBoolean()
    if love.math.random() > 0.5 then
      return true
    else
      return false
    end
  end

  -- poulate organisms group
  for r = 1, grid.rows do
    for c = 1, grid.cols do
      organism = {}
      organism.col = c
      organism.row = r
      organism.isAlive = false
      organism.aliveNeighbors = 0
      table.insert(organismsGroup, organism)
    end
  end

  -- create 'blinker' pattern
  organismsGroup[12].isAlive, organismsGroup[13].isAlive, organismsGroup[14].isAlive = true, true, true

  -- print all organisms for dev
  function printAllOrganisms( ... )
    for i,v in pairs(organismsGroup) do
      -- split every row
      if (i - 1) % 5 == 0 then print("---") end
      -- print cell
      print("C" .. v.col .. " R" .. v.row .. " | alive: " .. tostring(v.isAlive) .. " | alive neighbors: " .. v.aliveNeighbors)
      -- split last cell
      if i == table.getn(organismsGroup) then print("---") end
    end
  end

  -- cooldown counter for printAllOrganisms
  printCooldown = 0


  -- count the alive neighbors of an organism
  -- ========================================
  function countNeighbors(index, organism)
    local aliveNeighbors = 0

    function incrementAliveNeighbors()
      aliveNeighbors = aliveNeighbors + 1
    end

    -- north
    if organismsGroup[index - grid.cols] and organismsGroup[index - grid.cols].isAlive == true then incrementAliveNeighbors() end
    -- north east
    if organismsGroup[index - grid.cols + 1] and organismsGroup[index - grid.cols + 1].isAlive == true then incrementAliveNeighbors() end
    -- east
    if organismsGroup[index + 1] and organismsGroup[index + 1].isAlive == true then incrementAliveNeighbors() end
    -- south east
    if organismsGroup[index + grid.cols + 1] and organismsGroup[index + grid.cols + 1].isAlive == true then incrementAliveNeighbors() end
    -- south
    if organismsGroup[index + grid.cols] and organismsGroup[index + grid.cols].isAlive == true then incrementAliveNeighbors() end
    -- south west
    if organismsGroup[index + grid.cols - 1] and organismsGroup[index + grid.cols - 1].isAlive == true then incrementAliveNeighbors() end
    -- west
    if organismsGroup[index - 1] and organismsGroup[index - 1].isAlive == true then incrementAliveNeighbors() end
    -- north west
    if organismsGroup[index - grid.cols - 1] and organismsGroup[index - grid.cols - 1].isAlive == true then incrementAliveNeighbors() end

    organism.aliveNeighbors = aliveNeighbors
  end

  function countAllNeighbors()
    for i, v in ipairs(organismsGroup) do
      countNeighbors(i, v)
    end
  end

  -- kill or revive an organism based on its neighbors
  -- =================================================
  function switchState(organism)
    if organism.isAlive == false and organism.aliveNeighbors == 3 then -- if organism is dead and has 3 live neighbors revive
      organism.isAlive = true
    elseif organism.isAlive == true and organism.aliveNeighbors < 2 then -- if organism is alive and has less than 2 live neighbors kill it
      organism.isAlive = false
    elseif organism.isAlive == true and organism.aliveNeighbors > 3 then -- if organism is alive and has more than 4 live neighbors kill it
      organism.isAlive = false
    end
  end

  function switchAllStates()
    for i, v in ipairs(organismsGroup) do
      switchState(v)
    end
  end

  iterationTimer = 0
end

function love.update(dt)
  iterationTimer = iterationTimer + dt

  if iterationTimer > 0.25 then
    countAllNeighbors()
    switchAllStates()
    iterationTimer = 0
  end

  -- print details of all orgainsims
  -- ===============================
  printCooldown = printCooldown + dt

  if love.keyboard.isDown("p") and printCooldown > 0.25 then
    printAllOrganisms()
    printCooldown = 0
  end
end

function love.draw()
  -- draw organisms
  -- ==============
  for i, v in ipairs(organismsGroup) do
    -- set organism x/y cords
    local x = (v.col - 1) * grid.size + grid.gutter / 2
    local y = (v.row - 1) * grid.size + grid.gutter / 2

    -- set color based on organism alive/dead
    if v.isAlive == true then
      love.graphics.setColor(color.alive)
    else
      love.graphics.setColor(color.dead)
    end

    -- draw organism rectangle
    love.graphics.rectangle("fill", x, y, grid.size, grid.size)

    -- draw borders
    love.graphics.setColor(color.background)
    love.graphics.setLineWidth(grid.gutter)
    love.graphics.rectangle("line", x, y, grid.size, grid.size)
  end
end