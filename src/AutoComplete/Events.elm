module AutoComplete.Events exposing (..)

import AutoComplete.Messages exposing (..)
import AutoComplete.Models exposing (..)
import AutoComplete.Utils exposing (referenceDataName)
import Html exposing (..)
import Html.Events exposing (on, keyCode)
import Json.Decode as Decode


traceDecoder : String -> Decode.Decoder msg -> Decode.Decoder msg
traceDecoder message decoder =
    let
        log value =
            case Decode.decodeValue decoder value of
                Ok decoded ->
                    decoded |> Decode.succeed

                Err err ->
                    err |> Debug.log message |> Decode.fail
    in
        Decode.value
            |> Decode.andThen log


onEnterOrSpace : msg -> Attribute msg
onEnterOrSpace msg =
    let
        isEnterOrSpace code =
            if code == 13 || code == 32 then
                Decode.succeed msg
            else
                Decode.fail "not ENTER"
    in
        on "keyup" (Decode.andThen isEnterOrSpace keyCode)


onEsc : msg -> Attribute msg
onEsc msg =
    let
        isEsc code =
            if code == 27 then
                Decode.succeed msg
            else
                Decode.fail "not ENTER"
    in
        on "keyup" (Decode.andThen isEsc keyCode)


onBlurAttribute : Config msg item -> State -> Attribute (Msg item)
onBlurAttribute config state =
    let
        dataDecoder =
            Decode.at [ "relatedTarget", "attributes", referenceDataName, "value" ] Decode.string

        attrToMsg attr =
            if attr == state.id then
                NoOp
            else
                OnBlur

        blur =
            Decode.maybe dataDecoder
                |> Decode.map (Maybe.map attrToMsg)
                |> Decode.map (Maybe.withDefault OnBlur)
    in
        on "blur" blur
