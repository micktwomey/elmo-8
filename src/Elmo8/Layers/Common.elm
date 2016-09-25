module Elmo8.Layers.Common exposing (..)

{-| Reusable bits between layers

-}

{-| Canvas size is the physical size of the canvas WebGL is rendering to

This is used to scale the pixel sizes correctly.

-}
type alias CanvasSize = { width: Float, height: Float}
