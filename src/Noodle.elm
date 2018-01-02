module Noodle
    exposing
        ( Action
        , action
        , batch
        , none
        , update
        )

{-| A *starchy* library for managing application state.

    import Noodle

    type alias Model =
        Int

    type Msg
        = Increment
        | Decrement

    increment : Action Msg
    increment =
        Noodle.action Increment

    decrement : Action Msg
    decrement =
        Noodle.action Increment

    update : Action Msg -> Model -> ( Model, Action Msg )
    update =
        Noodle.update <|
            \msg model ->
                case msg of
                    Increment ->
                        Model + 1


    -- In another module, possible nested module:

    update : Msg -> Model -> ( Model, Cmd (Action Msg) )
    update msg model =
        case msg of
            Click ->
                ( model, increment )

If you like to organize your models in to seperate modules, and then embed those models
into other modules, you may find that sometimes there is state that you want to persist at
a higher level. You can use this library to help manage that state, and `Action`s that updaate
that state.

**Noodle** has taken a lot of inspiration from [`elm-taco`](https://github.com/ohanhi/elm-taco) and
[`redux`](https://redux.js.org/).


# Creating an `Action`

@docs Action, action


# Updating your Model

@docs update


# Helpers

@docs none, batch

-}

import Noodle.Internal


{-| Type representing actions that can be used to update your application model.
-}
type alias Action a =
    Noodle.Internal.Action Never a


{-| Create an `Action` from your own type.

    import Noodle

    type Msg
        = Increment
        | Decrement

    increment : Action Msg
    increment =
        Noodle.action Increment

    decrement : Action Msg
    decrement =
        Noodle.action Increment

-}
action : a -> Action a
action =
    Noodle.Internal.action


{-| An `Action` that does nothing. Similar to [`Cmd.none`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Platform-Cmd#none).
-}
none : Action a
none =
    Noodle.Internal.none


{-| Group multiple `Action`s into a single `Action`, which will be applied in order. This is
similar to [`Cmd.batch`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Platform-Cmd#batch).

    import Noodle

    makeRequests : Action Msg
    makeRequests =
        Noodle.batch
            [ increment
            , decrement
            ]

-}
batch : List (Action a) -> Action a
batch =
    Noodle.Internal.batch


{-| A function for updating your Model with an `Action`.

    import Noodle

    update : Action Msg -> Model -> ( Model, Cmd (Action Msg) )
    update =
        Noodle.update <|
            \msg model ->
                case msg of
                    Increment ->
                        model + 1

                    Decrement ->
                        model - 1

-}
update :
    (a -> b -> ( b, Cmd a ))
    -> Action a
    -> b
    -> ( b, Cmd (Action a) )
update f action store =
    let
        ( b, cmd, _ ) =
            Noodle.Internal.update f action store
    in
        ( b, cmd )
