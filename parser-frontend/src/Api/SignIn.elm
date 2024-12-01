module Api.SignIn exposing (..)

import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode


type alias TokenData =
    { token : String
    }


type alias Error =
    { message : String
    , field : Maybe String
    }


decoder : Json.Decode.Decoder TokenData
decoder =
    Json.Decode.map TokenData
        (Json.Decode.at [ "authentication_token", "token" ] Json.Decode.string)


post :
    { onResponse : Result (List Error) TokenData -> msg
    , username : String
    , password : String
    }
    -> Effect msg
post options =
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "username", Json.Encode.string options.username )
                , ( "password", Json.Encode.string options.password )
                ]

        cmd : Cmd msg
        cmd =
            Http.post
                { url = "http://localhost:4000/v1/tokens/authentication"
                , body = Http.jsonBody body
                , expect = Http.expectStringResponse options.onResponse handleHttpResponse
                }
    in
    Effect.sendCmd cmd


handleHttpResponse : Http.Response String -> Result (List Error) TokenData
handleHttpResponse response =
    case response of
        Http.BadUrl_ _ ->
            Err
                [ { field = Nothing
                  , message = "Unexpected URL format"
                  }
                ]

        Http.Timeout_ ->
            Err
                [ { field = Nothing
                  , message = "Request timed out, please try again"
                  }
                ]

        Http.NetworkError_ ->
            Err
                [ { field = Nothing
                  , message = "Could not connect, please try again"
                  }
                ]

        Http.BadStatus_ { statusCode } body ->
            case Json.Decode.decodeString errorsDecoder body of
                Ok errors ->
                    Err errors

                Err _ ->
                    Err
                        [ { message = "Something unexpected happened"
                          , field = Nothing
                          }
                        ]

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString decoder body of
                Ok data ->
                    Ok data

                Err _ ->
                    Err
                        [ { field = Nothing
                          , message = "Something unexpected happened while decoding"
                          }
                        ]


errorsDecoder : Json.Decode.Decoder (List Error)
errorsDecoder =
    Json.Decode.field "violations" (Json.Decode.list errorDecoder)


errorDecoder : Json.Decode.Decoder Error
errorDecoder =
    Json.Decode.map2 Error
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "field" (Json.Decode.maybe Json.Decode.string))
