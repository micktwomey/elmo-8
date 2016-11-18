module Elmo8.Assets exposing (..)

import WebGL
import Task
import Elmo8.Textures.Pico8Font exposing (pico8FontDataUri)
import Elmo8.Textures.Pico8PaletteMap exposing (pico8PaletteMapDataUri)


type alias URL =
    String


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
            WebGL.loadTexture url
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
