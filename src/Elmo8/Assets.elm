module Elmo8.Assets exposing (..)

import WebGL
import Task


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
