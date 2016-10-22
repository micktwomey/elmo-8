module Elmo8.Display exposing (..)

{-| The display (the thing you look at)

Takes layers (pixels, sprites, etc) and renders them using WebGL.

-}

import Html
import Html.Attributes
import WebGL
import Window
import Elmo8.Layers.Common exposing (CanvasSize)
import Elmo8.Layers.Pixels
import Elmo8.Layers.Text
import Elmo8.Layers.Sprites

type alias Model =
    { windowSize : Window.Size
    , canvasSize: CanvasSize
    , pixels : Elmo8.Layers.Pixels.Model
    , text : Elmo8.Layers.Text.Model
    , sprites : Elmo8.Layers.Sprites.Model
    }

type Msg
    = PixelsMsg Elmo8.Layers.Pixels.Msg
    | TextMsg Elmo8.Layers.Text.Msg
    | SpritesMsg Elmo8.Layers.Sprites.Msg

clear : Model -> Model
clear model =
    { model
    | sprites = Elmo8.Layers.Sprites.clear model.sprites
    , text = Elmo8.Layers.Text.clear model.text
    }

setPixel : Model -> Int -> Int -> Int -> Model
setPixel model x y colour =
    { model | pixels = Elmo8.Layers.Pixels.setPixel model.pixels x y colour }

getPixel : Model -> Int -> Int -> Int
getPixel model x y =
    Elmo8.Layers.Pixels.getPixel model.pixels x y

sprite : Model -> { x: Int, y: Int, index: Int } -> Model
sprite model s =
    { model | sprites = Elmo8.Layers.Sprites.sprite model.sprites s }

pixelPalette : Model -> Int -> Int -> Model
pixelPalette model from to =
    { model | pixels = Elmo8.Layers.Pixels.pixelPalette model.pixels from to }

screenPalette : Model -> Int -> Int -> Model
screenPalette model from to =
    { model | pixels = Elmo8.Layers.Pixels.screenPalette model.pixels from to }

resetPalette : Model -> Model
resetPalette model =
    { model | pixels = Elmo8.Layers.Pixels.resetPalette model.pixels }

print : Model -> Int -> Int -> Int -> String -> Model
print model x y colour string =
    { model | text = Elmo8.Layers.Text.print model.text x y colour string }

init : String -> (Model, Cmd Msg)
init spritesUrl =
    let
        canvasSize = { width = 512.0, height = 512.0}
        (pixels, pixelsCmd) = Elmo8.Layers.Pixels.init canvasSize
        (text, textCmd) = Elmo8.Layers.Text.init canvasSize
        (sprites, spritesCmd) = Elmo8.Layers.Sprites.init canvasSize spritesUrl
    in
        { windowSize = { width = 0, height = 0 }
        , canvasSize = canvasSize
        , pixels = pixels
        , text = text
        , sprites = sprites
        }
        !
        [ Cmd.map PixelsMsg pixelsCmd
        , Cmd.map TextMsg textCmd
        , Cmd.map SpritesMsg spritesCmd
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        PixelsMsg pixelsMsg ->
            let
                (pixels, cmd) = Elmo8.Layers.Pixels.update pixelsMsg model.pixels
            in
                { model | pixels = pixels } ! [ Cmd.map PixelsMsg cmd ]
        TextMsg sms ->
            let
                (text, cmd) = Elmo8.Layers.Text.update sms model.text
            in
                { model | text = text } ! [ Cmd.map TextMsg cmd ]
        SpritesMsg spritesMsg ->
            let
                (sprites, cmd) = Elmo8.Layers.Sprites.update spritesMsg model.sprites
            in
                { model | sprites = sprites } ! [ Cmd.map SpritesMsg cmd ]

getRenderables : Model -> List WebGL.Renderable
getRenderables model =
    List.concat
    [
    -- TODO: Text disabled due to problems
    Elmo8.Layers.Text.render model.text,
    Elmo8.Layers.Pixels.render model.pixels
    , Elmo8.Layers.Sprites.render model.sprites
    ]

view : Model -> Html.Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc (WebGL.SrcAlpha, WebGL.OneMinusSrcAlpha)
        ]
        [ Html.Attributes.width (round model.canvasSize.width)
        , Html.Attributes.height (round model.canvasSize.height)
        , Html.Attributes.style
            [ ("display", "block")
            -- , ("margin-left", "auto")
            -- , ("margin-right", "auto")
            -- , ("border", "1px solid red")
            ]
        ]
        (getRenderables model)
