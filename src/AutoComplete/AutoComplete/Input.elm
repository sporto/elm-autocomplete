module AutoComplete.AutoComplete.Input exposing (..)

import AutoComplete.Events exposing (onEsc, onBlurAttribute)
import AutoComplete.Messages exposing (..)
import AutoComplete.Models exposing (..)
import AutoComplete.Utils exposing (referenceAttr)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, value, style)
import Html.Events exposing (on, onInput)


view : Config msg item -> State -> Maybe item -> Html (Msg item)
view config model selected =
    let
        val =
            case model.query of
                Nothing ->
                    case selected of
                        Nothing ->
                            ""

                        Just item ->
                            config.toLabel item

                Just str ->
                    str
    in
        input
            [ onBlurAttribute config model
            , onEsc OnEsc
            , onInput OnQueryChange
            , referenceAttr config model
            , style config.inputStyles
            , value val
            , viewClassAttr config
            ]
            []


viewClassAttr : Config msg item -> Attribute msg2
viewClassAttr config =
    class ("elm-select-input " ++ config.inputClass)
