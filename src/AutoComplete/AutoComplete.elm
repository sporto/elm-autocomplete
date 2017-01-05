module AutoComplete.AutoComplete exposing (..)

import AutoComplete.AutoComplete.Input as Input
import AutoComplete.AutoComplete.Menu as Menu
import AutoComplete.Messages exposing (..)
import AutoComplete.Models exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id)


view : Config msg item -> State -> List item -> Maybe item -> Html (Msg item)
view config model items selected =
    div [ id model.id, class "elm-auto-complete" ]
        [ Input.view config model selected
        , Menu.view config model items selected
        ]
