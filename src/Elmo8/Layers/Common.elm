module Elmo8.Layers.Common exposing (..)

{-| Reusable bits between layers

-}

import Math.Vector2 exposing (Vec2)
import Math.Matrix4 exposing(Mat4, makeOrtho2D, translate3)

{-| Canvas size is the physical size of the canvas WebGL is rendering to

This is used to scale the pixel sizes correctly.

-}
type alias CanvasSize = { width: Float, height: Float}

type alias Vertex = { position : Vec2 }

minX : Float
minX = 0.0

maxX : Float
maxX = 128.0

minY : Float
minY = 0.0

maxY : Float
maxY = 128.0

scale : Float
scale = 1.0

{-| Create a 2D projection matrix.

0,0 is top left and 127,127 is bottom right. This matches up with the PICO-8.

-}
makeProjectionMatrix : Mat4
makeProjectionMatrix =
    makeOrtho2D
        (minX * scale)
        (maxX * scale)
        (maxX * scale)
        (minX * scale)
        -- |> translate3 0.375 0.375 0