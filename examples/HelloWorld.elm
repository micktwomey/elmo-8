import Elmo8.Console as Console
import Elmo8.Palettes.Pico8 as Palette

type alias Model = {
    t : Int
}

init : Model
init = { t = 0 }

update : Model -> Model
update model =
    { model | t = model.t + 1 }

draw_letter t i j0 =
    let
        j = 7 - j0
        col = 7 + j
        t1 = t + i*4 - j*2
        -- x = cos(t0) * 5
        x = 5 -- Bug in PICO-8 example, cos(nil) * 5 -> 1 * 5
        y = 38 + j + cos(t1/50) * 5
    in
        [ Console.palette(7, col)
        , Console.sprite(16+i, 8+i*8 + x, y)
        ]

draw : Console.Console -> List Console.Command
draw console =
    List.concat 
        List.map2 (\i j -> draw_letter model.t i j) [1..11] [0..7] 

main : Program Never
main =
 Console.boot
    { draw = draw
    }
