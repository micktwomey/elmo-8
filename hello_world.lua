-- hello world
-- by zep

t = 0

music(0)

function _update()
 t += 1
end

function _draw()
 cls()
  
 for i=1,11 do
  for j0=0,7 do
  j = 7-j0
  col = 7+j
  t1 = t + i*4 - j*2
  x = cos(t0)*5
  y = 38 + j + cos(t1/50)*5
  pal(7,col)
  spr(16+i, 8+i*8 + x, y)
  end
 end
	 
  print("this is pico-8",
    37, 70, 14) --8+(t/4)%8)

 print("nice to meet you",
    34, 80, 12) --8+(t/4)%8)

  spr(1, 64-4, 90)
end
