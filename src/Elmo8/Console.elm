module Elmo8.Console exposing (Command, putPixel, print, boot, Config, sprite)

{-| The ELMO-8 Fantasy Console

This is a PICO-8 inspired fantasy "console". This isn't really a console emulator but a simple graphics and game library for creating 8-bit retro games.

# Initialization

To start up the console you need to do a little bit of configuration (the pattern matches Elm's normal model/view/update):

    import Elmo8.Console as Console
    import Elmo8.Pico8 as Pico8

    type alias Model = {}

    draw : Model ->  List Console.Command
    draw model =
        [ Console.putPixel 0 0 Pico8.peach
        , Console.print "Hello World" 10 50 Pico8.orange
        , Console.sprite 0 60 90
        ]

    update : Model -> Model
    update model = model

    main : Program Never
    main =
        Console.boot
            { draw = draw
            , init = {}
            , update = update
            , spritesUrl = "birdwatching.png"
            }

@docs boot, Config

# Drawing

- The screen size is 128x128
- Co-ordinates go from (0,0) (top left) to (127,127) (bottom right)
- Colours are given as ints to look up in the palette, 0 - 15. Look in `Elmo8.Pico8` for colours, or http://www.romanzolotarev.com/pico-8-color-palette/

@docs putPixel, print, sprite

# Actions
@docs Command

-}

import AnimationFrame
import Html
import Html.Attributes
import Time exposing (..)
import Elmo8.Display


type alias Model model =
    { display : Elmo8.Display.Model
    , model : model
    , lastTick : Time.Time
    }


type alias Colour =
    Int


{-| Represents the console for interacting via functions

-}
type Console model
    = A (Model model)


type Msg
    = DisplayMsg Elmo8.Display.Msg
    | Tick Time.Time


{-| Commands to give to the console

Normally you don't create these directly, instead use the drawing functions to interact with the console.

-}
type Command
    = PutPixel Int Int Colour
    | Print Int Int Colour String
    | Sprite { x : Int, y : Int, index : Int }
    | PixelPalette Int Int
    | ScreenPalette Int Int
    | ResetPalette
    | Noop String


{-| Draw a pixel at the given position (x, y)

e.g. putPixel 64 64 9 -> draw a pixel in the middle and set the colour to orange (9).

Equivalent to PICO-8's `pset x y c`.

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

(See screenPalette for the `pal c0 c1 1` operation.)

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
palette old new =
    PixelPalette old new


{-| Remap a colour globally (screen)

Equivalent to PICO-8 `pal c0 c1 1`

This applies after `palette`, so it can remap again.

-}
screenPalette : Colour -> Colour -> Command
screenPalette old new =
    ScreenPalette old new


{-| Reset all palette remappings

-}
resetPalette : Command
resetPalette =
    ResetPalette


{-| Render a sprite (n) at the given position (x, y)

Sprite sheets are 128x128 images (usually a PNG). They are sliced into 8x8 squares, with the index used to pick a sprite. 0 is top left, 255 is bottom right.

Note that sprites are rendered on top of each other in the order given, if you want to layer them make sure to issue the draw commands with the top sprite last.

To render sprite 0 at (10, 10):

    sprite 0 10 10

-}
sprite : Int -> Int -> Int -> Command
sprite n x y =
    Sprite { x = x, y = y, index = n }


init : model -> String -> ( Model model, Cmd Msg )
init model spritesUrl =
    let
        ( displayModel, displayMsg ) =
            Elmo8.Display.init spritesUrl
    in
        { display = displayModel, model = model, lastTick = 0 }
            ! [ Cmd.map DisplayMsg displayMsg ]


processCommand : Command -> Model model -> Model model
processCommand command model =
    case command of
        Noop message ->
            model

        PutPixel x y colour ->
            { model | display = Elmo8.Display.setPixel model.display x y colour }

        Sprite s ->
            { model | display = Elmo8.Display.sprite model.display s }

        Print x y colour string ->
            { model | display = Elmo8.Display.print model.display x y colour string }

        PixelPalette from to ->
            { model | display = Elmo8.Display.pixelPalette model.display from to }

        ScreenPalette from to ->
            { model | display = Elmo8.Display.screenPalette model.display from to }

        ResetPalette ->
            { model | display = Elmo8.Display.resetPalette model.display }


update : (model -> List Command) -> (model -> model) -> Msg -> Model model -> ( Model model, Cmd Msg )
update draw updateModel msg model =
    case msg of
        Tick time ->
            let
                shouldTick =
                    (time - model.lastTick) >= (1.0 / 30)
            in
                case shouldTick of
                    True ->
                        let
                            clearedDisplayModel =
                                { model | display = Elmo8.Display.clear model.display }

                            commands =
                                draw model.model

                            updatedModel =
                                List.foldl processCommand clearedDisplayModel commands
                        in
                            { updatedModel | model = updateModel model.model, lastTick = time } ! []

                    False ->
                        model ! []

        DisplayMsg displayMsg ->
            let
                ( display, cmd ) =
                    Elmo8.Display.update displayMsg model.display
            in
                { model | display = display } ! [ Cmd.map DisplayMsg cmd ]


subscriptions : Model model -> Sub Msg
subscriptions model =
    AnimationFrame.times (Tick << Time.inSeconds)


view : Model model -> Html.Html Msg
view model =
    Html.div
        [ Html.Attributes.style
            [ ( "background-color", "#000" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            ]
        ]
        [ Elmo8.Display.view model.display |> Html.map DisplayMsg ]


{-| Console configuration

draw (Model -> List Command) emits a bunch of commands to update the console (e.g. drawing). It is given your model which is updated in `update`. Note that currently sprites and text are cleared between each draw command. This will change in future. Assume this is called at 30 fps.

update (Model -> Model) takes the previous model (state) and returns and updated version. In future it might be given more information (e.g. time deltas between frames). Assume this is called at 30 fps.

init (Model) returns an initial state for the model.

spriteUrl (String) is a URL pointing to a 128x128 sprite sheet (16x16 8x8 sprites). You reference them by index (e.g. 0 represents a rectangle (0,0) -> (8,8) on the sprite sheet). If this is invalid then sprite rendering won't work.

-}
type alias Config model =
    { draw : model -> List Command
    , update : model -> model
    , init : model
    , spritesUrl : String
    }


{-| Boot your console!

Supply a Config.

-}
boot : Config model -> Program Never (Model model) Msg
boot config =
    Html.program
        { init = init config.init config.spritesUrl
        , update = update config.draw config.update
        , subscriptions = subscriptions
        , view = view
        }
