{-| PICO-8's Hello.lua redone in ELMO-8

-}

import Elmo8.Console as Console
import Elmo8.Pico8 as Pico8

type alias Model = {
    t : Int
}

init : Model
init = { t = 0 }

update : Model -> Model
update model =
    { model | t = model.t + 1 }

draw_letter : Int -> Int -> Int -> List Console.Command
draw_letter t i j0 =
    let
        j = 7 - j0
        col = 7 + j
        t1 = t + i*4 - j*2
        -- x = cos(t) * 5
        -- PICO-8 example: cos(nil) * 5 -> 1 * 5
        x = 5
        y = 38 + j + cos(t1/3.5) * 5
    in
        [ Console.sprite (16+i) (8+i*8 + x + 2)  (round y + 2)
        , Console.sprite (32+i) (8+i*8 + x + 1)  (round y + 1)
        , Console.sprite (48+i) (8+i*8 + x)  (round y)
        ]

draw : Console.Console Model -> Model ->  List Console.Command
draw console model =
    [ List.map2 (\i j -> draw_letter model.t i j) [1..11] [0..10] |> List.concat
    , List.map (\i -> Console.putPixel i 0 i) [0..15]
    , [ Console.sprite 1 60 100
      , Console.putPixel 9 79 10
      , Console.print "Welcome to ELMO-8!" 10 80 9
      , Console.print "Hello World" 0 1 6
      , Console.print "Ö" 60 120 5
      ]
    ] |> List.concat

main : Program Never
main =
 Console.boot
    { draw = draw
    , init = init
    , update = update
    , spritesUrl = "hello_world.png"
    }
