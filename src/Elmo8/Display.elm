module Elmo8.Display exposing (..)

import Dict
import Html
import Html.App
import Html.Attributes
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Vector3 exposing (Vec3, vec3, fromTuple)
import WebGL
import Window
import Task
import Color

{-| The display (the thing you look at)

Sources and references:
- https://github.com/w0rm/elm-mogee
- https://github.com/zalando/elm-street-404/
- http://blog.tojicode.com/2012/07/sprite-tile-maps-on-gpu.html
- https://github.com/mattdesl/lwjgl-basics/wiki/Display
- https://github.com/w0rm/elm-webgl-playground/

Currently this looks like it will render in the following layers:

1. Render any putpixel stuff as points on the top layer
2. Render the sprites
3. Render the background

-}

type alias Model = 
    { size : Window.Size
    , maybeTexture : Maybe WebGL.Texture
    , pixels: Dict.Dict (Int, Int) Int  -- map (X, y) to pixel value, this is a sparse canvas
    }

type alias Vertex =
    { position : Vec2 }

type Msg 
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error


init : (Model, Cmd Msg)
init =
    -- let
    --     makeEmptyPixels : Int -> Int -> Int -> List Int
    --     makeEmptyPixels colour width height =
    --         List.repeat (height * width) 0 
    -- in
    { size = { width = 320, height = 240}
    , maybeTexture = Nothing
    , pixels = Dict.singleton (20, 20) 10
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

getRenderables : Model -> List WebGL.Renderable
getRenderables model =
    let
        textureRenderables = case model.maybeTexture of
            Just texture -> [ (render model.size texture) ] 
            Nothing -> [] 
    in
        List.concat 
            [ [ renderPixels model ] 
            , textureRenderables
            ]


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
        (getRenderables model)

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

getPixelPoints : Window.Size -> Dict.Dict (Int, Int) Int -> WebGL.Drawable Vertex
getPixelPoints size points =
    let
        toPoint : (Int, Int) -> Vertex
        toPoint (x, y) =
            Vertex 
                ( vec2 
                    ( (toFloat x) / (toFloat size.width) ) 
                    ( (toFloat y) / (toFloat size.height) )
                )
    in
        List.map toPoint (Dict.keys points)
            |> WebGL.Points  

renderPixels : Model -> WebGL.Renderable
renderPixels model =
    WebGL.render
        pixelsVertexShader
        pixelsFragmentShader
        (getPixelPoints model.size model.pixels)
        { screenSize = vec2 (toFloat model.size.width) (toFloat model.size.height)
        , colour = vec2 1.0 1.0
        }

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
