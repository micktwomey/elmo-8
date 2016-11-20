module Elmo8.Assets exposing (..)

{-| Assets and Asset management

-}

import Dict
import WebGL
import Math.Vector2 exposing (Vec2, vec2)
import Task
import Elmo8.GL.Font
import Elmo8.Textures.Pico8Font exposing (pico8FontDataUri)
import Elmo8.Textures.Pico8PaletteMap exposing (pico8PaletteMapDataUri)


type alias URL =
    String


fontKey : String
fontKey =
    "elmo8.font"


paletteKey : String
paletteKey =
    "elmo8.palette"


type alias Model =
    { textures : Dict.Dict String Texture
    , characterMeshes : Elmo8.GL.Font.CharacterMeshes
    }


type alias Texture =
    { texture : WebGL.Texture
    , textureSize : Vec2
    }

type alias Character =
    { width: Int
    , height: Int
    , x: Int
    , y: Int
    }

type Msg
    = TextureLoadError String WebGL.Error
    | TextureLoaded String WebGL.Texture


init : ( Model, Cmd Msg )
init =
    let
        emptyModel =
            Model Dict.empty Elmo8.GL.Font.meshesFromCharacters

        ( fontModel, fontMsg ) =
            loadTexture emptyModel fontKey [ pico8FontDataUri, pico8FontRelativeUri, pico8FontUri ]

        ( model, paletteMsg ) =
            loadTexture fontModel paletteKey [ pico8PaletteMapDataUri, pico8PaletteMapRelativeUri, pico8PaletteMapUri ]
    in
        model
            ! [ fontMsg
              , paletteMsg
              ]


loadTexture : Model -> String -> List URL -> ( Model, Cmd Msg )
loadTexture model key urls =
    model
        ! [ loadWebglTextureWithFallbacks urls
                |> Task.attempt
                    (\result ->
                        case result of
                            Err err ->
                                TextureLoadError key err

                            Ok val ->
                                TextureLoaded key val
                    )
          ]

getTexture : {a | textures : Dict.Dict String Texture } -> String -> Maybe Texture
getTexture {textures} key =
    Dict.get key textures

getPalette : {a | textures : Dict.Dict String Texture } -> Maybe Texture
getPalette model =
    getTexture model paletteKey

getFont : {a | textures : Dict.Dict String Texture } -> Maybe Texture
getFont model =
    getTexture model fontKey

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextureLoadError key error ->
            model ! []

        TextureLoaded key texture ->
            let
                ( width, height ) =
                    WebGL.textureSize texture

                textureSize =
                    vec2 (toFloat width) (toFloat height)

                loadedTexture =
                    { texture = texture, textureSize = textureSize }
            in
                { model | textures = Dict.insert key loadedTexture model.textures } ! []


{-| Try multiple sources to load texture

Give a list of URLs to try, e.g.:

- data url (not always available due to CORS)
- relative url (loads from same place as code)
- fallback CDN (will work except when there are network issues, least prefereble)

-}
loadWebglTextureWithFallbacks : List URL -> Task.Task WebGL.Error WebGL.Texture
loadWebglTextureWithFallbacks urls =
    case urls of
        [] ->
            Task.fail WebGL.Error

        url :: remainingUrls ->
            WebGL.loadTextureWithFilter WebGL.Nearest url
                |> Task.onError (\_ -> loadWebglTextureWithFallbacks remainingUrls)


pico8FontRelativeUri : String
pico8FontRelativeUri =
    "/assets/pico-8_regular_8.png"


pico8FontUri : String
pico8FontUri =
    "http://elmo-8.twomeylee.name/assets/pico-8_regular_8.png"


pico8PaletteMapRelativeUri : String
pico8PaletteMapRelativeUri =
    "/assets/pico-8-palette-map.png"


pico8PaletteMapUri : String
pico8PaletteMapUri =
    "http://elmo-8.twomeylee.name/assets/pico-8-palette-map.png"


{-| Load the Font texture
-}
loadFontTexture : Task.Task WebGL.Error WebGL.Texture
loadFontTexture =
    loadWebglTextureWithFallbacks
        [ pico8FontDataUri, pico8FontRelativeUri, pico8FontUri ]


{-| Load the palette map texture
-}
loadPaletteMapTexture : Task.Task WebGL.Error WebGL.Texture
loadPaletteMapTexture =
    loadWebglTextureWithFallbacks
        [ pico8PaletteMapDataUri, pico8PaletteMapRelativeUri, pico8PaletteMapUri ]
