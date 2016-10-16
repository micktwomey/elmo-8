module Elmo8.Layers.Pixels exposing (..)

{-| Pixel layer, suitable for putpixel and getpixel operations

The most basic layer, theoretically all you need :)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Vector3 exposing (Vec3, vec3, fromTuple)
import Math.Matrix4 exposing(Mat4, makeOrtho2D)
import Task
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
    , maybePalette : Maybe WebGL.Texture
    }

type Msg
    = SetPixel X Y PixelColour
    | TextureError WebGL.Error
    | TextureLoad WebGL.Texture
    | Clear

-- x, y, colour index
type alias Vertex = { position : Vec3 }

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
    , maybePalette = Nothing
    } 
    ! 
    [ WebGL.loadTexture "/pico-8-palette.png" |> Task.perform TextureError TextureLoad
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetPixel x y colour ->
            { model | pixels = Dict.insert (x, y) colour model.pixels } ! []
        Clear ->
            { model | pixels = Dict.empty } ! []
        TextureError error ->
            Debug.crash "Too lazy to handle texture error"
        TextureLoad texture ->
            { model | maybePalette = Just texture } ! []

render : CanvasSize -> Model -> List WebGL.Renderable
render canvasSize model =
    case model.maybePalette of
        Nothing -> []
        Just texture ->
            [
                WebGL.render
                    pixelsVertexShader
                    pixelsFragmentShader
                    (getPixelPoints model.pixels)
                    { canvasSize = vec2 canvasSize.width canvasSize.height
                    , screenSize = vec2 model.screenSize.width model.screenSize.height
                    , projectionMatrix = makeProjectionMatrix
                    , paletteTexture = texture
                    -- , paletteTextureSize = vec2 (toFloat (fst (WebGL.textureSize texture))) (toFloat (snd (WebGL.textureSize texture)))
                    , paletteWidth = 16.0
                    }
            ]

getPixelPoints : Dict.Dict (Int, Int) Int -> WebGL.Drawable Vertex
getPixelPoints points =
    let
        toPoint : ((Int, Int), Int) -> Vertex
        toPoint ((x, y), colourIndex) =
            Vertex
                ( vec3
                    (toFloat x)
                    (toFloat y)
                    (toFloat colourIndex)
                )
    in
        List.map toPoint (Dict.toList points)
            |> WebGL.Points

pixelsVertexShader : WebGL.Shader { attr | position : Vec3 } { unif | canvasSize : Vec2, screenSize : Vec2, projectionMatrix : Mat4 } { colourIndex : Float }
pixelsVertexShader = [glsl|
    precision mediump float;
    attribute vec3 position;
    uniform vec2 canvasSize;
    uniform vec2 screenSize;
    uniform mat4 projectionMatrix;
    varying float colourIndex;
    void main () {
        gl_PointSize = canvasSize.x / screenSize.x;

        gl_Position = projectionMatrix * vec4(position.x + 0.5, position.y + 0.5, 0.0, 1.0);

        colourIndex = position.z;
    }
|]

pixelsFragmentShader : WebGL.Shader {} { uniform | paletteTexture : WebGL.Texture , paletteWidth : Float } { colourIndex : Float }
pixelsFragmentShader = [glsl|
    precision mediump float;
    uniform sampler2D paletteTexture;
    uniform float paletteWidth;
    varying float colourIndex;
    void main () {
        // float index = (colourIndex / (paletteWidth * 2.0)) - 1.0;
        float index = colourIndex / paletteWidth;
        gl_FragColor = texture2D(paletteTexture, vec2(index, 0.0));
    }
|]
