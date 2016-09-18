module Elmo8.Layers.Sprites exposing (..)

import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Task
import WebGL
import Window

type alias Vertex = { position : Vec2 }

type alias Model = 
    { maybeTexture : Maybe WebGL.Texture
    }

type Msg 
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error


init : (Model, Cmd Msg)
init =
    { maybeTexture = Nothing
    } !
    [ WebGL.loadTexture "/texture.png" |> Task.perform TextureError TextureLoad
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        TextureLoad texture ->
            {model | maybeTexture = Just texture } ! []
        TextureError _ ->
            Debug.crash "Error loading texture"


render : Window.Size -> WebGL.Texture -> WebGL.Renderable
render size texture =
    WebGL.render
        vertexShader
        fragmentShader
        mesh
        { screenSize = vec2 (toFloat size.width) (toFloat size.height)
        , texture = texture
        , textureSize = vec2 (toFloat (fst (WebGL.textureSize texture))) (toFloat (snd (WebGL.textureSize texture))) 
        }


{-| A square, intended for rendering maps, sprites, etc

-}
mesh : WebGL.Drawable Vertex
mesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 1 1), Vertex (vec2 1 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 1), Vertex (vec2 1 1) )
        ]

vertexShader : WebGL.Shader {attr | position : Vec2} {unif | screenSize : Vec2 } {texturePos : Vec2}
vertexShader = [glsl|
  attribute vec2 position;
  uniform vec2 screenSize;
  varying vec2 texturePos;
  void main () {
    texturePos = position;
    gl_Position = vec4(position, 0.0, 1.0);
  }
|]


fragmentShader : WebGL.Shader {} {u | texture : WebGL.Texture, textureSize : Vec2 } {texturePos : Vec2}
fragmentShader = [glsl|
  precision mediump float;
  uniform sampler2D texture;
  uniform vec2 textureSize;
  varying vec2 texturePos;
  void main () {
    //gl_FragColor = texture2D(texture, texturePos);
    // Fake a lookup :)
    // TODO (blows buffers) figure out how to do a lookup (mapping to an array + a palette texture?)
    // TODO explore using WebGL.Points for pixels (since it's a small amount we can get away with it)
    // TODO (ugh) explore generating a png or if there's a raw/bmp option
    // TODO (requires js) explore using a canvas -> texture (some JS?)
    // TODO consider creating 128*128 renderables, each a single point ;)
    if ( texturePos.x < 0.5 ) {
        gl_FragColor = vec4(0.5, 0.5, 1.0, 1.0);
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
  }
|]
