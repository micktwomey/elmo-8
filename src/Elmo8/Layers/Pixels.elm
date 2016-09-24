module Elmo8.Layers.Pixels exposing (..)

{-| Pixel layer, suitable for putpixel and getpixel operations

The most basic layer, theoretically all you need :)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Vector3 exposing (Vec3, vec3, fromTuple)
import Math.Matrix4 exposing(Mat4, makeOrtho2D)
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

corners : Dict.Dict (X, Y) PixelColour
corners =
    Dict.fromList
        [ ( (0, 0), 0  )
        , ( (127, 0), 1 )
        , ( (127, 127), 2 )
        , ( (0, 127), 3 )
        , ( (0, 126), 4 )
        , ( (63, 63), 5 )
        ]

init : (Model, Cmd Msg)
init =
    -- { pixels = Dict.singleton (20, 20) 10 } ! []
    { pixels = corners } ! []

render : LayerSize -> Model -> List WebGL.Renderable
render screenSize model =
    [
        WebGL.render
            pixelsVertexShader
            pixelsFragmentShader
            (getPixelPoints model.pixels)
            { screenSize = vec2 screenSize.width screenSize.height
            , colour = vec2 1.0 1.0
            , projectionMatrix = makeOrtho2D (0.0 - 0.5) (127.0 + 0.5) (0.0 - 0.5) (127.0 + 0.5)
            }
    ]

getPixelPoints : Dict.Dict (Int, Int) Int -> WebGL.Drawable Vertex
getPixelPoints points =
    let
        toPoint : (Int, Int) -> Vertex
        toPoint (x, y) =
            Vertex
                ( vec2
                    (toFloat x)
                    (toFloat y)
                )
    in
        List.map toPoint (Dict.keys points)
            |> WebGL.Points

pixelsVertexShader : WebGL.Shader { attr | position : Vec2 } { unif | screenSize : Vec2, projectionMatrix : Mat4 } { colour : Vec3 }
pixelsVertexShader = [glsl|
    attribute vec2 position;
    uniform vec2 screenSize;
    uniform mat4 projectionMatrix;
    varying vec3 colour;
    void main () {
        gl_PointSize = 512.0 / screenSize.x;

        gl_Position = projectionMatrix * vec4(position, 0.0, 1.0);

        // TODO a lookup in the palette
        colour = vec3(0.0, 0.5, 1.0);
    }
|]

pixelsFragmentShader : WebGL.Shader {} { u | colour : Vec2 } { colour : Vec3 }
pixelsFragmentShader = [glsl|
    precision highp float;
    varying vec3 colour;
    void main () {
        gl_FragColor = vec4(colour, 1.0);
    }
|]
