module Basic exposing (..)

import Elmo8.Console as Console
import Elmo8.Pico8 as Pico8


type alias Model =
    {}


draw : Model -> List Console.Command
draw model =
    [ Console.putPixel 10 10 Pico8.peach
    , Console.print "Hello World" 10 50 Pico8.orange
    , Console.sprite 0 60 90
    ]


update : Model -> Model
update model =
    model


main =
    Console.boot
        { draw = draw
        , init = {}
        , update = update
        , spritesUrl = "birdwatching.png"
        }
