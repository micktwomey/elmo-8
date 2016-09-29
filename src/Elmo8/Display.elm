module Elmo8.Display exposing (..)

{-| The display (the thing you look at)

Takes layers (pixels, sprites, etc) and renders them using WebGL.

-}

import Html
import Html.Attributes
import WebGL
import Window
import Elmo8.Layers.Common exposing (CanvasSize)
-- import Elmo8.Layers.Layer exposing (Layer, renderLayer, createDefaultLayers)
import Elmo8.Layers.Pixels
import Elmo8.Layers.Text

type alias Model =
    { windowSize : Window.Size
    , canvasSize: CanvasSize
    , pixels : Elmo8.Layers.Pixels.Model
    , text : Elmo8.Layers.Text.Model
    }

type Msg
    = PixelsMsg Elmo8.Layers.Pixels.Msg
    | TextMsg Elmo8.Layers.Text.Msg

setPixel : Model -> Int -> Int -> Int -> Model
setPixel model x y colour =
    { model | pixels = Elmo8.Layers.Pixels.setPixel model.pixels x y colour }

getPixel : Model -> Int -> Int -> Int
getPixel model x y =
    Elmo8.Layers.Pixels.getPixel model.pixels x y

init : (Model, Cmd Msg)
init =
    let
        (pixels, pixelsCmd) = Elmo8.Layers.Pixels.init
        (text, textCmd) = Elmo8.Layers.Text.init
    in
        { windowSize = { width = 0, height = 0 }
        , canvasSize = { width = 512.0, height = 512.0}
        , pixels = pixels
        , text = text
        }
        !
        [ Cmd.map PixelsMsg pixelsCmd
        , Cmd.map TextMsg textCmd
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

getRenderables : Model -> List WebGL.Renderable
getRenderables model =
    List.concat
    [ Elmo8.Layers.Text.render model.canvasSize model.text
    , Elmo8.Layers.Pixels.render model.canvasSize model.pixels
    ]

view : Model -> Html.Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc (WebGL.One, WebGL.OneMinusSrcAlpha)
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
