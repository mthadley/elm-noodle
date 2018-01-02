module Tests.Noodle exposing (..)

import Expect exposing (..)
import Test exposing (..)
import Noodle


suite : Test
suite =
    describe "Noodle"
        [ test "should compile" <|
            \_ ->
                Expect.equal 1 1
        ]
