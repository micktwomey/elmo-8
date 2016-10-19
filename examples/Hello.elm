import Elmo8.Console as Console
import Elmo8.Palettes.Pico8 as Palette

type alias Model = {}

draw : Console.Console Model -> Model ->  List Console.Command
draw console model =
    [ Console.sprite 2 60 30
    , Console.putPixel 0 0 Palette.peach
    , Console.putPixel 127 127 Palette.peach
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
