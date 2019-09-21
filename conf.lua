function love.conf(t)
  t.version = "11.2"

  t.window.title = "Amphidextrous"
  t.window.width = 800
  t.window.height = 600
  t.modules.joystick = false
  t.modules.physics = false

  t.window.fullscreen = false
  t.window.fsaa = 8
  t.window.vsync = -1
  t.window.highdpi = true
end
