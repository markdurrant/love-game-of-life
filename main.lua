function love.load()
  -- grid dimensions
  -- ===============
  grid = {}
  grid.cols = 16 * 4
  grid.rows = 10 * 4
  grid.size = 18 -- width & height of grid cells in pixels
  grid.gutter = 6 -- size of gap between grid cells in pixels

  -- color definitions
  -- =================
  color = {}
  color.background = {0, 0, 0}
  color.alive = {150, 150, 255}
  color.dead = {30, 30, 50}

  -- display setup
  -- =============
  love.window.setMode(grid.cols * grid.size + grid.gutter, grid.rows * grid.size + grid.gutter)

  -- game state setup
  -- ================
  game = {}
  game.isPaused = true -- is the game paused
  game.iterationSpeed = 1 / 15 -- speed of each itteration in seconds
  game.iterationTimer = 0 -- itteration timer
  game.keySpeed = 0.25 -- keyboard repeat speed
  game.keyTimer = 0 -- keyboard repeat timer

  -- organisms setup
  -- ===============
  organismsGroup = {}

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

  -- set random alive/dead
  -- =====================
  function randomiseBoard()
    for i, v in ipairs(organismsGroup) do
      if love.math.random() > 0.5 then
        v.isAlive = true
      end
    end
  end

  randomiseBoard()

  -- count the alive neighbors of all organisms
  -- ==========================================
  function countAllNeighbors()
    local aliveNeighbors = 0

    local function incrementAliveNeighbors()
      aliveNeighbors = aliveNeighbors + 1
    end

    for i, v in ipairs(organismsGroup) do
      aliveNeighbors = 0

      -- north
      if organismsGroup[i - grid.cols] and organismsGroup[i - grid.cols].isAlive == true then incrementAliveNeighbors() end
      -- north east
      if organismsGroup[i - grid.cols + 1] and organismsGroup[i - grid.cols + 1].isAlive == true then incrementAliveNeighbors() end
      -- east
      if organismsGroup[i + 1] and organismsGroup[i + 1].isAlive == true then incrementAliveNeighbors() end
      -- south east
      if organismsGroup[i + grid.cols + 1] and organismsGroup[i + grid.cols + 1].isAlive == true then incrementAliveNeighbors() end
      -- south
      if organismsGroup[i + grid.cols] and organismsGroup[i + grid.cols].isAlive == true then incrementAliveNeighbors() end
      -- south west
      if organismsGroup[i + grid.cols - 1] and organismsGroup[i + grid.cols - 1].isAlive == true then incrementAliveNeighbors() end
      -- west
      if organismsGroup[i - 1] and organismsGroup[i - 1].isAlive == true then incrementAliveNeighbors() end
      -- north west
      if organismsGroup[i - grid.cols - 1] and organismsGroup[i - grid.cols - 1].isAlive == true then incrementAliveNeighbors() end

      v.aliveNeighbors = aliveNeighbors
    end
  end

  -- kill or revive an organism based on its neighbors
  -- =================================================
  function switchAllStates()
    for i, v in ipairs(organismsGroup) do
       -- if organism is dead and has 3 live neighbors revive
      if v.isAlive == false and v.aliveNeighbors == 3 then v.isAlive = true
      -- if v is alive and has less than 2 live neighbors kill it
      elseif v.isAlive == true and v.aliveNeighbors < 2 then  v.isAlive = false
      -- if v is alive and has more than 4 live neighbors kill it
      elseif v.isAlive == true and v.aliveNeighbors > 3 then v.isAlive = false end
    end
  end

  -- print all organisms for dev
  -- ===========================
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
end -- love.load()

function love.update(dt)
  game.iterationTimer = game.iterationTimer + dt
  game.keyTimer = game.keyTimer + dt

  -- each itteration count neighbors & switch states
  -- ===============================================
  if game.iterationTimer > game.iterationSpeed and game.isPaused == false then
    countAllNeighbors()
    switchAllStates()
    game.iterationTimer = 0
  end

  -- keyboard handler
  -- ===============================================
  if love.keyboard.isDown(" ") and game.keyTimer > game.keySpeed then
    if game.isPaused == true then game.isPaused = false else game.isPaused = true end
    game.keyTimer = 0
  end

  if love.keyboard.isDown("p") and game.keyTimer > game.keySpeed then
    printAllOrganisms()
    game.keyTimer = 0
  end
end --love.update

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
end -- love.draw