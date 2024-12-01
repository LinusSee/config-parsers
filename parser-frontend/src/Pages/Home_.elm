module Pages.Home_ exposing (Model, Msg, page)

import Auth
import Effect exposing (Effect)
import Html exposing (Html, button, div, input, option, select, text, textarea)
import Html.Attributes as Attr
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Url.Parser exposing (parse)
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { formData : ParserForm }


type PossibleParsers
    = StringParser
    | OneOfParser


type ParserForm
    = NoSelection
    | StringData String
    | OneOfData (List String)


init : () -> ( Model, Effect Msg )
init () =
    ( { formData = NoSelection }
    , Effect.none
    )



-- UPDATE


type Msg
    = ParserSelectionChanged String
    | StringDataChanged String
    | ApplyParserClicked
    | LogoutClicked


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ParserSelectionChanged newSelection ->
            let
                newFormData : ParserForm
                newFormData =
                    case valueToPossibleParser newSelection of
                        Nothing ->
                            NoSelection

                        Just StringParser ->
                            StringData ""

                        Just OneOfParser ->
                            OneOfData []
            in
            ( { model | formData = newFormData }, Effect.none )

        StringDataChanged newStringData ->
            case model.formData of
                StringData _ ->
                    ( { model | formData = StringData newStringData }, Effect.none )

                _ ->
                    ( model, Effect.none )

        ApplyParserClicked ->
            ( model, Effect.none )

        LogoutClicked ->
            ( model
            , Effect.signOut
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Homepage"
    , body =
        [ div [ Attr.class "mt-4" ]
            [ text "Hello, world!"
            , button [ Attr.class "cp-btn cp-btn-primary", Html.Events.onClick LogoutClicked ] [ Html.text "Logout" ]
            ]
        , div [ Attr.class "flex flex-col" ]
            [ viewParserSelect model.formData
            , div [ Attr.class "flex flex-col" ]
                (case model.formData of
                    NoSelection ->
                        [ text "" ]

                    StringData _ ->
                        [ input [ Attr.class "cp-input cp-input-bordered", Html.Events.onInput StringDataChanged ] []
                        , textarea [ Attr.class "cp-textarea cp-textarea-bordered" ] []
                        ]

                    OneOfData _ ->
                        [ input [ Attr.class "cp-input cp-input-bordered" ] []
                        , textarea [ Attr.class "cp-textarea cp-textarea-bordered" ] []
                        ]
                )
            , if model.formData /= NoSelection then
                button [ Attr.class "cp-btn cp-btn-primary", Html.Events.onClick ApplyParserClicked ] [ text "Apply parser" ]

              else
                text ""
            ]
        ]
    }


viewParserSelect : ParserForm -> Html Msg
viewParserSelect parserForm =
    let
        parserOption : Bool -> PossibleParsers -> Html msg
        parserOption selected parser =
            option
                [ Attr.value <| possibleParserToValue parser
                , Attr.selected selected
                ]
                [ text <| possibleParserToString parser ]
    in
    select
        [ Attr.class "cp-select cp-select-bordered w-full max-w-xs"
        , Html.Events.onInput ParserSelectionChanged
        ]
        [ option
            [ Attr.disabled True
            , Attr.selected (parserForm == NoSelection)
            ]
            [ text "Select a parser" ]
        , parserOption (parserIsSelected parserForm StringParser) StringParser
        , parserOption (parserIsSelected parserForm OneOfParser) OneOfParser
        ]


parserIsSelected : ParserForm -> PossibleParsers -> Bool
parserIsSelected form possibleParser =
    case form of
        StringData _ ->
            StringParser == possibleParser

        OneOfData _ ->
            OneOfParser == possibleParser

        NoSelection ->
            False


possibleParserToString : PossibleParsers -> String
possibleParserToString possibleParser =
    case possibleParser of
        StringParser ->
            "String"

        OneOfParser ->
            "OneOf"


possibleParserToValue : PossibleParsers -> String
possibleParserToValue possibleParser =
    case possibleParser of
        StringParser ->
            "string"

        OneOfParser ->
            "oneOf"


valueToPossibleParser : String -> Maybe PossibleParsers
valueToPossibleParser value =
    case value of
        "string" ->
            Just StringParser

        "oneOf" ->
            Just OneOfParser

        _ ->
            Nothing
