module Elmo8.Pico8 exposing
    ( black, darkblue, darkpurple, darkgreen, brown, darkgrey, lightgrey, white, red, orange, yellow, green, blue, indigo, pink, peach
    , pset, spr, print
    )

{-| (Mostly) PICO-8 Compatible API

For folks familiar with the PICO-8 this module exposes function calls which (mostly) match up to the PICO-8's.

Aims to match (as much as is reasonable) the API here: http://www.lexaloffle.com/pico-8.php?page=manual

Even if a function has the full PICO-8 function signature note all flags might be implemented (yet).

# Drawing

@docs pset, spr, print

# Colours

The PICO-8 has a fairly snazzy palette of 16 colours, identified by an int from 0 to 15. You can also use these handy identifiers.

@docs black, darkblue, darkpurple, darkgreen, brown, darkgrey, lightgrey, white, red, orange, yellow, green, blue, indigo, pink, peach

-}

import Elmo8.Console exposing (Command)

{-| Black (0)
-}
black : Int
black = 0

{-| Dark Blue (1)
-}
darkblue : Int
darkblue = 1

{-| Dark Purple (2)
-}
darkpurple : Int
darkpurple = 2

{-| Dark Green (3)
-}
darkgreen : Int
darkgreen = 3

{-| Brown (4)
-}
brown : Int
brown = 4

{-| Dark Grey (5)
-}
darkgrey : Int
darkgrey = 5

{-| Light Grey (6)
-}
lightgrey : Int
lightgrey = 6

{-| White (7)
-}
white : Int
white = 7

{-| Red (8)
-}
red : Int
red = 8

{-| Orange (9)
-}
orange : Int
orange = 9

{-| Yellow (10)
-}
yellow : Int
yellow = 10

{-| Green (11)
-}
green : Int
green = 11

{-| Blue (12)
-}
blue : Int
blue = 12

{-| Indigo (13)
-}
indigo : Int
indigo = 13

{-| Ping (14)
-}
pink : Int
pink = 14

{-| Peach (15)
-}
peach : Int
peach = 15


{-| Set the colour of a pixel at (x,y) using colour (c)

Same as PICO-8's `pset x y [c]`.

- x and y should be 0 - 127
- c should be 0 - 15.

-}
pset : Int -> Int -> Int -> Command
pset x y colour =
    Elmo8.Console.putPixel x y colour

{-| Draw a sprite n at (x,y)

Sames as PICO-8's `spr n x y [w h] [flip_x] [flip_y]`

Note that `[w h] [flip_x] [flip_y]` is currently not implemented (it will be).

- draw sprite n (0..255) at position x,y
- (Not implemented) width and height are 1,1 by default and specify how many sprites wide to blit.
- (Not implemented) Colour 0 drawn as transparent by default (see palt())
- (Not implemented) flip_x=true to flip horizontally
- (Not implemented) flip_y=true to flip vertically
-}
spr : Int -> Int -> Int -> Int -> Int -> Bool -> Bool -> Command
spr index x y width height flip_x flip_y =
    Elmo8.Console.sprite index x y

{-| Print string (str) at (x,y) using colour (c)

Same as PICO-8's `print str [x y [col]]`.

(Not implemented) If only str is supplied, and the cursor reaches the end of the screen, a carriage return and vertical scroll is automatically applied. (terminal-like behaviour)
-}
print : String -> Int -> Int -> Int -> Command
print string x y colour =
    Elmo8.Console.print string x y colour
