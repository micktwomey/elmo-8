module Elmo8.Display exposing (..)

{-| The display (the thing you look at)

Takes layers (pixels, sprites, etc) and renders them using WebGL.

-}

import Html
import Html.Attributes
import WebGL
import Window
import Elmo8.Layers.Common exposing (LayerSize)
import Elmo8.Layers.Layer exposing (Layer, renderLayer, createDefaultLayers)

type alias Model =
    { windowSize : Window.Size
    , layerSize: LayerSize
    , layers : List Layer
    }

type Msg = LayerMsg Elmo8.Layers.Layer.Msg

init : List (Layer, Cmd Elmo8.Layers.Layer.Msg) -> (Model, Cmd Msg)
init layersWithMsgs =
    let
        layerMessages = List.map (\(_, msg) -> Cmd.map LayerMsg msg) layersWithMsgs
        layers = List.map (\(l, _) -> l) layersWithMsgs
    in
        { windowSize = { width = 128, height = 128 }
        , layerSize = { width = 128.0, height = 128.0}
        , layers = layers
        } ! layerMessages

initWithDefaultLayers : (Model, Cmd Msg)
initWithDefaultLayers =
    init createDefaultLayers

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LayerMsg layerMessage ->
            let
                (layers, msg) = Elmo8.Layers.Layer.updateLayers layerMessage model.layers
            in
                { model | layers = layers } ! [ Cmd.map LayerMsg msg ]

getRenderables : Model -> List WebGL.Renderable
getRenderables model =
    let
        render : Model -> Layer -> List WebGL.Renderable
        render model layer = renderLayer layer model.layerSize

    in
        List.map (\l -> render model l) model.layers
            |> List.concat

view : Model -> Html.Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc (WebGL.One, WebGL.OneMinusSrcAlpha)
        ]
        -- [ Html.Attributes.width model.windowSize.width
        -- , Html.Attributes.height model.windowSize.width
        [ Html.Attributes.width 512
        , Html.Attributes.height 512
        , Html.Attributes.style [ ("display", "block"), ("border", "1px solid red") ]
        ]
        (getRenderables model)
