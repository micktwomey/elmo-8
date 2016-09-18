module Elmo8.Layers.Layer exposing (..)

import WebGL

{-| Screen size as a float (easier to deal with in WebGL, less conversion)
-}
type alias LayerSize = { width: Float, height: Float}


-- type Layer model msg = 
--     Layer 
--         { model 
--         | render : LayerSize -> List WebGL.Renderable
--         , init : Cmd msg
--         }

-- layer :
--     { model
--     | init : Cmd msg
--     , render : LayerSize -> List WebGL.Renderable 
--     } 
--     -> Layer model msg
-- layer {init, render} =
--     Layer
--         { init = init
--         , render = render
--         }


type Layer model msg = 
    Layer 
        { render : LayerSize -> model -> List WebGL.Renderable
        , init : (model, Cmd msg)
        }

layer :
    { init : (model, Cmd msg)
    , render : LayerSize -> model -> List WebGL.Renderable 
    } 
    -> Layer model msg
layer {init, render} =
    Layer
        { init = init
        , render = render
        }

-- renderLayer : LayerSize -> {render : LayerSize -> a -> List WebGL.Renderable} -> a -> List WebGL.Renderable
-- renderLayer size {render} model =
--     render size model

renderLayer : Layer model msg -> LayerSize -> List WebGL.Renderable
renderLayer layer size =
    -- layer.render size
    []

-- render : ScreenSize -> Layer l -> List WebGL.Renderable
-- render size l =
--     l.render size
