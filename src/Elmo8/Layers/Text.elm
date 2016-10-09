module Elmo8.Layers.Text exposing (..)

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
-- import Math.Vector3 exposing (Vec3, vec3)
import Math.Vector4 exposing (Vec4, vec4)
import Math.Matrix4 exposing(Mat4, makeOrtho2D)
import Task
import WebGL

import Elmo8.Layers.Common exposing (CanvasSize, Vertex, makeProjectionMatrix)

-- <Char width="8" offset="0 0" rect="79 12 6 10" code="A"/>
type alias Character =
    { x : Int
    , y : Int
    , width : Int
    , height : Int
    }

type alias Model =
    { maybeTexture : Maybe WebGL.Texture
    }

type Msg
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error

init : (Model, Cmd Msg)
init =
    { maybeTexture = Nothing
    }
    !
    [ WebGL.loadTexture "/font/pico-8_regular_8.PNG" |> Task.perform TextureError TextureLoad
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        TextureError error ->
            model ! []
        TextureLoad texture ->
            { model | maybeTexture = Just texture } ! []

render : CanvasSize -> Model -> List WebGL.Renderable
render canvasSize model =
    case model.maybeTexture of
        Nothing -> []
        Just texture ->
            [
                WebGL.render
                    vertexShader
                    fragmentShader
                    mesh
                    { projectionMatrix = makeProjectionMatrix
                    , colour = vec4 1.0 1.0 1.0 1.0
                    , charCoords = vec4 64 23 6 10
                    , texSize = 128.0
                    , offset = vec2 0 0
                    -- , positio = vec2 1.0 1.0
                    , fontTexture = texture
                    }
            ]


{-| A square, intended for rendering maps, sprites, etc

-}
mesh : WebGL.Drawable Vertex
mesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 1 1), Vertex (vec2 1 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 1), Vertex (vec2 1 1) )
        ]

-- https://github.com/w0rm/elm-webgl-playground/blob/master/Animation2D.elm
-- http://stackoverflow.com/questions/22080881/how-to-render-text-in-modern-opengl-with-glsl
vertexShader : WebGL.Shader
    { attr | position : Vec2 }
    { uniform
        | projectionMatrix : Mat4
        , charCoords : Vec4
        , texSize : Float
        , offset : Vec2
    }
    { tc : Vec2 }
vertexShader = [glsl|
    precision highp float;

    uniform mat4 projectionMatrix;        // The projection-view-model matrix
    uniform vec4 charCoords;    // The CharCoord struct for the character you are rendering, {x, y, w, h}
    uniform float texSize;      // The size of the texture which contains the rasterized characters (assuming it is square)
    uniform vec2 offset;        // The offset at which to paint, w.r.t the first character

    attribute vec2 position;

    varying vec2 tc;

    void main(){
        tc = (charCoords.xy + charCoords.zw * vec2(position.x, 1. - position.y)) / texSize;

        // Map the vertices of the unit square to a rectangle with correct aspect ratio and positioned at the correct offset
        float x = (charCoords[2] * position.x + offset.x) / charCoords[3];
        float y = position.y + offset.y / charCoords[3];

        // Apply the model, view and projection transformations
        gl_Position = projectionMatrix * vec4(x, y, 0., 1.);
    }
|]

fragmentShader : WebGL.Shader
    {}
    { uniform | colour : Vec4, fontTexture : WebGL.Texture }
    { tc : Vec2 }
fragmentShader = [glsl|
    precision highp float;

    uniform vec4 colour;
    uniform sampler2D fontTexture;

    varying vec2 tc;

    void main() {
        gl_FragColor = colour * texture2D(fontTexture, tc);
    }
|]

-- https://github.com/andryblack/fontbuilder
-- grep Char fonts/pico-8_regular_8.xml | awk -F'"' '{print ", (\'"$8"\', Character "$6, ")"}' | pbcopy
fontList : List (Char, Character)
fontList = 
    [ (' ', Character 1 11 0 0 )
    , ('!', Character 2 1 2 10 )
    , ('"', Character 5 1 6 4 )
    , ('#', Character 12 1 6 10 )
    , ('$', Character 19 1 6 10 )
    , ('%', Character 26 1 6 10 )
    , ('&', Character 33 1 6 10 )
    , ('\'', Character 40 1 4 4 )
    , ('(', Character 45 1 4 10 )
    , (')', Character 50 1 4 10 )
    , ('*', Character 55 1 6 10 )
    , ('+', Character 62 3 6 6 )
    , (',', Character 69 7 4 4 )
    , ('-', Character 74 5 6 2 )
    , ('.', Character 81 9 2 2 )
    , ('/', Character 84 1 6 10 )
    , ('0', Character 91 1 6 10 )
    , ('1', Character 98 1 6 10 )
    , ('2', Character 105 1 6 10 )
    , ('3', Character 112 1 6 10 )
    , ('4', Character 119 1 6 10 )
    , ('5', Character 1 12 6 10 )
    , ('6', Character 8 12 6 10 )
    , ('7', Character 15 12 6 10 )
    , ('8', Character 22 12 6 10 )
    , ('9', Character 29 12 6 10 )
    , (':', Character 36 14 2 6 )
    , (';', Character 39 14 4 8 )
    , ('<', Character 44 12 6 10 )
    , ('=', Character 51 14 6 6 )
    , ('>', Character 58 12 6 10 )
    , ('?', Character 65 12 6 10 )
    , ('@', Character 72 12 6 10 )
    , ('A', Character 79 12 6 10 )
    , ('B', Character 86 12 6 10 )
    , ('C', Character 93 12 6 10 )
    , ('D', Character 100 12 6 10 )
    , ('E', Character 107 12 6 10 )
    , ('F', Character 114 12 6 10 )
    , ('G', Character 1 23 6 10 )
    , ('H', Character 8 23 6 10 )
    , ('I', Character 15 23 6 10 )
    , ('J', Character 22 23 6 10 )
    , ('K', Character 29 23 6 10 )
    , ('L', Character 36 23 6 10 )
    , ('M', Character 43 23 6 10 )
    , ('N', Character 50 23 6 10 )
    , ('O', Character 57 23 6 10 )
    , ('P', Character 64 23 6 10 )
    , ('Q', Character 71 23 6 10 )
    , ('R', Character 78 23 6 10 )
    , ('S', Character 85 23 6 10 )
    , ('T', Character 92 23 6 10 )
    , ('U', Character 99 23 6 10 )
    , ('V', Character 106 23 6 10 )
    , ('W', Character 113 23 6 10 )
    , ('X', Character 120 23 6 10 )
    , ('Y', Character 1 34 6 10 )
    , ('Z', Character 8 34 6 10 )
    , ('[', Character 15 34 4 10 )
    , ('\\', Character 20 34 6 10 )
    , (']', Character 27 34 4 10 )
    , ('^', Character 32 34 6 4 )
    , ('_', Character 39 42 6 2 )
    , ('`', Character 46 34 4 4 )
    , ('a', Character 51 36 6 8 )
    , ('b', Character 58 36 6 8 )
    , ('c', Character 65 36 6 8 )
    , ('d', Character 72 36 6 8 )
    , ('e', Character 79 36 6 8 )
    , ('f', Character 86 36 6 8 )
    , ('g', Character 93 36 6 8 )
    , ('h', Character 100 36 6 8 )
    , ('i', Character 107 36 6 8 )
    , ('j', Character 114 36 6 8 )
    , ('k', Character 1 47 6 8 )
    , ('l', Character 8 47 6 8 )
    , ('m', Character 15 47 6 8 )
    , ('n', Character 22 47 6 8 )
    , ('o', Character 29 47 6 8 )
    , ('p', Character 36 47 6 8 )
    , ('q', Character 43 47 6 8 )
    , ('r', Character 50 47 6 8 )
    , ('s', Character 57 47 6 8 )
    , ('t', Character 64 47 6 8 )
    , ('u', Character 71 47 6 8 )
    , ('v', Character 78 47 6 8 )
    , ('w', Character 85 47 6 8 )
    , ('x', Character 92 47 6 8 )
    , ('y', Character 99 47 6 8 )
    , ('z', Character 106 47 6 8 )
    , ('{', Character 113 45 6 10 )
    , ('|', Character 120 45 2 10 )
    , ('}', Character 1 56 6 10 )
    , ('~', Character 8 58 6 6 )
    -- Exciting magical bonus characters :)
    , ('À', Character 15 56 14 10 )
    , ('Á', Character 30 56 14 10 )
    , ('Â', Character 45 56 14 10 )
    , ('Ã', Character 60 56 14 10 )
    , ('Ä', Character 75 56 14 10 )
    , ('Å', Character 90 56 10 10 )
    , ('Æ', Character 101 56 10 10 )
    , ('Ç', Character 112 56 10 10 )
    , ('È', Character 1 67 14 10 )
    , ('É', Character 16 67 10 10 )
    , ('Ê', Character 27 67 14 10 )
    , ('Ë', Character 42 67 14 10 )
    , ('Ì', Character 57 67 14 10 )
    , ('Í', Character 72 67 10 10 )
    , ('Î', Character 83 67 14 10 )
    , ('Ï', Character 98 67 10 10 )
    , ('Ð', Character 109 71 14 2 )
    , ('Ñ', Character 1 78 14 10 )
    , ('Ò', Character 16 78 14 10 )
    , ('Ó', Character 31 78 10 10 )
    , ('Ô', Character 42 78 14 10 )
    , ('Õ', Character 57 80 14 6 )
    , ('Ö', Character 72 80 14 6 )
    , ('×', Character 87 78 14 10 )
    , ('Ø', Character 102 78 14 10 )
    , ('Ù', Character 1 89 14 10 )
    ]

fontMap : Dict.Dict Char Character
fontMap =
    Dict.fromList fontList
