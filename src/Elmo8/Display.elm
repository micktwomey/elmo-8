module Elmo8.Display exposing (..)

import Html
import Html.App
import Html.Attributes
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import WebGL
import Window
import Task

{-| The display (the thing you look at)

Sources and references:
- https://github.com/w0rm/elm-mogee
- https://github.com/zalando/elm-street-404/
- http://blog.tojicode.com/2012/07/sprite-tile-maps-on-gpu.html
- https://github.com/mattdesl/lwjgl-basics/wiki/Display
- https://github.com/w0rm/elm-webgl-playground/

-}

type alias Model = 
    { size : Window.Size
    , maybeTexture : Maybe WebGL.Texture
    }

type alias Vertex =
    { position : Vec2 }

type Msg 
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error


init : (Model, Cmd Msg)
init =
    { size = { width = 320, height = 240}
    , maybeTexture = Nothing
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
        

view : Model -> Html.Html Msg
view model =
    WebGL.toHtmlWith
        [ WebGL.Enable WebGL.Blend
        , WebGL.BlendFunc (WebGL.One, WebGL.OneMinusSrcAlpha)
        ]
        [ Html.Attributes.width model.size.width
        , Html.Attributes.height model.size.width
        , Html.Attributes.style [ ("display", "block"), ("border", "1px solid red") ]
        ]
        ( case model.maybeTexture of
            Just texture -> [render model.size texture]
            Nothing -> []
        )

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
    gl_FragColor = texture2D(texture, texturePos);
  }
|]


-- tileMapVertextShader : WebGL.Shader {} {} {}
-- tileMapVertextShader = [glsl|
--     precision mediump float;
--     attribute vec2 position;
--     attribute vec2 texture;

--     varying vec2 pixelCoord;
--     varying vec2 texCoord;

--     uniform vec2 viewOffset;
--     uniform vec2 viewportSize;
--     uniform vec2 inverseTileTextureSize;
--     uniform float inverseTileSize;

--     void main(void) {
--         pixelCoord = (texture * viewportSize) + viewOffset;
--         texCoord = pixelCoord * inverseTileTextureSize * inverseTileSize;
--         gl_Position = vec4(position, 0.0, 1.0);
--     }
-- |]


main : Program Never
main =
  Html.App.program
    { init = init
    , subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    }
