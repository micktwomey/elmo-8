
import Html
import Html.App
import Elmo8.Display
import Elmo8.Layers.Layer
import Elmo8.Layers.Pixels

type alias Model = 
    { display : Elmo8.Display.Model }

type Msg = DisplayMsg Elmo8.Display.Msg 

init : (Model, Cmd Msg)
init = 
    let
        (pixels, _) = Elmo8.Layers.Pixels.init
        (display, _) = Elmo8.Display.init [ Elmo8.Layers.Layer.PixelsLayer pixels ]
    in 
        { display = display } ! []

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    model ! []

view : Model -> Html.Html Msg
view model =
    Html.div [] [ Elmo8.Display.view model.display |> Html.App.map DisplayMsg ]

main : Program Never
main =
  Html.App.program
    { init = init
    , subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    }
