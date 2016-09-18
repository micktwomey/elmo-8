module Elmo8.Layers.Layer exposing (..)

import WebGL

import Elmo8.Layers.Common exposing (LayerSize)

import Elmo8.Layers.Pixels

type Layer = 
    PixelsLayer Elmo8.Layers.Pixels.Model

renderLayer : Layer -> LayerSize -> List WebGL.Renderable
renderLayer layer size =
    case layer of
        PixelsLayer pixels ->
            Elmo8.Layers.Pixels.render size pixels


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


-- type Layer model msg = 
--     Layer 
--         { render : LayerSize -> model -> List WebGL.Renderable
--         , init : (model, Cmd msg)
--         }

-- layer :
--     { init : (model, Cmd msg)
--     , render : LayerSize -> model -> List WebGL.Renderable 
--     } 
--     -> Layer model msg
-- layer {init, render} =
--     Layer
--         { init = init
--         , render = render
--         }

-- renderLayer : LayerSize -> {render : LayerSize -> a -> List WebGL.Renderable} -> a -> List WebGL.Renderable
-- renderLayer size {render} model =
--     render size model

-- renderLayer : Layer model msg -> LayerSize -> List WebGL.Renderable
-- renderLayer layer size =
--     -- layer.render size
--     []

-- render : ScreenSize -> Layer l -> List WebGL.Renderable
-- render size l =
--     l.render size
