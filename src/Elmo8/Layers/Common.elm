module Elmo8.Layers.Common exposing (..)

{-| Reusable bits between layers

-}

{-| Screen size as a float (easier to deal with in WebGL, less conversion)
-}
type alias LayerSize = { width: Float, height: Float}
