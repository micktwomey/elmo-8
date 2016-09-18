module Elmo8.Display exposing (..)

{-| The display (the thing you look at)

Takes layers (pixels, sprites, etc) and renders them using WebGL.

-}

import Html
import Html.Attributes
import WebGL
import Window
import Elmo8.Layers.Common exposing (LayerSize)
import Elmo8.Layers.Layer exposing (Layer, renderLayer)

type alias Model = 
    { windowSize : Window.Size
    , layerSize: LayerSize
    , layers : List Layer
    }

type Msg = Nothing

init : List Layer -> (Model, Cmd Msg)
init layers =
    { windowSize = { width = 320, height = 240} 
    , layerSize = { width = 320.0, height = 240.0}
    , layers = layers
    } ! []

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    model ! []

getRenderables : Model -> List WebGL.Renderable
getRenderables model =
    let
        render : Model -> Layer -> List WebGL.Renderable
        render model layer = renderLayer layer model.layerSize
        
    in  
        List.map (\l -> render model l) model.layers
            |> List.concat
    -- let
    --     textureRenderables = case model.maybeTexture of
    --         Just texture -> [ (render model.size texture) ] 
    --         Nothing -> [] 
    -- in
    --     List.concat 
    --         [ [ renderPixels model ] 
    --         , textureRenderables
    --         ]


view : Model -> Html.Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc (WebGL.One, WebGL.OneMinusSrcAlpha)
        ]
        [ Html.Attributes.width model.windowSize.width
        , Html.Attributes.height model.windowSize.width
        , Html.Attributes.style [ ("display", "block"), ("border", "1px solid red") ]
        ]
        (getRenderables model)

-- main : Program Never
-- main =
--   Html.App.program
--     { init = init
--     , subscriptions = \_ -> Sub.none
--     , update = update
--     , view = view
--     }
