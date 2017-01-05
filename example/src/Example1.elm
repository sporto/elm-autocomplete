module Example1 exposing (..)

import AutoComplete
import Debug
import Html exposing (..)
import Html.Attributes exposing (class)
import Movies


{-|
Model to be passed to the auto-complete component. You model can be anything.
E.g. Records, tuples or just strings.
-}
type alias Movie =
    { id : String
    , label : String
    }


{-|
In your main application model you should store:

- The selected item e.g. selectedMovieId
- The state for the select component
-}
type alias Model =
    { id : String
    , movies : List Movie
    , selectedMovieId : Maybe String
    , autoCompleteState : AutoComplete.State
    }


{-|
This just transforms a list of tuples into records
-}
movies : List Movie
movies =
    List.map (\( id, name ) -> Movie id name) Movies.movies


{-|
Your model should store the selected item and the state of the Select component(s)
-}
initialModel : String -> Model
initialModel id =
    { id = id
    , movies = movies
    , selectedMovieId = Nothing
    , autoCompleteState = AutoComplete.newState id
    }


{-|
Your application messages need to include:
- OnSelect item : This will be called when an item is selected
- AutoCompleteMsg (AutoComplete.Msg item) : A message that wraps internal Select library messages. This is necessary to route messages back to the component.
-}
type Msg
    = NoOp
    | OnSelect Movie
    | AutoCompleteMsg (AutoComplete.Msg Movie)


{-|
Create the configuration for the Select component

`AutoComplete.newConfig` takes two args:

- The selection message e.g. `OnSelect`
- A function that extract a label from an item e.g. `.label`
-}
autoCompleteConfig : AutoComplete.Config Msg Movie
autoCompleteConfig =
    AutoComplete.newConfig OnSelect .label
        |> AutoComplete.withInputClass "col-12"
        |> AutoComplete.withInputStyles [ ( "padding", "0.5rem" ) ]
        |> AutoComplete.withMenuClass "border border-gray"
        |> AutoComplete.withMenuStyles [ ( "background", "white" ) ]
        |> AutoComplete.withItemClass "border-bottom border-silver p1"
        |> AutoComplete.withItemStyles [ ( "color", "darkgrey" ) ]
        |> AutoComplete.withCutoff 6


{-|
Your update function should route messages back to the Select component, see `AutoCompleteMsg`.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        -- OnSelect is triggered when a selection is made on the AutoComplete component.
        OnSelect movie ->
            ( { model | selectedMovieId = Just movie.id }, Cmd.none )

        -- Route message to the Select component.
        -- The returned command is important.
        AutoCompleteMsg subMsg ->
            let
                ( updated, cmd ) =
                    AutoComplete.update autoCompleteConfig subMsg model.autoCompleteState
            in
                ( { model | autoCompleteState = updated }, cmd )

        NoOp ->
            ( model, Cmd.none )


{-|
Your view renders the AutoComplete component passing the config, state, list of items and the currently selected item.
-}
view : Model -> Html Msg
view model =
    let
        selectedMovie =
            case model.selectedMovieId of
                Nothing ->
                    Nothing

                Just id ->
                    List.filter (\movie -> movie.id == id) movies
                        |> List.head
    in
        div [ class "bg-silver p1" ]
            [ h3 [] [ text "Basic example" ]
            , text (toString model.selectedMovieId)
              -- Render the Select view. You must pass:
              -- - The configuration
              -- - A unique identifier for the select component
              -- - The Select internal state
              -- - A list of items
              -- - The currently selected item as Maybe
            , h4 [] [ text "Pick a movie" ]
            , Html.map AutoCompleteMsg (AutoComplete.view autoCompleteConfig model.autoCompleteState model.movies selectedMovie)
            ]
