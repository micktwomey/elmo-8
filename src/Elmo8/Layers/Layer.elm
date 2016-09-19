module Elmo8.Layers.Layer exposing (..)

import WebGL

import Elmo8.Layers.Common exposing (LayerSize)

import Elmo8.Layers.Pixels

type Layer =
    PixelsLayer Elmo8.Layers.Pixels.Model

type Msg =
    PixelMsg Elmo8.Layers.Pixels.Msg

renderLayer : Layer -> LayerSize -> List WebGL.Renderable
renderLayer layer size =
    case layer of
        PixelsLayer pixels ->
            Elmo8.Layers.Pixels.render size pixels

createDefaultLayers : List (Layer, Cmd Msg)
createDefaultLayers =
    let
        (pix, pixmsgs) = Elmo8.Layers.Pixels.init
    in
    [ (PixelsLayer pix, Cmd.map PixelMsg pixmsgs)
    ]

updateLayers : Msg -> List Layer -> (List Layer, Cmd Msg)
updateLayers msg layers =
    layers ! []
