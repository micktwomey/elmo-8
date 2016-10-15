module Elmo8.Layers.Sprites exposing (..)

import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import Task
import WebGL
import Elmo8.Layers.Common exposing (CanvasSize, makeProjectionMatrix, Vertex)

type alias Model = 
    { maybeTexture : Maybe WebGL.Texture
    }

type Msg 
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error


init : String -> (Model, Cmd Msg)
init uri =
    { maybeTexture = Nothing
    } !
    [ WebGL.loadTexture uri |> Task.perform TextureError TextureLoad
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        TextureLoad texture ->
            {model | maybeTexture = Just texture } ! []
        TextureError _ ->
            Debug.crash "Error loading texture"


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
                { screenSize = vec2 canvasSize.width canvasSize.height
                , texture = texture
                , textureSize = vec2 (toFloat (fst (WebGL.textureSize texture))) (toFloat (snd (WebGL.textureSize texture))) 
                , projectionMatrix = makeProjectionMatrix
                }
            ]


{-| A square, intended for rendering maps, sprites, etc

-}
mesh : WebGL.Drawable Vertex
mesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 8 8), Vertex (vec2 8 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 8), Vertex (vec2 8 8) )
        ]

vertexShader : WebGL.Shader 
    {attr | position : Vec2} 
    {unif | screenSize : Vec2, projectionMatrix : Mat4 } 
    {texturePos : Vec2}
vertexShader = [glsl|
  attribute vec2 position;
  uniform vec2 screenSize;
  uniform mat4 projectionMatrix;
  varying vec2 texturePos;
  void main () {
    //vec2 clipSpace = position / screenSize * 2.0 - 1.0;
    //gl_Position = projectionMatrix * vec4(clipSpace.x, -clipSpace.y, 0, 1);
    //texturePos = position;
    //gl_Position = projectionMatrix * vec4(position, 0.0, 1.0);

    texturePos = position;
    gl_Position = projectionMatrix * vec4(position.x, position.y, 0.0, 1.0);
  }
|]


fragmentShader : WebGL.Shader 
    {} 
    {u | texture : WebGL.Texture, textureSize : Vec2, projectionMatrix : Mat4 } 
    {texturePos : Vec2}
fragmentShader = [glsl|
  precision highp float;
  uniform mat4 projectionMatrix;
  uniform sampler2D texture;
  uniform vec2 textureSize;
  varying vec2 texturePos;
  void main () {
    vec2 size = vec2(64.0, 64.0) / textureSize;
    //vec2 textureClipSpace = texturePos / textureSize * 1.0 - 1.0;
    vec2 textureClipSpace = (projectionMatrix * vec4(texturePos * size, 0, 1)).xy;
    vec4 temp = texture2D(texture, textureClipSpace);
    //float a = temp.a;
    //gl_FragColor = vec4(temp.r * a, temp.g * a, temp.b * a, a);
    gl_FragColor = temp + vec4(0.5, 0.5, 0.5, 1.0);
  }
|]
