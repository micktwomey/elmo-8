module Elmo8.Layers.Pixels exposing (..)

{-| Pixel layer, suitable for putpixel and getpixel operations

The most basic layer, theoretically all you need :)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Vector3 exposing (Vec3, vec3, fromTuple)
import Math.Vector4 exposing (Vec4, vec4)
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
    , pixelPalette : Dict.Dict PixelColour PixelColour
    , screenPalette : Dict.Dict PixelColour PixelColour
    }

type Msg
    = SetPixel X Y PixelColour
    | TextureError WebGL.Error
    | TextureLoad WebGL.Texture
    | Clear

-- TODO: instead of colour remap, transparency? (Don't need to use palette map then)
-- x, y, colour index, colour remap
type alias Vertex = { position : Vec4 }

setPixel : Model -> Int -> Int -> PixelColour -> Model
setPixel model x y colour =
    { model | pixels = Dict.insert (x, y) colour model.pixels }

getPixel : Model -> Int -> Int -> PixelColour
getPixel model x y =
    Dict.get (x, y) model.pixels
        |> Maybe.withDefault 0

pixelPalette : Model -> PixelColour -> PixelColour -> Model
pixelPalette model from to =
    { model | pixelPalette = Dict.insert from to model.pixelPalette }

screenPalette : Model -> PixelColour -> PixelColour -> Model
screenPalette model from to =
    { model | screenPalette = Dict.insert from to model.screenPalette }

resetPalette : Model -> Model
resetPalette model =
    { model | screenPalette = Dict.empty , pixelPalette = Dict.empty }

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
    , pixelPalette = Dict.empty
    , screenPalette = Dict.empty
    } 
    ! 
    [ WebGL.loadTexture "/pico-8-palette-map.png" |> Task.perform TextureError TextureLoad
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
                    (getPixelPoints model)
                    { canvasSize = vec2 canvasSize.width canvasSize.height
                    , screenSize = vec2 model.screenSize.width model.screenSize.height
                    , projectionMatrix = makeProjectionMatrix
                    , paletteTexture = texture
                    -- , paletteTextureSize = vec2 (toFloat (fst (WebGL.textureSize texture))) (toFloat (snd (WebGL.textureSize texture)))
                    , paletteSize = vec2 16.0 16.0
                    }
            ]

getPixelPoints : Model -> WebGL.Drawable Vertex
getPixelPoints model =
    let
        toPoint : ((Int, Int), Int) -> Vertex
        toPoint ((x, y), colourIndex) =
            let 
                -- TODO decide if it's just easier to do the mapping here and remove mapping in shader
                -- TODO decide on transparency
                colour = Dict.get colourIndex model.pixelPalette 
                    |> Maybe.withDefault colourIndex
            in
                Vertex
                    ( vec4
                        (toFloat x)
                        (toFloat y)
                        (toFloat colour)
                        (Dict.get colour model.screenPalette |> Maybe.withDefault 0 |> toFloat)
                    )
    in
        List.map toPoint (Dict.toList model.pixels)
            |> WebGL.Points

pixelsVertexShader : WebGL.Shader { attr | position : Vec4 } { unif | canvasSize : Vec2, screenSize : Vec2, projectionMatrix : Mat4 } { colourIndex : Float, colourRemap : Float }
pixelsVertexShader = [glsl|
    precision mediump float;
    attribute vec4 position;
    uniform vec2 canvasSize;
    uniform vec2 screenSize;
    uniform mat4 projectionMatrix;
    varying float colourIndex;
    varying float colourRemap;
    void main () {
        gl_PointSize = canvasSize.x / screenSize.x;

        gl_Position = projectionMatrix * vec4(position.x + 0.5, position.y + 0.5, 0.0, 1.0);

        colourIndex = position.z;
        colourRemap = position.a;
    }
|]

pixelsFragmentShader : WebGL.Shader {} { uniform | paletteTexture : WebGL.Texture , paletteSize : Vec2 } { colourIndex : Float, colourRemap : Float }
pixelsFragmentShader = [glsl|
    precision mediump float;
    uniform sampler2D paletteTexture;
    uniform vec2 paletteSize;
    varying float colourIndex;
    varying float colourRemap;
    void main () {
        // Texture origin bottom left
        // Use slightly less than 1.0 to slightly nudge into correct pixel
        float index = colourIndex / paletteSize.x;
        float remap = 0.999 - (colourRemap / paletteSize.y);
        gl_FragColor = texture2D(paletteTexture, vec2(index, remap));
    }
|]
