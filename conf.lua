function love.conf(t)
  t.identity = 'com.wolftrail.ctg'              -- The name of the save directory (string)
  t.version = '11.5'                            -- The LÖVE version this game was made for (string)

  t.window.title = 'Clear The Grid'
  t.window.width = 720
  t.window.height = 540
  t.window.minwidth = 720
  t.window.minheight = 540
  t.window.resizable = true
end
