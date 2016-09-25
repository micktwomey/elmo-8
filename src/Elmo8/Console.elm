module Elmo8.Console exposing (Command, Console, getPixel, putPixel, print, boot)

{-| The ELMO-8 Fantasy Console

This is a PICO-8 inspired fantasy "console". This isn't really a console emulator but a simple graphics and game library for creating 8-bit retro games.

# Initialization
@docs boot

# Drawing
@docs putPixel, print

# Reading state
During draw you can read state from the Console using the following functions. These apply to the state *before* your drawing commands update it.

@docs getPixel

# Actionsc
@docs Command

# Data
@docs Console

-}

import AnimationFrame
import Html
import Html.App
import Time exposing (..)

import Elmo8.Display

type alias Model =
    { console : ConsoleModel
    , display : Elmo8.Display.Model
    }

-- Private
type alias Colour = Int
type alias ConsoleModel = {}

{-| Represents the console for interacting via functions

-}
type Console = A ConsoleModel

type Msg
    = DisplayMsg Elmo8.Display.Msg
    | Tick Time.Time

{-| Commands to give to the console

Normally you don't create these directly, instead use the drawing functions to interact with the console.

-}
type Command
    = PutPixel Int Int Colour
    | Print Int Int Colour String

{-| Draw a pixel at the given position

-}
putPixel : Int -> Int -> Colour -> Command
putPixel x y colour =
    PutPixel x y colour

{-| Read a colour value from the given pixel

-}
getPixel : Console -> Int -> Int -> Colour
getPixel (A console) x y =
    0

{-| Print a string at the given position

-}
print : String -> Int -> Int -> Colour -> Command
print string x y colour =
    Print x y colour string

init : (Model, Cmd Msg)
init =
    let
        (displayModel, displayMsg) = Elmo8.Display.init
    in
        { console = {}, display = displayModel}
        ! [ Cmd.map DisplayMsg displayMsg ]


processCommand : Command -> Model -> Model
processCommand command model =
    case command of
        PutPixel x y colour ->
            { model | display = Elmo8.Display.setPixel model.display x y colour }
        Print x y colour string ->
            model

update : (Console -> List Command) -> Msg -> Model -> (Model, Cmd Msg)
update draw msg model =
    let
        commands = draw (A model.console)
        updatedModel = List.foldl processCommand model commands
    in
        updatedModel ! [ ]

subscriptions : Model -> Sub Msg
subscriptions model =
    AnimationFrame.diffs (Tick << Time.inSeconds)

view : Model -> Html.Html Msg
view model =
    Html.div [] [ Elmo8.Display.view model.display |> Html.App.map DisplayMsg ]

{-| Console configuration

draw is a function which can optionally read information from the Console (the previous state) and then emit a bunch of commands to update the console (e.g. drawing).

-}
type alias Config =
    { draw: Console -> List Command
    }

{-| Boot your console!

Supply a Config.

-}
boot : Config -> Program Never
boot config =
    Html.App.program
        { init = init
        , update = update config.draw
        , subscriptions = subscriptions
        , view = view
        }
