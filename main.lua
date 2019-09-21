local Color = require("color")
local Fish = require("fish")
local LSystem = require("lsystem")
local Plastic = require("plastic")
local Sub = require("sub")
local Vec2 = require("vec2")
local XWave = require('xwave')

local DEBUG = false

local WIDTH = 800
local HEIGHT = 600
local NUM_SYSTEMS = 13

local BEGIN_DIFFICULTY = 0.985
local END_DIFFICULTY = 0.95
local N_SECONDS_TO_MAX_DIFFICULTY = 60 * 5

local t = 0
local start_game_t = 0

function love.load()
  math.randomseed(os.time())
  sniglet_font = love.graphics.newFont("fonts/sniglet.fnt")
  sniglet_small_font = love.graphics.newFont("fonts/snigletsmall.fnt")
  music = love.audio.newSource("music/quest.mp3", "stream")
  tide_loop = love.audio.newSource("sfx/ocean.wav", "stream")
  lost_sfx = love.audio.newSource("sfx/Retro_Game_Sounds_SFX_22.wav", "static")
  saved_sfx = love.audio.newSource("sfx/Retro_Game_Sounds_SFX_82.wav", "static")
  removed_plastic_sfx = love.audio.newSource("sfx/Retro_Game_Sounds_SFX_85.wav", "static")
  game_over_sfx = love.audio.newSource("sfx/Retro_Game_Sounds_SFX_51.wav", "static")

  tide_loop:setLooping(true)
  tide_loop:setVolume(0.1)
  love.audio.play(tide_loop)

  setup_shader()
  setup_intro()
end

function love.update(dt)
  t = t + dt
  if wait_for_update then
    wait_for_update = false
  end

  if intro then
    if not intro_transition then
      intro_play_alpha = 0.7 + math.sin(3 * t) * 0.3
      intro_change_fish_counter = intro_change_fish_counter - dt
      if intro_change_fish_counter <= 0 then
        intro_fish = Fish(true)
        intro_change_fish_counter = intro_change_fish_delay
      end
    else
      intro_transition_alpha = math.min(1.0, intro_transition_alpha + dt / 2.0)
      if intro_transition_alpha == 1.0 then
        setup_level()
        intro = false
        wait_for_update = true
        love.audio.play(music)
        start_game_t = t
      end
    end
    return
  elseif outro then
    outro_continue_alpha = 0.7 + math.sin(3 * t) * 0.3
    return
  end

  if game_over then
    game_over_alpha = math.min(1.0, game_over_alpha + dt / 2.0)
    music:setVolume(1.0 - game_over_alpha)

    if game_over_alpha == 1.0 then
      setup_outro()
      wait_for_update = true
    end
    return
  end

  shader:send("time", t)

  for i = 1, NUM_SYSTEMS do
    offset = offsets[i] + math.sin(0.5 * t + offset_phases[i]) * 2.0
    left_angles[i] = -angles[i] + offset + math.sin(0.5 * t + angle_phases[i]) * 3.0
    right_angles[i] = angles[i] + offset + math.sin(0.5 * t - angle_phases[i]) * 2.0
  end

  local theta_t = (math.pi / 2.0) + math.sin(-1.5 * t) * (math.pi / 2.01)

  local tw = 0.0
  for i = 1, #xwaves do
    xwaves[i]:update(t + tw, dt)
    tw = tw - 0.25
  end

  saved_fish_flag = false
  removed_plastic_flag = false
  local to_remove = {}
  for i = 1, #bags do
    bags[i]:update(t, dt)
    if (bags[i].center_pos.y < -50.0) then
      to_remove[#to_remove + 1] = i
    else
      for a = 1, #sub.arms do
        if (Vec2:sub(sub.arms[a].current_pos, bags[i].center_pos):norm() < 20.0) then
          to_remove[#to_remove + 1] = i
          if bags[i].is_stuck_to_fish then
            saved_fish_flag = true
            points = points + 100
          else
            removed_plastic_flag = true
            points = points + 50
          end
        end
      end
    end
  end

  for i = #to_remove, 1, -1 do
    local ix = to_remove[i]
    if bags[ix].is_stuck_to_fish then
      bags[ix].is_stuck_to_fish.happy = true
      bags[ix].is_stuck_to_fish.is_stuck_to_bag = nil
    else
    end
    table.remove(bags, to_remove[i])
  end

  lost_fish_flag = false
  to_remove = {}
  for i = 1, #fishes do
    fishes[i]:update(t, dt)
    if (fishes[i].pos.x > WIDTH + 50.0 or fishes[i].pos.x < -50.0) then
      to_remove[#to_remove + 1] = i
    elseif (fishes[i].pos.y < -25.0) then
      to_remove[#to_remove + 1] = i
      lost_a_fish()
    end
  end

  for i = #to_remove, 1, -1 do
    table.remove(fishes, to_remove[i])
  end

  for i = 1, #fishes do
    if (fishes[i].is_stuck_to_bag) then
      fishes[i].target = fishes[i].is_stuck_to_bag.center_pos
    else
      for j = 1, #bags do
        if (not bags[j].is_stuck_to_fish) then
          if (Vec2:sub(fishes[i].pos, bags[j].center_pos):norm() < 20.0) then
            bags[j].is_stuck_to_fish = fishes[i]
            fishes[i].is_stuck_to_bag = bags[j]
            fishes[i].happy = false
            fishes[i].target = bags[j].center_pos
          end
        end
      end
    end
  end

  local game_t = t - start_game_t
  local delta_difficulty = END_DIFFICULTY - BEGIN_DIFFICULTY
  local difficulty = BEGIN_DIFFICULTY + (
    delta_difficulty * math.min(game_t / N_SECONDS_TO_MAX_DIFFICULTY, 1.0)
  )

  if (math.random() > difficulty) then
    local y = 250.0 + math.random() * (HEIGHT - 275.0)
    local left_facing = math.random() > 0.5
    local x
    if (left_facing) then
      x = WIDTH + 50.0
    else
      x = -50.0
    end
    fishes[#fishes + 1] = Fish(left_facing, Vec2(x, y))
  end

  if (math.random() > difficulty) then
    local y = HEIGHT + 25.0
    local x = 75.0 + math.random() * (WIDTH - 150.0)
    bags[#bags + 1] = Plastic(Vec2(x, y))
  end

  local pt = 0.1 * t
  local sub_offset_x = math.sin(2 + 1.9 * pt) * math.cos(1.1 + pt / 0.55) * 100
  local sub_offset_y = math.sin(0.7 + 0.7 * pt) * math.cos(2.2 + pt / 0.6) * 70
  local new_x = 400 + sub_offset_x
  local new_y = 300 + sub_offset_y
  local delta_x = sub.pos.x - new_x
  local delta_y = sub.pos.y - new_y
  sub.pos.x = new_x
  sub.pos.y = new_y
  for i = 1, #sub.arms do
    local arm = sub.arms[i]
    arm.target.x = arm.target.x - delta_x
    arm.target.y = arm.target.y - delta_y
  end
  sub:update(t, dt)
end

function love.keypressed(k)
  if k == 'escape' then
    love.event.quit()
  end
end

function love.mousepressed(x, y, button, istouch, presses)
  if intro then
    local sfx = love.audio.newSource("sfx/Retro_Game_Sounds_SFX_85.wav", "static")
    sfx:play()
    intro_transition = true
  elseif outro then
    local sfx = love.audio.newSource("sfx/Retro_Game_Sounds_SFX_85.wav", "static")
    sfx:play()
    outro = false
    setup_intro()
  else
  sub:set_target(x, y)
  end
end

function love.draw()
  if intro then
    draw_intro()
    return
  elseif outro then
    draw_outro()
    return
  end

  if game_over_flag then
    game_over_flag = false
    game_over_sfx:stop()
    game_over_sfx:play()
  end

  if not game_over then
    if lost_fish_flag then
      lost_fish_flag = false
      lost_sfx:stop()
      lost_sfx:play()
    end
    if saved_fish_flag then
      saved_fish_flag = false
      saved_sfx:stop()
      saved_sfx:play()
    end
    if removed_plastic_flag then
      removed_plastic_flag = false
      removed_plastic_sfx:stop()
      removed_plastic_sfx:play()
    end
  end

  if wait_for_update then
    return
  end

  local wave_color = Color:color_from_index(27)
  local sand_color = Color:color_from_index(24)
  love.graphics.setBackgroundColor(Color:color_from_index(26):rgba())
  love.graphics.setColor(wave_color:rgba())
  xwaves[1]:draw()

  love.graphics.setCanvas(wave2)
  love.graphics.clear()
  shader:send("wave_seed", {10.0, 10000.0})
  shader:send("bottom_color", Color:color_from_index(26):lighten(0.1):rgba())
  shader:send("top_color", Color:color_from_index(30):rgba(0.0))
  shader:send("line_color", wave_color:darken(0.0):rgba())
  shader:send("under_color", sand_color:rgba())
  love.graphics.setShader(shader)
  love.graphics.rectangle('fill', 0, 0, 800, 530)

  love.graphics.setShader()
  love.graphics.setCanvas()

  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(1, 1, 1, 1)
  local wave_y = 20 + 10.0 * math.sin(0.5 * t + 0.3)
  love.graphics.draw(wave2, 0, wave_y, 0)
  love.graphics.setBlendMode("alpha")

  love.graphics.origin()
  lsystems[2]:draw()
  love.graphics.origin()
  lsystems[4]:draw()
  love.graphics.origin()
  lsystems[5]:draw()
  love.graphics.origin()
  lsystems[8]:draw()
  love.graphics.origin()
  lsystems[9]:draw()
  love.graphics.origin()
  lsystems[11]:draw()
  love.graphics.origin()
  lsystems[13]:draw()
  love.graphics.origin()

  love.graphics.setColor(sand_color:rgba())
  love.graphics.rectangle("fill", 0, 530 + wave_y, WIDTH, HEIGHT)

  for i = 1, #fishes do
    fishes[i]:draw()
  end

  love.graphics.setLineWidth(1.0)
  for i = 1, #bags do
    bags[i]:draw()
  end

  sub:draw()

  lsystems[1]:draw()
  love.graphics.origin()
  lsystems[3]:draw()
  love.graphics.origin()
  lsystems[6]:draw()
  love.graphics.origin()
  lsystems[7]:draw()
  love.graphics.origin()
  lsystems[10]:draw()
  love.graphics.origin()
  lsystems[12]:draw()
  love.graphics.origin()

  if game_over then
    love.graphics.setColor(0, 0, 0, game_over_alpha)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
  end

  love.graphics.setColor(1, 1, 1)
  if DEBUG then
    love.graphics.setFont(sniglet_small_font)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 520)
    love.graphics.print("#fishes: "..tostring(#fishes), 10, 550)
    love.graphics.print("#bags: "..tostring(#bags), 10, 580)
  end

  love.graphics.printf("AMPHIDEXTROUS", 250, 0, 300, "center")

  love.graphics.setFont(sniglet_font)
  love.graphics.print(tostring(points), 10, 0)
  love.graphics.scale(0.8)
  local lives_x = WIDTH / 0.8
  for i = 1, #lives do
    lives_x = lives_x - lives[i].length / 0.8 - 10
    lives[i].pos.x = lives_x
    lives[i].pos.y = 30
    lives[i]:draw()
  end
end

function setup_lsystems()
  axiom = "X"
  productions = {
    ["X"] = function()
      if math.random() < 0.9 then
        return "F-[[X]+X]+F[-FX]-X"
      else
        return "F+[[X]+X]-F[+FX]+F[-X]"
      end
    end,
    ["F"] = function()
      if math.random() < 0.95 then
        return "FF"
      else
        return "FFF"
      end
    end
  }
  lsystems = {}
  centers = {}
  left_angles = {}
  right_angles = {}
  offsets = {}
  offset_phases = {}
  angle_phases = {}
  lengths = {}
  angles = {}
  stem_colors = {}
  leaf_colors = {}

  for i = 1, NUM_SYSTEMS do
    centers[i] = (math.random() - 0.5) * 15.0
    left_angles[i] = 0
    right_angles[i] = 0
    offset_phases[i] = math.random() * math.pi
    angle_phases[i] = math.random() * math.pi
    angles[i] = 36.5 + (math.random() - 0.5) * 25.0
    offsets[i] = (math.random() - 0.5) * 10.0
    lengths[i] = 28.0 + math.random() * 20.0
    stem_colors[i] = Color:random_color(0.85):rgba()
    leaf_colors[i] = Color:random_color(0.3):rgba()
    finals = {
      ["-"] = function() love.graphics.rotate((math.pi / 180.0) * left_angles[i]) end,
      ["+"] = function() love.graphics.rotate((math.pi / 180.0) * right_angles[i]) end,
      ["["] = function() love.graphics.push() end,
      ["]"] = function()
        love.graphics.pop()
      end,
      ["F"] = function(ix, symbol, iterations)
        love.graphics.setColor(stem_colors[i])
        love.graphics.setLineWidth(2)
        love.graphics.setLineJoin("none")
        love.graphics.line(0, 0, 0, -lengths[i] / (iterations + 1))
        love.graphics.translate(0, -lengths[i] / (iterations + 1))
      end,
      ["X"] = function(ix, symbol, iterations)
        love.graphics.setColor(leaf_colors[i])
        love.graphics.circle("fill", 0, 0, 5)
      end
    }
    lsystems[i] = LSystem(
      axiom,
      productions,
      finals,
      Vec2(30 + 64 * (i - 1) + (math.random() - 0.5) * 50.0, 560)
    )
    lsystems[i]:iterate(3)
  end
end

function lost_a_fish()
  lost_fish_flag = true
  table.remove(lives)
  if #lives == 0 then
    game_over = true
    game_over_flag = true
  end
end

function draw_intro()
  love.graphics.setBackgroundColor(Color:color_from_index(26):rgba())

  love.graphics.scale(2.0)
  intro_fish.pos.x = 175
  intro_fish.pos.y = 30
  intro_fish.happy = true
  intro_fish:draw()

  love.graphics.origin()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(sniglet_font)
  love.graphics.print("AMPHIDEXTROUS", 270, 100)
  love.graphics.setColor(1, 1, 1, intro_play_alpha)
  love.graphics.print("Press play", 320, 260)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(sniglet_small_font)
  love.graphics.printf(
    "Save the fishes by cleaning the ocean from plastic",
    100, 150, 600, "center"
  )
  love.graphics.print("Music by steriotyper.itch.io", 250, 400)
  love.graphics.print("Sound effects by loadless.itch.io and", 200, 430)
  love.graphics.print("jalastram.itch.io (CC-BY-CA 3.0)", 220, 460)

  love.graphics.printf(
    "A game by Jonas Nockert for Kodsnack's Game Jam #3",
    100, 550, 600, "center"
  )

  if intro_transition then
    love.graphics.setColor(0, 0, 0, intro_transition_alpha)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
  end
end

function draw_outro()
  love.graphics.setBackgroundColor(Color:color_from_index(26):rgba())

  love.graphics.scale(2.0)
  outro_fish.pos.x = 175
  outro_fish.pos.y = 30
  outro_fish:draw()

  love.graphics.origin()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(sniglet_font)
  love.graphics.printf(points.." points", 300, 100, 200, "center")
  love.graphics.setColor(1, 1, 1, outro_continue_alpha)
  love.graphics.printf("Press continue", 200, 260, 400, "center")
end

function setup_intro()
  intro_fish = Fish(true)
  intro_fish.happy = true
  intro_play_alpha = 1.0
  intro_transition = false
  intro_transition_delay = 0.5
  intro_transition_alpha = 0.0
  intro = true
  intro_change_fish_delay = 1
  intro_change_fish_counter = 0
end

function setup_outro()
  outro_fish = Fish(true)
  outro_fish.happy = false
  outro_continue_alpha = 0.0
  outro = true
end

function setup_level()
  lives = {}
  lives[1] = Fish(true)
  lives[2] = Fish(true)
  lives[3] = Fish(true)
  lives[4] = Fish(true)
  lives[5] = Fish(true)
  points = 0
  game_over = false
  game_over_flag = false
  game_over_alpha = 0.0
  wait_for_update = false

  lost_fish_flag = false
  saved_fish_flag = false
  removed_plastic_flag = false

  bags = {}
  fishes = {}
  setup_lsystems()

  xwaves = {}
  local poses = {{
    f_r  = 0.9,
    f_t  = 1.0,
    f_cr = 1.0,
    f_s  = 0.8,
    theta_t = math.pi * ( 90.0 / 180.0),
    theta_c = math.pi * (  0.0 / 180.0),
    theta_r = math.pi * (  0.0 / 180.0),
    crest_circle_radius = 30.0,
    crest_circle_center = Vec2(-200.0, 35.0)
  }}
  local lambda = poses[1].crest_circle_radius * 7.0
  poses[1].crest_circle_center.x = -lambda * 1.3
  xwaves[1] = XWave(poses, 8, lambda, WIDTH, HEIGHT)

  sub = Sub(Vec2(400, 300))

  music:setLooping(true)
  music:setVolume(1.0)
  lost_sfx:setVolume(0.2)
  saved_sfx:setVolume(0.9)
  removed_plastic_sfx:setVolume(0.6)
end

function setup_shader()
  local data = love.image.newImageData(800, 10)
  for i = 0, 9, 1 do
      local handdrawn_data = {}
      for line in love.filesystem.lines("handdrawn-data" .. i .. ".txt") do
          handdrawn_data[#handdrawn_data+1] = tonumber(line)
      end

      -- print(#handdrawn_data)
      for j=0, #handdrawn_data-1 do
          local v = 0.5 + handdrawn_data[j + 1] / 6.0
          data:setPixel(j, i, 0, v, 0, 1.0)
      end
  end
  handdrawn_data = love.graphics.newImage(data)
  wave2 = love.graphics.newCanvas(800, 530)
  shader = love.graphics.newShader("wave.glsl")
  shader:send("handdrawn", handdrawn_data)
end
