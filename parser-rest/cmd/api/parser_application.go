package main

import (
	"net/http"

	"github.com/LinusSee/config-parsers/internal/parsers"
)

func (app *application) testElementaryParser(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ParserType  string `json:"parserType"`
		ParserValue string `json:"parserValue"`
		TargetValue string `json:"valueToParser"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err, invalidBody, "Failed to read json body")
		return
	}

	parser := parsers.ElementaryParser{
		Value: input.ParserValue,
	}
	result, err := parsers.ApplyStringParser(parser, input.TargetValue)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"result": result}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
