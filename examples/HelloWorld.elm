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

draw : Console.Console -> List Console.Command
draw console =
    [ Console.putPixel 0 0 Palette.peach
    , Console.putPixel 10 10 Palette.peach
    , Console.putPixel 50 50 Palette.peach
    , Console.putPixel 100 100 Palette.peach
    , Console.putPixel 127 127 Palette.peach
    , Console.print "Hello" 20 20 Palette.orange
    ]

main : Program Never
main =
 Console.boot
    { draw = draw
    }
