module Elmo8.GL.Display exposing (..)

{-| WebGL display

-}

import Html
import Html.Attributes
import Math.Vector2 exposing (Vec2, vec2, getX, getY)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import WebGL

type alias Model =
    { screenSize : Vec2
    , resolution : Vec2
    , projectionMatrix : Mat4
    }

-- TODO: add subscription to window resize events
type Msg = Nothing

init : (Model, Cmd Msg)
init =
    { screenSize = vec2 512.0 512.0
    , resolution = vec2 128.0 128.0
    , projectionMatrix = makeOrtho2D 0.0 128.0 128.0 0.0
    }
    !
    []

view : Model -> List WebGL.Renderable -> Html.Html Msg
view model renderables =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc ( WebGL.SrcAlpha, WebGL.OneMinusSrcAlpha )
        ]
        [ Html.Attributes.width (getX model.screenSize |> round)
        , Html.Attributes.height (getY model.screenSize |> round)
        -- , Html.Attributes.style
        --     [ ( "display", "block" )
        --       -- , ("margin-left", "auto")
        --       -- , ("margin-right", "auto")
        --       -- , ("border", "1px solid red")
        --     ]
        ]
        renderables
