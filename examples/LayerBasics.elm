
import Html
import Html.App
import Elmo8.Display

type alias Model = 
    { display : Elmo8.Display.Model }

type Msg = DisplayMsg Elmo8.Display.Msg 

init : (Model, Cmd Msg)
init = 
    let
        (display, _) = Elmo8.Display.initWithDefaultLayers
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
