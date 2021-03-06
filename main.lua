function love.load()
  hsl = require("hsl")

  -- grid dimensions
  -- ===============
  grid = {}
  grid.cols = 16 * 2
  grid.rows = 10 * 2
  grid.size = 32 -- width & height of grid cells in pixels
  grid.gutter = 4 -- size of gap between grid cells in pixels

  -- color definitions
  -- =================
  color = {}
  color.background = {hsl.toRgb(0, 0, 0)}
  color.trail = {hsl.toRgb(0, 0, 15)}
  color.alive = {hsl.toRgb(220, 100, 60)}
  color.old = {hsl.toRgb(220, 100, 40)}
  color.dead = {hsl.toRgb(0, 0, 10)}


  -- display setup
  -- =============
  love.window.setMode(grid.cols * grid.size + grid.gutter, grid.rows * grid.size + grid.gutter)

  -- game state setup
  -- ================
  game = {}
  game.isPaused = true -- is the game paused
  game.trailsOn = true -- trails on
  game.iterationSpeed = 1 / 15 -- speed of each itteration in seconds
  game.iterationTimer = 0 -- itteration timer
  game.keySpeed = 0.25 -- keyboard repeat speed
  game.keyTimer = 0 -- keyboard repeat timer


  -- welcome message
  -- ===============
  print("\n*************************************************************************\n**** Press space to play/pause. Press 'p' to print status to console ****\n*************************************************************************")


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
      organism.hasbeenAlive = false
      organism.age = 0
      organism.aliveNeighbors = 0
      table.insert(organismsGroup, organism)
    end
  end

  -- set random alive/dead
  -- =====================
  function randomiseBoard()
    for i, v in ipairs(organismsGroup) do
      if love.math.random() > 0.8 then v.isAlive = true
      else v.isAlive = false end
    end
  end

  -- count the alive neighbors of all organisms
  -- ==========================================
  function countAllNeighbors()
    local aliveNeighbors = 0

    local function incrementAliveNeighbors()
      aliveNeighbors = aliveNeighbors + 1
    end

    for i, v in ipairs(organismsGroup) do
      aliveNeighbors = 0
      a = 0
      b = 0
      c = 0
      d = 0
      if organismsGroup[i].row == 1 then a = (grid.cols * grid.rows) end
      if organismsGroup[i].col == 1 then b = grid.cols end
      if organismsGroup[i].col == grid.cols then c = -grid.cols end
      if organismsGroup[i].row == grid.rows then d = -(grid.cols * grid.rows) end
      -- north
      if organismsGroup[i - grid.cols + a].isAlive == true then incrementAliveNeighbors() end
      -- north east
      if organismsGroup[i - grid.cols + 1 + a + c].isAlive == true then incrementAliveNeighbors() end
      -- east
      if organismsGroup[i + 1 + c].isAlive == true then incrementAliveNeighbors() end
      -- south east
      if organismsGroup[i + grid.cols + 1 + c + d].isAlive == true then incrementAliveNeighbors() end
      -- south
      if organismsGroup[i + grid.cols + d].isAlive == true then incrementAliveNeighbors() end
      -- south west
      if organismsGroup[i + grid.cols - 1 + b + d].isAlive == true then incrementAliveNeighbors() end
      -- west
      if organismsGroup[i - 1 + b].isAlive == true then incrementAliveNeighbors() end
      -- north west
      if organismsGroup[i - grid.cols - 1 + a + b].isAlive == true then incrementAliveNeighbors() end
      v.aliveNeighbors = aliveNeighbors
    end
  end

  -- kill or revive an organism based on its neighbors
  -- =================================================
  function switchAllStates()
    for i, v in ipairs(organismsGroup) do
      if v.isAlive == true then v.age = v.age + 1 end
      if v.isAlive == true then v.hasbeenAlive = true end
      -- if organism is dead and has 3 live neighbors revive
      if v.isAlive == false and v.aliveNeighbors == 3 then v.isAlive = true
      -- if v is alive and has less than 2 live neighbors kill it
      elseif v.isAlive == true and v.aliveNeighbors < 2 then
        v.isAlive = false
        organism.age = 0
      -- if v is alive and has more than 3 live neighbors kill it
      elseif v.isAlive == true and v.aliveNeighbors > 3 then
        v.isAlive = false
        v.age = 0
      end
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

  if love.keyboard.isDown("t") and game.keyTimer > game.keySpeed then
    if game.trailsOn == true then game.trailsOn = false else game.trailsOn = true end
    game.keyTimer = 0
  end

  if love.keyboard.isDown("p") and game.keyTimer > game.keySpeed then
    printAllOrganisms()
    game.keyTimer = 0
  end

  if love.keyboard.isDown("r") and game.keyTimer > game.keySpeed then
    randomiseBoard()
    game.isPaused = true
    for i, v in ipairs(organismsGroup) do
      v.hasbeenAlive = false
      v.age = 0
    end
    game.keyTimer = 0
  end

  -- pick up mouse event
  if love.mouse.isDown("l") and game.keyTimer > game.keySpeed then
    local mouseCol = math.floor(love.mouse.getX() / grid.size)
    local mouseRow = math.floor(love.mouse.getY() / grid.size)
    organismsGroup[mouseCol + (mouseRow * grid.cols) + 1].isAlive = true

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
      if v.age < 3 then love.graphics.setColor(color.alive)
      else love.graphics.setColor(color.old) end
    else
      if v.hasbeenAlive == true and game.trailsOn == true then
      love.graphics.setColor(color.trail) else
      love.graphics.setColor(color.dead) end
    end

    -- draw organism rectangle
    love.graphics.rectangle("fill", x, y, grid.size, grid.size)

    -- draw borders
    love.graphics.setColor(color.background)
    love.graphics.setLineWidth(grid.gutter)
    love.graphics.rectangle("line", x, y, grid.size, grid.size)
  end
end -- love.draw
