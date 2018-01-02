module Noodle.Internal
    exposing
        ( Action
        , action
        , batch
        , map
        , none
        , tag
        , update
        )

import Task


type Action tag a
    = None
    | Batch (List (Action tag a))
    | Tagged tag (Action tag a)
    | TaggedResult tag (Action tag a)
    | Update a


action : a -> Action tag a
action =
    Update


none : Action tag a
none =
    None


batch : List (Action tag a) -> Action tag a
batch =
    Batch


tag : tag -> Action tag a -> Action tag a
tag =
    Tagged


map : (a -> b) -> Action a c -> Action b c
map f action =
    case action of
        None ->
            None

        Tagged msg action ->
            Tagged (f msg) <| map f action

        TaggedResult msg action ->
            TaggedResult (f msg) <| map f action

        Batch actions ->
            Batch <| List.map (map f) actions

        Update a ->
            Update a


update :
    (a -> b -> ( b, Cmd a ))
    -> Action tag a
    -> b
    -> ( b, Cmd (Action tag a), Cmd tag )
update f action store =
    case action of
        None ->
            noop store

        Tagged msg action ->
            update f action store
                |> mapSecond (Cmd.map <| TaggedResult msg)

        TaggedResult msg action ->
            let
                ( newStore, cmd, outCmd ) =
                    update f action store
            in
                ( newStore
                , cmd
                , Cmd.batch
                    [ Task.perform identity <| Task.succeed msg
                    , outCmd
                    ]
                )

        Batch actions ->
            let
                applyActions action ( store, cmd, outCmd ) =
                    update f action store
                        |> mapSecond (\c -> Cmd.batch [ cmd, c ])
                        |> mapThird (\c -> Cmd.batch [ outCmd, c ])
            in
                List.foldl applyActions (noop store) actions

        Update a ->
            let
                ( newStore, cmd ) =
                    f a store
            in
                ( newStore
                , Cmd.map Update cmd
                , Cmd.none
                )



-- Helpers


noop : a -> ( a, Cmd b, Cmd c )
noop a =
    ( a, Cmd.none, Cmd.none )


mapThird : (c -> d) -> ( a, b, c ) -> ( a, b, d )
mapThird f ( a, b, c ) =
    ( a, b, f c )


mapSecond : (b -> d) -> ( a, b, c ) -> ( a, d, c )
mapSecond f ( a, b, c ) =
    ( a, f b, c )
