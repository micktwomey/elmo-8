module Elmo8.Console exposing (Command, Console, getPixel, putPixel, print, boot, palette, sprite)

{-| The ELMO-8 Fantasy Console

This is a PICO-8 inspired fantasy "console". This isn't really a console emulator but a simple graphics and game library for creating 8-bit retro games.

# Initialization
@docs boot

# Drawing
@docs putPixel, print, palette, sprite

# Reading state
During draw you can read state from the Console using the following functions. These apply to the state *before* your drawing commands update it.

@docs getPixel

# Actions
@docs Command

# Data
@docs Console

-}

import AnimationFrame
import Html
import Html.Attributes
import Html.App
import Time exposing (..)

import Elmo8.Display

type alias Model model =
    { display : Elmo8.Display.Model
    , model : model
    , lastTick : Time.Time
    }

-- Private
type alias Colour = Int

{-| Represents the console for interacting via functions

-}
type Console model = A (Model model)

type Msg
    = DisplayMsg Elmo8.Display.Msg
    | Tick Time.Time

{-| Commands to give to the console

Normally you don't create these directly, instead use the drawing functions to interact with the console.

-}
type Command
    = PutPixel Int Int Colour
    | Print Int Int Colour String
    | Sprite Int Int Int
    | Noop String

{-| Draw a pixel at the given position

-}
putPixel : Int -> Int -> Colour -> Command
putPixel x y colour =
    PutPixel x y colour

{-| Read a colour value from the given pixel

-}
getPixel : Console model -> Int -> Int -> Colour
getPixel (A console) x y =
    Elmo8.Display.getPixel console.display x y

{-| Print a string at the given position

-}
print : String -> Int -> Int -> Colour -> Command
print string x y colour =
    Print x y colour string

{-| Remap a colour in the palette used for drawing operations 

pal c0 c1 [p]

	Draw all instances of colour c0 as c1 in subsequent draw calls

	pal() to reset to system defaults (including transparency values)
	Two types of palette (p; defaults to 0)
		0 draw palette   : colours are remapped on draw    // e.g. to re-colour sprites
		1 screen palette : colours are remapped on display // e.g. for fades
	c0 colour index 0..15
	c1 colour index to map to

-}
palette : Colour -> Colour -> Command
palette old new = Noop "palette"

{-| Render a sprite at the given position 

spr n x y [w h] [flip_x] [flip_y]

	draw sprite n (0..255) at position x,y
	width and height are 1,1 by default and specify how many sprites wide to blit.
	Colour 0 drawn as transparent by default (see palt())
	flip_x=true to flip horizontally
	flip_y=true to flip vertically

-}
sprite : Int -> Int -> Int -> Command
sprite sprite x y =
    Sprite sprite x y

init : model -> String -> (Model model, Cmd Msg)
init model spritesUri =
    let
        (displayModel, displayMsg) = Elmo8.Display.init spritesUri
    in
        { display = displayModel, model = model, lastTick = 0 }
        ! [ Cmd.map DisplayMsg displayMsg ]


processCommand : Command -> Model model -> Model model
processCommand command model =
    case command of
        Noop message -> model
        PutPixel x y colour ->
            { model | display = Elmo8.Display.setPixel model.display x y colour }
        Sprite index x y ->
            { model | display = Elmo8.Display.sprite model.display index x y }
        Print x y colour string ->
            model

update : (Console model -> model -> List Command) -> (model -> model) -> Msg -> Model model -> (Model model, Cmd Msg)
update draw updateModel msg model =
    case msg of
        Tick time ->
            let
                shouldTick = (time - model.lastTick) >= (1.0 / 30)
            in 
                case shouldTick of
                    True ->
                        let
                            clearedDisplayModel = { model | display = Elmo8.Display.clear model.display }
                            commands = draw (A model) model.model
                            updatedModel = List.foldl processCommand clearedDisplayModel commands
                        in
                            { updatedModel | model = updateModel model.model, lastTick = time } ! [ ]
                    False ->
                        model ! []
        DisplayMsg displayMsg ->
            let
                (display, cmd) = Elmo8.Display.update displayMsg model.display
            in
                { model | display = display} ! [ Cmd.map DisplayMsg cmd ]

subscriptions : Model model -> Sub Msg
subscriptions model =
    AnimationFrame.times (Tick << Time.inSeconds)

view : Model model -> Html.Html Msg
view model =
    Html.body
        [ Html.Attributes.style
            [ ( "background-color", "#000" )
            , ( "display",  "flex" )
            , ( "align-items", "center")
            , ( "justify-content", "center" )
            ]
        ]
        [ Elmo8.Display.view model.display |> Html.App.map DisplayMsg ]

{-| Console configuration

draw is a function which can optionally read information from the Console (the previous state) and then emit a bunch of commands to update the console (e.g. drawing).

update takes the previous model (state) and returns and updated version.

init returns an initial state for the model.

-}
type alias Config model =
    { draw: Console model -> model -> List Command
    , update: model -> model
    , init: model
    , spritesUri : String
    }

{-| Boot your console!

Supply a Config.

-}
boot : Config model -> Program Never
boot config =
    Html.App.program
        { init = init config.init config.spritesUri
        , update = update config.draw config.update
        , subscriptions = subscriptions
        , view = view
        }
