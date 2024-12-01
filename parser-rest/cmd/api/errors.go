package main

import (
	"net/http"

	"github.com/LinusSee/config-parsers/internal/data"
	"github.com/LinusSee/config-parsers/internal/validator"
)

type appError string

type ErrorDetail struct {
	Type  string
	Title string
}

const (
	invalidParameters = appError("invalidParameters")
	invalidHeaders    = appError("invalidHeaders")
	invalidBody       = appError("invalidBody")

	resourceNotFound = appError("resourceNotFound")

	internalServerError = appError("internalServerError")
)

var appErrors = map[appError]ErrorDetail{
	invalidParameters: {Type: "https://prism-analytics.io/problems/invalid-parameters", Title: "The data passed as parameters is not valid."},
	invalidHeaders:    {Type: "https://prism-analytics.io/problems/invalid-headers", Title: "The request headers are not as expected."},
	invalidBody:       {Type: "https://prism-analytics.io/problems/invalid-body", Title: "The data passed as the body is not valid."},

	resourceNotFound: {Type: "https://prism-analytics.io/problems/resource-not-found", Title: "The requested resource could not be found."},

	internalServerError: {Type: "https://prism-analytics.io/problems/internal-server-error", Title: "An internal server error occured."},
}

func (app *application) logError(r *http.Request, err error) {
	var (
		method = r.Method
		uri    = r.URL.RequestURI()
	)

	app.logger.Error(err.Error(), "method", method, "uri", uri)
}

func (app *application) problemDetailResponse(w http.ResponseWriter, r *http.Request, status int, problemDetail data.ProblemDetail) {
	err := app.writeAnyJSON(w, status, problemDetail, nil)
	if err != nil {
		app.logError(r, err)
		w.WriteHeader(500)
	}
}

func (app *application) errorResponse(w http.ResponseWriter, r *http.Request, status int, message any) {
	env := envelope{"error": message}

	err := app.writeJSON(w, status, env, nil)
	if err != nil {
		app.logError(r, err)
		w.WriteHeader(500)
	}
}

func (app *application) invalidCredentialsResponse(w http.ResponseWriter, r *http.Request) {
	message := "invalid authentication credentials"
	app.errorResponse(w, r, http.StatusUnauthorized, message)
}

func (app *application) badRequestResponse(w http.ResponseWriter, r *http.Request, err error, errorKey appError, detail string) {
	app.errorResponse(w, r, http.StatusBadRequest, err.Error())

	app.logError(r, err)

	problemDetail := badRequestProblemDetail(errorKey, detail)
	app.problemDetailResponse(w, r, http.StatusBadRequest, problemDetail)
}

// func (app *application) failedValidationResponse(w http.ResponseWriter, r *http.Request, errors map[string]string) {
// 	app.errorResponse(w, r, http.StatusUnprocessableEntity, errors)

// 	// problemDetail := validationProblemDetail(errorKey, detail, errors)
// 	// app.problemDetailResponse(w, r, http.StatusBadRequest, problemDetail)
// }

func (app *application) failedValidationResponse(w http.ResponseWriter, r *http.Request, errorKey appError, detail string, errors []validator.ValidationError) {
	problemDetail := validationProblemDetail(errorKey, detail, errors)
	app.problemDetailResponse(w, r, http.StatusBadRequest, problemDetail)
}

func (app *application) serverErrorResponse(w http.ResponseWriter, r *http.Request, err error) {
	app.logError(r, err)

	detailMessage := "the server encountered a problem and could not process your request"
	problemDetail := internalErrorProblemDetail(detailMessage)
	app.problemDetailResponse(w, r, http.StatusInternalServerError, problemDetail)
}

func badRequestProblemDetail(errorKey appError, detail string) data.ProblemDetail {
	errorDetail := appErrors[errorKey]
	problemDetail := data.ProblemDetail{
		Status: http.StatusBadRequest,
		Type:   errorDetail.Type,
		Title:  errorDetail.Title,
		Detail: detail,
	}

	return problemDetail
}

func validationProblemDetail(errorKey appError, detail string, errors []validator.ValidationError) data.ProblemDetail {
	errorDetail := appErrors[errorKey]
	problemViolations := make([]data.ProblemDetailViolation, 0, len(errors))
	for _, valError := range errors {
		problemViolations = append(problemViolations, data.ProblemDetailViolation{Field: valError.Key, Message: valError.Message})
	}

	problemDetail := data.ProblemDetail{
		Status:     http.StatusBadRequest,
		Type:       errorDetail.Type,
		Title:      errorDetail.Title,
		Detail:     detail,
		Violations: problemViolations,
	}

	return problemDetail
}

func internalErrorProblemDetail(detail string) data.ProblemDetail {
	errorDetail := appErrors[internalServerError]

	problemDetail := data.ProblemDetail{
		Status: http.StatusNotFound,
		Type:   errorDetail.Type,
		Title:  errorDetail.Title,
		Detail: detail,
	}

	return problemDetail
}
