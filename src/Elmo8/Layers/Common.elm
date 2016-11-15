module Elmo8.Layers.Common exposing (..)

{-| Reusable bits between layers

-}

import Math.Vector2 exposing (Vec2)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)

-- Use the main site as a CDN for now
-- TODO: configure this at app startup, with sensible defaults
pico8FontUri : String
pico8FontUri = "http://elmo-8.twomeylee.name/assets/pico-8_regular_8.png"

pico8PaletteMapUri : String
pico8PaletteMapUri = "http://elmo-8.twomeylee.name/assets/pico-8-palette-map.png"


{-| Canvas size is the physical size of the canvas WebGL is rendering to

This is used to scale the pixel sizes correctly.

-}
type alias CanvasSize =
    { width : Float, height : Float }


type alias Vertex =
    { position : Vec2 }


{-| Create a 2D projection matrix.

0,0 is top left and 127,127 is bottom right. This matches up with the PICO-8.

-}
makeProjectionMatrix : Mat4
makeProjectionMatrix =
    makeOrtho2D 0.0 128.0 128.0 0.0
