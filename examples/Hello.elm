import Elmo8.Console as Console
import Elmo8.Palettes.Pico8 as Palette

type alias Model = {}

draw : Console.Console Model -> Model ->  List Console.Command
draw console model =
    [ Console.putPixel 0 0 Palette.peach
    , Console.putPixel 127 0 Palette.peach
    , Console.putPixel 0 127 Palette.peach
    , Console.putPixel 127 127 Palette.peach
    , Console.print "Hello" 20 20 Palette.orange
    , Console.sprite 0 60 30
    ]

update : Model -> Model
update model = model

main : Program Never
main =
 Console.boot
    { draw = draw
    , init = { }
    , update = update
    , spritesUri = "/birdwatching.png"
    }
