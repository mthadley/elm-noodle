module Tests.Noodle.Tagged exposing (..)

import Expect exposing (..)
import Test exposing (..)
import Noodle.Tagged


suite : Test
suite =
    describe "Noodle.Tagged"
        [ test "should compile" <|
            \_ ->
                Expect.equal 1 1
        ]
