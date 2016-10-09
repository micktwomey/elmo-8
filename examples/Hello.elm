import Elmo8.Console as Console
import Elmo8.Palettes.Pico8 as Palette

type alias Model = { drawn : Bool }

draw : Console.Console Model -> Model ->  List Console.Command
draw console model =
    case model.drawn of 
        True -> []
        False -> 
            [ Console.putPixel 0 0 Palette.peach
            , Console.putPixel 10 10 Palette.peach
            , Console.putPixel 50 50 Palette.peach
            , Console.putPixel 100 100 Palette.peach
            , Console.putPixel 127 127 Palette.peach
            , Console.print "Hello" 20 20 Palette.orange
            ]

update : Model -> Model
update model = { drawn = True }

main : Program Never
main =
 Console.boot
    { draw = draw
    , init = { drawn = False }
    , update = update
    }
