module Pages.SignIn exposing (Model, Msg, page)

import Api.SignIn
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { username : String
    , password : String
    , isSubmittingForm : Bool
    , errors : List Api.SignIn.Error
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { username = ""
      , password = ""
      , isSubmittingForm = False
      , errors = []
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserUpdatedInput Field String
    | UserSubmittedForm
    | SignInApiResponded (Result (List Api.SignIn.Error) Api.SignIn.TokenData)


type Field
    = Username
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserUpdatedInput Username value ->
            ( { model | username = value }
            , Effect.none
            )

        UserUpdatedInput Password value ->
            ( { model | password = value }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model | isSubmittingForm = True }
            , Api.SignIn.post
                { onResponse = SignInApiResponded
                , username = model.username
                , password = model.password
                }
            )

        SignInApiResponded (Ok { token }) ->
            ( { model | isSubmittingForm = False }
            , Effect.signIn { token = token }
            )

        SignInApiResponded (Err errors) ->
            ( { model
                | isSubmittingForm = False
                , errors = errors
              }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ viewPage model
        ]
    }


viewPage : Model -> Html Msg
viewPage model =
    viewForm model


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ Attr.class "flex justify-center mx-[10%]", Html.Events.onSubmit UserSubmittedForm ]
        [ Html.div [ Attr.class "cp-card bg-base-100 w-96 shadow-xl sm:w-[100%] lg:w-96 bg-base-100 shadow-xl mt-20 mb-20" ]
            [ Html.div [ Attr.class "cp-card-body" ]
                [ Html.h2 [ Attr.class "cp-card-title mb-2" ] [ Html.text "Login" ]
                , viewFormInput { field = Username, value = model.username, error = findFieldError "username" model }
                , viewFormInput { field = Password, value = model.password, error = findFieldError "password" model }
                , Html.div []
                    [ case findFormError model of
                        Just error ->
                            Html.p
                                [ Attr.class "help content is-danger" ]
                                [ Html.text error.message ]

                        Nothing ->
                            Html.text ""
                    ]
                , Html.div
                    [ Attr.class "card-actions justify-end" ]
                    [ Html.button [ Attr.class "cp-btn cp-btn-primary w-full", Attr.type_ "submit" ] [ Html.text "Login" ]
                    ]
                ]
            ]
        ]


viewFormInput : { field : Field, value : String, error : Maybe Api.SignIn.Error } -> Html Msg
viewFormInput options =
    Html.div []
        [ Html.label [ Attr.class "cp-form-control" ]
            [ Html.div [ Attr.class "cp-label" ] [ Html.span [ Attr.class "cp-label-text" ] [ Html.text (fromFieldToLabel options.field) ] ]
            , Html.input
                [ Attr.class "cp-input cp-input-bordered"
                , Attr.type_ (fromFieldToInputType options.field)
                , Attr.classList
                    [ ( "cp-input-error", options.error /= Nothing )
                    ]
                , Attr.value options.value
                , Html.Events.onInput (UserUpdatedInput options.field)
                ]
                []
            ]
        , case options.error of
            Just error ->
                Html.p [] [ Html.text error.message ]

            Nothing ->
                Html.text ""
        ]


fromFieldToLabel : Field -> String
fromFieldToLabel field =
    case field of
        Username ->
            "Username"

        Password ->
            "Password"


fromFieldToInputType : Field -> String
fromFieldToInputType field =
    case field of
        Username ->
            "username"

        Password ->
            "password"



-- ERRORS


findFieldError : String -> Model -> Maybe Api.SignIn.Error
findFieldError field model =
    let
        hasMatchingField : Api.SignIn.Error -> Bool
        hasMatchingField error =
            error.field == Just field
    in
    model.errors
        |> List.filter hasMatchingField
        |> List.head


findFormError : Model -> Maybe Api.SignIn.Error
findFormError model =
    let
        doesntHaveField : Api.SignIn.Error -> Bool
        doesntHaveField error =
            error.field == Nothing
    in
    model.errors
        |> List.filter doesntHaveField
        |> List.head
