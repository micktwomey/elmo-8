module Elmo8.Layers.Common exposing (..)

{-| Reusable bits between layers

-}

import Math.Vector2 exposing (Vec2)
import Math.Matrix4 exposing(Mat4, makeOrtho2D)

{-| Canvas size is the physical size of the canvas WebGL is rendering to

This is used to scale the pixel sizes correctly.

-}
type alias CanvasSize = { width: Float, height: Float}

type alias Vertex = { position : Vec2 }

minX : Float
minX = 0.0

maxX : Float
maxX = 127.0

minY : Float
minY = 0.0

maxY : Float
maxY = 127.0

pixelSizeScaling : Float
pixelSizeScaling = 0.5

makeProjectionMatrix : Mat4
makeProjectionMatrix =
    makeOrtho2D
        (minX - pixelSizeScaling)
        (maxX + pixelSizeScaling)
        (minX - pixelSizeScaling)
        (maxX + pixelSizeScaling)
