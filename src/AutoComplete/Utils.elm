module AutoComplete.Utils exposing (..)

import AutoComplete.Models exposing (..)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, value)


referenceDataName : String
referenceDataName =
    "data-auto-complete-id"


referenceAttr : Config msg item -> State -> Attribute msg2
referenceAttr config model =
    attribute referenceDataName model.id
