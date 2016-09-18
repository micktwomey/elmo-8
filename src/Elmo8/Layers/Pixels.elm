module Elmo8.Layers.Pixels exposing (..)

{-| Pixel layer, suitable for putpixel and getpixel operations

The most basic layer, theoretically all you need :)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Vector3 exposing (Vec3, vec3, fromTuple)
import WebGL

import Elmo8.Layers.Common exposing (LayerSize)
-- import Elmo8.Layers.Layer exposing (Layer)

type alias X = Int
type alias Y = Int

{-| An index into the palette, usually 0 - 15 for 16 colour palettes

-}
type alias PixelColour = Int

type alias Vertex = { position : Vec2 }

type alias Model =
    { pixels : Dict.Dict (X, Y) PixelColour
    }

type Msg 
    = SetPixel X Y PixelColour
    | GetPixel X Y
    | Clear PixelColour

init : (Model, Cmd Msg)
init =
    { pixels = Dict.singleton (20, 20) 10 } ! []

-- layer : Layer Model Msg 
-- layer =
--     Elmo8.Layers.Layer.layer 
--         { init = init
--         , render = render
--         }

render : LayerSize -> Model -> List WebGL.Renderable
render screenSize model =
    [ 
        WebGL.render
            pixelsVertexShader
            pixelsFragmentShader
            (getPixelPoints screenSize model.pixels)
            { screenSize = vec2 screenSize.width screenSize.height
            , colour = vec2 1.0 1.0
            }
    ]

getPixelPoints : LayerSize -> Dict.Dict (Int, Int) Int -> WebGL.Drawable Vertex
getPixelPoints size points =
    let
        toPoint : (Int, Int) -> Vertex
        toPoint (x, y) =
            Vertex 
                ( vec2 
                    ( (toFloat x) / size.width ) 
                    ( (toFloat y) / size.height )
                )
    in
        List.map toPoint (Dict.keys points)
            |> WebGL.Points

pixelsVertexShader : WebGL.Shader { attr | position : Vec2 } { unif | screenSize : Vec2 } { colour : Vec3 }
pixelsVertexShader = [glsl|
    attribute vec2 position;
    uniform vec2 screenSize;
    varying vec3 colour;
    void main () {
        gl_PointSize = 10.0;

        gl_Position = vec4(position, 0.0, 1.0);

        // TODO a lookup in the palette
        colour = vec3(0.5, 0.5, 0.0);
    }
|]

pixelsFragmentShader : WebGL.Shader {} { u | colour : Vec2 } { colour : Vec3 }
pixelsFragmentShader = [glsl|
    precision mediump float;
    varying vec3 colour;
    void main () {
        gl_FragColor = vec4(colour, 1.0);
    }
|]
