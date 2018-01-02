module Noodle.Tagged
    exposing
        ( Action
        , action
        , batch
        , map
        , none
        , tag
        , update
        )

{-| This module allows you to tag an `Action` with a custom
`msg` that can be fed back in to your application after the
original `Action` has been applied to your application `Model`.

    import Noodle.Tagged as Noodle
    import RemoteData

    type alias Model =
        { collapsed : Bool
        }

    type Msg
        = Refresh
        | RecieveUser

    update : Msg -> Model -> ( Model, Cmd (Action Msg) )
    update msg model =
        case msg of
            Refresh ->
                ( model, Noodle.tag RecieveUser loadUser )

            RecieveUser ->
                ( { model | collapsed = True }, Noodle.none )


# Creating an `Action`

@docs Action, action


# Updating your Model

@docs update


# Tagging an `Action`

@docs tag, map


# Helpers

@docs none, batch

-}

import Noodle.Internal


{-| Type representing actions that can be used to update your application model. This type has two parameters, `tag` which is the type that will be returned from `Noodle.update`, and `a` which is the type that is passed to your own `update`.
-}
type alias Action tag a =
    Noodle.Internal.Action tag a


{-| Create an `Action` from your own type.

    import Noodle

    type alias Action msg =
        Noodle.Action Msg msg

    type Msg
        = Increment
        | Decrement

    increment : Action msg
    increment =
        Noodle.action Increment

    decrement : Action msg
    decrement =
        Noodle.action Increment

-}
action : a -> Action tag a
action =
    Noodle.Internal.action


{-| An `Action` that does nothing. Similar to [`Cmd.none`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Platform-Cmd#none).
-}
none : Action tag a
none =
    Noodle.Internal.none


{-| Group multiple `Action`s into a single `Action`, which will be applied in order. This is
similar to [`Cmd.batch`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Platform-Cmd#batch).

    import Noodle.Tagged as Noodle

    makeRequests : Action tag Msg
    makeRequests =
        Noodle.batch
            [ increment
            , decrement
            ]

-}
batch : List (Action tag a) -> Action tag a
batch =
    Noodle.Internal.batch


{-| Tag an action with your own custom `msg`, via a command that is returned by `Noodle.Tagged.update`.
-}
tag : tag -> Action tag a -> Action tag a
tag =
    Noodle.Internal.tag


{-| Map an Action that is tagged with `a` to an action that is tagged with `b`. This is similar to [`Cmd.map`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Platform-Cmd#map).
-}
map : (a -> b) -> Action a c -> Action b c
map =
    Noodle.Internal.map


{-| A function for updating your Model with an `Action`.

Here is one possible way to structure your top-level application logic:

    import Noodle

    type alias Store =
        { count : Int
        }

    type alias Action msg =
        Noodle.Action msg Msg

    type Msg
        = Thing
        | OtherThing

    update : Action Msg -> Model -> ( Model, Cmd (Action Msg) )
    update =
        Noodle.update <|
            \msg model ->
                case msg of
                    Thing ->
                        ( model, Cmd.none )

                    OtherThing ->
                        ( model, Cmd.none )

Then import your `Store` module, making sure to wire everything up:

    import Noodle.Tagged as Noodle
    import Store
    import UserPage

    type alias Model =
        { Store : Store.Store
        , userPage : UserPage.Model
        }

    type Msg
        = StoreMsg Store.Msg
        | PageMsg UserPage.Msg

    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
        case msg of
            StoreMsg msg ->
                let
                    (store, storeCmd, outCmd) =
                        Store.update msg model.store
                in
                    ( {model | store = store }
                    , Cmd.batch
                        [ Cmd.map StoreMsg storeCmd
                        , outCmd
                        ]
                    )

            PageMsg msg ->
                let
                    (model, action) =
                        UserPage.update msg model.userPage

                    (store, cmd, outCmd) =
                        Store.update
                            (Noodle.map PageMsg action)
                            model.store
                in
                    ( {model | store = store, userPage = model}
                    , Cmd.batch
                        [ Cmd.map StoreMsg storeCmd
                        , outCmd
                        ]

We need to make sure to batch the returned `Cmd`s, and also map some of our `Action`s. Don't worry, if the types don't line up, the Elm compiler will remind us.

-}
update :
    (a -> b -> ( b, Cmd a ))
    -> Action tag a
    -> b
    -> ( b, Cmd (Action tag a), Cmd tag )
update =
    Noodle.Internal.update
