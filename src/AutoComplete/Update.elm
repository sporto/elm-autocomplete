module AutoComplete.Update exposing (..)

import AutoComplete.Messages exposing (..)
import AutoComplete.Models as Models
import Task


update : Models.Config msg item -> Msg item -> Models.State -> ( Models.State, Cmd msg )
update config msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnEsc ->
            ( { model | query = Nothing }, Cmd.none )

        OnBlur ->
            ( { model | query = Nothing }, Cmd.none )

        OnQueryChange value ->
            let
                cmd =
                    case config.onQueryChange of
                        Just constructor ->
                            Task.succeed value
                                |> Task.perform constructor

                        Nothing ->
                            Cmd.none
            in
                ( { model | query = Just value }, cmd )

        OnSelect item ->
            let
                cmd =
                    Task.succeed item
                        |> Task.perform config.onSelect
            in
                ( { model | query = Nothing }, cmd )
