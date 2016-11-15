module HelloPico8 exposing (..)

{-| PICO-8 style hello world

Draws pixels in the corners, writes a message and then shows a sprite.

This uses the full PICO-8 API for all functions, which can be a little unwieldy without some helpers.

-}

import Elmo8.Console as Console
import Elmo8.Pico8 as Pico8


type alias Model =
    {}


draw : Model -> List Console.Command
draw model =
    [ Pico8.pset 0 0 Pico8.red
    , Pico8.pset 127 0 Pico8.yellow
    , Pico8.pset 0 127 Pico8.green
    , Pico8.pset 127 127 Pico8.blue
    , Pico8.print "Hello" 20 20 Pico8.orange
      -- Note that Elmo8.Console's sprite is simpler
    , Pico8.spr 0 60 30 1 1 False False
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
