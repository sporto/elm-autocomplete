module Example2 exposing (..)

import AutoComplete
import Debug
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode


type alias Model =
    { id : String
    , characters : List Character
    , selectedCharacterId : Maybe String
    , autoCompleteState : AutoComplete.State
    }


type alias Character =
    String


initialModel : String -> Model
initialModel id =
    { id = id
    , characters = []
    , selectedCharacterId = Nothing
    , autoCompleteState = AutoComplete.newState id
    }


initialCmds : Cmd Msg
initialCmds =
    Cmd.none


type Msg
    = NoOp
    | AutoCompleteMsg (AutoComplete.Msg Character)
    | OnFetch (Result Http.Error (List Character))
    | OnQuery String
    | OnSelect Character


autoCompleteConfig : AutoComplete.Config Msg Character
autoCompleteConfig =
    AutoComplete.newConfig OnSelect identity
        |> AutoComplete.withInputClass "col-12"
        |> AutoComplete.withMenuClass "border border-gray bg-white"
        |> AutoComplete.withItemClass "border-bottom border-silver p1"
        |> AutoComplete.withCutoff 12
        |> AutoComplete.withOnQuery OnQuery


fetchUrl : String -> String
fetchUrl query =
    "http://swapi.co/api/people/?search=" ++ query


fetch : String -> Cmd Msg
fetch query =
    Http.get (fetchUrl query) resultDecoder
        |> Http.send OnFetch


resultDecoder : Decode.Decoder (List Character)
resultDecoder =
    Decode.at [ "results" ] collectionDecoder


collectionDecoder : Decode.Decoder (List Character)
collectionDecoder =
    Decode.list memberDecoder


memberDecoder : Decode.Decoder Character
memberDecoder =
    Decode.field "name" Decode.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        AutoCompleteMsg subMsg ->
            let
                ( updated, cmd ) =
                    AutoComplete.update autoCompleteConfig subMsg model.autoCompleteState
            in
                ( { model | autoCompleteState = updated }, cmd )

        OnQuery query ->
            ( model, fetch query )

        OnFetch result ->
            case result of
                Ok characters ->
                    ( { model | characters = characters }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        OnSelect character ->
            ( { model | selectedCharacterId = Just character }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        selecteCharacter =
            case model.selectedCharacterId of
                Nothing ->
                    Nothing

                Just id ->
                    model.characters
                        |> List.filter (\character -> character == id)
                        |> List.head
    in
        div [ class "bg-silver p1" ]
            [ h3 [] [ text "Async example" ]
            , text (toString model.selectedCharacterId)
            , h4 [] [ text "Pick an star wars character" ]
            , Html.map AutoCompleteMsg (AutoComplete.view autoCompleteConfig model.autoCompleteState model.characters selecteCharacter)
            ]
