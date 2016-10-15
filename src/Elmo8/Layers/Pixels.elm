module Elmo8.Layers.Pixels exposing (..)

{-| Pixel layer, suitable for putpixel and getpixel operations

The most basic layer, theoretically all you need :)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Vector3 exposing (Vec3, vec3, fromTuple)
import Math.Matrix4 exposing(Mat4, makeOrtho2D)
import WebGL

import Elmo8.Layers.Common exposing (CanvasSize, Vertex, makeProjectionMatrix)
-- import Elmo8.Layers.Layer exposing (Layer)

type alias X = Int
type alias Y = Int

{-| An index into the palette, usually 0 - 15 for 16 colour palettes

-}
type alias PixelColour = Int

type alias Model =
    { pixels : Dict.Dict (X, Y) PixelColour
    , screenSize : { width : Float, height : Float }
    }

type Msg
    = SetPixel X Y PixelColour
    | Clear


setPixel : Model -> Int -> Int -> PixelColour -> Model
setPixel model x y colour =
    { model | pixels = Dict.insert (x, y) colour model.pixels }

getPixel : Model -> Int -> Int -> PixelColour
getPixel model x y =
    Dict.get (x, y) model.pixels
        |> Maybe.withDefault 0

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
    { pixels = Dict.empty
    , screenSize = { width = 128.0, height = 128.0 }
    } ! []

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetPixel x y colour ->
            { model | pixels = Dict.insert (x, y) colour model.pixels } ! []
        Clear ->
            { model | pixels = Dict.empty } ! []

render : CanvasSize -> Model -> List WebGL.Renderable
render canvasSize model =
    [
        WebGL.render
            pixelsVertexShader
            pixelsFragmentShader
            (getPixelPoints model.pixels)
            { canvasSize = vec2 canvasSize.width canvasSize.height
            , screenSize = vec2 model.screenSize.width model.screenSize.height
            , projectionMatrix = makeProjectionMatrix
            , colour = vec2 1.0 1.0
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

pixelsVertexShader : WebGL.Shader { attr | position : Vec2 } { unif | canvasSize : Vec2, screenSize : Vec2, projectionMatrix : Mat4 } { colour : Vec3 }
pixelsVertexShader = [glsl|
    attribute vec2 position;
    uniform vec2 canvasSize;
    uniform vec2 screenSize;
    uniform mat4 projectionMatrix;
    varying vec3 colour;
    void main () {
        gl_PointSize = canvasSize.x / screenSize.x;

        gl_Position = projectionMatrix * vec4(position.x + 0.5, position.y + 0.5, 0.0, 1.0);

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
